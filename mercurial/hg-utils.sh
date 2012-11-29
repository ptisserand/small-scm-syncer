LOG_FILE=/dev/stdout

function remote_exists() {
    local host=$1
    local path=$2
    
    ssh ${host/ssh:\/\/} hg -R ${path} identify >> ${LOG_FILE} 2>&1 
}


function remote_push() {
    # must be in repository directory
    local host=$1
    local path=$2
    
    hg push ${host}/${path} >> ${LOG_FILE } 2>&1 
}

function remote_clone() {
    # must be in repository directory
    local host=$1
    local path=$2
    
    echo "hg clone --no-update . ${host}/${path}"
    hg clone --noupdate . ${host}/${path} >> ${LOG_FILE} 2>&1 
}

function remote_update() {
    # Will create if needed remote repository
    # must be in repository directory
    local host=$1
    local path=$2
    
    remote_exists ${host} ${path}
    if test $? -eq 0; then
	echo "Pushing to ${host}:${path}"
	remote_push ${host} ${path}
    else
	echo "Cloning to ${host}:${path}"
	remote_clone ${host} ${path}
    fi
}

function local_pull() {

}

function local_clone() {

}

function local_update() {

}
