#!/bin/bash
set -euo pipefail

git clone https://github.com/restic/restic /tmp/restic 1>&2
cd /tmp/restic 1>&2
go run build.go 1>&2

cat restic
