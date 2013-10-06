#!/bin/bash
# You can override config options very easily.
# Just create a custom options file in the custom/ directory.
# It may be version specific:
# - custom/options.sh
# - custom/options-5.sh
# - custom/options-5.3.sh
# - custom/options-5.3.1.sh
#
# Don't touch this file here - it would prevent you from just
# "svn update"'ing your phpfarm source code.

version=$1
vmajor=$2
vminor=$3
vpatch=$4

configure=`stat -c '%Y' "options.sh"`
configoptions="\
--disable-short-tags \
--with-layout=GNU \
--enable-bcmath \
--enable-calendar \
--enable-exif \
--enable-ftp \
--enable-mbstring \
--enable-pcntl \
--enable-soap \
--enable-sockets \
--enable-wddx \
--enable-zip \
--with-zlib \
--with-gettext \
"

# --enable-sqlite-utf8 was removed starting with PHP 5.4.0.
test $vmajor -eq 5 -a $vminor -lt 4
if [ $? -eq 0 ]; then
configoptions="\
$configoptions \
--enable-sqlite-utf8 \
"
fi

echo $version $vmajor $vminor $vpatch

for suffix in "" "-$vmajor" "-$vmajor.$vminor" "-$vmajor.$vminor.$vpatch"; do
    custom="custom/options$suffix.sh"
    if [ -e "$custom" ]; then
        tstamp=`stat -c '%Y' "$custom"`
        if [ $tstamp -gt $configure ]; then
            configure=$tstamp
        fi
        source "$custom" "$version" "$vmajor" "$vminor" "$vpatch"
    fi
done
