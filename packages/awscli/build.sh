#shellcheck shell=bash
# shellcheck disable=SC2034
# shellcheck disable=SC1091

TERMUX_PKG_HOMEPAGE=https://aws.amazon.com/cli
TERMUX_PKG_DESCRIPTION="A Unified Tool to Manage Your AWS Services"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="2.15.21"
TERMUX_PKG_SRCURL="https://awscli.amazonaws.com/awscli-${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256="SKIP_CHECKSUM" # verified using gpg signatures instead
TERMUX_PKG_BUILD_DEPENDS="python, python-pip"
TERMUX_PKG_SETUP_PYTHON=true
# TERMUX_PKG_PYTHON_COMMON_DEPS="setuptools>=62.4, setuptools_rust, cffi, wheel"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--prefix=$TERMUX_PREFIX
--with-install-type=portable-exe
--with-download-deps
"

TERMUX_PKG_AUTO_UPDATE=true

_import_awscli_pgp_key() {

    # This key expired 2023-09-17 but it is still in use
    # Found at https://docs.aws.amazon.com/cli/latest/userguide/getting-started-source-install.html#source-getting-started-install-reqs
    cat <<EOF | gpg --import -
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBF2Cr7UBEADJZHcgusOJl7ENSyumXh85z0TRV0xJorM2B/JL0kHOyigQluUG
ZMLhENaG0bYatdrKP+3H91lvK050pXwnO/R7fB/FSTouki4ciIx5OuLlnJZIxSzx
PqGl0mkxImLNbGWoi6Lto0LYxqHN2iQtzlwTVmq9733zd3XfcXrZ3+LblHAgEt5G
TfNxEKJ8soPLyWmwDH6HWCnjZ/aIQRBTIQ05uVeEoYxSh6wOai7ss/KveoSNBbYz
gbdzoqI2Y8cgH2nbfgp3DSasaLZEdCSsIsK1u05CinE7k2qZ7KgKAUIcT/cR/grk
C6VwsnDU0OUCideXcQ8WeHutqvgZH1JgKDbznoIzeQHJD238GEu+eKhRHcz8/jeG
94zkcgJOz3KbZGYMiTh277Fvj9zzvZsbMBCedV1BTg3TqgvdX4bdkhf5cH+7NtWO
lrFj6UwAsGukBTAOxC0l/dnSmZhJ7Z1KmEWilro/gOrjtOxqRQutlIqG22TaqoPG
fYVN+en3Zwbt97kcgZDwqbuykNt64oZWc4XKCa3mprEGC3IbJTBFqglXmZ7l9ywG
EEUJYOlb2XrSuPWml39beWdKM8kzr1OjnlOm6+lpTRCBfo0wa9F8YZRhHPAkwKkX
XDeOGpWRj4ohOx0d2GWkyV5xyN14p2tQOCdOODmz80yUTgRpPVQUtOEhXQARAQAB
tCFBV1MgQ0xJIFRlYW0gPGF3cy1jbGlAYW1hem9uLmNvbT6JAlQEEwEIAD4WIQT7
Xbd/1cEYuAURraimMQrMRnJHXAUCXYKvtQIbAwUJB4TOAAULCQgHAgYVCgkICwIE
FgIDAQIeAQIXgAAKCRCmMQrMRnJHXJIXEAChLUIkg80uPUkGjE3jejvQSA1aWuAM
yzy6fdpdlRUz6M6nmsUhOExjVIvibEJpzK5mhuSZ4lb0vJ2ZUPgCv4zs2nBd7BGJ
MxKiWgBReGvTdqZ0SzyYH4PYCJSE732x/Fw9hfnh1dMTXNcrQXzwOmmFNNegG0Ox
au+VnpcR5Kz3smiTrIwZbRudo1ijhCYPQ7t5CMp9kjC6bObvy1hSIg2xNbMAN/Do
ikebAl36uA6Y/Uczjj3GxZW4ZWeFirMidKbtqvUz2y0UFszobjiBSqZZHCreC34B
hw9bFNpuWC/0SrXgohdsc6vK50pDGdV5kM2qo9tMQ/izsAwTh/d/GzZv8H4lV9eO
tEis+EpR497PaxKKh9tJf0N6Q1YLRHof5xePZtOIlS3gfvsH5hXA3HJ9yIxb8T0H
QYmVr3aIUes20i6meI3fuV36VFupwfrTKaL7VXnsrK2fq5cRvyJLNzXucg0WAjPF
RrAGLzY7nP1xeg1a0aeP+pdsqjqlPJom8OCWc1+6DWbg0jsC74WoesAqgBItODMB
rsal1y/q+bPzpsnWjzHV8+1/EtZmSc8ZUGSJOPkfC7hObnfkl18h+1QtKTjZme4d
H17gsBJr+opwJw/Zio2LMjQBOqlm3K1A4zFTh7wBC7He6KPQea1p2XAMgtvATtNe
YLZATHZKTJyiqA==
=vYOk
-----END PGP PUBLIC KEY BLOCK-----
EOF

}

termux_pkg_auto_update() {
    local tarball
    local sig
    local version

    _import_awscli_pgp_key

    tarball="$(mktemp -p "$TERMUX_PKG_TMPDIR" "awscli.XXXXXX.tar.gz")"
    sig="$(mktemp -p "$TERMUX_PKG_TMPDIR" "awscli.XXXXXX.sig")"
    wget -O "$tarball" https://awscli.amazonaws.com/awscli.tar.gz
    wget -O "$sig" https://awscli.amazonaws.com/awscli.tar.gz.sig

    if ! gpg --verify "$sig" "$tarball"; then
        rm -f "$sig"
        rm -f "$tarball"
        termux_error_exit "Error: failed to validate upstream source code"
    fi

    rm -f "$sig"

    version="$(tar tzf "$tarball" | head -n 1 | grep -oP "\d+\.\d+\.\d+")"

    rm -f "$tarball"

    if [ -z "$version" ]; then
        termux_error_exit "Error: failed to extract latest version"
    fi

    if [ "$TERMUX_PKG_VERSION" != "$version" ]; then
        termux_pkg_upgrade_version "$version" --skip-version-check
    fi
}

termux_step_get_source() {
    local tarball
    local sig

    _import_awscli_pgp_key

    tarball="$(mktemp -p "$TERMUX_PKG_TMPDIR" "awscli.XXXXXX.tar.gz")"
    sig="$(mktemp -p "$TERMUX_PKG_TMPDIR" "awscli.XXXXXX.sig")"

    wget -O "$tarball" "$TERMUX_PKG_SRCURL"
    wget -O "$sig" "$TERMUX_PKG_SRCURL.sig"

    if ! gpg --verify "$sig" "$tarball"; then
        rm -f "$sig"
        rm -f "$tarball"
        termux_error_exit "Error: failed to validate upstream source code"
    fi

    rm -f "$sig"

    mkdir -p "$TERMUX_PKG_SRCDIR"

    tar --strip-components=1 -xf "$tarball" -C "$TERMUX_PKG_SRCDIR"

    rm -f "$tarball"
}

termux_step_pre_configure() {
    # CFLAGS+=" -Wno-incompatible-function-pointer-types"
    # termux_setup_cmake
    # termux_setup_rust
    # termux_setup_python_pip

    echo -e "\n$(python --version)\n"
    python -m venv "$TERMUX_PKG_TMPDIR/awscli-venv"
    echo -e "\n$(pip --version)\n"

    # pip3 install \
    #     'flit_core>=3.7.1,<3.9.1' \
    #     'colorama>=0.2.5,<0.4.7' \
    #     'docutils>=0.10,<0.20' \
    #     'cryptography>=3.3.2,<40.0.2' \
    #     'ruamel.yaml>=0.15.0,<=0.17.21' \
    #     'prompt-toolkit>=3.0.24,<3.0.39' \
    #     'distro>=1.5.0,<1.9.0' \
    #     'awscrt>=0.19.18,<=0.19.19' \
    #     'python-dateutil>=2.1,<3.0.0' \
    #     'jmespath>=0.7.1,<1.1.0' \
    #     'urllib3>=1.25.4,<1.27' \
    #     'pyinstaller==5.12.0' # 'ruamel.yaml.clib>=0.2.0,<=0.2.7' \

    # pip install "$TERMUX_PKG_SRCDIR"

    exit 1
}
