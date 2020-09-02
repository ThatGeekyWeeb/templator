#!/bin/sh
set -e # Die when theres a issue
search_val=$1
search="$(printf 'crew search %b' "$search_val")"
${search}
