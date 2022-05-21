# Vorble Platform

*Version 0.1.0*

This sub-directory holds some custom loadouts for Platform. You can run these loadouts with this example script (put it in the Platform root directory):

```sh
#!/bin/sh

set -eu

export USERS="keith root vorble"

`dirname $0`/setup.sh.compatible
```

See [setup.vorble](../setup.vorble) for a more featureful custom setup script.
