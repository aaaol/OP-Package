#!/bin/bash
source ./scripts/sync_utils.sh

log "Starting repository sync: $1"

# 配置Git
git config --global user.name "GitHub Actions"
git config --global user.email "actions@github.com"

# 执行同步操作
if clone_repo "https://github.com/$SOURCE_REPO.git" "main"; then
    cd $(basename $SOURCE_REPO)
    git remote add target "https://$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git"
    git fetch --depth=1 target
    
    if git merge --allow-unrelated-histories -m "Merge updates [$1]" target/main; then
        git push target HEAD:main
        log "Sync completed successfully"
        exit 0
    else
        log "ERROR: Merge failed"
        exit 1
    fi
else
    log "FATAL: Sync operation failed"
    exit 1
fi
