NAME=loggly-homedirs

.PHONY: artifact
artifact:
	true

.PHONY: deb
deb:
	sh /opt/loggly/buildtools/git/package.sh --prefix /opt/homedirs -C build  -n $(NAME)
#	fpm -s dir -t deb --prefix "/opt/loggly/loggly-homedirs" -n loggly-homedirs -v $pkgversion -C $dir "$@"
