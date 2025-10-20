# Homebrew 自动备份

## 备份内容

- **Brewfile**: 完整的依赖清单（推荐恢复方式）
- **brew-formulae.txt**: 命令行工具列表
- **brew-casks.txt**: GUI 应用列表
- **brew-backup.json**: 详细安装信息（含版本、依赖）

## 定时任务

已配置 launchd 定时任务，**每周三下午 3:30** 自动更新备份并提交到 Git。

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

### 方式 1：使用 Brewfile（推荐）

```bash
brew bundle install --file=/Users/ggg/private/homebrew/Brewfile
```

### 方式 2：使用列表文件

```bash
cat /Users/ggg/private/homebrew/brew-formulae.txt | xargs brew install
cat /Users/ggg/private/homebrew/brew-casks.txt | xargs brew install --cask
```

## 修改备份时间

编辑 `~/Library/LaunchAgents/com.homebrew.backup.plist`，修改 `StartCalendarInterval` 部分：

```xml
<key>StartCalendarInterval</key>
<dict>
    <key>Weekday</key>
    <integer>3</integer>  <!-- 星期几 (0=周日, 1=周一, ..., 6=周六) 不设置则每天 -->
    <key>Hour</key>
    <integer>15</integer>  <!-- 修改小时 (0-23) -->
    <key>Minute</key>
    <integer>30</integer>  <!-- 修改分钟 (0-59) -->
</dict>
```

修改后重新加载：
```bash
launchctl unload ~/Library/LaunchAgents/com.homebrew.backup.plist
launchctl load ~/Library/LaunchAgents/com.homebrew.backup.plist
```

---

**作者**: yangyang.huang  
**邮箱**: yangyang@weimill.com  
**创建时间**: 2025-10-20
