#!/bin/bash

set -euo pipefail

THIS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

"$THIS_DIR"/mkdirs.sh
curl -fsS https://dlang.org/install.sh | bash -s dmd-2.082.1
