# Noctalia v5 迁移、视觉恢复与锁屏集成

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 迁移目标

用户已迁移大部分主体配置且 pin v5.0.1，周边仍有 v4 HM module/可执行文件/IPC。agent 修改 programs.noctalia-shell→programs.noctalia、noctalia 命令和 noctalia msg IPC，集成文件改名 settings/noctalia.nix；亮度字段适配并删除旧 schema 不接受的字段。

### 行为边界

已从迁移初期的 Swayidle/Swaylock 主路径进入 Noctalia 主锁屏阶段；原 300/600/1200 秒叙述只适用于早期 checkpoint。当前保留 swaylock 作为 allow-when-locked 的救援路径，不能把早期策略与当前职责同时当成生效配置。

### 验证

坐标方案仅静态 diff 检查，未 Nix build/check 或锁定运行验证。

### 系统侧

flake 导入 Noctalia NixOS module，实际 programs.noctalia 配置放 niri/os/default.nix：enable 跟随 feature，package=null，recommendedServices.enable=true，systemd.enable=false。系统侧供依赖，HM 安装与生成用户设置，Niri 继续启动。

### 服务语义

recommendedServices 是 mkDefault，不覆盖 host 普通优先级配置。Aliyun/WSL 作为无 default monitor 的 headless host 在既有断言下不能合法启用 Noctalia，早先提出对它们自动启用服务的风险不适用当前有效配置。

### 视觉恢复

keyboard_layout show_icon 改 show_glyph，删除 cycle_command 以用内置切换。关闭 Noctalia 壁纸层与 desktop widgets，露出 Niri 纯黑背景；媒体条件显示，sysmon 用 gauge/隐藏数值；顶部栏全宽贴顶、下圆角保留，NixOS icon colorize 为单色。

### 通知和 taskbar

toast position 与 control-center notifications 面板位置不同；IPC 无图标坐标，用户选择保留默认面板位置。taskbar icon_scale 与 bar 可用高度不同；只读 runtime settings 未覆盖 taskbar。指示点偏移是基于上游计算的解释，并非此前整理重新复现。

### 锁屏职责

Noctalia 接管常规/idle/休眠前锁定；swaylock 继续安装，Super+Alt+L 保留 allow-when-locked 救援。regular login_box 保留 session/Caps Lock/键盘布局，透明外框与半透明输入。

### 坐标失败与修正

最初声明 widget 样式但省略 cx/cy，实际落0/0导致左上角；不能继续把该旧方案当可用。Noctalia 运行时会为锁定输出补必需 login_box，删除后重生不是任意 bug。最终用户选只在 role=default monitor 显示锁屏 UI，按 mode/scale 算 logical dimensions，cx/cy 均为半宽/半高，完整 placement/widget_order，box尺寸0让Noctalia自适应。

### 显示与覆盖边界

其他输出仍锁定，视觉为黑；运行时可保留其他输出的 widget 记录。settings.toml 的旧覆盖可能优先于声明式设置，需要后续明确处理，实验不修改该文件。固定 mode/scale 是当前方案前提。
