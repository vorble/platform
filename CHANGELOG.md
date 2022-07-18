# Change Log

## 0.2.0

*Not Released*

* Adds `feature/git` and includes it as part of `feature/dev`.
* Adds `feature/cryptsetup` and includes it as part of `vorble/feature/base`.
* Adjusts output when `DEBUG=1` to include the names of all features being set up, prefixed with "Setting up features:".
* Removes legacy `pre_install_hook` and `post_install_hook` functions for features and loadouts. Use `pre_install` and `post_install` instead.
* `CPU_VENDOR` is adjusted to remove `arm` case and allow a blank value to be produced after checks. Use the `ARCH` variable for architecture detection instead. Additional CPU vendors can be added as they become relevant.

## 0.1.0

*Tuesday, May 31, 2022*

First release!

The software provides methods to set up preferred tools and system configuration on different operating systems. The set of features chosen is called a loadout and the setup process leverages the system's package manager to install software as needed. Some basic features are included to install some of my usual tools.

The real power comes from custom loadouts that you write for yourself. You could write scripts to emplace your usual user configuration or set up remote access keys. A custom loadout in the [vorble](vorble) directory is included as a reference and example.

The current supported systems are CentOS 7/8/9, Debian GNU/Linux 10/11, Fedora 36, OpenBSD 7.1, and openSUSE Leap 15.

See the License section in [README.md](README.md) for information on licensing.

Special thanks to mulethew for testing and checking things over.
