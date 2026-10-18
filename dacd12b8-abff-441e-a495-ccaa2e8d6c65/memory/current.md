# Noctalia v5 迁移、视觉恢复与锁屏集成

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 迁移目标

用户已迁移大部分主体配置且 pin v5.0.1，周边仍有 v4 HM module/可执行文件/IPC。agent 修改 programs.noctalia-shell→programs.noctalia、noctalia 命令和 noctalia msg IPC，集成文件改名 settings/noctalia.nix；亮度字段适配并删除旧 schema 不接受的字段。

### 行为边界

此阶段保留 Swayidle/Swaylock 的 300/600/1200 秒行为，Noctalia 三个 idle behavior 关闭；保留 Cliphist，不提前采用后续 Noctalia 主锁屏方案。

### 验证

历史记录 用户 shell check Exit code0；四个配置以及 package=null/systemd=false 接线求值成功。该检查早于后续视觉和锁屏改动。

### 系统侧

flake 导入 Noctalia NixOS module，实际 programs.noctalia 配置放 niri/os/default.nix：enable 跟随 feature，package=null，recommendedServices.enable=true，systemd.enable=false。系统侧供依赖，HM 安装与生成用户设置，Niri 继续启动。

### 服务语义

recommendedServices 是 mkDefault，不覆盖 host 普通优先级配置。Aliyun/WSL 作为无 default monitor 的 headless host 在既有断言下不能合法启用 Noctalia，早先提出对它们自动启用服务的风险不适用当前有效配置。
