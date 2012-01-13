find . -name "*.deb" -delete ; make package-external ; for p in beCommon beCollector beTapper beSplitter beSolr; do cd $p ; make package ; cd ..; done
