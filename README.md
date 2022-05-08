# Platform

A tool that provides a quick method for setting up various types of Unix-like operating systems.

## Usage

The typical usage of this software involves writing a short setup script to set up the environment, choosing a loadout, and running the included [setup.sh](setup.sh) script:

```sh
#!/bin/sh

export DEBUG=0
export DRY_RUN=0
export LOADOUT="loadout/base"
export PLZHELP=1

`dirname $0`/setup.sh
```

* `DEBUG` can be set to enable debugging output.
* `DRY_RUN` can be set to disable modifying the system.
* `LOADOUT` is a space separated list of files from the [loadout](loadout) or another custom loadout directory.
* `PLZHELP` controls whether the software's pleas for help are displayed.
* See the [option](option) directory for all configurable options.

You may run the [setup.sh.compatible](setup.sh.compatible) script instead of [setup.sh](setup.sh) if you plan to keep the platform code up-to-date independently from your customized loadout. [setup.sh.compatible](setup.sh.compatible) inspects the options used to either convert old options to new ones or fail/warn about deprecations. It warns about upcoming deprecations, warns about converting one option to another, and fails when using deprecated options.

See [setup.vorble](setup.vorble) for a complete usage example.
See [License](#License) and [Customization](#Customization) for information about packaging and distributing your changes with this software.

## Target Operating Systems

* Linux
  * Debian 10, Buster
  * Debian 11, Bullseye
* OpenBSD

## License

This software is licensed under the GPLv3 license. See [LICENSE](LICENSE) for the full license details.

### Customization

Some alterations to the directory structure of this software are required for its normal operation, so some specific kinds of modifications are acceptable and would fall under the modifying party's copyright and license.

Permitted customization:

* You may create one or more invocation scripts alongside the [setup.sh](setup.sh) for the purpose of invoking [setup.sh](setup.sh) with customized parameters. See [setup.vorble](setup.vorble) for an example.
* You may create new directories in the project root to hold custom env, hook, feature, loadout, and other related files. See directory [vorble](vorble) for an example.
* You may package and distribute the combined software provided the copyright and license terms for the modifications are clearly indicated.
  - Please use, for example, files named "LICENSE-custom" and "COPYRIGHT-custom" if your new directory is named "custom".
