#!/bin/sh
set -e
set -u
set -o pipefail


ORIGINAL_ENTRYPOINT=${ORIGINAL_ENTRYPOINT:-"/usr/local/bin/docker-entrypoint.sh"}
MAXTIME=${MAXTIME:-60}

MYHOST="$1"
shift
DA_REST="$@"

MYSTART=$(date +%s)
until $(echo '\q' | mysql -h "${MYHOST}" -u "root" --password="${MYSQL_ROOT_PASSWORD}")
do
  sleep 1
  if [ $(( MYSTART + MAXTIME )) -lt $(date +%s) ]
  then
    >&2 printf "Timeout after %s seconds.\n" "${MAXTIME}"
    exit 255
  else
    >&2 printf "Waiting for server %s...\n" "${MYHOST}"
  fi
done

printf "Successfully established connection to %s.\n" "${MYHOST}"

exec ${ORIGINAL_ENTRYPOINT} ${DA_REST}
