#!/usr/bin/env bash

set -eu

basedir="$(dirname "$0")"
cd "$basedir"
basedir="$(pwd)"

version="$1"
php_file="php-$version"

rm -rf "$php_file" "../inst/$php_file"

if [[ -f "./custom/post-remove.sh" ]]; then
    ./custom/post-remove.sh "$version"
fi

