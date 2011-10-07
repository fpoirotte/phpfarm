phpfarm
=======

Set of scripts to install a dozen of PHP versions in parallel on a system.
It also creates a Pyrus installation for each PHP version.
Primarily developed for PEAR's continuous integration machine.

The PHP source packages are fetched from ``museum.php.net`` (which is not
always up-to-date), the official php.net download pages and the
pre-release channels.
If a file cannot be found, try to fetch it manually and put it into
``src/bzips/``.


Setup
-----
- Check out phpfarm from git:
  ``git clone git://git.code.sf.net/p/phpfarm/code phpfarm``
- ``cd phpfarm/src/``
- ``./compile.sh 5.3.0``
- PHP gets installed into ``phpfarm/inst/php-$version/``
- ``phpfarm/inst/bin/php-$version`` is also executable
  You should add ``inst/bin`` to your ``$PATH``, i.e.
  ``PATH="$PATH:$HOME/phpfarm/inst/bin"`` in ``.bashrc``


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


Bonus features
--------------
You may actually compile and install several versions of PHP in turn
by passing the name of each version to ``compile.sh``::

    ``./compile.sh  5.3.1  5.4.0beta1``

You may also create a file called ``custom/default-versions.txt``
which contains the names of the versions (one per line) you want
installed by default.
Empty lines are ignored in this file. Lines starting with a hash (#)
are treated as comments and also ignored.
This file will be used by ``./compile.sh`` when it's called without any
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

- Do not use ``--enable-sigchld`` in your custom options if you plan
  to install extensions using pear/pecl. When enabled, this option
  will result in a failure during the ``phpize`` step (this issue
  lies in PHP itself and is not specific to phpfarm).

- By default, a (local) PEAR installation is created for every PHP version
  you build. If you don't plan to use PEAR, you can prevent this from
  happening by adding ``--without-pear`` to your ``$configoptions``.
