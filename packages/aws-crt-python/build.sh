# shellcheck shell=bash
# shellcheck disable=SC2034
TERMUX_PKG_HOMEPAGE=https://github.com/awslabs/aws-crt-python
TERMUX_PKG_DESCRIPTION="Python Bindings for the AWS Common Runtime"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="0.19.19"
TERMUX_PKG_SRCURL=git+$TERMUX_PKG_HOMEPAGE
TERMUX_PKG_SHA256="SKIP_CHECKSUM"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"
TERMUX_PKG_SETUP_PYTHON=true

termux_step_post_get_source() {
	python3 "$TERMUX_PKG_SRCDIR/continuous-delivery/update-version.py"
}

termux_step_configure() {
	termux_setup_cmake
}

termux_step_make_install() {
	local toolchain_file
	toolchain_file="$(mktemp -p "$TERMUX_PKG_TMPDIR" "aws-crt-python.XXXXXX.cmake")"
	cat <<-EOF >"$toolchain_file"
		set(CMAKE_SYSTEM_NAME "Android")
		set(CMAKE_SYSTEM_PROCESSOR "${TERMUX_ARCH}")
		set(CMAKE_ANDROID_NDK "${NDK}")
	EOF
	CMAKE_TOOLCHAIN_FILE="$toolchain_file" pip3 install --no-binary :all: --verbose "$TERMUX_PKG_SRCDIR" --prefix "$TERMUX_PREFIX" || {
		rm -f "$toolchain_file"
		termux_error_exit "Failed to install $TERMUX_PKG_NAME"
	}
	rm -f "$toolchain_file"
}
