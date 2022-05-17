# Vorble Platform

*Version 0.1.0*

This sub-directory holds some custom loadouts for Platform. You can run these loadouts with this example script (put it in the Platform root directory):

```sh
#!/bin/sh

set -eu

# These are required for the example custom loadout to operate fully!
export PATH_ENV="vorble/env"
export PATH_HOOK="vorble/hook"
export PATH_OPTION="vorble/option"

# Set these to your preference.
export LOADOUT="vorble/loadout/base"
export USERS="keith root vorble"

`dirname $0`/setup.sh.compatible
```

See [setup.vorble](../setup.vorble) for a more featureful custom setup script.
