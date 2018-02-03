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
# Author: François Poirotte <clicky@erebot.net>
#

basedir="$(dirname "$0")"
cd "$basedir"|| exit
basedir="$(pwd)"
source helpers.sh

versions=()
for arg; do
    if [ "x$arg" != "x" ]; then
        versions[${#versions[@]}]="$arg"
    fi
done

if [ $# -eq 0 ]; then
    default_versions="$basedir/custom/default-versions.txt"
    if [ -e "$default_versions" ]; then
        while read -r arg; do
            # Ignore comments and strip leading/trailing whitespace.
            arg="$(printf "%s\n" "$arg" | sed -e 's/#.*$//;s/\s+$//;s/^\s+//')"
            if [ "x$arg" != "x" ]; then
                versions[${#versions[@]}]="$arg"
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
done

# Detect obsolete versions and suggest removing them,
# but only if we were run without any arguments.
if [ $# -eq 0 ]; then
    instbasedir="$basedir/../inst/"
    for inst_version in $(ls -1p "$instbasedir" | grep '^php-.*/$'); do
        # Remove "php-" prefix and "/" suffix.
        inst_version=${inst_version:4:-1}

        found=0
        for version in "${versions[@]}"; do
            parse_version "$version"
            if [ "$inst_version" == "$VERSION" ]; then
                found=1
                break
            fi
        done

        if [ $found -eq 0 ]; then
            echo -n "Remove obsolete version $inst_version? [Y/n] "
            read -r remove
            if [ -z "$remove" ] || [ "$remove" = "y" ] || [ "$remove" = "Y" ]; then
                rm -vfr "$instbasedir/php-$inst_version"
            fi

            if [ -e "$basedir/php-$inst_version" ]; then
                echo -n "Remove compilation directory $basedir/php-$inst_version? [Y/n] "
                read -r remove
                if [ -z "$remove" ] || [ "$remove" = "y" ] || [ "$remove" = "Y" ]; then
                    rm -vfr "$basedir/php-$inst_version"
                fi
            fi
        fi
    done

    # The removal of obsolete versions
    # may have left us with broken links.
    # Remove these here.
    find -L "$instbasedir/bin" -type l -delete
fi

exit 0
