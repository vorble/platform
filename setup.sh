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

# -----------------------------------------------------------------------------
# Start
# -----------------------------------------------------------------------------

export PLATFORM_VERSION=0.0.3

# -e for exit on failed command.
# -u for undefined variables are an error.
set -eu

# Feature and other scripts are executed by the name listed in the loadout and
# other feature scripts. The current directory must be the root of this bundle
# of scripts for everything to work properly.
# TODO: It would be nice to be able to completely separate a loadout from the
# platform code base.
cd `dirname $0`


# -----------------------------------------------------------------------------
# Options
# -----------------------------------------------------------------------------

# DEBUG must come first.
. option/DEBUG
. option/ALLOW_NONFREE
. option/DRY_RUN
. option/PATH_ENV
. option/PATH_ETC
. option/PATH_HOOK


# -----------------------------------------------------------------------------
# Environment
# -----------------------------------------------------------------------------

. env/CPU_VENDOR
. env/DISTRO
. env/DISTRO_VERSION
. env/IS_METAL
. env/KERNEL
. env/PACKAGE_MANAGER
# The following envs have dependencies on the previous.
. env/HAS_AMD_GRAPHICS
. env/HAS_NVIDIA_GRAPHICS

# Load additional env from PATH_ENV directories. This function checks PATH_ENV
# to ensure it consists of directories. It outputs a glob pattern suitable for
# matching files in the directory. E.g. PATH_ENV=a:b produces output:
# a/*
# b/*
list_envs_for_glob() {
    echo $PATH_ENV | tr ':' '\n' | while read -r PATH_ENV_PART; do
        # Since echo always prints a line, it might be blank.
        if [ -n "$PATH_ENV_PART" ]; then
            if [ -d "$PATH_ENV_PART" ]; then
                echo "$PATH_ENV_PART/*"
            fi
        fi
    done
}

for FNAME in $( list_envs_for_glob ); do
    # An env directory could be empty, so you might get an unmatched glob, so
    # ensure the listed item is a file before including it.
    if [ -f "$FNAME" ]; then
        . "$FNAME"
    fi
done


# -----------------------------------------------------------------------------
# Main Process
# -----------------------------------------------------------------------------

# The setup process is recursive: any feature listed in a list_prerequisites
# will be run through setup_features first, WITHOUT being expanded via
# list_features.

. include/install_packages
. include/feature_has_function
. include/list_features
. include/list_hooks_with_function
. include/list_packages

setup_features() {
    local FEATURE
    for FEATURE in "${@}"; do
        if feature_has_function "$FEATURE" list_prerequisites; then
            setup_features $( "$FEATURE" list_prerequisites ) # Recursive!
        fi
    done
    if [ "$DEBUG" != "0" ]; then
        echo "Setting up features: ${@}"
    fi
    for FEATURE in "${@}"; do
        if feature_has_function "$FEATURE" pre_install_hook; then
            "$FEATURE" pre_install_hook
        fi
    done
    install_packages $( list_packages "${@}" | sort -u )
    for FEATURE in "${@}"; do
        if feature_has_function "$FEATURE" post_install_hook; then
            "$FEATURE" post_install_hook
        fi
    done
}

list_hooks_with_function on_start | while read -r HOOK; do
    "$HOOK" on_start
done

setup_features $( list_features $LOADOUT | sort -u )

list_hooks_with_function on_finish | while read -r HOOK; do
    "$HOOK" on_finish
done
