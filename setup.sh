#!/bin/sh

# -e for exit on failed command.
# -u for undefined variables are an error.
set -eu

export PLATFORM_VERSION=0.0.3

# DEBUG must come first.
if [ "${DEBUG+x}" = "x" ]; then
    export DEBUG="${DEBUG}"
else
    export DEBUG=0
fi
if [ "$DEBUG" != "0" ]; then
    echo "DEBUG=$DEBUG"
fi

if [ "${CUSTOM_ENV+x}" = "x" ]; then
    export CUSTOM_ENV="${CUSTOM_ENV}"
else
    export CUSTOM_ENV=
fi
if [ "$DEBUG" != "0" ]; then
    echo "CUSTOM_ENV=$CUSTOM_ENV"
fi

if [ "${DRY_RUN+x}" = "x" ]; then
    export DRY_RUN="${DRY_RUN}"
else
    export DRY_RUN=0
fi
if [ "$DEBUG" != "0" ]; then
    echo "DRY_RUN=$DRY_RUN"
fi

if [ "${LOADOUT+x}" = "x" ]; then
    export LOADOUT="${LOADOUT}"
else
    export LOADOUT="loadout/base"
fi
if [ "$DEBUG" != "0" ]; then
    echo "LOADOUT=$LOADOUT"
fi

if [ "${PATH_ETC+x}" = "x" ]; then
    export PATH_ETC="${PATH_ETC}"
else
    export PATH_ETC=/usr/local/etc
fi
if [ "$DEBUG" != "0" ]; then
    echo "PATH_ETC=$PATH_ETC"
fi

if [ "${PLZHELP+x}" = "x" ]; then
    export PLZHELP="${PLZHELP}"
else
    export PLZHELP=0
fi
if [ "$DEBUG" != "0" ]; then
    echo "PLZHELP=$PLZHELP"
fi


. env/CPU_VENDOR
. env/DISTRO
. env/DISTRO_VERSION
. env/IS_METAL
. env/KERNEL
. env/PACKAGE_MANAGER
# The following envs have dependencies on the previous.
. env/HAS_AMD_GRAPHICS
. env/HAS_NVIDIA_GRAPHICS

# TODO: Would a custom ENV dir be better? Include all scripts from the dir?
# TODO: A custom hooks dir would be good too.
set +e
if [ -n "$CUSTOM_ENV" ]; then
    . $CUSTOM_ENV
fi
set -e

. include/install_packages

feature_exists() {
    local FEATURE
    for FEATURE in ${@}; do
        if [ ! -x "${FEATURE}" ]; then
            echo "Feature ${FEATURE} is not an executable file." 1>&2
            exit 1
        fi
    done
}

feature_has_function() {
    local FEATURE=$1
    local FUNCTION=$2
    # For bash.
    #"${FEATURE}" declare -F "${FUNCTION}" > /dev/null
    # For POSIX shell.
    "${FEATURE}" type "${FUNCTION}" > /dev/null 2> /dev/null
}

# List the dependencies of the feature and then the feature itself. Use this to
# build the dependency tree.
list_features() {
    local FEATURE DEP DEPS
    for FEATURE in ${@}; do
        feature_exists ${FEATURE}
        if feature_has_function ${FEATURE} list_features; then
            DEPS=`"${FEATURE}" list_features`
            for DEP in ${DEPS}; do
                list_features ${DEP}
            done
        fi
        echo ${FEATURE}
    done
}

list_packages() {
    local FEATURE PKGS PKG
    for FEATURE in ${@}; do
        if feature_has_function ${FEATURE} list_packages; then
            PKGS=`"${FEATURE}" list_packages`
            for PKG in ${PKGS}; do
                echo $PKG
            done
        fi
    done
}

setup_features() {
    local FEATURES FEATURE PREREQS PKGS
    FEATURES="${@}"
    for FEATURE in ${FEATURES}; do
        if feature_has_function ${FEATURE} list_prerequisites; then
            PREREQS=`"${FEATURE}" list_prerequisites`
            setup_features ${PREREQS}
        fi
    done
    for FEATURE in ${FEATURES}; do
        if feature_has_function ${FEATURE} pre_install_hook; then
            "${FEATURE}" pre_install_hook
        fi
    done
    PKGS=`list_packages ${FEATURES} | sort -su`
    if [ "${PKGS}" != "" ]; then
        install_packages ${PKGS}
    fi
    for FEATURE in ${FEATURES}; do
        if feature_has_function ${FEATURE} post_install_hook; then
            "${FEATURE}" post_install_hook
        fi
    done
}


FEATURES=`list_features ${LOADOUT} | sort -su`

for HOOK in hook/*; do
    if feature_has_function ${HOOK} on_start; then
        "${HOOK}" on_start
    fi
done

setup_features ${FEATURES}

for HOOK in hook/*; do
    if feature_has_function ${HOOK} on_finish; then
        "${HOOK}" on_finish
    fi
done
