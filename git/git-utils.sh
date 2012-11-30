LOG_FILE=/dev/null

function remote_exists() {
    local host=$1
    local path=$2

    git ls-remote ${host}:${path} >> ${LOG_FILE} 2>&1
}

function remote_push() {
    local host=$1
    local path=$2
    git push --mirror ${host}:${path} >> ${LOG_FILE} 2>&1
}

# Appending this file to gitolite configuration will allow W access to syncer
# and create repository if needed
function append_configuration() {
    local conf=$1
    local path=$2

    cat >> ${conf} <<EOF
repo     ${path}
         RW = syncer
EOF
}

function remote_clone() {
    local host=$1
    local path=$2
    
    echo "Remote clone"
    # first update configuration since we are using gitolite
    my_tmp=`mktemp -d`
    pushd ${my_tmp} >> ${LOG_FILE} 2>&1
    git clone ${host}:gitolite-admin
    pushd gitolite-admin/conf >> ${LOG_FILE} 2>&1
    append_configuration syncer.conf ${path}
    cat syncer.conf
    git add syncer.conf >> ${LOG_FILE} 2>&1
    git commit -m "Add right for ${path}" >> ${LOG_FILE} 2>&1 
    git push >> ${LOG_FILE} 2>&1
    popd >> ${LOG_FILE} 2>&1
    rm -f -r gitolite-admin >> ${LOG_FILE} 2>&1
    popd >> ${LOG_FILE} 2>&1
    rmdir ${my_tmp} >> ${LOG_FILE} 2>&1
    # and then push to remote
    remote_push ${host} ${path}
}

function remote_update() {
    # must be in repository directory
    local host=$1
    local path=$2

    remote_exists ${host} ${path}
    if test $? -eq 0; then
	remote_push ${host} ${path}
    else
	remote_clone ${host} ${path}
    fi
}

