# 架构会话 fork：file-manager、terminal 与 Portal

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### File manager

用户想Yazi作为默认目录处理器，Wayfile移出Niri；不为GUI能力建立monitor新协议，当前Wayfile随Niri启用，Yazi跨headless始终可用。feature HM-only，以原生MIME关联选默认实现。

### Desktop entry

原先新增yazi.desktop被用户指出与包自带重复；仅需使用包的desktopID，Terminal=true仍需要可用终端入口。未把文件管理器与Portal文件选择器混为一谈。

### 验证

用户check失败点被源码修复；最后历史记录仍明确没有修复后成功检查结果。不要用更早Niri环境的check替代WSL/Portal验证。

### Terminal

从user terminal.nix迁成HM terminal feature；保留Kitty/Alacritty与xdg.terminal-exec，桌面/WSL启用、server minimal不启用。用户stash掉file-manager后单独整理terminal边界。

### 终端接口

Niri Mod+T、Fuzzel、Noctalia改为xdg-terminal-exec并受该HM能力enable守卫；去掉Kitty直接依赖及专用-e。没有新增仓库internal桥接option；缺接口时省略这些设置。

### File chooser

新增file-manager.fileChooser.enable，默认随feature；统一控制Portal、backend/provider、配置和terminal能力检查，不把整个chooser绑到Niri。

### 恢复与语法

用户恢复stash后worktree冲突标记已修，但index旧版本仍有，后用户add清除。初次file-manager check失败因顶层assertions与显式config混用；修复为放在config内，并去冗余enable条件。

### 能力契约

用户最终认可HM侧检查实际config.xdg.terminal-exec.enable，而非OS侧间接检查terminalfeature及allowUidList。不会反向禁止其他模块提供原生终端接口，也不增加排他双向等价断言。

### Portal链路

file-manager/termfilechooser→xdg-terminal-exec→终端→Yazi，只有调用XDG FileChooser Portal的应用才能走这条链。不会保证所有GTK/Qt/浏览器应用都使用它。

### OS配套

在WSL上首次独立启用HM Portal，useUserPackages模式要求系统pathsToLink含/share/applications及/share/xdg-desktop-portal。增加file-manager/os/default.nix，existModule.os=true；整体cfg.enable守卫，路径列表用fileChooser.enable的optionals，不清空其他模块列表。

### 最终状态

最后一次staged审阅主题已变为ThinkBook framebuffer/udev/kmscon初始化，不能把末尾提交草稿当作Yazi Portal通过的证明。这只是所选归纳覆盖的范围, 不宣称恢复了完整原始对话。
