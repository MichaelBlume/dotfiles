NAME=loggly-homedirs

.PHONY: artifact
artifact:
	true

.PHONY: deb
deb:
	sh /opt/loggly/buildtools/git/package.sh --prefix /opt/homedirs -C build/home  -n $(NAME)
