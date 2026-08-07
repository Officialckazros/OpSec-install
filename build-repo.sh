#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APT_REPO_DIR="${SCRIPT_DIR}/apt-repo"

mkdir -p "${APT_REPO_DIR}"

chmod 755 "${SCRIPT_DIR}/opsec/DEBIAN/postinst" "${SCRIPT_DIR}/opsec/DEBIAN/prerm" "${SCRIPT_DIR}/opsec/usr/bin/"* "${SCRIPT_DIR}/opsec/usr/local/sbin/"* 2>/dev/null || true
chmod 755 "${SCRIPT_DIR}/opsec-software/DEBIAN/postinst" "${SCRIPT_DIR}/opsec-software/DEBIAN/prerm" "${SCRIPT_DIR}/opsec-software/usr/bin/opsec-software" 2>/dev/null || true
chmod 755 "${SCRIPT_DIR}/opsec-de/DEBIAN/postinst" "${SCRIPT_DIR}/opsec-de/DEBIAN/prerm" "${SCRIPT_DIR}/opsec-de/usr/bin/"* 2>/dev/null || true
chmod 755 "${SCRIPT_DIR}/add-repo.sh" "${SCRIPT_DIR}/install.sh" "${SCRIPT_DIR}/setup.sh" "${SCRIPT_DIR}/iso-builder/build-iso.sh" 2>/dev/null || true

# Ensure control file permissions are correct for dpkg-deb (it insists on 0755 for
# maintainer scripts and refuses world-writable control dirs).
for pkg in opsec opsec-software opsec-de; do
    find "${SCRIPT_DIR}/${pkg}/DEBIAN" -type f -exec chmod 644 {} \;
    for script in postinst postrm preinst prerm; do
        if [ -f "${SCRIPT_DIR}/${pkg}/DEBIAN/${script}" ]; then
            chmod 755 "${SCRIPT_DIR}/${pkg}/DEBIAN/${script}"
        fi
    done
done

# Build real, spec-compliant .deb archives with dpkg-deb instead of a hand-rolled
# ar writer. dpkg-deb handles compression, permissions, and ar formatting correctly.
build_deb() {
    local pkg_dir="$1"
    local output_deb="$2"
    fakeroot dpkg-deb --build --root-owner-group "${pkg_dir}" "${output_deb}" \
        || dpkg-deb --build --root-owner-group "${pkg_dir}" "${output_deb}"
}

build_deb "${SCRIPT_DIR}/opsec" "${APT_REPO_DIR}/opsec_1.0.0_all.deb"
build_deb "${SCRIPT_DIR}/opsec-software" "${APT_REPO_DIR}/opsec-software_1.0.0_all.deb"
build_deb "${SCRIPT_DIR}/opsec-de" "${APT_REPO_DIR}/opsec-de_1.0.0_all.deb"

# Generate a spec-correct Packages index (with SHA256/MD5Sum/SHA1) and a signed-less
# Release file using apt-ftparchive, the standard Debian repo indexing tool. Without
# checksums, modern apt refuses to fetch .deb files even with [trusted=yes].
cd "${APT_REPO_DIR}"
rm -f Packages Packages.gz Release InRelease

apt-ftparchive packages . > Packages
gzip -9c Packages > Packages.gz

cat > apt-ftparchive-release.conf <<EOF
APT::FTPArchive::Release::Origin "OpSec-install";
APT::FTPArchive::Release::Label "OpSec";
APT::FTPArchive::Release::Suite "stable";
APT::FTPArchive::Release::Codename "opsec";
APT::FTPArchive::Release::Architectures "all amd64";
APT::FTPArchive::Release::Description "OpSec APT repository";
EOF

apt-ftparchive -c apt-ftparchive-release.conf release . > Release
rm -f apt-ftparchive-release.conf

exit 0
