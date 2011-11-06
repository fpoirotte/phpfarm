#!/bin/bash
#install pyrus specific to the given php version
# automatically tries to download latest pyrus version if
# there is none in bzips/

if [ $# -lt 2 ] ; then
    echo "pass version and PHP installation directory as parameters"
    exit 1
fi

version="$1"
vmajor=`echo ${version%%.*}`
vminor=`echo ${version%.*}`
vminor=`echo ${vminor#*.}`
instdir="$2"

if [ ! -d "$instdir" ]; then
    echo "PHP installation directory does not exist: $instdir"
    exit 2
fi

test $vmajor -gt 5 -o \( $vmajor -eq 5 -a $vminor -ge 3 \)
if [ $? -ne 0 ]; then
    echo "Skipping Pyrus installation for PHP < 5.3.0"
    exit 0
fi

pwd=`pwd`
cd "`dirname "$0"`"
basedir=`pwd`
cd "$pwd"

pyrusphar="$basedir/bzips/pyrus.phar"
pyrustarget="$instdir/pyrus.phar"
if [ ! -e "$pyrusphar" ]; then
    #download pyrus from svn
    wget -O "$pyrusphar"\
        "http://pear2.php.net/pyrus.phar"
fi
if [ ! -e "$pyrusphar" ]; then
    echo "Please put pyrus.phar into bzips/"
    exit 3
fi

cp "$pyrusphar" "$pyrustarget"
chmod +x "$pyrustarget"
mkdir -p "$instdir/pear"

pyrusbin="$instdir/bin/pyrus"
echo '#!/bin/sh'> "$pyrusbin"
echo "\"$instdir/bin/php\" -d detect_unicode=0 \"$pyrustarget\" \"$instdir/pear\" \"\$@\"" >> "$pyrusbin"
chmod +x "$pyrusbin"
"$pyrusbin" set php_prefix "$instdir/bin/"

#symlink
ln -sf "$pyrusbin" "$instdir/../bin/pyrus-$version"

# Use as main version if necessary.
if [ "$version" = "$PHPFARM_MAIN_VERSION" ]; then
    echo "Marking pyrus-$version as the main version of pyrus."
    ln -sf "$instdir/../bin/pyrus-$version" "$instdir/../bin/pyrus"
fi

echo "include_path=\".:$instdir/pear/\"" >> "$instdir/etc/php.ini"
exit 0
