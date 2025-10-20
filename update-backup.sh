#!/bin/bash

# Homebrew 备份自动更新脚本
# 作者: yangyang.huang
# 日期: 2025-10-20

BACKUP_DIR="/Users/ggg/private/homebrew"
LOG_FILE="$BACKUP_DIR/backup.log"

# 记录日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "开始 Homebrew 备份..."

# 切换到备份目录
cd "$BACKUP_DIR" || exit 1

# 导出 Brewfile
if brew bundle dump --file="$BACKUP_DIR/Brewfile" --force; then
    log "✓ Brewfile 导出成功"
else
    log "✗ Brewfile 导出失败"
    exit 1
fi

# 导出命令行工具列表
if brew list --formula > "$BACKUP_DIR/brew-formulae.txt"; then
    log "✓ 命令行工具列表导出成功"
else
    log "✗ 命令行工具列表导出失败"
fi

# 导出 GUI 应用列表
if brew list --cask > "$BACKUP_DIR/brew-casks.txt"; then
    log "✓ GUI 应用列表导出成功"
else
    log "✗ GUI 应用列表导出失败"
fi

# 导出详细信息 JSON
if brew info --json=v2 --installed > "$BACKUP_DIR/brew-backup.json"; then
    log "✓ 详细信息 JSON 导出成功"
else
    log "✗ 详细信息 JSON 导出失败"
fi

# 检查是否有变更
if [[ -n $(git status --porcelain) ]]; then
    log "检测到变更，准备提交..."

    # 添加所有变更
    git add -A

    # 提交变更
    COMMIT_MSG="自动备份: $(date '+%Y-%m-%d %H:%M:%S')"
    if git commit -m "$COMMIT_MSG"; then
        log "✓ Git 提交成功: $COMMIT_MSG"

        # 自动推送到远程仓库
        if git push origin main 2>&1 | tee -a "$LOG_FILE"; then
            log "✓ Git 推送成功"
        else
            log "✗ Git 推送失败，请检查网络或权限"
        fi
    else
        log "✗ Git 提交失败"
    fi
else
    log "无变更，跳过提交"
fi

log "Homebrew 备份完成"
log "----------------------------------------"
