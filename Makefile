NAME=loggly-homedirs
REVISION=$(shell svn info | awk '/Revision: / {print $$2}')
VERSION=$(REVISION).trunk

.PHONY: build
build:
	true

.PHONY: install
install:
	[ -d "$(DESTDIR)" ]
	install -d $(DESTDIR)/opt/homedirs
	rsync -avC --exclude .svn . $(DESTDIR)/opt/homedirs

.PHONY: deb
deb:
	rm -r debian || true
	dh_make -s -n -c blank -e $$USER -p "$(NAME)_$(VERSION)"
	install -m 755 postinst debian/
	debuild -uc -us

