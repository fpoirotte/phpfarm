phpfarm
=======

phpfarm is a set of scripts to install a dozen of PHP versions in parallel
on a single system. It also installs the pear and pyrus installers and
creates a local Pyrus installation for each PHP version as well.

This tool was primarily developed for PEAR's continuous integration machine.

The PHP source packages are fetched from http://museum.php.net/ (which is not
always up-to-date), the official php.net download pages and the pre-release
channels.

The Pyrus PHAR archive is fetched from http://pear2.php.net/pyrus.phar (which
always refers the latest version).

Last but not least, phpfarm can automatically apply the Suhosin patch
for the version of PHP you are installing. It does so by looking at
http://www.hardened-php.net/suhosin/download.html for compatible versions
of the patch.

If a file cannot be found, try to fetch it manually and put it into
``src/bzips/``.


Setup
-----
- Check out phpfarm from git:
  ``git clone git://git.code.sf.net/p/phpfarm/code phpfarm``
- ``cd phpfarm/src/``
- ``./main.sh 5.3.0``
- PHP gets installed into ``phpfarm/inst/php-$version/``
- ``phpfarm/inst/bin/php-$version`` is also executable
  You should add ``inst/bin``, ``inst/current/bin`` and
  ``inst/current/sbin`` to your ``$PATH``, i.e.
  ``PATH="$PATH:$HOME/phpfarm/inst/bin:$HOME/phpfarm/inst/current/bin:$HOME/phpfarm/inst/current/sbin"``
  in your ``.bashrc``


Configure options customization
-------------------------------
Default configuration options are in ``src/options.sh``.
You may create version-specific custom option files:

- ``custom/options.sh``
- ``custom/options-5.sh``
- ``custom/options-5.3.sh``
- ``custom/options-5.3.1.sh``

The shell script needs to define a variable "``$configoptions``" with
all ``./configure`` options.
Do not try to change ``prefix`` and ``exec-prefix``.


Switching default php versions
------------------------------
Using the command ``switch-phpfarm``, you can make one of the installed
PHP versions the default one that gets run when just typing ``php``::

    $ switch-phpfarm
    Switch the currently active PHP version of phpfarm
    Available versions:
    * 5.2.17
      5.3.16
      5.4.6
    $ switch-phpfarm 5.4.6
    Setting active PHP version to 5.4.6
    PHP 5.4.6 (cli) (built: Sep 13 2012 11:24:56) (DEBUG)
    $ switch-phpfarm
    Switch the currently active PHP version of phpfarm
    Available versions:
      5.2.17
      5.3.16
    * 5.4.6

You need to have ``inst/current-bin`` in your ``$PATH`` to make this work.
See `Setup`_ for more information on how to configure your ``$PATH``.


php.ini customization
---------------------
``php.ini`` values may also be customized:

- ``custom/php.ini``
- ``custom/php-5.ini``
- ``custom/php-5.3.ini``
- ``custom/php-5.3.1.ini``

Please note that a few substitutions are done in those files in order
to generate the final php.ini configuration file. Namely, the following
variables are substitued:

- ``$ext_dir`` gets replaced by the path to the extension directory
  This is mostly used to set the ``extension_dir`` option to the right
  value.
  This is also useful when installing a ``zend_extension`` like
  Xdebug as ``extension_dir`` is not automatically prepended to the
  path for those extensions.


.. _`post-install script`:

Post-install customization
--------------------------
You may also create version-specific scripts that will be run after
the PHP binary has been successfully compiled, installed and configured:

- ``custom/post-install.sh``
- ``custom/post-install-5.sh``
- ``custom/post-install-5.3.sh``
- ``custom/post-install-5.3.1.sh``

These scripts can be used for example to discover PEAR channels
and pre-install some extensions/packages needed by your project.

Each script is called with three arguments:

- The PHP version that was just installed (eg. ``5.3.1-zts-suhosin-debug``).
- The full path to the folder where that version was install
  (eg. ``/home/clicky/phpfarm/inst/php-5.3.1-zts-suhosin-debug/``).
- The full path to the shared folder containing the links to the main
  executables for each version (eg. ``/home/clicky/phpfarm/inst/bin/``).

.. note::
    You do not need to specify a "shebang line" (``#!...``) at the beginning
    of the scripts. Bash will always be used to execute them.

Given all the previous bits of information, the following shell script may
be used to discover a PEAR channel and install a PEAR extension::

    # "$3/pear-$1" could also be used in place of "$2/bin/pear"
    # (both refer to the pear installer for this specific version of PHP).
    "$2/bin/pear" channel-discover pear.phpunit.de
    "$2/bin/pear" install pear.phpunit.de/PHPUnit

    # The exit status must be 0 when the scripts terminates without any error.
    # Any other value will be treated as an error.
    exit 0

.. warning::
    Your post-install customization script should always exit with a zero
    status when they terminate normally. Any other value will be considered
    a failure and will make phpfarm exit immediately with an error.


Special flags in version strings
--------------------------------

phpfarm recognizes a few special flags in the version string.
These flags must be appended to the version string and separated
from it and from one another by dashes (-).

The following flags are currently accepted:

-   ``32bits`` to force the creation of a 32 bits version of PHP on a 64 bits
    machine.

    ..  note::
        If specified, this flag appears in the final name of the PHP binary
        (eg. ``php-5.4.13-32bits``).

-   ``debug`` to compile a version with debugging symbols.

    ..  note::
        If specified, this flag appears in the final name of the PHP binary
        (eg. ``php-5.4.13-debug``).
        On the other hand, if this flag is not specified, the debugging symbols
        and other unnecessary data will be stripped from the binaries produced
        (resulting in slightly smaller binaries being installed).

-   ``gcov`` to enable GCOV code coverage information (requires LTP).

    ..  note::
        If specified, this flag appears in the final name of the PHP binary
        (eg. ``php-5.4.13-gcov``).

-   ``pear`` to install the pear/pecl utilities
    (useful if you plan to install packages from the
    `PHP Extension and Application Repository`__
    or extensions from the `PHP Extension Community Library`__).

    ..  note::
        For this to work, you also need to drop a copy of the
        `install-pear-nozlib.phar`__ archive in the ``bzips/`` folder.

         Users of PHP 5.5.0alpha1 and later may instead prefer `this link`__
         which includes a more up-to-date version of the ``Archive_Tar``
         package, as a workaround for `bug #63073`__.

-   ``suhosin`` to apply the Suhosin patch before compiling PHP.
    This patch provides several enhancements to build an hardened PHP binary.

    ..  note::
        If specified, this flag appears in the final name of the PHP binary
        (eg. ``php-5.4.13-suhosin``).

-   ``zts`` to enable the Zend Thread Safety mechanisms.

    ..  note::
        If specified, this flag appears in the final name of the PHP binary
        (eg. ``php-5.4.13-zts``).

__  http://pear.php.net/
__  http://pecl.php.net/
__  http://pear.php.net/install-pear-nozlib.phar
__  http://packages.erebot.net/install-pear-nozlib.phar
__  https://bugs.php.net/bug.php?id=63073

.. warning::
    The ``suhosin`` flag only applies the Suhosin patch. It does not
    automatically install the Suhosin extension. If you want to benefit
    from the whole set of attack mitigation techniques provided by Suhosin,
    you must also install the Suhosin extension separately (and manually),
    using a `post-install script`_

For example, to build a thread-safe version of PHP 5.3.1 with debugging
symbols, use::

    ./main.sh  5.3.1-zts-debug

..  note::
    The order in which the flags appear does not matter, phpfarm will
    reorganize them if needed. Hence, ``5.3.1-zts-debug`` is effectively
    the same as ``5.3.1-debug-zts``.

..  note::
    The order of the flags in the name of the final binary will always match
    the order in which they are listed above.
    Therefore, a PHP 5.4.13 binary with all the flags applied would be named
    ``php-5.4.13-32bits-debug-gcov-suhosin-zts``.
    Future versions of phpfarm will continue to use that same logic whenever
    new flags are added.


Bonus features
--------------
You may actually compile and install several versions of PHP in turn
by passing the name of each version to ``main.sh``::

    ./main.sh  5.3.1  5.4.0beta1

You may also create a file called ``custom/default-versions.txt``
which contains the names of the versions (one per line) you want
installed by default.
Empty lines are ignored in this file. Lines starting with a hash (#)
are treated as comments and also ignored.
This file will be used by ``./main.sh`` when it's called without any
argument and is mostly useful when you often need to recompile the same
versions of PHP (eg. as part of a Continuous Integration process).
It generally looks somewhat like this::

    # Generic version used for dev.
    5.3.1

    # Beta version used to test for regressions
    # and to report bugs to the PHP folks.
    5.4.0beta1

    # Custom version which installs specific extensions/packages
    # required for production during the post-install step.
    5.3.1-prod


Caveats
-------
The following entries are known issues which may or may not be solved
in the future:

-   Do not use ``--enable-sigchld`` in your custom options if you plan
    to install extensions using pear/pecl. When enabled, this option
    will result in a failure during the ``phpize`` step (this issue
    lies in PHP itself and is not specific to phpfarm).

-   The ``--with-pear=DIR`` configure option has been disabled on purpose
    and this behaviour cannot be changed using ``$configoptions``.
    If you want to create a (local) PEAR installation, drop a copy
    of http://pear.php.net/install-pear-nozlib.phar in the ``bzips/`` folder
    and then use the ``pear`` flag. The layout of the PEAR installation
    that is created matches the layout expected by the Pyrus package manager.

-   While this specific version of phpfarm strives to maintain compatibility
    with the original one, a few incompatible changes were made.
    These changes and the rationale behind them are listed below:

    -   Historically, this phpfarm created a symbolic link in the installation
        folder named ``main`` pointing to the "main PHP version" (the one you
        would usually add to your ``$PATH``).
        The original phpfarm later added a similar concept with a link named
        ``current-bin`` pointing to the main version's ``bin/`` directory.

        However, looking at the future, this link seems a little bit too
        restrictive as some binaries may also be installed in the ``sbin/``
        directory (eg. ``php-fpm``).

        Therefore, this version of phpfarm now uses a symbolic link named
        ``current`` (to roughly match the decision of the original phpfarm)
        pointing to the main version's root directory.

    -   The original phpfarm added a script named ``switch-phpfarm`` at some
        time to ease switching between different PHP versions.

        While this version has a similar script (derived from the original one),
        its output is formatted slightly differently: there is an additional
        space before the name of each installed version and an asterisk (\*)
        appears before the name of the currently active version.
        See `Switching default php versions`_ for an example of such output.


About phpfarm
-------------
Written by Christian Weiske, cweiske@cweiske.de
Additional changes by François Poirotte, clicky@erebot.net

Homepage: https://sourceforge.net/p/phpfarm

Licensed under the `AGPL v3`__ or later.
 
__ http://www.gnu.org/licenses/agpl

