#!/usr/bin/env bash

tempfile="$1" # Set tempfile to first argument 

# Set websites for distfiles
CPAN_SITE="https://cpan.perl.org/modules/by-module"
DEBIAN_SITE="https://ftp.debian.org/debian/pool"
FREEDESKTOP_SITE="https://freedesktop.org/software"
GNU_SITE="https://ftp.gnu.org/gnu"
GNOME_SITE="https://ftp.gnome.org/pub/GNOME/sources"
KERNEL_SITE="https://www.kernel.org/pub/linux"
MOZILLA_SITE="https://ftp.mozilla.org/pub"
NONGNU_SITE="https://download.savannah.nongnu.org/releases"
PYPI_SITE="https://files.pythonhosted.org/packages/source"
SOURCEFORGE_SITE="https://downloads.sourceforge.net/sourceforge"
UBUNTU_SITE="https://archive.ubuntu.com/ubuntu/pool"
XORG_SITE="https://www.x.org/releases/individual"
KDE_SITE="https://download.kde.org/stable"
##
predep+=( acl attr autoconf automake binutils bison bz2 cloog cmake compressdoc diffutils doxygen expat filecmd flex g6awk gcc8 gcc_tools gdbm gettext git glibc gmp gnutls groff icu4c intltool isl krb5 less libedit libffi libiconv libidn2 libmetalink libpipeline libpsl libressl libsigsegv libssh2 libtasn1 libtirpc libtool libunbound libunistring libxml2 linuxheaders lzip m4 make mandb manpages meson most mpc mpfr ncurses nettle ninja openssl osl p11kit patch perl_locale_messages perl_text_unidecode perl_unicode_eastasianwidth perl_xml_parser pkgconfig python27 python3 readline ruby sed setuptools slang sqlite texinfo trousers uchardet unzip util_macros wget xzutils zip zlibpkg tar pkg_config libglib which)
# ^ Create array with list of core packages

IFS="" # Remove IFS to keep newlines
dep_sed(){
sed -e 's/libltdl/libtool/g' -e 's/gtk+3/pygtk/g' -e 's/gtk+2/pygtk/g' -e 's/    depends_on "gtkmm"/    depends_on "gtkmm2"\n    depends_on "gtkmm3"/g' -e 's/gstreamer1/gstreamer/g' -e 's/libsigc++/libsigcplusplus/g' -e 's/python3_setuptools/setuptools/g' -e 's/vorbis_tools/libvorbis/g' -e 's/desktop_file_utils/desktop_file_utilities/g' -e 's/xorgproto/xorg_proto/g' -e 's/libcurl/curl/g' -e 's/libutf8proc/utf8proc/g' -e 's/http:/https:/g' -e 's/xxd/vim/g' -e 's/_devel//g' -e 's/eudev_libudev/eudev/g' -e 's/zlib/zlibpkg/g' -e 's/liblzma/lzma/g' -e "s/'xz'/'xzutils'/g" -e 's/awk/gawk/g' -e 's/libtasn1_tools/libtasn1/g' -e 's/pkg_config/pkgconfig/g' -e 's/p11_kit/p11kit/g' -e 's/gnupg2/gnupg/g' | sed -z "s/  depends_on 'perl'\n//g"
}
depend(){
source "$tempfile"
printf "  source_url '%b'" "$distfiles" | sed "s/\${pkgname}/$pkgname/g" |tr "$" "#"
printf "\n  source_sha256 '%b'\n" "$checksum"
printf '\n'
deps=$(echo "$makedepends $depends $hostmakedepends" | tr "\n" " " | sed -e 's/  / /g' -e "s/'//g" -e 's/libltdl/libtool/g' -e 's/gtk+3/pygtk/g' -e 's/gtk+2/pygtk/g' -e 's/gstreamer1/gstreamer/g' -e 's/libsigc++/libsigcplusplus/g' -e 's/python3_setuptools/setuptools/g' -e 's/vorbis_tools/libvorbis/g' -e 's/desktop_file_utils/desktop_file_utilities/g' -e 's/xorgproto/xorg_proto/g' -e 's/-devel//g' | tr "-" "_" | sed -e 's/libcurl/curl/g' -e 's/libutf8proc/utf8proc/g' -e 's/efl/libefl/g' -e 's/pkg_config/pkgconfig/g' -e 's/pam/openpam/g')
deps=$(printf ' "%b" ' "$deps" | sed -e 's/ " //g' -e 's/"//g')
deps=$(echo $deps | tr " " "\n" | tr "\n" " " | tr '[:upper:]' '[:lower:]' | tr " " "\n")
deps_ar=( $deps )
source <(echo "deps_ar=($(printf '%s' ${deps_ar[@]}))")
for l in "${deps_ar[@]}"
do
printf "  depends_on '%b'\n" "$l"
done
}
root() {
source $tempfile # Source variables within tempfile (template) 
if [ "$2" != "no_checks" ]; then
  if [ $build_style = python3-module ]; then
    printf 'Python is broken, we cant do that type of build style! - Yet!\n'
    exit 1
  fi
fi
printf "require 'package'\n\n" # Print header
pkgname=$(printf '%b' "$pkgname" | tr '[:upper:]' '[:lower:]')
printf "class %b < Package\n" "${pkgname^}" | sed 's/-/_/g' # Set pkgname
printf "  description '%b'\n" "$short_desc" # set desc from short_desc
printf "  homepage '%b'\n" "$homepage" # set homepage
printf "  version '%b'\n" "$version" # set version
if [ -z "$archs" ]; then
  printf "  compatibility 'all'\n"
elif [ "$archs" = "noarch" ]; then
    printf "  compatibility 'all'\n"
else
    printf "  compatibility '%b'" "$archs"
fi
# ^^ Set archs
depend
##
if [ "$build_style" = "gnu-configure" ]; then
cat << 'EOF'
  def self.build
      system \"./configure #{CREW_OPTIONS} ${configure_args}\"
      system \"make -j#{CREW_NPROC}\"
  end
  def self.install
      system \"make install DESTDIR=#{CREW_DEST_DIR}\"
  end
end
EOF
## ^^ Set configure based build style - Above works 100% of the time - There are issues with Meson, Cmake and others, only this seems to work everytime!
##
elif [ "$build_style" = "cmake" ]; then
cat << 'EOF'
 def self.build
   system "cmake . -DCMAKE_INSTALL_PREFIX=#{CREW_PREFIX} -DINSTALL_LIBDIR=#{CREW_LIB_PREFIX} -DCMAKE_BUILD_TYPE=Release"
   system "make -j#{CREW_NPROC}"
 end
 def self.install
   system "DESTDIR=#{CREW_DEST_DIR} make install"
 end
end
EOF
elif [ "$build_style" = "gnu-makefile" ]; then
cat << 'EOF'
  def self.build
   system "make -j#{CREW_NPROC} PREFIX=#{CREW_PREFIX}"
  end
  def self.install
   system "make -j#{CREW_NPROC} install PREFIX=#{CREW_PREFIX}"
  end
end
EOF
elif [ "$build_style" = "meson" ]; then
cat << 'EOF'
  def self.build
    system "meson --prefix=#{CREW_PREFIX} --libdir=#{CREW_LIB_PREFIX} _build"
    system 'ninja -v -C _build'
  end
  
  def self.install
    system "DESTDIR=#{CREW_DEST_DIR} ninja -C _build install"
  end
end
EOF
fi
}
source <(sed '2!d' $1)
pkgname=$(echo $pkgname | sed 's/-/_/g')
state_pre=0
echo $(root $@ | dep_sed) > ./$pkgname.rb
for b in "${predep[@]}"
do
   sed -i -z "s/  depends_on '$b'\n//g" ./$pkgname.rb #Quotes when working with strings
done
sed 's/\\//g' -i ./$pkgname.rb
#  sed "s/  depends_on 'flex'\n//g" | sed "s/  depends_on 'tar'\n//g" | sed "s/  depends_on 'binutils'\n//g
#
#

if [ ! -z ${search_bol} ]; then
source $tempfile
depends_save="$makedepends $depends $hostmakedepends"
printf '\n'
depends_save=$(echo "$depends_save" | tr "\n" " " | sed 's/  / /g'| tr "-" "_" | sed "s/'//g" | dep_sed)
depends_save=$(printf ' "%b" ' "$depends_save" | sed 's/ " //g')
depends_save=$(echo $depends_save | tr " " "\n" | sed -e 's/^\|$/\x27/g' | tr "\n" " " | sed -e 's/"//g' -e "s/'//g")
search_ar=( "$depends_save" )
search_ar=($(echo "${search_ar[@]}" | tr " " "\n"))
source <(echo "ar=($(printf '%s' ${search_ar[@]}))")
printf "There are %b direct deps for this package" "${#ar[@]}"
state=0
printf '\n'
upack=()
for b in "${ar[@]}"
do
bash ./search.sh ${ar[$state]}
if [ $? != 0 ]; then
upack+=(${ar[$state]})
fi
state=$(($state + 1))
done
if [ ${upack[@]} = 0 ]; then
echo "All deps were matched! :)"
else
echo "${upack[@]}"
echo "The above deps were not matched :( - And may need to to be packaged"
fi
fi