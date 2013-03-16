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
    echo 'Please specify php version or create "custom/default-versions.txt" file' >&2
    exit 1
fi

for version in "${versions[@]}"; do
    ./compile.sh "$version"
    res=$?
    if [ $res -ne 0 ]; then
        echo "An error occurred while trying to install PHP $version." >&2
        exit $res
    fi

    # Set the main version.
    if [ "$version" == "$main_version" ]; then
        source helpers.sh
        parse_version "$main_version"
        echo "Setting $VERSION as your main PHP version"
        #directory phps get installed into
        instbasedir="`readlink -f "$basedir/../inst"`"
        #directory this specific version was installed into
        instdir="$instbasedir/php-$VERSION"
        ln -sf -T "$instbasedir/php-$VERSION/bin" "$instbasedir/main"
    fi
done

# Detect obsolete versions and suggest removing them,
# but only if we were run without any arguments.
if [ $# -eq 0 ]; then
    for inst_version in `ls -1 "$instbasedir" | grep ^php-`; do
        # Remove "php-" prefix.
        inst_version=${inst_version:4}

        found=0
        for version in "${versions[@]}"; do
            parse_version "$version"
            if [ "$inst_version" == "$VERSION" ]; then
                found=1
                break
            fi
        done

        if [ $found -eq 0 ]; then
            echo "Remove obsolete version $inst_version? [Y/n]"
            read remove
            if [ -z "$remove" -o "$remove" = "y" -o "$remove" = "Y" ]; then
                rm -vfr "$instbasedir/php-$inst_version"

                # Remove other leftover files.
                rm -vf "$instbasedir/bin/pear-$inst_version"
                rm -vf "$instbasedir/bin/peardev-$inst_version"
                rm -vf "$instbasedir/bin/pecl-$inst_version"
                rm -vf "$instbasedir/bin/phar-$inst_version"
                rm -vf "$instbasedir/bin/php-$inst_version"
                rm -vf "$instbasedir/bin/php-cgi-$inst_version"
                rm -vf "$instbasedir/bin/php-config-$inst_version"
                rm -vf "$instbasedir/bin/phpize-$inst_version"
                rm -vf "$instbasedir/bin/pyrus-$inst_version"
            fi

            if [ -e "$basedir/php-$inst_version" ]; then
                echo "Remove compilation directory $basedir/php-$inst_version? [Y/n]"
                read remove
                if [ -z "$remove" -o "$remove" = "y" -o "$remove" = "Y" ]; then
                    rm -vfr "$basedir/php-$inst_version"
                fi
            fi
        fi
    done
then

exit 0
