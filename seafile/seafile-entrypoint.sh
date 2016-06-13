#!/bin/bash
set -e
set -u
set -o pipefail
set -x

BASEPATH=${BASEPATH:-"/opt/haiwen"}
INSTALLPATH=${INSTALLPATH:-"${BASEPATH}/seafile-server-latest"}

validate_vars() {
  for VAR in "$@"
  do
    if [ -z "$VAR" ]
    then
      echo "Missing variable value"
      exit 1
    fi
  done
}

run_seafile() {
  # Needed to check the return code
  set +e
  ${INSTALLPATH}/seafile.sh start
  local RET=$?
  # Try an initial setup on error
  if [ ${RET} -eq 255 ]
  then
    setup_sqlite
  elif [ ${RET} -gt 0 ]
  then
    exit 255
  fi
  set -e
  ${INSTALLPATH}/seahub.sh start
  keep_in_foreground
}

setup_mysql() {
  echo "setup_mysql is ongoing."
}

setup_sqlite() {
  echo "setup_sqlite"
  # Setup Seafile
  ${INSTALLPATH}/setup-seafile.sh auto \
    -n "${SEAFILE_NAME}" \
    -i "${SEAFILE_ADDRESS}" \
    -p "${SEAFILE_PORT:-8082}" \
    -d "${SEAFILE_DATA_DIR:-"/opt/haiwen/seafile-data"}"
  mv /opt/haiwen/ccnet /seafile
  ln -s /seafile/ccnet /opt/haiwen/ccnet

  setup_seahub
}

setup_seahub() {
  # Setup Seahub
  export LANG='en_US.UTF-8'
  export LC_ALL='en_US.UTF-8'
  export CCNET_CONF_DIR="/opt/haiwen/ccnet"
  export SEAFILE_CONF_DIR="/opt/haiwen/seafile-data"
  export SEAFILE_CENTRAL_CONF_DIR="/opt/haiwen/conf"

  export PYTHONPATH=${INSTALLPATH}/seafile/lib/python2.6/site-packages:${INSTALLPATH}/seafile/lib64/python2.6/site-packages:${INSTALLPATH}/seahub:${INSTALLPATH}/seahub/thirdpart:${PYTHONPATH:-}
  export PYTHONPATH=${INSTALLPATH}/seafile/lib/python2.7/site-packages:${INSTALLPATH}/seafile/lib64/python2.7/site-packages:$PYTHONPATH

  # From https://github.com/haiwen/seafile-server-installer-cn/blob/master/seafile-server-ubuntu-14-04-amd64-http
  sed -i 's/= ask_admin_email()/= '"\"${SEAFILE_ADMIN}\""'/' ${INSTALLPATH}/check_init_admin.py
  sed -i 's/= ask_admin_password()/= '"\"${SEAFILE_ADMIN_PW}\""'/' ${INSTALLPATH}/check_init_admin.py

  ${INSTALLPATH}/seafile.sh start

  python ${INSTALLPATH}/check_init_admin.py

}

keep_in_foreground() {
# As there seems to be no way to let Seafile processes run in the foreground we 
# need a foreground process. This has a dual use as a supervisor script because 
# as soon as one process is not running, the command returns an exit code >0 
# leading to a script abortion thanks to "set -e".
while true
do
  for SEAFILE_PROC in "seafile-controller" "ccnet-server" "seaf-server" "gunicorn"
  do
    ps -ef | grep -v "grep" | grep -q "${SEAFILE_PROC}"
    sleep 1
  done
  sleep 5
done
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
ENVFILE=${ENVFILE:-"/seafile/conf/envvars"}

if [ -r "${ENVFILE}" ]
then
  . ${ENVFILE}
fi

case $MODE in
  "run")
    run_seafile
  ;;
  "setup" | "setup_mysql")
    setup_mysql
  ;;
  "setup_sqlite")
    setup_sqlite
  ;;
  "setup_seahub")
    setup_seahub
  ;;
esac
