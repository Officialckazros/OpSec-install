PACKAGE = opsec
VERSION = 1.0.0
ARCH = all
DEB = $(PACKAGE)_$(VERSION)_$(ARCH).deb

all: build-repo

build:
	chmod +x opsec/DEBIAN/postinst opsec/DEBIAN/prerm opsec/usr/bin/opsec opsec-software/DEBIAN/postinst opsec-software/DEBIAN/prerm opsec-software/usr/bin/opsec-software setup.sh install.sh add-repo.sh build-repo.sh
	./build-repo.sh

build-repo: build

install-repo: build-repo
	./setup.sh

install: build-repo
	./install.sh

clean:
	rm -rf apt-repo *.deb

.PHONY: all build build-repo install-repo install clean
