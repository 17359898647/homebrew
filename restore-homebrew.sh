#!/bin/bash

###############################################################################
# Homebrew 恢复脚本
# 功能: 从备份文件恢复所有 Homebrew 软件包
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
BREWFILE="${SCRIPT_DIR}/Brewfile"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Homebrew 恢复脚本${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查 Homebrew 是否已安装
if ! command -v brew &> /dev/null; then
    echo -e "${RED}❌ 错误: Homebrew 未安装${NC}"
    echo -e "${YELLOW}请先安装 Homebrew: https://brew.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 检测到 Homebrew 已安装${NC}"
echo ""

# 检查 Brewfile 是否存在
if [ ! -f "$BREWFILE" ]; then
    echo -e "${RED}❌ 错误: 找不到 Brewfile${NC}"
    echo -e "${YELLOW}路径: ${BREWFILE}${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 找到 Brewfile: ${BREWFILE}${NC}"
echo ""

# 显示将要安装的软件数量
echo -e "${BLUE}📊 Brewfile 内容预览:${NC}"
echo "----------------------------------------"
cat "$BREWFILE"
echo "----------------------------------------"
echo ""

# 询问用户确认
echo -e "${YELLOW}⚠️  即将开始恢复 Homebrew 软件包${NC}"
echo -e "${YELLOW}   这可能需要较长时间，取决于网络速度和软件数量${NC}"
echo ""
read -p "是否继续? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}❌ 用户取消操作${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}🚀 开始恢复 Homebrew 软件包...${NC}"
echo ""

# 更新 Homebrew
echo -e "${BLUE}📦 正在更新 Homebrew...${NC}"
brew update

echo ""
echo -e "${BLUE}📥 正在安装软件包（跳过已安装的软件）...${NC}"
echo ""

# 使用 Brewfile 恢复，跳过已安装的软件
if brew bundle install --file="$BREWFILE" --no-upgrade; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  ✅ Homebrew 恢复完成！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""

    # 显示统计信息
    echo -e "${BLUE}📊 当前安装的软件统计:${NC}"
    echo -e "  命令行工具: $(brew list --formula | wc -l | tr -d ' ') 个"
    echo -e "  GUI 应用: $(brew list --cask | wc -l | tr -d ' ') 个"
    echo ""

    # 运行诊断
    echo -e "${BLUE}🔍 运行 Homebrew 诊断...${NC}"
    brew doctor || true

    echo ""
    echo -e "${GREEN}✨ 恢复流程全部完成！${NC}"
else
    echo ""
    echo -e "${YELLOW}⚠️  部分软件安装失败或跳过${NC}"
    echo -e "${YELLOW}   请查看上方输出信息了解详情${NC}"
    echo ""
    echo -e "${BLUE}💡 提示:${NC}"
    echo -e "  - 某些软件可能需要额外的系统权限"
    echo -e "  - 可以使用 'brew install <软件名>' 单独重试失败的软件"
    echo -e "  - 运行 'brew doctor' 检查系统状态"
    exit 1
fi

# 清理旧版本和缓存(可选)
echo ""
read -p "是否清理旧版本和缓存? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}🧹 正在清理...${NC}"
    brew cleanup
    echo -e "${GREEN}✅ 清理完成${NC}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  🎉 所有操作完成！${NC}"
echo -e "${BLUE}========================================${NC}"
