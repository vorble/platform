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

export PLATFORM_VERSION=0.1.0

# -e for exit on failed command.
# -u for undefined variables are an error.
set -eu

# Feature and other scripts are executed by the name listed in the loadout and
# other feature scripts. The current directory must be the root of this bundle
# of scripts for everything to work properly.
cd `dirname $0`


# -----------------------------------------------------------------------------
# Options
# -----------------------------------------------------------------------------

# DEBUG must come first.
. option/DEBUG
. option/DRY_RUN
. option/ENABLE_HOOK_WATERMARK
. option/FEATURE_FILE
. option/LOADOUT
. option/PATH_ENV
. option/PATH_HOOK
. option/PATH_OPTION
. option/PLZHELP
. option/WATERMARK_DIR

# Load additional options from PATH_OPTION directories. This function checks
# PATH_OPTION to ensure it consists of directories. It outputs a glob pattern
# suitable for matching files in the directory. E.g. PATH_OPTION=a:b produces
# output:
# a/*
# b/*
list_options_for_glob() {
    echo $PATH_OPTION | tr ':' '\n' | while read -r PATH_OPTION_PART; do
        # Since echo always prints a line, it might be blank.
        if [ -n "$PATH_OPTION_PART" ]; then
            if [ -d "$PATH_OPTION_PART" ]; then
                echo "$PATH_OPTION_PART/*"
            fi
        fi
    done
}

for FNAME in $( list_options_for_glob ); do
    # An option directory could be empty, so you might get an unmatched glob, so
    # ensure the listed item is a file before including it.
    if [ -f "$FNAME" ]; then
        . "$FNAME"
    fi
done


# -----------------------------------------------------------------------------
# Environment
# -----------------------------------------------------------------------------

. env/CPU_VENDOR
. env/DISTRO
. env/DISTRO_VERSION
. env/IS_METAL
. env/KERNEL
. env/PACKAGE_MANAGER

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
. include/feature_file_add
. include/feature_file_contains
. include/feature_has_function
. include/list_features
. include/list_hooks_with_function
. include/list_packages

setup_features() {
    local FEATURE
    local FEATURES
    local INCOMPLETE_FEATURES
    local TEMP
    FEATURES="$( list_features "${@}" )"
    FEATURES="$( echo $FEATURES | tr ' ' '\n' | sort -u )"
    # Prerequisites are set up first, but each feature with prerequisites is
    # handled separately. If you have two features being set up, both with
    # prerequisites, then the first feature will have its prerequisites set up
    # before the second.
    for FEATURE in $FEATURES; do
        if feature_has_function "$FEATURE" list_prerequisites; then
            TEMP="$( "$FEATURE" list_prerequisites )"
            setup_features $TEMP # Recursive
        fi
    done
    if [ "$DEBUG" != "0" ]; then
        echo "Setting up features: ${@}"
    fi
    INCOMPLETE_FEATURES=""
    for FEATURE in $FEATURES; do
        if ! feature_file_contains "$FEATURE"; then
            INCOMPLETE_FEATURES="$INCOMPLETE_FEATURES${INCOMPLETE_FEATURES+ }$FEATURE"
        fi
    done
    for FEATURE in $INCOMPLETE_FEATURES; do
        if feature_has_function "$FEATURE" pre_install_hook; then
            "$FEATURE" pre_install_hook
        fi
    done
    TEMP="$( list_packages $INCOMPLETE_FEATURES )"
    TEMP="$( echo $TEMP | tr ' ' '\n' | sort -u )"
    install_packages $TEMP
    for FEATURE in $INCOMPLETE_FEATURES; do
        if feature_has_function "$FEATURE" post_install_hook; then
            "$FEATURE" post_install_hook
        fi
    done
    for FEATURE in $INCOMPLETE_FEATURES; do
        feature_file_add "$FEATURE"
    done
    # Same behavior as prerequisite handling above (see commentary).
    for FEATURE in $FEATURES; do
        if feature_has_function "$FEATURE" list_postrequisites; then
            TEMP="$( "$FEATURE" list_postrequisites )"
            setup_features $TEMP # Recursive
        fi
    done
}

list_hooks_with_function on_start | while read -r HOOK; do
    "$HOOK" on_start
done

setup_features $LOADOUT

list_hooks_with_function on_finish | while read -r HOOK; do
    "$HOOK" on_finish
done
