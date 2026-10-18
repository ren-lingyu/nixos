# WSL vscode-server 移除与提交语义

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 目标与执行边界

旧目标 所审阅项目版本 是把 inline vscode-server 提取为独立模块；用户希望改成完整移除 integration。agent 仅提供手动 rebase/amend 步骤，没有代执行历史改写。

### 进行中状态

已完成上述只读核验，不再处于待 amend / continue 的状态。

### 证据缺口

原始工作阶段的完整项目快照存在恢复限制. 新来源只保留有支持的归纳, 不根据当前 HEAD 或附近提交猜测旧环境.

### 结果核验

历史记录 的只读工具输出确认 rebase 已结束、工作树干净；历史结果是 chore(wsl): remove vscode-server integration。检查 flake.nix、flake.lock 和 WSL 文件未发现相关 input/import/service 残留。未重跑 Nix 检查。

### 已核实的 project provenance

历史归纳记载曾只读审阅明确的项目版本. 该事实不证明相邻脏工作区或整个会话对应同一提交. 本次仅保留审阅结论和限制, 不继承此前历史的 parent 关系.
