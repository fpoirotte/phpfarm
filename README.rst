phpfarm
=======

**WARNING:** as of 2021, PHPFarm is not actively maintained anymore.
Existing users should transition to alternative solutions instead:

* Debian Linux provides co-installable packages (`php7.4`, `php8.1`, `php8.2`, etc.)
* Fedora Linux / Enterprise Linux users may refer to Remi Collet's repository (https://rpms.remirepo.net/wizard/)
* etc.


phpfarm is a set of scripts to install a dozen of PHP versions in parallel
on a single system. It also installs the pear and pyrus installers and
creates a local Pyrus installation for each PHP version as well.

This tool was primarily developed for PEAR's continuous integration machine.

The PHP source packages are fetched from http://museum.php.net/ (which is not
always up-to-date), the official php.net download pages and the pre-release
channels.

The Pyrus PHAR archive is fetched from http://pear2.php.net/pyrus.phar (which
always refers the latest version).

If a file cannot be found, try to fetch it manually and put it into
``src/bzips/``.


Setup
-----
- Check out phpfarm from git:
  ``git clone https://github.com/fpoirotte/phpfarm.git phpfarm``
- ``cd phpfarm/src/``
- ``./main.sh 5.3.0``
- PHP gets installed into ``phpfarm/inst/php-$version/bin/php``
  and a symbolic link to it is created in ``phpfarm/inst/bin/php-$version``.

You should consider adding ``inst/bin``, ``inst/current/bin`` and
``inst/current/sbin`` to your ``$PATH``, i.e. append
``PATH="$HOME/phpfarm/inst/bin:$HOME/phpfarm/inst/current/bin:$HOME/phpfarm/inst/current/sbin:$PATH"``
to your ``.bashrc`` or similar file.


Configure options customization
-------------------------------
Default configuration options are in ``src/options.sh``.
You may create version-specific custom option files:

- ``src/custom/options.sh``
- ``src/custom/options-<major>.sh``
- ``src/custom/options-<major>.<minor>.sh``
- ``src/custom/options-<major>.<minor>.<patch>.sh``
- ``src/custom/options-<major>.<minor>.<patch>-<flags>.sh``

Where:

- ``<major>`` is the version's major number (eg. "5" for PHP 5.3.1).
- ``<minor>`` is the version's minor number (eg. "3" for PHP 5.3.1).
- ``<patch>`` is the version's patch number (eg. "1" for PHP 5.3.1).
- ``<flag>`` matches the specific compilation/installation flags (if any)
  for that PHP version. See `Special flags in version strings`_
  for information on supported flags. The flags should appear in the exact
  same order as listed in that chapter for this to work.

The shell script needs to define a variable named ``$configoptions`` with
all ``./configure`` options.
Do not try to change ``prefix`` and ``exec-prefix``.


Switching default php versions
------------------------------
We recommend that you add the ``inst/bin`` directory to your ``$PATH``
to make the ``switch-phpfarm`` command always available.
See `Setup`_ for more information on how to configure your ``$PATH``.

Using the ``switch-phpfarm`` command, you can make one of the installed
PHP versions the default one that gets run when just typing ``php``::

    $ switch-phpfarm
    Switch the currently active PHP version of phpfarm
    Available versions:
    * 5.2.17
      5.3.16
      5.4.6

    $ switch-phpfarm 5.4.6
    Setting active PHP version to 5.4.6
    PHP 5.4.6 (cli) (built: Sep 13 2012 11:24:56)

    $ switch-phpfarm
    Switch the currently active PHP version of phpfarm
    Available versions:
      5.2.17
      5.3.16
    * 5.4.6

We also provide a completion script compatible with both Bash & ZSH
to make ``switch-phpfarm`` auto-complete its arguments.
To use it, first make sure that ``inst/bin`` is in your ``$PATH``
(see `Setup`_ for more information on how to configure your ``$PATH``.)

Then, for Bash: simply copy ``src/phpfarm.autocomplete`` to ``/etc/bash_completion.d/phpfarm`` as root.

For ZSH:

- Copy ``src/phpfarm.autocomplete`` to ``/usr/local/share/zsh/site-functions/_phpfarm``
  (or another directory in your configuration's ``fpath``) as root

- Add this line to ``~/.zshrc`` right after the call to ``compinit``:
  ``compdef _phpfarm switch-phpfarm``

php.ini customization
---------------------
The final ``php.ini`` configuration file is made from several pieces:

- First, the default development configuration (found in ``php.ini-development``
  for PHP 5.3.0 or later, and ``php.ini-recommended`` in prior versions)
  gets copied to the location of the final configuration file.
- Then, the contents of the files listed below is appended at the end of that
  file to obtain the final configuration file:

  - ``src/custom/php.ini`` (initialized from a copy of
    ``src/default-custom-php.ini`` if it does not already exist)
  - ``src/custom/php-<major>.ini``
  - ``src/custom/php-<major>.<minor>.ini``
  - ``src/custom/php-<major>.<minor>.<patch>.ini``
  - ``src/custom/php-<major>.<minor>.<patch>-<flags>.ini``

  Where:

  - ``<major>`` is the version's major number (eg. "5" for PHP 5.3.1).
  - ``<minor>`` is the version's minor number (eg. "3" for PHP 5.3.1).
  - ``<patch>`` is the version's patch number (eg. "1" for PHP 5.3.1).
  - ``<flag>`` matches the specific compilation/installation flags (if any)
    for that PHP version. See `Special flags in version strings`_
    for information on supported flags. The flags should appear in the exact
    same order as listed in that chapter for this to work.

Please note that a few substitutions are done in those files in order
to generate the final ``php.ini`` configuration file. Namely, the following
variables are substitued:

- ``$ext_dir`` gets replaced by the path to the extension directory
  This is mostly used to set the ``extension_dir`` option to the right
  value.
  This is also useful when installing a ``zend_extension`` like
  Xdebug as the contents of ``extension_dir`` is not used to locate
  those extensions.
- ``$install_dir`` gets replaced by the path to the installation directory
  of that specific PHP version (eg. ``/home/me/phpfarm/inst/php-5.3.1``).

.. _`post-install script`:

Post-install customization
--------------------------
You may also create version-specific scripts that will be run after
the PHP binary has been successfully compiled, installed and configured:

- ``src/custom/post-install.sh``
- ``src/custom/post-install-<major>.sh``
- ``src/custom/post-install-<major>.<minor>.sh``
- ``src/custom/post-install-<major>.<minor>.<patch>.sh``
- ``src/custom/post-install-<major>.<minor>.<patch>-<flags>.sh``

Where:

- ``<major>`` is the version's major number (eg. "5" for PHP 5.3.1).
- ``<minor>`` is the version's minor number (eg. "3" for PHP 5.3.1).
- ``<patch>`` is the version's patch number (eg. "1" for PHP 5.3.1).
- ``<flag>`` matches the specific compilation/installation flags (if any)
  for that PHP version. See `Special flags in version strings`_
  for information on supported flags. The flags should appear in the exact
  same order as listed in that chapter for this to work.

These scripts can be used for example to discover PEAR channels
and pre-install some extensions/packages needed by your project.

Each script is called with three arguments:

- The PHP version that was just installed (eg. ``5.3.1-zts-debug``).
- The full path to the folder where that version was install
  (eg. ``/home/clicky/phpfarm/inst/php-5.3.1-zts-debug/``).
- The full path to the shared folder containing the links to the main
  executables for each version (eg. ``/home/clicky/phpfarm/inst/bin/``).

Please note that a "shebang line" (``#!...``) is not required at the beginning
of those scripts. Bash will always be used to execute them.

Given all the previous bits of information, the following shell script may
be used to discover a PEAR channel and install a PEAR extension::

    # "$3/pear-$1" could also be used in place of "$2/bin/pear"
    # (both refer to the pear installer for this specific version of PHP).
    "$2/bin/pear" channel-discover pear.phpunit.de
    "$2/bin/pear" install pear.phpunit.de/PHPUnit

    # The exit status must be 0 when the scripts terminates without any error.
    # Any other value will be treated as an error.
    exit 0

..  warning::

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
    `PHP Extension and Application Repository`_
    or extensions from the `PHP Extension Community Library`_).

    ..  note::

        For this to work, you also need to drop a copy of the
        `install-pear-nozlib.phar`_ archive in the ``bzips/`` folder.
        If specified, this flag **will not** appear in the final name
        of the PHP binary.

-   ``zts`` to enable the Zend Thread Safety mechanisms.

    ..  note::

        If specified, this flag appears in the final name of the PHP binary
        (eg. ``php-5.4.13-zts``).

..  _`PHP Extension and Application Repository`:
    http://pear.php.net/
..  _`PHP Extension Community Library`:
    http://pecl.php.net/
..  _`install-pear-nozlib.phar`:
    http://pear.php.net/install-pear-nozlib.phar

For example, to build a thread-safe version of PHP 5.3.1 with debugging
symbols, use::

    ./main.sh  5.3.1-zts-debug

..  note::

    The order in which the flags appear on the command line does not matter,
    phpfarm will reorganize them if needed. Hence, ``5.3.1-zts-debug``
    is effectively the same as ``5.3.1-debug-zts``.

..  note::

    The order of the flags in the name of the final binary will always match
    the order in which they are listed above.
    Therefore, a PHP 5.4.13 binary with all the flags applied would be named
    ``php-5.4.13-32bits-debug-gcov-zts``.
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

Last but not least, you may pass options to the ``make`` program by setting
the ``MAKE_OPTIONS`` environment variable (eg. ``MAKE_OPTIONS="-j3"``).


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

    -   Historically, this version of phpfarm created a symbolic link
        in the installation folder named ``main`` pointing to the
        "main PHP version" (the one you would usually add to your ``$PATH``).
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

