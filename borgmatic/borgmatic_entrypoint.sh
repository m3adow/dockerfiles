#!/bin/bash
set -euo pipefail

/usr/local/bin/borg-latest.sh
/usr/local/bin/borgmatic "$@"
