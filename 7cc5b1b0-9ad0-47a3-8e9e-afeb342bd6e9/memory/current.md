# 架构会话 fork：file-manager、terminal 与 Portal

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### File manager

用户想Yazi作为默认目录处理器，Wayfile移出Niri；不为GUI能力建立monitor新协议，当前Wayfile随Niri启用，Yazi跨headless始终可用。feature HM-only，以原生MIME关联选默认实现。

### Desktop entry

原先新增yazi.desktop被用户指出与包自带重复；仅需使用包的desktopID，Terminal=true仍需要可用终端入口。未把文件管理器与Portal文件选择器混为一谈。

### 验证

独立staged集合与格式检查通过；没有该terminal/Niri变更Nix运行检查。

### Terminal

从user terminal.nix迁成HM terminal feature；保留Kitty/Alacritty与xdg.terminal-exec，桌面/WSL启用、server minimal不启用。用户stash掉file-manager后单独整理terminal边界。

### 终端接口

Niri Mod+T、Fuzzel、Noctalia改为xdg-terminal-exec并受该HM能力enable守卫；去掉Kitty直接依赖及专用-e。没有新增仓库internal桥接option；缺接口时省略这些设置。

### File chooser

新增file-manager.fileChooser.enable，默认随feature；统一控制Portal、backend/provider、配置和terminal能力检查，不把整个chooser绑到Niri。
