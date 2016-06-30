#!/bin/bash
set -e
set -u
set -o pipefail

DATADIR=${DATADIR:-"/seafile"}
BASEPATH=${BASEPATH:-"/opt/haiwen"}
INSTALLPATH=${INSTALLPATH:-"${BASEPATH}/$(ls -1 ${BASEPATH} | grep -E '^seafile-server-[0-9.-]+')"}

trapped() {
  ${INSTALLPATH}/seafile.sh stop
  ${INSTALLPATH}/seahub.sh stop
}

run_seafile() {
  # If there's an existing seafile config, link the dirs
  move_and_link
  # Needed to check the return code
  set +e
  ${INSTALLPATH}/seafile.sh start
  local RET=$?
  set -e
  # Try an initial setup on error
  if [ ${RET} -eq 255 ]
  then
    set +u
    # If $MYSQL_SERVER is set, we assume MYSQL setup is intended,
    # otherwise sqlite
    if [ -n "${MYSQL_SERVER}" ]
    then
      setup_mysql
      ${INSTALLPATH}/seafile.sh start
    else
      setup_sqlite
      ${INSTALLPATH}/seafile.sh start
    fi
  elif [ ${RET} -gt 0 ]
  then
    exit 1
  fi
  ${INSTALLPATH}/seahub.sh start
  keep_in_foreground
}

setup_mysql() {
  echo "setup_mysql"

  set +u
  OPTIONAL_PARMS="$([ -n "${MYSQL_ROOT_PASSWORD}" ] && printf '%s' "-r ${MYSQL_ROOT_PASSWORD}")"
  set -u

  ${INSTALLPATH}/setup-seafile-mysql.sh auto \
    -n "${SEAFILE_NAME}" \
    -i "${SEAFILE_ADDRESS}" \
    -p "${SEAFILE_PORT}" \
    -d "${SEAFILE_DATA_DIR}" \
    -o "${MYSQL_SERVER}" \
    -t "${MYSQL_PORT:-3306}" \
    -u "${MYSQL_USER}" \
    -w "${MYSQL_USER_PASSWORD}" \
    -q "${MYSQL_USER_HOST:-"%"}" \
    ${OPTIONAL_PARMS}

  setup_seahub
  move_and_link
}

setup_sqlite() {
  echo "setup_sqlite"
  # Setup Seafile
  ${INSTALLPATH}/setup-seafile.sh auto \
    -n "${SEAFILE_NAME}" \
    -i "${SEAFILE_ADDRESS}" \
    -p "${SEAFILE_PORT}" \
    -d "${SEAFILE_DATA_DIR}"

  setup_seahub
  move_and_link
}

setup_seahub() {
  # Setup Seahub
  export LANG='en_US.UTF-8'
  export LC_ALL='en_US.UTF-8'
  export CCNET_CONF_DIR="${BASEPATH}/ccnet"
  export SEAFILE_CONF_DIR="${SEAFILE_DATA_DIR}"
  export SEAFILE_CENTRAL_CONF_DIR="${BASEPATH}/conf"

  export PYTHONPATH=${INSTALLPATH}/seafile/lib/python2.6/site-packages:${INSTALLPATH}/seafile/lib64/python2.6/site-packages:${INSTALLPATH}/seahub:${INSTALLPATH}/seahub/thirdpart:${PYTHONPATH:-}
  export PYTHONPATH=${INSTALLPATH}/seafile/lib/python2.7/site-packages:${INSTALLPATH}/seafile/lib64/python2.7/site-packages:$PYTHONPATH

  # From https://github.com/haiwen/seafile-server-installer-cn/blob/master/seafile-server-ubuntu-14-04-amd64-http
  sed -i 's/= ask_admin_email()/= '"\"${SEAFILE_ADMIN}\""'/' ${INSTALLPATH}/check_init_admin.py
  sed -i 's/= ask_admin_password()/= '"\"${SEAFILE_ADMIN_PW}\""'/' ${INSTALLPATH}/check_init_admin.py

  ${INSTALLPATH}/seafile.sh start

  python ${INSTALLPATH}/check_init_admin.py
}

move_and_link() {
  # Stop Seafile/hub instances if running
  ${INSTALLPATH}/seahub.sh stop
  ${INSTALLPATH}/seafile.sh stop

  for SEADIR in "ccnet" "conf" "seafile-data" "seahub-data" 
  do
    if [ -e "${BASEPATH}/${SEADIR}" ]
    then
      cp -a ${BASEPATH}/${SEADIR} ${DATADIR}
      rm -rf "${BASEPATH}/${SEADIR}"
    fi
    # If there's content in the dirs (=existing config)
    # do a link
    if [ "$(ls -A ${DATADIR}/${SEADIR})" ]
    then
      ln -s ${DATADIR}/${SEADIR} ${BASEPATH}/${SEADIR}
    fi
  done

  # Do also move/link the seahub.db
  # As this is normally in the root dir of seafile (/opt/haiwen)
  # SEAHUB_DB_DIR needs to be defined if it should be moved elsewhere under /seafile
  local SH_DB_DIR="${DATADIR}/${SEAHUB_DB_DIR}"
  if [ -e "${BASEPATH}/seahub.db" ]
  then
    mv ${BASEPATH}/seahub.db ${SH_DB_DIR}/
  fi
  if [ -e "${SH_DB_DIR}/seahub.db" ]
  then
    ln -s ${SH_DB_DIR}/seahub.db ${BASEPATH}/seahub.db
  fi
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
  esac
done

# Fill vars with defaults if empty
MODE=${MODE:-"run"}

SEAFILE_DATA_DIR=${SEAFILE_DATA_DIR:-"${DATADIR}/seafile-data"}
SEAFILE_PORT=${SEAFILE_PORT:-8082}
SEAHUB_DB_DIR=${SEAHUB_DB_DIR:-}


trap trapped SIGINT SIGTERM
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
