# 架构会话 fork：file-manager、terminal 与 Portal

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### File manager

用户想Yazi作为默认目录处理器，Wayfile移出Niri；不为GUI能力建立monitor新协议，当前Wayfile随Niri启用，Yazi跨headless始终可用。feature HM-only，以原生MIME关联选默认实现。

### Desktop entry

原先新增yazi.desktop被用户指出与包自带重复；仅需使用包的desktopID，Terminal=true仍需要可用终端入口。未把文件管理器与Portal文件选择器混为一谈。

### 验证

该阶段staged/diff草稿审查完成，没有新Nix check。Niri.enable由目录schema始终定义，不必因profile未导入就猜该enable不存在。
