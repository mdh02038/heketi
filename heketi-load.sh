#!/bin/bash
#
# HEKETI_TOPOLOGY_FILE can be passed as an environment variable with the
# filename of the initial topology.json. In case the heketi.db does not exist
# yet, this file will be used to populate the database.

: "${HEKETI_PATH:=/var/lib/heketi}"
HEKETI_BIN="/usr/bin/heketi"
LOG="${HEKETI_PATH}/container.log"

info() {
    echo "$*" | tee -a "$LOG"
}

error() {
    echo "error: $*" | tee -a "$LOG" >&2
}

fail() {
    error "$@"
    exit 1
}

# if the heketi.db has not be initialized and HEKETI_TOPOLOGY_FILE is set load the topology file
if [[ ! -e "{$HEKETI_PATH}/inited" && -n "${HEKETI_TOPOLOGY_FILE}" ]]; then

    # wait until heketi replies
    while ! curl http://localhost:8080/hello; do
        sleep 0.5
    done

    # load the topology
    if [[ -n "${HEKETI_ADMIN_KEY}" ]]; then
        HEKETI_SECRET_ARG="--secret='${HEKETI_ADMIN_KEY}'"
    fi
    echo heketi-cli --user=admin "${HEKETI_SECRET_ARG}" topology load --json="${HEKETI_TOPOLOGY_FILE}"
    heketi-cli --user=admin "${HEKETI_SECRET_ARG}" topology load --json="${HEKETI_TOPOLOGY_FILE}"
    if [[ $? -ne 0 ]]; then
        # something failed, need to exit with an error
        fail "failed to load topology from ${HEKETI_TOPOLOGY_FILE}"
    else
        touch "${HEKETI_PATH}/inited"
    fi

fi
