#!/bin/bash
# Requires gitio-cli to be preinstalled
# Requires node as well
pkgname="$1"
if ! wget -q -e robots=off -r -A.patch -nd -l 1 "https://github.com/void-linux/void-packages/tree/master/srcpkgs/$pkgname/patches/"; then
  exit 1
fi
patches+=($(ls ./ | sed '/^.*\.patch/!d' | tr "\n" " "))
rm ./*.patch &>/dev/null
printf '\n'
echo "  def self.patch"
version_node=$(nodebrew ls | cut -d$'\n' -f1)
for i in ${patches[@]}
do
  node /usr/local/share/nodebrew/node/$version_node/bin/gitio-cli/index.js "https://raw.githubusercontent.com/void-linux/void-packages/master/srcpkgs/$pkgname/patches/$i" | tr "\n" " " | cut -d':' -f2- | sed 's/ Long URL: .*//g' | wl-copy
  echo "    system \"curl --ssl --progress-bar -o $i -L$(wl-paste)\""
  printf "    abort 'Checksum mismatch. :/ Try again.'.lightred unless Digest::SHA256.hexdigest( File.read('$i') ) == '%b'\n" $(curl -Ls $(wl-paste) | sha256sum | cut -d" " -f1)
done
source ./template
if [ -z $patch_args ]; then
  patch_type="-Np0"
else
  patch_type="$patch_args"
fi

for i in ${patches[@]}
do
  echo "    system \"patch ${patch_type} ./$i\""
done
echo "  end"
