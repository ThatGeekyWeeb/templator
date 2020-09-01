#!/bin/sh
if [ -z $1 ]; then
  printf '\r Enter pkgname: > ' && read 'pkgname'
else
  pkgname="$1"
fi
curl -LO --progress-bar -C - "https://raw.githubusercontent.com/void-linux/void-packages/master/srcpkgs/${pkgname}/template"