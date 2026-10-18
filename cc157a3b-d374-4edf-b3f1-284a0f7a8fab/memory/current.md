# Features 与 hosts 的 cfg 局部别名重构

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 契约

cfg只用于读取自身feature配置；OS用config.modules.features.<name>，HM用osConfig。定义左侧option路径、跨feature引用、动态路径、options schema及message完整路径不替换；定义右侧读取自身cfg可以使用。

### 实现

24个features文件完成别名整理；原staged X11 HM文件为MM，额外清理trailing whitespace在worktree，不暗中stage。

### 验证

hosts阶段第一次沙箱外no-build flake check通过，用户rebuild后symlink/closure对比仍一致，failed units为空。源历史记录压缩后的resume只是恢复和总结，没有新仓库操作。

### 运行证据

用户rebuild test后，历史只读比较current/system-profile/booted symlink仍指向事前同一store closure，diff-closures无输出，沙箱外failed-units为空。比copying0paths更强，但仅覆盖该主机当时active closure。

### 状态

hosts11文件staged，提交草稿区分集合级和实例级cfg。源未提供这组修改后exact project commit；无额外parent。

### Host cfg

hosts11文件改用实例级cfg=config.modules.hosts.<host>，集合入口用cfg=config.modules.hosts；仅替换自身读取，定义路径/错误文本不改。users评估后未修改。
