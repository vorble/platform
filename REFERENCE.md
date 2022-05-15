# Platform Reference

*Version 0.1.0*

The following document outlines the API provided by Platform for writing custom loadouts.

## Index

* Environment
* Options
* "Features"
  - Loadouts/Features
  - Hooks
* "Includes"
  - Environment/Options
  - Includes


## Environment

The following environment variables are determined by platform tools when it runs and are available for use by custom loadouts:

* `CPU_VENDOR` - The CPU vendor. Values are `intel` or `amd`.
* `DISTRO` - The operating system distribution. For Linux, this is the name of the Linux distribution, e.g. `Debian`. Possible values are: `CentOS`, `Debian`, `Fedora`, `OpenBSD`.
* `DISTRO_VERSION` - The version of the operating system distribution. Values depend on `DISTRO`.
* `HAS_AMD_GRAPHICS` - Values are 0 or 1. Value is 0 if an AMD graphics device was not detected. Value is 1 if an AMD graphics device was detected.
* `HAS_NVIDIA_GRAPHICS` - Values are 0 or 1. Value is 0 if an Nvidia graphics device was not detected. Value is 1 if an Nvidia graphics device was detected.
* `IS_METAL` - Values are 0 or 1. Value is 0 if the system is detected as being virtualized. Value is 1 if the system is running on "metal" (not virtualized).
* `KERNEL` - The kernel name. Values are `Linux` or `OpenBSD`.
* `PACKAGE_MANAGER` - The system's package manager. Values are `apt` (Debian), `yum` (CentOS/Fedora), and `pkg_add` (OpenBSD).
TODO: Package manager for CentOS 8/9?


## Options

The following options, controllable with environment variables, are available:

* `ALLOW_NONFREE` - Values are 0 or 1. Default 0. Set to 0 to disallow non-free software. Set to 1 to allow non-free software. **If a custom loadout does not support this option, then it should disallow using the features with a guard of some sort.**
* `DEBUG` - Values are 0 or 1. Default 0. Set to 0 for normal operation. Set to 1 to enable debug logging.
* `DRY_RUN` - Values are 0 or 1. Default 0. Set to 0 to perform setup commands on the system. Set to 1 to echo the commands to be performed instead of performing them. **If a custom loadout does not support this option, then it should disallow using the features with a guard of some sort.**
* `FEATURE_FILE` - Value is a path to a file. Default to a file in `/tmp`. Set this option to control where the feature file, which is used to keep track of the progress of the platform setup and is deleted when finished, is written. The user must have access to write to this file.
* `LOADOUT` - Value is a **space separated** list of features. Default to blank. Set this option to control which features will be installed.
* `PATH_ENV` - Value is a **colon separated** list of env directories. Default to blank. Set this option to add additional environment variable scripts for custom loadouts.
* `PATH_HOOK` - Value is a **colon separated** list of hook directories. Default to blank. Set this option to add additional hook scripts for custom loadouts.
* `PATH_OPTION` - Value is a **color separated** list of option directories. Default to blank. Set this option to add additional option scripts for custom loadouts.
* `PLZHELP` - Value is 0 or 1. Default to 0. Set this option to 0 for normal operation. Set this option to 1 to enable extra logging messages about things that might not be fully tested or finished in the software. Set this option if you would like to help improve the software.
* `WATERMARK_DIR` - Value is a path to a directory. Default to `/usr/local/etc/platform/`. Set this option to control where watermark files are stored which record the versions and loadouts used.


## "Features"

The general idea of a "feature" applies to several types of scripts used for different purposes, but having similar layout: loadout, feature, and hook scripts. The scripts should perform no action when run with no arguments and, when implemented in POSIX shell (`#!/bin/sh`), should run its arguments received as a command with the syntax `"${@}"`. Any executable file will work as long as it does similar.

### Loadouts/Features

Should be located in a `loadout` or `feature` directory/sub-directory.

* `list_prerequisites`
* `list_features`
* `pre_install_hook`
* `list_packages`
* `post_install_hook`
* `list_postrequisites`

### Hooks

Hooks Should be located in a `hook` directory/sub-directory. Additional hooks can be added to the setup process with the `PATH_HOOK` option.

* `on_start`
* `on_finish`

### `"${@}"`

For feature scripts implemented in POSIX or similar shells, the script should execute the command `"${@}"` as its final statement to give the platform tools a way to execute the functions contained within. In addition to the functions outlined in the API, the platform tools will also send the shell command `type xyz` where `xyz` is the name of one of the functions. The script should exit with a successful code if the function `xyz` is defined.


## "Includes"

### Environment/Options

Should be located in a `env` or `option` directory/sub-directory. Additional environment and options can be added to the setup process with the `PATH_ENV` and `PATH_OPTION` options.

### Includes

Should be located in a `include` directory/sub-directory.
