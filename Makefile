PACKAGE = opsec
VERSION = 1.0.0
ARCH = all
DEB = $(PACKAGE)_$(VERSION)_$(ARCH).deb
ISO = opsecOS-1.0.0-amd64.iso

all: build-repo iso

build:
	chmod +x opsec/DEBIAN/postinst opsec/DEBIAN/prerm opsec/usr/bin/opsec opsec-software/DEBIAN/postinst opsec-software/DEBIAN/prerm opsec-software/usr/bin/opsec-software setup.sh install.sh add-repo.sh build-repo.sh iso-builder/build-iso.sh opsec-os/security/*.sh opsec-os/desktop/*.sh
	./build-repo.sh

build-repo: build

iso:
	chmod +x iso-builder/build-iso.sh
	./iso-builder/build-iso.sh

install-repo: build-repo
	./setup.sh

install: build-repo
	./install.sh

clean:
	rm -rf apt-repo *.deb *.iso

.PHONY: all build build-repo iso install-repo install clean
