#!/bin/bash

###############################################################################
# VS Code 符号链接恢复脚本
# 功能: 创建 VS Code 配置文件的符号链接，实现配置实时同步
# 作者: yangyang.huang
# 邮箱: yangyang@weimill.com
###############################################################################

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VSCODE_CONFIG_DIR="${SCRIPT_DIR}/vscode-config"
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  VS Code 符号链接恢复脚本${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查 VS Code 配置备份目录是否存在
if [ ! -d "$VSCODE_CONFIG_DIR" ]; then
    echo -e "${RED}❌ 错误: 找不到 VS Code 配置备份目录${NC}"
    echo -e "${YELLOW}路径: ${VSCODE_CONFIG_DIR}${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 找到 VS Code 配置备份目录${NC}"
echo -e "${BLUE}   源目录: ${VSCODE_CONFIG_DIR}${NC}"
echo ""

# 检查 VS Code 用户配置目录是否存在
if [ ! -d "$VSCODE_USER_DIR" ]; then
    echo -e "${YELLOW}⚠️  VS Code 用户配置目录不存在，正在创建...${NC}"
    mkdir -p "$VSCODE_USER_DIR"
    echo -e "${GREEN}✅ 已创建目录: ${VSCODE_USER_DIR}${NC}"
fi

echo -e "${GREEN}✅ VS Code 用户配置目录存在${NC}"
echo -e "${BLUE}   目标目录: ${VSCODE_USER_DIR}${NC}"
echo ""

# 定义配置文件列表
declare -a CONFIG_FILES=(
    "settings.json"
    "keybindings.json"
)

# 显示即将创建的符号链接
echo -e "${BLUE}📋 将要创建的符号链接:${NC}"
echo "----------------------------------------"
for file in "${CONFIG_FILES[@]}"; do
    echo "  ${file}"
    echo "    源: ${VSCODE_CONFIG_DIR}/${file}"
    echo "    目标: ${VSCODE_USER_DIR}/${file}"
    echo ""
done
echo "----------------------------------------"
echo ""

# 询问用户确认
echo -e "${YELLOW}⚠️  即将创建 VS Code 配置符号链接${NC}"
echo -e "${YELLOW}   现有配置文件将被备份为 .backup 后缀${NC}"
echo ""
read -p "是否继续? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}❌ 用户取消操作${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}🔗 开始创建符号链接...${NC}"
echo ""

# 创建符号链接
SUCCESS_COUNT=0
SKIP_COUNT=0
BACKUP_COUNT=0

for file in "${CONFIG_FILES[@]}"; do
    SOURCE_FILE="${VSCODE_CONFIG_DIR}/${file}"
    TARGET_FILE="${VSCODE_USER_DIR}/${file}"

    echo -e "${BLUE}📄 处理: ${file}${NC}"

    # 检查源文件是否存在
    if [ ! -f "$SOURCE_FILE" ]; then
        echo -e "${YELLOW}   ⚠️  源文件不存在，跳过${NC}"
        ((SKIP_COUNT++))
        echo ""
        continue
    fi

    # 检查目标位置
    if [ -L "$TARGET_FILE" ]; then
        # 已经是符号链接
        CURRENT_TARGET=$(readlink "$TARGET_FILE")
        if [ "$CURRENT_TARGET" = "$SOURCE_FILE" ]; then
            echo -e "${GREEN}   ✅ 符号链接已存在且正确，跳过${NC}"
            ((SUCCESS_COUNT++))
        else
            echo -e "${YELLOW}   ⚠️  符号链接已存在但指向不同位置${NC}"
            echo -e "${YELLOW}      当前指向: ${CURRENT_TARGET}${NC}"
            echo -e "${BLUE}   🔄 重新创建符号链接...${NC}"
            rm "$TARGET_FILE"
            ln -s "$SOURCE_FILE" "$TARGET_FILE"
            echo -e "${GREEN}   ✅ 已更新符号链接${NC}"
            ((SUCCESS_COUNT++))
        fi
    elif [ -f "$TARGET_FILE" ]; then
        # 是普通文件，需要备份
        BACKUP_FILE="${TARGET_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${BLUE}   💾 备份现有文件到: ${BACKUP_FILE}${NC}"
        mv "$TARGET_FILE" "$BACKUP_FILE"
        ln -s "$SOURCE_FILE" "$TARGET_FILE"
        echo -e "${GREEN}   ✅ 已创建符号链接${NC}"
        ((SUCCESS_COUNT++))
        ((BACKUP_COUNT++))
    else
        # 不存在，直接创建
        ln -s "$SOURCE_FILE" "$TARGET_FILE"
        echo -e "${GREEN}   ✅ 已创建符号链接${NC}"
        ((SUCCESS_COUNT++))
    fi

    echo ""
done

# 显示统计信息
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  ✅ 符号链接创建完成！${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${BLUE}📊 操作统计:${NC}"
echo -e "  成功创建/验证: ${SUCCESS_COUNT} 个"
echo -e "  跳过: ${SKIP_COUNT} 个"
echo -e "  备份文件: ${BACKUP_COUNT} 个"
echo ""

# 验证符号链接
echo -e "${BLUE}🔍 验证符号链接状态...${NC}"
echo "----------------------------------------"
ls -la "$VSCODE_USER_DIR" | grep -E "settings|keybindings" || true
echo "----------------------------------------"
echo ""

# 显示符号链接详情
echo -e "${BLUE}📝 符号链接详情:${NC}"
for file in "${CONFIG_FILES[@]}"; do
    TARGET_FILE="${VSCODE_USER_DIR}/${file}"
    if [ -L "$TARGET_FILE" ]; then
        LINK_TARGET=$(readlink "$TARGET_FILE")
        echo -e "  ${GREEN}✅${NC} ${file}"
        echo -e "     → ${LINK_TARGET}"
    else
        echo -e "  ${RED}❌${NC} ${file} (不是符号链接)"
    fi
done
echo ""

# 显示使用说明
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  💡 使用说明${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "符号链接已创建，现在具有以下特性:"
echo ""
echo -e "  ${GREEN}✨${NC} 在 VS Code 中修改设置 → 自动同步到 Git 仓库"
echo -e "  ${GREEN}✨${NC} 定时任务会自动提交变更到 GitHub"
echo -e "  ${GREEN}✨${NC} 其他设备克隆仓库后运行此脚本即可同步配置"
echo ""
echo -e "${BLUE}查看符号链接状态:${NC}"
echo -e "  ls -la \"$VSCODE_USER_DIR\" | grep -E \"settings|keybindings\""
echo ""
echo -e "${BLUE}查看符号链接目标:${NC}"
echo -e "  readlink \"$VSCODE_USER_DIR/settings.json\""
echo ""
echo -e "${BLUE}如果需要恢复备份文件:${NC}"
echo -e "  rm \"$VSCODE_USER_DIR/settings.json\""
echo -e "  cp \"$VSCODE_USER_DIR/settings.json.backup.*\" \"$VSCODE_USER_DIR/settings.json\""
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  🎉 所有操作完成！${NC}"
echo -e "${BLUE}========================================${NC}"
