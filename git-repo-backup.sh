#!/bin/bash

set -e

if [ $# != 2 ] ; then
    echo "USAGE: $0 GITREPO BACKUPDIR"
    exit 1
fi

REPO=$1
if [ ! -d ${REPO}/objects ] ; then
    echo "ERROR: bad git repo '${REPO}'"
    exit 1
fi

TARGETBASE=$2
if [ ! -d ${TARGETBASE} ] ; then
    mkdir -p ${TARGETBASE}
fi
if [ ! -d ${TARGETBASE} ] ; then
    echo "ERROR: cannot create target directory '${TARGETBASE}'"
fi

if git --version &> /dev/null; then
    :
else
    echo "ERROR: cannot find 'git'"
fi

NAME=$(basename ${REPO} .git)
TIMESTAMP=$(date +%FT%T)
TARGET=${TARGETBASE}/${NAME}-${TIMESTAMP}
LATEST=${TARGETBASE}/${NAME}-latest
LOG=${TARGETBASE}/${NAME}.log

function full_snapshot {
    local SRC=$1
    local DST=$2
    echo "--- full snapshot"
    echo "------ source: ${SRC}"
    echo "------ target: ${DST}"
    rsync --archive --delete --exclude objects ${SRC} ${DST}
    rsync --archive --delete --include objects --exclude '/*/*' ${SRC} ${DST}
    rm -f ${LATEST}
    ln -s ${DST} ${LATEST}
    echo "--- done"
}

function incremental_snapshot {
    local SRC=$1
    local DST=$2
    local BAS=$3
    echo "--- incremental snapshot"
    echo "------ source: ${SRC}"
    echo "------ target: ${DST}"
    echo "------ base:   ${BAS}"
    rsync --archive --link-dest=${BAS} --delete --exclude objects ${SRC} ${DST}
    rsync --archive --link-dest=${BAS} --delete --include objects --exclude '/*/*' ${SRC} ${DST}
    rm -f ${LATEST}
    ln -s ${DST} ${LATEST}
    echo "--- done"
}

(
echo ${TIMESTAMP}

if [ -d ${TARGET} ] ; then
    echo "--- target ${TARGET} already exists"
    TARGET=$(mktemp ${TARGET}-XXXXXX)
    echo "--- using uniquified target ${TARGET}"
fi

if [ ! -L ${LATEST} ] ; then
    echo "--- no previous snapshot -> full snapshot"
    full_snapshot ${REPO} ${TARGET}
    exit 0
elif [ ! -e ${LATEST} ] ; then
    echo "--- invalid previous snapshot -> full snapshot"
    full_snapshot ${REPO} ${TARGET}
    exit 0
fi

LAST=$(readlink ${LATEST})
if [ ! -d ${LAST} ] ; then
    echo "--- latest link exists '${LATEST}' but points to non-existent dir '${LAST}' -> full snapshot"
    full_snapshot ${REPO} ${TARGET}
    exit 0
fi

if diff <(cd ${LATEST}/$(basename ${REPO}) ; git for-each-ref --sort=-committerdate refs/heads/) \
        <(cd ${REPO} ; git for-each-ref --sort=-committerdate refs/heads/) &> /dev/null ; then
    echo "--- no commits since last snapshot '${LAST}' -> nothing to do"
    exit 0
fi

incremental_snapshot ${REPO} ${TARGET} ${LAST}
) >> ${LOG}
