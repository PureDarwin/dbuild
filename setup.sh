# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= #
# PureDarwin - setup.sh                                                         #
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= #
# This script should be sourced into the user's terminal to setup the build     #
#   environment for PureDarwin, including optionally setting environment        #
#   variables and copying build scripts to the proper location.                 #
# This includes installing the `rc` command into the host tools directory,      #
#   and updating the user's path to include the host tools bin/ directory.      #
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= #

# Basic host detection
if [ -z "${RC_HOST_ARCH}" ]; then
    export RC_HOST_ARCH=$(uname -m)
fi

if [ -z "${RC_HOST_TYPE}" ]; then
    export RC_HOST_TYPE=$(uname -s)
fi

# Setup host-dependent variables/perform host-dependent checks
case ${RC_HOST_TYPE} in
    "Darwin")
        if [ -z "${RC_DARWIN_ROOT}" ]; then
            # Darwin doesn't have readlink -f
            export RC_DARWIN_ROOT="$(pwd -P)"
        fi

        if [ -z "${RC_BUILD_JOBS}" ]; then
            # TODO: Tune this
            export RC_BUILD_JOBS=1
        fi

        ;;
    "Linux")
        if [ -z "${RC_DARWIN_ROOT}" ]; then
            export RC_DARWIN_ROOT="$(readlink -f ${PWD})"
        fi

        if [ -z "${RC_BUILD_JOBS}" ]; then
            # TODO: Tune this
            export RC_BUILD_JOBS=1
        fi

        ;;
    *)
        echo "Unsupported host system type '${RC_HOST_TYPE}'!"

        unset RC_HOST_ARCH
        unset RC_HOST_TYPE

        return
        ;;
esac

# Set various variables for the build system to use.
# These can be manually overwritten by the user, always check before overwriting
#   preexisting variables.
if [ -z "${RC_BUILD_ROOT}" ]; then
    export RC_BUILD_ROOT="${RC_DARWIN_ROOT}/build"
fi

# PureDarwin system sources go here
if [ -z "${RC_SOURCE_DIR}" ]; then
    export RC_SOURCE_DIR="${RC_DARWIN_ROOT}/src"
fi

if [ -z "${RC_PRODUCT_DIR}" ]; then
    export RC_PRODUCT_DIR="${RC_DARWIN_ROOT}/products"
fi

if [ -z "${RC_SYSTEM_ROOT}" ]; then
    export RC_SYSTEM_ROOT="${RC_PRODUCT_DIR}/root"
fi

# Host tool sources needed for the build go here
# These get built first into ${RC_HOST_BIN} before the system build starts.
# We update the user's $PATH below
if [ -z "${RC_TOOLS_DIR}" ]; then
    export RC_TOOLS_DIR="${RC_DARWIN_ROOT}/tools"
fi

if [ -z "${RC_HOST_BIN}" ]; then
    export RC_HOST_BIN="${RC_PRODUCT_DIR}/toolchain/bin"
fi

# Help the build system find our host tools first
if [ ! -d "${RC_HOST_BIN}" ]; then
    mkdir -pv "${RC_HOST_BIN}"
fi

export PATH="${RC_HOST_BIN}:${PATH}"

# Remove duplicate entries from $PATH
OLD_PATH=$PATH:; PATH=

while [ -n "$OLD_PATH" ]; do
    x=${OLD_PATH%%:*}

    case $PATH: in
        *:"$x":*) ;;
        *) PATH="$PATH:$x";;
    esac

    OLD_PATH=${OLD_PATH#*:}
done

PATH=${PATH#:}
unset OLD_PATH

# This file will is installed to ${RC_HOST_BIN} by this script. This is the main
#   PureDarwin source manipulation tool.
# We create "${RC_HOST_BIN}" if necessary and install this with the host `install`
#   command. If you don't have `install`, good luck building an OS...
host_rc_binary="${RC_TOOLS_DIR}/dbuild/rc"

if [ "${host_rc_binary}" -nt "${RC_HOST_BIN}/$(basename ${host_rc_binary})" ]; then
    install -CSv -m 0755 "${host_rc_binary}" "${RC_HOST_BIN}/$(basename ${host_rc_binary})"
fi

# Refrain from polluting the user's shell
unset host_rc_binary

# This allows for us to preprocess certain arguments to the `rc` command and
#   preempt their implementation. Implement `rc root` to move to the root directory
# TODO: Decide if this should be a `cd` or `pushd`
function rc {
    if [ $# == 0 ] || [ "$1" == "root" ]; then
        cd "${RC_DARWIN_ROOT}"

        return $?
    fi

    env rc $@
}

# Print out our default configuration
echo "Darwin Build Configuration:"
echo "RC_DARWIN_ROOT: ${RC_DARWIN_ROOT}"
echo "RC_SOURCE_DIR: ${RC_SOURCE_DIR}"
echo ""
echo "RC_BUILD_ROOT: ${RC_BUILD_ROOT}"
echo "RC_PRODUCT_DIR: ${RC_PRODUCT_DIR}"
echo "RC_SYSTEM_ROOT: ${RC_SYSTEM_ROOT}"
echo ""
echo "RC_HOST_TYPE: ${RC_HOST_TYPE}"
echo "RC_HOST_ARCH: ${RC_HOST_ARCH}"
echo "RC_TOOLS_DIR: ${RC_TOOLS_DIR}"
echo "RC_HOST_BIN: ${RC_HOST_BIN}"
echo ""
echo "RC_BUILD_JOBS: ${RC_BUILD_JOBS}"

# This will kill symlinks in the current working directory
rc root
