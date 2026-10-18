# 引入 flake-parts 并确定 self.modules registry

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 依赖决定

先新增root flake-parts input/lock，不让nixvim强制follows以减少兼容风险。重复flake-parts节点本身不是运行期重复包成本，也不等于必须合并。

### 状态

原outputs尚未迁到mkFlake，staged只有输入和lock，提交草稿仅审阅该变更。用户后续自报已提交，但未核实其exact hash。
