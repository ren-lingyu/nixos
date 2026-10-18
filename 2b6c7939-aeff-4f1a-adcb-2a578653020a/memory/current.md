# X11 fallback 从 XFCE 迁移到 IceWM

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 目标

主会话仍Niri；X11是通用兼容fallback，支持greeter直接登录，也支持Niri已登录后从tty运行X11-Session。不是wemeet专用，不需要多种实现profile。

### OS/HM

最终采用OS+HM分层：OS管startx/Xorg/IceWM和session入口；HM管用户launcher并优先原生programs/services options。此前为避免接口变化而建议不加HM已被后续用户要求取代。

### 边界

保留清理DISPLAY/WAYLAND_DISPLAY/SWAYSOCK/NIRI_SOCKET，不硬编码启动fcitx5，不绑共享user graphical target；跨VT剪贴板互通不在目标中。第一阶段不消费host monitors、不加新的monitor internal option、不生成xrandr布局，仅提供工具。

### 实现

existModule.hm=true，wrapper仍X11-Session，client通过dbus-run-session启动icewm-session；OS启用IceWM/startx，移除XFCE；新增HM侧rofi等用户launcher最小配置，提供xdg-utils/xrandr但无布局策略。

### 验证与未解问题

用户报告rebuild test成功、tty2进入X11且wemeet大致正常；Edge等会在Niri已有实例中打开。该问题在末尾被重复提出后中断，没有已完成的根因诊断或修复；不能认定switch/boot或重启是答案。
