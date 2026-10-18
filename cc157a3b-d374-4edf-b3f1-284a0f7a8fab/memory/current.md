# Features 与 hosts 的 cfg 局部别名重构

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 契约

cfg只用于读取自身feature配置；OS用config.modules.features.<name>，HM用osConfig。定义左侧option路径、跨feature引用、动态路径、options schema及message完整路径不替换；定义右侧读取自身cfg可以使用。

### 实现

24个features文件完成别名整理；原staged X11 HM文件为MM，额外清理trailing whitespace在worktree，不暗中stage。

### 验证

目前只有定向搜索和diff检查；尚无运行检查，不能把别名重构意图直接当作无行为变化证明。
