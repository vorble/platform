#!/bin/sh

# -e for exit on failed command.
# -u for undefined variables are an error.
set -eu


#LOADOUT="loadout/common"
LOADOUT="loadout/dev"


export PLATFORM_VERSION=0.0.3
export DEBUG=0
#export DEBUG=1
. env/CPU_VENDOR
. env/HAS_AMD_GRAPHICS
. env/HAS_NVIDIA_GRAPHICS
. env/IS_METAL
export DEBUG=0


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
    #"${FEATURE}" declare -F "${FUNCTION}" > /dev/null
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

list_apt_packages() {
    local FEATURE PKGS PKG
    for FEATURE in ${@}; do
        if feature_has_function ${FEATURE} list_apt_packages; then
            PKGS=`"${FEATURE}" list_apt_packages`
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
    PKGS=`list_apt_packages ${FEATURES} | sort -su`
    if [ "${PKGS}" != "" ]; then
        # TODO - actually do the install
        echo apt-get install --yes ${PKGS}
    fi
    for FEATURE in ${FEATURES}; do
        if feature_has_function ${FEATURE} post_install_hook; then
            "${FEATURE}" post_install_hook
        fi
    done
}

FEATURES=`list_features ${LOADOUT} | sort -su`
setup_features ${FEATURES}
