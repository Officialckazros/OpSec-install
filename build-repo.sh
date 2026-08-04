#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR
APT_REPO_DIR="${SCRIPT_DIR}/apt-repo"
export APT_REPO_DIR

mkdir -p "${APT_REPO_DIR}"

chmod 755 "${SCRIPT_DIR}/opsec/DEBIAN/postinst" "${SCRIPT_DIR}/opsec/DEBIAN/prerm" "${SCRIPT_DIR}/opsec/usr/bin/opsec" 2>/dev/null || true
chmod 755 "${SCRIPT_DIR}/opsec-software/DEBIAN/postinst" "${SCRIPT_DIR}/opsec-software/DEBIAN/prerm" "${SCRIPT_DIR}/opsec-software/usr/bin/opsec-software" 2>/dev/null || true
chmod 755 "${SCRIPT_DIR}/add-repo.sh" "${SCRIPT_DIR}/install.sh" "${SCRIPT_DIR}/setup.sh" 2>/dev/null || true

python3 -c '
import os, sys, tarfile, io

def build_deb(pkg_dir, output_deb):
    control_dir = os.path.join(pkg_dir, "DEBIAN")
    control_tar_buf = io.BytesIO()
    with tarfile.open(fileobj=control_tar_buf, mode="w:gz") as tar:
        for root, dirs, files in os.walk(control_dir):
            for file in files:
                full_path = os.path.join(root, file)
                rel_path = "./" + os.path.relpath(full_path, control_dir)
                ti = tar.gettarinfo(full_path, arcname=rel_path)
                ti.uid = 0
                ti.gid = 0
                ti.uname = "root"
                ti.gname = "root"
                if file in ["postinst", "prerm"]:
                    ti.mode = 0o755
                else:
                    ti.mode = 0o644
                with open(full_path, "rb") as f:
                    tar.addfile(ti, f)
    control_tar_bytes = control_tar_buf.getvalue()

    data_tar_buf = io.BytesIO()
    with tarfile.open(fileobj=data_tar_buf, mode="w:gz") as tar:
        for root, dirs, files in os.walk(pkg_dir):
            if "DEBIAN" in root.split(os.sep):
                continue
            for file in files:
                full_path = os.path.join(root, file)
                rel_path = "./" + os.path.relpath(full_path, pkg_dir)
                ti = tar.gettarinfo(full_path, arcname=rel_path)
                ti.uid = 0
                ti.gid = 0
                ti.uname = "root"
                ti.gname = "root"
                if "bin" in root.split(os.sep):
                    ti.mode = 0o755
                else:
                    ti.mode = 0o644
                with open(full_path, "rb") as f:
                    tar.addfile(ti, f)
    data_tar_bytes = data_tar_buf.getvalue()

    debian_binary = b"2.0\n"

    def ar_header(name, size):
        return f"{name:<16}{1000000000:<12}{0:<6}{0:<6}{100644:<8}{size:<10}`\n".encode("ascii")

    with open(output_deb, "wb") as f:
        f.write(b"!<arch>\n")
        f.write(ar_header("debian-binary", len(debian_binary)))
        f.write(debian_binary)
        if len(debian_binary) % 2 != 0:
            f.write(b"\n")
        f.write(ar_header("control.tar.gz", len(control_tar_bytes)))
        f.write(control_tar_bytes)
        if len(control_tar_bytes) % 2 != 0:
            f.write(b"\n")
        f.write(ar_header("data.tar.gz", len(data_tar_bytes)))
        f.write(data_tar_bytes)
        if len(data_tar_bytes) % 2 != 0:
            f.write(b"\n")

script_dir = os.environ["SCRIPT_DIR"]
apt_repo_dir = os.environ["APT_REPO_DIR"]

build_deb(os.path.join(script_dir, "opsec"), os.path.join(apt_repo_dir, "opsec_1.0.0_all.deb"))
build_deb(os.path.join(script_dir, "opsec-software"), os.path.join(apt_repo_dir, "opsec-software_1.0.0_all.deb"))
'

OPSEC_SIZE=$(stat -f%z "${APT_REPO_DIR}/opsec_1.0.0_all.deb" 2>/dev/null || stat -c%s "${APT_REPO_DIR}/opsec_1.0.0_all.deb" 2>/dev/null || echo "2048")
OPSEC_SW_SIZE=$(stat -f%z "${APT_REPO_DIR}/opsec-software_1.0.0_all.deb" 2>/dev/null || stat -c%s "${APT_REPO_DIR}/opsec-software_1.0.0_all.deb" 2>/dev/null || echo "2048")

cat <<EOF > "${APT_REPO_DIR}/Packages"
Package: opsec
Version: 1.0.0
Architecture: all
Maintainer: ckazros <officialckazros@gmail.com>
Filename: opsec_1.0.0_all.deb
Size: ${OPSEC_SIZE}
Description: Complete OpSec suite containing Mullvad VPN, Mullvad Browser, and Proton Mail.

Package: opsec-software
Version: 1.0.0
Architecture: all
Maintainer: ckazros <officialckazros@gmail.com>
Filename: opsec-software_1.0.0_all.deb
Size: ${OPSEC_SW_SIZE}
Description: Complete OpSec software suite containing Mullvad VPN, Mullvad Browser, and Proton Mail.
EOF

gzip -9c "${APT_REPO_DIR}/Packages" > "${APT_REPO_DIR}/Packages.gz"

exit 0
