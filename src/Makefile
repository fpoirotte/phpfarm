#!/usr/bin/env make
# vim:ft=make noexpandtab:

INSTALLED_VERSION := $(wildcard ../inst/php-*)
COMPILED_VERSION := $(wildcard php-*)


all:
	MAKE_OPTIONS="$(MAKEFLAGS)" ./main.sh

0% 1% 2% 3% 4% 5% 6% 7% 8% 9%:
	MAKE_OPTIONS="$(MAKEFLAGS)" ./main $@

clean:
	$(RM) -r $(INSTALLED_VERSIONS) $(COMPILED_VERSIONS)

switch:
	test -n $(VERSION)
	../inst/bin/switch-phpfarm $(VERSION)

key-%:
	wget -O- 'https://pgp.mit.edu/pks/lookup?op=get&search=0x$*' | \
		gpg --no-default-keyring --primary-keyring ./php.gpg --import -

keys:
	gpg --no-default-keyring --primary-keyring ./php.gpg --list-keys

.PHONY: all clean switch keys
