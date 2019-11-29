#!/bin/bash
set -ueo pipefail
# set -x

BORG_ARCH=${BORG_ARCH:-linux64}
BORG_PATH=${BORG_PATH:-}
BORG_UPDATE_ONLY=${BORG_UPDATE_ONLY:-0}

if [ -z "${BORG_PATH}" ]
then
  if [ -n "$(which borg)" ]
  then
    BORG_PATH="$(which borg)"
  elif [ -e "./borg" ]
  then
    BORG_PATH="./borg"
  fi
fi

get_newest_version(){
  # Get currently installed version
  BORG_VERSION_STRING=$(${BORG_PATH} -V 2>/dev/null|| borg -V 2>/dev/null \
    ./borg -V 2>/dev/null || echo "None")
  BORG_CURRENT_VERSION=$(echo "${BORG_VERSION_STRING}" | cut -d' ' -f2)

  # Get latest release version
  BORG_LATEST_VERSION=$(wget -qO- https://api.github.com/repos/borgbackup/borg/releases/latest | grep 'tag_name' | cut -d\" -f4)

  if [ "${BORG_CURRENT_VERSION}" != "${BORG_LATEST_VERSION}" ]
  then
    download_and_verify "${BORG_LATEST_VERSION}"
    echo "Borg has been updated."
  else
    echo "No Borg update needed."
  fi
}

download_and_verify(){
  OUTPUT_DIR=$(mktemp -d -q /tmp/XXXXXXXX)
  # Download current version (passed via $1) and check signature
  wget -nv -P "${OUTPUT_DIR}"  https://github.com/borgbackup/borg/releases/download/"${1}"/borg-"${BORG_ARCH}"
  wget -nv -P "${OUTPUT_DIR}" -q https://github.com/borgbackup/borg/releases/download/"${1}"/borg-"${BORG_ARCH}".asc

  set +e
  VERIFY=$(gpg --batch --status-fd 1 --verify "${OUTPUT_DIR}"/borg-"${BORG_ARCH}".asc "${OUTPUT_DIR}"/borg-"${BORG_ARCH}" 2>/dev/null)
  VERIFYRC=$?
  set -e

  # If signature verification was not successful, try to download pubkey
  if [ ${VERIFYRC} -ne 0 ]
  then
    GPG_FP=$(echo "${VERIFY}"| grep -E '^\[GNUPG:\] NO_PUBKEY' | cut -d' ' -f3)
    # Try several keyservers as some tend to be unresponsive
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${GPG_FP}" \
      || gpg --batch --keyserver pgp.mit.edu --recv-keys "${GPG_FP}" \
      || gpg --batch --keyserver keyserver.pgp.com --recv-keys "${GPG_FP}" \
      || gpg --batch --keyserver pool.sks-keyservers.net --recv-keys "${GPG_FP}"
    gpg --batch --status-fd 1 --verify "${OUTPUT_DIR}"/borg-"${BORG_ARCH}".asc "${OUTPUT_DIR}"/borg-"${BORG_ARCH}" 2>/dev/null
  fi

  # Move borg binary to BORG_PATH if defined, else in CWD
  mv "${OUTPUT_DIR}"/borg-"${BORG_ARCH}" "${BORG_PATH:-./borg}"
  chmod +x "${BORG_PATH:-./borg}"
  rm "${OUTPUT_DIR}"/borg-*
  rmdir "${OUTPUT_DIR}"
}

delete_key(){
  # Delete key
  gpg --batch --quiet --yes --delete-key 243ACFA951F78E01 || true
}

# Delete key is just for testing purposes
# delete_key
get_newest_version

if [ "${BORG_UPDATE_ONLY}" == "0" ]
then
        exec "${BORG_PATH:-./borg}" "$@"
fi
