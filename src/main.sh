#!/bin/bash
#
# phpfarm
#
# Installs multiple versions of PHP beside each other.
# Both CLI and CGI versions are compiled.
# Sources are fetched from museum.php.net if no
# corresponding file bzips/php-$version.tar.bz2 exists.
#
# Usage:
# ./main.sh 5.3.1 [...]
#
# You should add ../inst/bin to your $PATH to have easy access
# to all php binaries. The executables are called
# php-$version and php-cgi-$version
#
# In case the options in options.sh do not suit you or you just need
# different options for different php versions, you may create
# custom/options-$version.sh scripts that define a $configoptions
# variable. See options.sh for more details.
#
# Put pyrus.phar into bzips/ to automatically get version-specific
# pyrus/pear2 commands.
#
# Author: Christian Weiske <cweiske@php.net>
#

basedir="`dirname "$0"`"
cd "$basedir"
basedir=`pwd`

versions=()
for arg; do
    if [ "x$arg" != "x" ]; then
        versions[${#versions[@]}]="$arg"
    fi
done

main_version=
if [ $# -eq 0 ]; then
    default_versions="$basedir/custom/default-versions.txt"
    if [ -e "$default_versions" ]; then
        while read arg; do
            if [ "x$arg" != "x" -a "${arg:0:1}" != "#" ]; then
                versions[${#versions[@]}]="$arg"

                # The first entry in this file is the main version.
                if [ -z "$main_version" ]; then
                    main_version="$arg"
                fi
            fi
        done < "$default_versions"
    fi
fi

if [ ${#versions[@]} -eq 0 ]; then
    echo 'Please specify php version or create "custom/default-versions.txt" file'
    exit 1
fi

for version in "${versions[@]}"; do
    ./compile.sh "$version"
    res=$?
    if [ $res -ne 0 ]; then
        echo "An error occurred while trying to install PHP $version."
        exit $res
    fi
done

# Set the main version.
if [ -n "$main_version" ]; then
    source helpers.sh
    parse_version "$main_version"
    echo "Setting $VERSION as your main PHP version"
    #directory phps get installed into
    instbasedir="`readlink -f "$basedir/../inst"`"
    #directory this specific version was installed into
    instdir="$instbasedir/php-$VERSION"
    ln -sf -T "$instbasedir/php-$VERSION/bin" "$instbasedir/main"
fi

exit 0

