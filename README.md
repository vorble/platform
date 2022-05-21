# Platform

*Version 0.1.0*

A programmable system configuration framework. Define a loadout and set of features for your UNIX-like system and get them set up quickly and consistently.

## Usage

Try it out:

```sh
DRY_RUN=1 ./platform vorble/loadout/base
```

* `DRY_RUN` can be set to disable modifying the system.
* See the [option](option) directory for all configurable options.
* See the [vorble/option](vorble/option) for all configurable options specific to the `vorble` custom loadouts.

You are invited to create your own custom loadouts! Do so by creating a new directory in the root of this source package. For example, create the directory `example` (copy `vorble` as a template and remove what you don't need) and run the loadout by using the name as a prefix:

```sh
./platform example/loadout/base
```

See [REFERENCE.md](REFERENCE.md) for complete usage details.

See [License](#License) and [Customization](#Customization) for information about packaging and distributing your changes with this software.

### Built-Ins

See the [loadout](loadout) and [feature](feature) directories for a list of built-in features and loadouts.
See the [vorble/loadout](vorble/loadout) and [vorble/feature](vorble/feature) directories for a list of features and loadouts built into the `vorble` custom loadout.

## Target Operating Systems

* Linux
  * Debian 10/11
  * CentOS 7/8/9
  * Fedora 36
  * openSUSE Leap 15
* OpenBSD 7.1

## License

This software is licensed under the GPLv3 license. See [LICENSE](LICENSE) for the full license details.

### Customization

Some alterations to the directory structure of this software are required for its normal operation, so some specific kinds of modifications are acceptable and would fall under the modifying party's copyright and license.

Permitted customization:

* You may create new directories in the project root to hold custom env, feature, hook, loadout, option, and other related files. See directory [vorble](vorble) for an example.
* You may package and distribute the combined software provided the copyright and license terms for the modifications are clearly indicated.
  - Please use, for example, files named "LICENSE-custom" and "COPYRIGHT-custom" if your new directory is named "custom".

## More Information

This software follows the [Semantic Versioning 2.0.0](https://semver.org/) versioning scheme.
