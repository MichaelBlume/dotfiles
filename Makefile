SVN=svn
NAME=loggly-homedirs
REVISION=$(shell $(SVN) info | awk '/Revision: / {print $$2}')
VERSION=$(REVISION).trunk

.PHONY: build
build:
	true

.PHONY: install
install:
	[ -d "$(DESTDIR)" ]
	install -d $(DESTDIR)/opt/homedirs
	rsync -avC --exclude .svn --exclude debian --exclude Makefile . $(DESTDIR)/opt/homedirs

.PHONY: deb
deb:
	rm -r debian || true
	dh_make -s -n -c blank -e $$USER -p "$(NAME)_$(VERSION)" < /dev/null
	install -m 755 postinst debian/
	debuild -uc -us

