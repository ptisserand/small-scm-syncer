#!/bin/bash

GLOG_FILE=/dev/null

source `dirname $0`/hg-utils.sh

TMP_FILE=`mktemp`
cat >> ${TMP_FILE} <<EOF
a/b
a/c/d
e/f
EOF

function usage() {
    echo "$0 local_top_dir host [specific repositories to sync]"
    echo "local_repository: local top directory for hg repositories"
    echo "host: remote host: (ssh://hg@mercurial-server)"
    exit 1
}

if test $# -lt 2; then
    usage
fi

WORKDIR=$1
shift
HOST=$1
shift
if test $# -ge 1; then
    REP_LIST="$*"
else
    REP_LIST=`cat ${TMP_FILE}`
fi

# list of repository to sync
pushd ${WORKDIR} >> ${GLOG_FILE} 2>&1
for rr in ${REP_LIST}; do
    pushd ${rr} >> ${GLOG_FILE} 2>&1
    echo "Doing ${rr}"
    remote_update ${HOST} ${rr}
    popd >> ${GLOG_FILE} 2>&1
done
popd >> ${GLOG_FILE} 2>&1

rm ${TMP_FILE}
