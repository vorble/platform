#!/bin/sh

# Copyright (C) 2022 Keith "vorble"
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# -e for exit on failed command.
# -u for undefined variables are an error.
set -eu

cd `dirname $0`

export PLATFORM_VERSION=0.0.3

# DEBUG must come first.
. option/DEBUG
. option/ENV_DIR
. option/DRY_RUN
. option/HOOK_DIR
. option/PATH_ETC

. env/CPU_VENDOR
. env/DISTRO
. env/DISTRO_VERSION
. env/IS_METAL
. env/KERNEL
. env/PACKAGE_MANAGER
# The following envs have dependencies on the previous.
. env/HAS_AMD_GRAPHICS
. env/HAS_NVIDIA_GRAPHICS

if [ -n "$ENV_DIR" ]; then
    for ENV_FILE in $ENV_DIR/*; do
        . $ENV_FILE
    done
fi

HOOKS="hook/*"
if [ -n "$HOOK_DIR" ]; then
    HOOKS="$HOOKS $HOOK_DIR/*"
fi


. include/install_packages

feature_exists() {
    local FEATURE
    for FEATURE in ${@}; do
        if [ ! -x "${FEATURE}" ]; then
            echo "Feature ${FEATURE} is not an executable file." 1>&2
            return 1
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
    if [ "$DEBUG" != "0" ]; then
        echo "Setting up features: ${FEATURES}"
    fi
    for FEATURE in ${FEATURES}; do
        if feature_has_function ${FEATURE} pre_install_hook; then
            echo "pre_install_hook ${FEATURE}"
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

for HOOK in $HOOKS; do
    if feature_has_function ${HOOK} on_start; then
        "${HOOK}" on_start
    fi
done

setup_features ${FEATURES}

for HOOK in $HOOKS; do
    if feature_has_function ${HOOK} on_finish; then
        "${HOOK}" on_finish
    fi
done
