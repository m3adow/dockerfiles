#!/bin/bash
set -e
set -u
set -o pipefail

run_seafile() {
  echo "run_seafile\n"
}

setup_mysql() {
  echo "setup_mysql"
}

setup_sqlite() {
  echo "setup_sqlite"
}



while getopts ":m:e:" OPT
do
  case $OPT in
    m)
      MODE=${OPTARG}
    ;;
    e)
      ENVFILE=${OPTARG}
    ;;
  esac
done

# Fill vars with defaults if empty
MODE=${MODE:-"run"}
ENVFILE=${ENVFILE:-"/srv/seafile/conf/envfile"}

case $MODE in
  "run")
    run_seafile
  "setup" | "setup_mysql")
    setup_mysql
  "setup_sqlite")
    setup_sqlite
