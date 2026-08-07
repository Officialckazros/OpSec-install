PACKAGE = opsec
VERSION = 1.0.0
ARCH = all
DEB = $(PACKAGE)_$(VERSION)_$(ARCH).deb
ISO = opsecOS-1.0.0-amd64.iso

all: build-repo

build:
	chmod +x opsec/DEBIAN/postinst opsec/DEBIAN/prerm opsec/usr/bin/opsec opsec/usr/bin/opsec-launch opsec/usr/bin/opsec-software-install opsec/usr/local/sbin/*.sh opsec-software/DEBIAN/postinst opsec-software/DEBIAN/prerm opsec-software/usr/bin/opsec-software opsec-de/DEBIAN/postinst opsec-de/DEBIAN/prerm opsec-de/usr/bin/* setup.sh install.sh add-repo.sh build-repo.sh iso-builder/build-iso.sh opsec-os/security/*.sh opsec-os/desktop/*.sh tools/*.py
	./build-repo.sh

build-repo: build

iso:
	chmod +x iso-builder/build-iso.sh
	sudo ./iso-builder/build-iso.sh

docker-iso:
	chmod +x iso-builder/docker-build-iso.sh
	./iso-builder/docker-build-iso.sh

install-repo: build-repo
	./setup.sh

install: build-repo
	./install.sh

clean:
	rm -rf apt-repo *.deb *.iso

.PHONY: all build build-repo iso install-repo install clean
