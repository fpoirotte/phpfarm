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


.PHONY: all clean switch
