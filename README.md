# Homebrew 自动备份

## 备份内容

### 📦 Homebrew 软件包
- **Brewfile**: 完整的依赖清单（推荐恢复方式）
- **brew-formulae.txt**: 命令行工具列表
- **brew-casks.txt**: GUI 应用列表
- **brew-backup.json**: 详细安装信息（含版本、依赖）

### ⚙️ VS Code 配置（符号链接方式）
- **vscode-config/settings.json**: 用户设置
- **vscode-config/keybindings.json**: 快捷键配置
- **vscode-config/snippets/**: 代码片段目录

> 💡 **实时同步**: VS Code 配置文件使用符号链接方式，修改会立即同步到 Git 仓库

## 定时任务

已配置 launchd 定时任务，**每天下午 3:00** 自动更新备份并提交到 Git。

### 管理命令

```bash
# 查看任务状态
launchctl list | grep com.homebrew.backup

# 停止定时任务
launchctl unload ~/Library/LaunchAgents/com.homebrew.backup.plist

# 重新加载定时任务
launchctl load ~/Library/LaunchAgents/com.homebrew.backup.plist

# 手动执行备份
/Users/ggg/private/homebrew/update-backup.sh
```

### 日志文件

- **backup.log**: 备份脚本执行日志
- **launchd.log**: launchd 标准输出
- **launchd-error.log**: launchd 错误日志

## 恢复方法

### 📥 第一步：获取备份文件

#### 从 GitHub 克隆备份仓库

```bash
# 克隆备份仓库到本地
git clone https://github.com/17359898647/homebrew.git ~/homebrew-backup
cd ~/homebrew-backup
```

#### 或从已有备份目录

```bash
cd /Users/ggg/private/homebrew
```

### 🔄 第二步：恢复 Homebrew 软件

#### 方式 1：使用 Brewfile 一键恢复（推荐✅）

**最快捷的恢复方式，自动安装所有软件和依赖：**

```bash
# 进入备份目录
cd ~/homebrew-backup  # 或 /Users/ggg/private/homebrew

# 一键恢复所有软件
brew bundle install --file=./Brewfile

# 如果遇到已安装的软件，跳过错误继续安装
brew bundle install --file=./Brewfile --no-upgrade
```

**Brewfile 优势：**
- ✅ 自动处理依赖关系
- ✅ 同时安装命令行工具和 GUI 应用
- ✅ 支持 Homebrew Taps（第三方仓库）
- ✅ 幂等操作，可重复执行

#### 方式 2：逐步恢复（精细控制）

**2.1 仅恢复命令行工具（Formulae）**

```bash
# 查看将要安装的工具列表
cat brew-formulae.txt

# 批量安装命令行工具
cat brew-formulae.txt | xargs brew install

# 或逐个安装（更安全）
while read formula; do
    echo "正在安装: $formula"
    brew install "$formula"
done < brew-formulae.txt
```

**2.2 仅恢复 GUI 应用（Casks）**

```bash
# 查看将要安装的应用列表
cat brew-casks.txt

# 批量安装 GUI 应用
cat brew-casks.txt | xargs brew install --cask

# 或逐个安装
while read cask; do
    echo "正在安装: $cask"
    brew install --cask "$cask"
done < brew-casks.txt
```

**2.3 选择性恢复特定软件**

```bash
# 从列表中选择需要的软件安装
grep -i "docker" brew-formulae.txt | xargs brew install
grep -i "vscode" brew-casks.txt | xargs brew install --cask
```

#### 方式 3：查看详细信息后再决定

```bash
# 查看 JSON 格式的完整备份信息（包含版本号）
cat brew-backup.json | jq '.formulae[] | {name: .name, version: .installed[0].version}'
```

### ✅ 第三步：恢复 VS Code 配置（可选）

**使用符号链接方式实现实时同步：**

```bash
# 进入备份目录
cd ~/homebrew-backup  # 或 /Users/ggg/private/homebrew

# 备份现有配置（如果存在）
mv "$HOME/Library/Application Support/Code/User/settings.json" \
   "$HOME/Library/Application Support/Code/User/settings.json.backup"
mv "$HOME/Library/Application Support/Code/User/keybindings.json" \
   "$HOME/Library/Application Support/Code/User/keybindings.json.backup"

# 创建符号链接
ln -s "$(pwd)/vscode-config/settings.json" \
      "$HOME/Library/Application Support/Code/User/settings.json"
ln -s "$(pwd)/vscode-config/keybindings.json" \
      "$HOME/Library/Application Support/Code/User/keybindings.json"

# 验证符号链接
ls -la "$HOME/Library/Application Support/Code/User/" | grep -E "settings|keybindings"
```

**符号链接优势：**
- ✅ 配置修改自动同步到 Git 仓库
- ✅ 跨设备统一配置管理
- ✅ 无需手动备份，实时更新

**如果不想使用符号链接，也可以直接复制：**

```bash
cp vscode-config/settings.json "$HOME/Library/Application Support/Code/User/"
cp vscode-config/keybindings.json "$HOME/Library/Application Support/Code/User/"
```

### ✅ 第四步：验证恢复结果

```bash
# 检查已安装的命令行工具
brew list --formula

# 检查已安装的 GUI 应用
brew list --cask

# 验证特定软件是否安装成功
brew list | grep -i "软件名"

# 查看 Homebrew 整体状态
brew doctor

# 验证 VS Code 配置（如果已恢复）
cat "$HOME/Library/Application Support/Code/User/settings.json" | head -5
```

### 🔧 常见问题处理

#### 问题1：某些软件安装失败

```bash
# 查看失败原因
brew install --verbose 软件名

# 更新 Homebrew 后重试
brew update && brew install 软件名
```

#### 问题2：跳过已安装的软件

```bash
# Brewfile 方式会自动跳过
brew bundle install --file=./Brewfile --no-upgrade

# 手动方式需要检查
brew list | grep "软件名" || brew install 软件名
```

#### 问题3：清理旧版本和缓存

```bash
# 清理旧版本
brew cleanup

# 清理下载缓存
brew cleanup --prune=all
```

### 📊 对比不同恢复方式

| 方式 | 速度 | 精确度 | 依赖处理 | 适用场景 |
|------|------|--------|----------|----------|
| **Brewfile** | ⭐⭐⭐ | ⭐⭐⭐ | ✅ 自动 | 全新系统恢复 |
| **列表批量安装** | ⭐⭐ | ⭐⭐ | ⚠️ 手动 | 快速恢复主要软件 |
| **逐个安装** | ⭐ | ⭐⭐⭐ | ⚠️ 手动 | 选择性恢复 |
| **JSON 查看后安装** | ⭐ | ⭐⭐⭐ | ⚠️ 手动 | 需要版本控制 |

## 修改备份时间

当前配置为**每天下午 3:00**执行。如需修改，编辑 `~/Library/LaunchAgents/com.homebrew.backup.plist`：

```xml
<!-- 每天下午 3:00 -->
<key>StartCalendarInterval</key>
<dict>
    <key>Hour</key>
    <integer>15</integer>  <!-- 小时 (0-23) -->
    <key>Minute</key>
    <integer>0</integer>   <!-- 分钟 (0-59) -->
</dict>

<!-- 每周三下午 3:30 -->
<key>StartCalendarInterval</key>
<dict>
    <key>Weekday</key>
    <integer>3</integer>   <!-- 星期几 (0=周日, 1=周一, ..., 6=周六) -->
    <key>Hour</key>
    <integer>15</integer>
    <key>Minute</key>
    <integer>30</integer>
</dict>
```

修改后重新加载：
```bash
launchctl unload ~/Library/LaunchAgents/com.homebrew.backup.plist
launchctl load ~/Library/LaunchAgents/com.homebrew.backup.plist
```

## VS Code 配置管理

### 📂 配置结构

```
vscode-config/
├── settings.json        # 用户设置
├── keybindings.json     # 快捷键配置
└── snippets/            # 代码片段目录
```

### 🔗 符号链接说明

当前 VS Code 配置文件使用符号链接方式管理：

```bash
# 实际配置文件位置（Git 管理）
/Users/ggg/private/homebrew/vscode-config/settings.json
/Users/ggg/private/homebrew/vscode-config/keybindings.json

# VS Code 读取位置（符号链接）
~/Library/Application Support/Code/User/settings.json → vscode-config/settings.json
~/Library/Application Support/Code/User/keybindings.json → vscode-config/keybindings.json
```

### ✨ 工作原理

1. **实时同步**: 在 VS Code 中修改设置 → 自动保存到 Git 仓库目录
2. **自动备份**: 定时任务每天下午 3:00 自动提交变更到 GitHub
3. **跨设备同步**: 其他设备克隆仓库后创建符号链接即可同步配置

### 🛠️ 管理命令

```bash
# 查看当前符号链接状态
ls -la "$HOME/Library/Application Support/Code/User/" | grep -E "settings|keybindings"

# 查看符号链接目标
readlink "$HOME/Library/Application Support/Code/User/settings.json"

# 手动同步配置到 Git（通常不需要，定时任务会自动执行）
cd /Users/ggg/private/homebrew
git add vscode-config/
git commit -m "更新 VS Code 配置"
git push

# 恢复到之前的配置版本
cd /Users/ggg/private/homebrew
git log --oneline vscode-config/  # 查看配置变更历史
git checkout <commit-hash> -- vscode-config/  # 恢复到指定版本
```

### ⚠️ 注意事项

1. **不要删除符号链接**: 如果需要临时使用本地配置，请复制文件而不是删除链接
2. **敏感信息**: 确保配置文件中不包含 API 密钥、密码等敏感信息
3. **扩展备份**: VS Code 扩展已通过 Brewfile 备份，恢复时使用 `brew bundle` 即可

### 🔄 切换回普通文件模式

如果不想使用符号链接，可以切换回普通文件模式：

```bash
# 删除符号链接
rm "$HOME/Library/Application Support/Code/User/settings.json"
rm "$HOME/Library/Application Support/Code/User/keybindings.json"

# 复制配置文件
cp /Users/ggg/private/homebrew/vscode-config/settings.json \
   "$HOME/Library/Application Support/Code/User/"
cp /Users/ggg/private/homebrew/vscode-config/keybindings.json \
   "$HOME/Library/Application Support/Code/User/"
```

---

**作者**: yangyang.huang
**邮箱**: yangyang@weimill.com
**创建时间**: 2025-10-20
**最后更新**: 2025-10-22
