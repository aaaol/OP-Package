#!/bin/bash
source ./scripts/sync_utils.sh

IFS=',' read -ra PKG_LIST <<< "$1"

UPDATE_PACKAGE() {
    local pkg=$1
    local repo=$2
    local branch=${3:-main}
    local special=${4:-}
    shift 4
    local aliases=("$@")
    
    log "Processing package: $pkg ($repo)"
    cleanup_pkg "$pkg" "${aliases[@]}"
    
    if clone_repo "https://github.com/$repo.git" "$branch"; then
        local repo_name=$(basename $repo)
        case $special in
            pkg)
                find ./$repo_name/*/ -maxdepth 3 -type d -iname "*$pkg*" -exec cp -rf {} ./ \;
                rm -rf ./$repo_name/
                ;;
            name)
                mv -f $repo_name $pkg
                ;;
            *)
                # 默认处理
                ;;
        esac
        log "Package $pkg updated successfully"
    else
        log "ERROR: Failed to update package $pkg"
    fi
}

# 包定义配置 (可提取到单独配置文件)
declare -A PACKAGES=(
    ["OpenAppFilter"]="destan19/OpenAppFilter master"
    ["argon"]="sbwml/luci-theme-argon openwrt-24.10"
    ["passwall"]="xiaorouji/openwrt-passwall main pkg"
)

for pkg in "${PKG_LIST[@]}"; do
    if [[ -n "${PACKAGES[$pkg]}" ]]; then
        UPDATE_PACKAGE "$pkg" ${PACKAGES[$pkg]}
    else
        log "WARNING: Package $pkg not configured"
    fi
done
