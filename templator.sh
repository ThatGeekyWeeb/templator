#!/bin/bash
if test -f ./template; then
    tempfile="./template"
fi
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

IFS=""
root() {
tempcont="$(cat "$tempfile")"
source ./template
makedepends=$(echo $makedepends | sed 's/-/_/g' | sed 's/_devel//g')
printf "require 'package'\n\n"

printf 'class %b < Package\n' "${pkgname^}" | sed 's/-/_/g'
printf '    description "%b"\n' "$short_desc"
printf '    homepage "%b"\n' "$homepage"
printf '    version "%b"\n' "$version"
if [ -z "$archs" ]; then
    printf '    compatibility "all"\n'
elif [ "$archs" = "noarch" ]; then
    printf '    compatibility "all"\n'
else
    printf '    compatibility "%b"' "$archs"
fi

printf '    source_url "%b"' "$distfiles" | sed "s/\${pkgname}/$pkgname/g" |tr "$" "#" | sed "s/\${version%.*}/${version%.*}/g"
printf '\n    source_sha256 "%b"' "$checksum"
# $hostmakedepends is most likely useless
printf '\n\n    depends_on '
printf '%b' "$makedepends" | tr " " "\n" |sed -e 's/^\|$/"/g' | tr "\n" "~" |sed 's/~/\n    depends_on /g' | sed 's/-devel//g' | sed 's/-/_/g'
printf '%b' "$depends" | tr " " "\n" |sed -e 's/^\|$/"/g' | tr "\n" "~" |sed 's/~/\n    depends_on /g' | sed 's/-devel//g' | sed 's/-/_/g'

if [ "$build_style" = "gnu-configure" ]; then
printf "\n
    def self.build
        system \"./configure #{CREW_OPTIONS} ${configure_args}\"
        system \"make -j#{CREW_NPROC}\"
    end
    def self.install
        system \"make install DESTDIR=#{CREW_DEST_DIR}\"
    end
end"
fi
}
root | sed 's/libltdl/libtool/g' | sed 's/gtk+3/pygtk/g' | sed 's/gtk+2/pygtk/g' | sed 's/    depends_on "gtkmm"/    depends_on "gtkmm2"\n    depends_on "gtkmm3"/g' | sed 's/gstreamer1/gstreamer/g' | sed 's/libsigc++/libsigcplusplus/g'