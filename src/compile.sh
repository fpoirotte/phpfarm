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
# ./compile.sh 5.3.1
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

#directory of this file. all php sources are extracted in it
basedir="`dirname "$0"`"
cd "$basedir"
basedir=`pwd`

#we need a php version
source helpers.sh
parse_version $1
if [ $? -ne 0 ]; then
    echo 'Please specify a valid php version' >&2
    exit 1
fi

#directory of php sources of specific version
srcdir="php-$VERSION"
#directory with source archives
bzipsdir='bzips'
#directory phps get installed into
instbasedir="`readlink -f "$basedir/../inst"`"
#directory this specific version gets installed into
instdir="$instbasedir/php-$VERSION"
#directory where all bins are symlinked
shbindir="$instbasedir/bin"

#already extracted?
if [ ! -d "$srcdir" ]; then
    echo 'Source directory does not exist; trying to extract'
    srcfile="$bzipsdir/php-$SHORT_VERSION.tar.bz2"
    if [ ! -f "$srcfile" ]; then
        echo 'Source file not found:'
        echo "$srcfile"
        url="http://museum.php.net/php$VMAJOR/php-$SHORT_VERSION.tar.bz2"
        wget -P "$bzipsdir" "$url"
        if [ ! -f "$srcfile" ]; then
            echo "Fetching sources from museum failed"
            echo $url
            #museum failed, now we try real download
            url="https://www.php.net/get/php-$SHORT_VERSION.tar.bz2/from/this/mirror"
            wget -P "$bzipsdir" -O "$srcfile" "$url"
        fi
        if [ ! -s "$srcfile" -a -f "$srcfile" ]; then
            rm "$srcfile"
        fi

        if [ ! -f "$srcfile" ]; then
            echo "Fetching sources from official download site failed"
            echo $url
            #use ilia's RC (5.3.x)
            url="https://downloads.php.net/ilia/php-$SHORT_VERSION.tar.bz2"
            wget -P "$bzipsdir" -O "$srcfile" "$url"
        fi
        if [ ! -s "$srcfile" -a -f "$srcfile" ]; then
            rm "$srcfile"
        fi

        if [ ! -f "$srcfile" ]; then
            echo "Fetching sources from ilia's site failed"
            echo $url
            #use stas's RC (5.4.x)
            url="https://downloads.php.net/stas/php-$SHORT_VERSION.tar.bz2"
            wget -P "$bzipsdir" -O "$srcfile" "$url"
        fi
        if [ ! -s "$srcfile" -a -f "$srcfile" ]; then
            rm "$srcfile"
        fi

        if [ ! -f "$srcfile" ]; then
            echo "Fetching sources from stas's site failed"
            echo $url
            #use dsp's RC (5.5.x)
            url="https://downloads.php.net/dsp/php-$SHORT_VERSION.tar.bz2"
            wget -P "$bzipsdir" -O "$srcfile" "$url"
        fi
        if [ ! -s "$srcfile" -a -f "$srcfile" ]; then
            rm "$srcfile"
        fi

        if [ ! -f "$srcfile" ]; then
            echo "Fetching sources from dsp's site failed"
            echo $url
            #use Tyrael's RC (5.6.x)
            url="https://downloads.php.net/tyrael/php-$SHORT_VERSION.tar.bz2"
            wget -P "$bzipsdir" -O "$srcfile" "$url"
        fi
        if [ ! -s "$srcfile" -a -f "$srcfile" ]; then
            rm "$srcfile"
        fi

        if [ ! -f "$srcfile" ]; then
            echo "Fetching sources failed:" >&2
            echo $url >&2
            exit 2
        fi
    fi
    #extract
    tar xjvf "$srcfile" --show-transformed-names --transform 's#^[^/]*#php-'"$VERSION"'#'
fi

#read customizations
source 'options.sh' "$VERSION" "$VMAJOR" "$VMINOR" "$VPATCH"
cd "$srcdir"

#only configure/make during the first install of a new version
#or after some change occurred in customizations.
tstamp=0
if [ -f "config.nice" -a -f "config.status" ]; then
   tstamp=`stat -c '%Y' "config.status"`
fi

if [ $ARCH32 = 1 ]; then
    ARCH=i386
    CFLAGS="$CFLAGS -m32"
    CXXFLAGS="$CXXFLAGS -m32"
    LDFLAGS="$LDFLAGS -m32"
    export ARCH
    export CFLAGS
    export CXXFLAGS
    export LDFLAGS
fi

echo "Last config. change:   $configure"
echo "Last ./configure:      $tstamp"
if [ $configure -gt $tstamp ]; then
    #configuring
    echo "(Re-)configuring"
    if [ $DEBUG = 1 ]; then
        configoptions="--enable-debug $configoptions"
        test $VMAJOR -gt 5 -o \( $VMAJOR -eq 5 -a $VMINOR -ge 6 \)
        if [[ $? -eq 0 && $configoptions == *--enable-phpdbg* ]]; then
            configoptions="--enable-phpdbg-debug $configoptions"
        fi
    fi
    if [ $ZTS = 1 ]; then
        configoptions="--enable-maintainer-zts $configoptions"
    fi
    if [ $GCOV = 1 ]; then
        configoptions="--enable-gcov $configoptions"
    fi

    # --enable-cli first appeared in PHP 5.3.0.
    otheroptions=
    if [ $VMAJOR -gt 5 -o $VMINOR -ge 3 ]; then
        otheroptions="$otheroptions --enable-cli"
    fi

    # For PHP 5.4.0+, also build php-fpm.
    # In PHP 5.3.0, only one SAPI can be built at a time
    # (and we already build php-cgi, hence a conflict).
    if [ $VMAJOR -gt 5 -o $VMINOR -ge 4 ]; then
        otheroptions="$otheroptions --enable-fpm"
    fi

    #Disable PEAR installation (handled separately below).
    ./configure $configoptions \
         --prefix="$instdir" \
         --exec-prefix="$instdir" \
         --without-pear \
         --enable-cgi \
         $otheroptions

    if [ $? -gt 0 ]; then
        echo "configure failed." >&2
        exit 3
    fi
else
    echo "Skipping ./configure step"
fi

# Check that no unknown options have been used.
unknown_options=
if [ -e "config.status" ]; then
    unknown_options=`sed -ne '/Following unknown configure options were used/,/for available options/p' config.status | sed -n -e '$d' -e '/^$/d' -e '3,$p'`
fi
# PHP 5.4+ uses a different way to report such problems.
if [ -z "$unknown_options" -a -e "config.log" ]; then
    unknown_options=`sed -n -r -e 's/configure:[^\020]+WARNING: unrecognized options: //p' config.log`
fi

if [ -n "$unknown_options" ]; then
    # If the error comes from a previous run, ./configure won't kick in and
    # it won't display the error message. We do the work in its place here.
    if [ $configure -le $tstamp ]; then
        echo "ERROR: The following unrecognized configure options were used:" >&2
        echo "" >&2
        echo $unknown_options >&2
        echo "" >&2
        echo "Check 'configure --help' for available options." >&2
    fi
    echo "Please fix your configure options and try again." >&2
    exit 3
fi

if [ $configure -gt $tstamp -o ! -f sapi/cli/php ]; then
    #compile sources
    make $MAKE_OPTIONS
    if [ "$?" -gt 0 ]; then
        echo "make failed."
        exit 4
    fi
fi

#install SAPIs, etc.
make install
if [ "$?" -gt 0 ]; then
    echo "make install failed."
    exit 5
fi

#determine path to extension directory
ext_dir=`"$instdir/bin/php-config" --extension-dir`

#install PEAR separately
if [ $PEAR = 1 ]; then
    pearphar="$basedir/bzips/install-pear-nozlib.phar"
    if [ ! -e "$pearphar" ]; then
        #download PEAR installer
        wget -O "$pearphar" \
            "https://pear.php.net/install-pear-nozlib.phar"
    fi
    if [ ! -e "$pearphar" ]; then
        echo "Please put install-pear-nozlib.phar into bzips/"
        exit 2
    fi

    echo "Installing PEAR environment:     $instdir/pear/"
    mkdir -p "$instdir/pear/php"

    #use local modules
    pear_ext_dir="`pwd`/modules"

    #take care of static vs. dynamic modules
    pear_exts=""
    for ext in phar xml pcre; do
        if [ -f "$pear_ext_dir/$ext.so" ]; then
            pear_exts=" -dextension=$ext.so"
        fi
    done

    #proceed with the installation
    sapi/cli/php -n                     \
        -ddisplay_startup_errors=0      \
        -dauto_prepend_file=../ereg.php \
        -dextension_dir="$pear_ext_dir" \
        $pear_exts                      \
        -dshort_open_tag=0              \
        -dsafe_mode=0                   \
        -dopen_basedir=                 \
        -derror_reporting=1803          \
        -dmemory_limit=-1               \
        -ddetect_unicode=0              \
        "$pearphar"                     \
            -dp         "a"                         \
            -ds         "-$VERSION"                 \
            --dir       "$instdir/pear/php"         \
            --bin       "$instdir/bin"              \
            --config    "$instdir/pear/cfg"         \
            --www       "$instdir/pear/www"         \
            --data      "$instdir/pear/data"        \
            --doc       "$instdir/pear/docs"        \
            --test      "$instdir/pear/tests"       \
            --cache     "$instdir/pear/cache"       \
            --temp      "$instdir/pear/temp"        \
            --download  "$instdir/pear/downloads"
    if [ "$?" -gt 0 ]; then
        echo PEAR installation failed.
        exit 5
    fi

    #add symlink to extension directory as "ext"
    #for compatibility with Pyrus.
    ln -sfT "$ext_dir" "$instdir/pear/ext"
    #add a symlink to PEAR's cfg_dir for convenience.
    ln -sfT "$instdir/pear/cfg" "$instdir/etc/pear"
fi

#copy php.ini
#you can define your own ini target directory by setting $initarget
if [ "x$initarget" = x ]; then
    initarget="$instdir/etc/php.ini"
fi
mkdir -p `dirname "$initarget"`
if [ -f "php.ini-development" ]; then
    #php 5.3
    cp "php.ini-development" "$initarget"
elif [ -f "php.ini-recommended" ]; then
    #php 5.1, 5.2
    cp "php.ini-recommended" "$initarget"
else
    echo "No php.ini file found."
    echo "Please copy it manually to $initarget"
fi

#set default ini values
cd "$basedir"
if [ -f "$initarget" ]; then
    #fixme: make the options unique or so
    custom="custom/php.ini"
    [ ! -e "$custom" ] && cp "default-custom-php.ini" "$custom"

    for suffix in "" "-$VMAJOR" "-$VMAJOR.$VMINOR" "-$SHORT_VERSION" "-$VERSION"; do
        custom="custom/php$suffix.ini"
        [ -e "$custom" ] && cat "$custom" >> "$initarget"
    done
    sed -i -e 's#$ext_dir#'"$ext_dir"'#' -e 's#$install_dir#'"$instdir"'#' "$initarget"
fi

#create bin
[ ! -d "$shbindir" ] && mkdir "$shbindir"
if [ ! -d "$shbindir" ]; then
    echo "Cannot create shared bin dir" >&2
    exit 6
fi
#symlink all files

#php may be called php.gcno
#same for php-cgi.
for binary in php php-cgi php-config phpize; do
    if [ -f "$instdir/bin/$binary" ]; then
        ln -fs "$instdir/bin/$binary" "$shbindir/$binary-$VERSION"
    elif [ -f "$instdir/bin/$binary.gcno" ]; then
        ln -fs "$instdir/bin/$binary.gcno" "$shbindir/$binary-$VERSION"
    else
        echo "no $binary found" >&2
        exit 7
    fi
done

#other optional SAPIs.
for binary in php-fpm phpdbg; do
    if [ -f "$instdir/bin/$binary" ]; then
        ln -fs "$instdir/bin/$binary" "$shbindir/$binary-$VERSION"
    elif [ -f "$instdir/sbin/$binary" ]; then
        ln -fs "$instdir/sbin/$binary" "$shbindir/$binary-$VERSION"
    fi
done

#strip executables in non-debug builds.
if [ $DEBUG != 1 ]; then
    for binary in php php-cgi php-fpm phpdbg; do
        if [ -f "$shbindir/$binary-$VERSION" ]; then
            strip --strip-unneeded "$shbindir/$binary-$VERSION"
        fi
    done
fi

# If PEAR was installed, finish the setup here.
# Recent versions of PHP also come with a phar.phar archive
# that makes it easy to manipulate PHP archives.
# Let's be user-friendly and add symlinks to all these tools.
for binary in pear peardev pecl phar; do
    if [ -e "$instdir/bin/$binary" ]; then
        ln -fs "$instdir/bin/$binary" "$shbindir/$binary-$VERSION"
    fi
done

# Export various variables for use
# in post-install scripts and such.
export VERSION
export VMAJOR
export VMINOR
export VPATCH
export SHORT_VERSION
export ARCH

cd "$basedir"
./pyrus.sh "$VERSION" "$instdir"

# Post-install stuff
for suffix in "" "-$VMAJOR" "-$VMAJOR.$VMINOR" "-$SHORT_VERSION" "-$VERSION"; do
    post="custom/post-install$suffix.sh"
    if [ -e "$post" ]; then
        echo ""
        echo "Running commands from '$post'"
        /bin/bash "$post" "$VERSION" "$instdir" "$shbindir"
    fi
done
exit 0

