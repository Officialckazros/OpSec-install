PACKAGE = opsec-software
VERSION = 1.0.0
ARCH = all
DEB = $(PACKAGE)_$(VERSION)_$(ARCH).deb

all: build

build:
	chmod +x opsec-software/DEBIAN/postinst opsec-software/DEBIAN/prerm opsec-software/usr/bin/opsec-software setup.sh install.sh
	dpkg-deb --build opsec-software $(DEB)

install-repo: build
	./setup.sh

install: build
	./install.sh

clean:
	rm -f *.deb

.PHONY: all build install-repo install clean
