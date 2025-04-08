#!/bin/bash

LOG_DIR="logs"
mkdir -p $LOG_DIR

log() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1" | tee -a "$LOG_DIR/operation.log"
}

clone_repo() {
    local repo_url=$1
    local branch=$2
    local depth=${3:-1}
    
    log "Cloning $repo_url (branch: $branch)"
    if git clone --depth=$depth --single-branch --branch $branch "$repo_url"; then
        log "Clone successful"
        return 0
    else
        log "ERROR: Clone failed"
        return 1
    fi
}

cleanup_pkg() {
    local pkg_name=$1
    shift
    local pkg_list=("$pkg_name" "$@")
    
    for name in "${pkg_list[@]}"; do
        log "Cleaning up package: $name"
        find ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "*$name*" -exec rm -rf {} + 2>/dev/null
    done
}
