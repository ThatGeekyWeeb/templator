#!/bin/bash
pkgname="$1"
if ! wget -q -e robots=off -r -A.patch -nd -l 1 "https://github.com/void-linux/void-packages/tree/master/srcpkgs/$pkgname/patches/"; then
  echo "No patches for $pkgname were found, yay!"
  exit 1
fi
patches+=($(ls ./ | sed '/^.*\.patch/!d' | tr "\n" " "))
rm ./*.patch &>/dev/null
for i in ${patches[@]}
do
  wget -P ./$pkgname.patches/ -q --show-progress --progress=bar "https://raw.githubusercontent.com/void-linux/void-packages/master/srcpkgs/$pkgname/patches/$i"
done