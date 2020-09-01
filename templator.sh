#!/bin/bash

tempfile="$1" # Set tempfile to first argument 

# Set websites for distfiles
CPAN_SITE="https://cpan.perl.org/modules/by-module"
DEBIAN_SITE="http://ftp.debian.org/debian/pool"
FREEDESKTOP_SITE="https://freedesktop.org/software"
GNU_SITE="https://ftp.gnu.org/gnu"
GNOME_SITE="https://ftp.gnome.org/pub/GNOME/sources"
KERNEL_SITE="https://www.kernel.org/pub/linux"
MOZILLA_SITE="https://ftp.mozilla.org/pub"
NONGNU_SITE="https://download.savannah.nongnu.org/releases"
PYPI_SITE="https://files.pythonhosted.org/packages/source"
SOURCEFORGE_SITE="https://downloads.sourceforge.net/sourceforge"
UBUNTU_SITE="http://archive.ubuntu.com/ubuntu/pool"
XORG_SITE="https://www.x.org/releases/individual"
KDE_SITE="https://download.kde.org/stable"
##

IFS="" # Remove IFS to keep newlines
depend(){
printf "  source_url '%b'" "$distfiles" | sed "s/\${pkgname}/$pkgname/g" |tr "$" "#" | sed "s/\${version%.*}/${version%.*}/g" # Set source-pkg
printf "\n  source_sha256 '%b'" "$checksum" # set checksum
# $hostmakedepends is most likely useless - So we skip it, if it does it should be defined with ${hostmakedepends} which will be sourced and replaced properly
printf '\n\n  depends_on '
printf '%b' "$makedepends" | tr " " "\n" | sed -e 's/^\|$/\x27/g' | tr "\n" "~" | tr " " "~" | sed 's/~/\n  depends_on /g' | sed 's/-devel//g' | sed 's/-/_/g' # Edit makedepends
printf '%b' "$depends" | tr " " "\n" |sed -e 's/^\|$/\x27/g' | tr "\n" "~" |sed 's/~/\n  depends_on /g' | sed 's/-devel//g' | sed 's/-/_/g' # Edit depends
printf '\n'
}
root() {
source $tempfile # Source variables within tempfile (template) 
if [ "$2" != "no_checks" ]; then
  if [ $build_style = python3-module ]; then
    printf 'Python is broken, we cant do that type of build style! - Yet!\n'
    exit 1
  fi
fi
search_dep=$(echo $makedepends#)
makedepends=$(echo $makedepends | sed 's/-/_/g' | sed 's/_devel//g' | tr '[:upper:]' '[:lower:]') # Preset makedepends
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
printf "
  def self.build
      system \"./configure #{CREW_OPTIONS} ${configure_args}\"
      system \"make -j#{CREW_NPROC}\"
  end
  def self.install
      system \"make install DESTDIR=#{CREW_DEST_DIR}\"
  end
end"
## ^^ Set configure based build style - Above works 100% of the time - There are issues with Meson, Cmake and others, only this seems to work everytime!
##
elif [ "$build_style" = "meson" ]; then
printf "
  def self.build
    system 'meson',
           \"--prefix=#{CREW_PREFIX}\",
           \"--libdir=#{CREW_LIB_PREFIX}\",
           '_build'
    system 'ninja -v -C _build'
  end
  
  def self.install
    system \"DESTDIR=#{CREW_DEST_DIR} ninja -C _build install\"
  end
end"
elif [ "$build_style" = "cmake" ]; then
printf "
 def self.build
   system \"cmake . -DCMAKE_INSTALL_PREFIX=#{CREW_PREFIX} -DINSTALL_LIBDIR=#{CREW_LIB_PREFIX} -DCMAKE_BUILD_TYPE=Release\"
   system \"make -j#{CREW_NPROC}\"
 end\"
 def self.install
   system \"DESTDIR=#{CREW_DEST_DIR} make install\"
 end
end"
elif [ "$build_style" = "gnu-makefile" ]; then
printf "
 def self.build
  system \"make -j#{CREW_NPROC} PREFIX=#{CREW_PREFIX} %b\"
 end
 def self.install
  system \"make -j#{CREW_NPROC} install PREFIX=#{CREW_PREFIX}\"
 end
end" "$make_build_arg"
fi
}
source <(sed '2!d' $tempfile)
printf '%b'"$(root $@ | sed 's/libltdl/libtool/g' | sed 's/gtk+3/pygtk/g' | sed 's/gtk+2/pygtk/g' | sed 's/    depends_on "gtkmm"/    depends_on "gtkmm2"\n    depends_on "gtkmm3"/g' | sed 's/gstreamer1/gstreamer/g' | sed 's/libsigc++/libsigcplusplus/g' | sed 's/python3_setuptools/setuptools/g' | sed 's/vorbis_tools/libvorbis/g' | sed 's/desktop_file_utils/desktop_file_utilities/g' | sed 's/xorgproto/xorg_proto/g' | sed 's/libcurl/curl/g' | sed 's/libutf8proc/utf8proc/g')" > ./$pkgname.rb

if [ ! -z ${search_bol} ]; then
source $tempfile
depends_save="$makedepends"
printf '\n'
depends_save=$(echo "$depends_save" | tr "\n" " " | sed 's/  / /g' | sed "s/'//g" | sed 's/libltdl/libtool/g' | sed 's/gtk+3/pygtk/g' | sed 's/gtk+2/pygtk/g' | sed 's/gstreamer1/gstreamer/g' | sed 's/libsigc++/libsigcplusplus/g' | sed 's/python3_setuptools/setuptools/g' | sed 's/vorbis_tools/libvorbis/g' | sed 's/desktop_file_utils/desktop_file_utilities/g' | sed 's/xorgproto/xorg_proto/g' | sed 's/-devel//g' | tr "-" "_" | sed 's/libcurl/curl/g' | sed 's/libutf8proc/utf8proc/g')
bash ./search.sh $depends_save
fi