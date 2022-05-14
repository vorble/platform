# Platform Reference

## Index

* "Features"
  - Loadouts/Features
  - Hooks
* "Includes"
  - Environment/Options
  - Includes
* Options

### "Features"

The general idea of a "feature" applies to several types of scripts used for different purposes, but having similar layout: loadout, feature, and hook scripts. The scripts should perform no action when run with no arguments and, when implemented in POSIX shell (`#!/bin/sh`), should run its arguments received as a command with the syntax `"${@}"`. Any executable file will work as long as it does similar.

#### Loadouts/Features

Should be located in a `loadout` or `feature` directory/sub-directory.

* `list_prerequisites`
* `list_features`
* `pre_install_hook`
* `list_packages`
* `post_install_hook`
* `list_postrequisites`

#### Hooks

Should be located in a `hook` directory/sub-directory. Additional hooks can be added to the setup process with the `PATH_HOOK` option.

* `on_start`
* `on_finish`

### "Includes"

#### Environment/Options

Should be located in a `env` or `option` directory/sub-directory. Additional environment and options can be added to the setup process with the `PATH_ENV` and `PATH_OPTION` options.

#### Includes

Should be located in a `include` directory/sub-directory.
