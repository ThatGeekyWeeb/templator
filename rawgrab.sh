#!/bin/bash
if [ ! -z $4 ]; then 
  out="-L -o $4"
else
  out="-LO"
fi
curl --ssl ${out} "https://github.com/$1/raw/$2/packages/$3"