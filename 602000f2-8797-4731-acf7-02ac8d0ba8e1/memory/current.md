# WSL vscode-server 移除与提交语义

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 目标与执行边界

旧目标 所审阅项目版本 是把 inline vscode-server 提取为独立模块；用户希望改成完整移除 integration。agent 仅提供手动 rebase/amend 步骤，没有代执行历史改写。

### 进行中状态

用户报告已清理工作区，进入 edit 并 stage。会话 历史记录 检查到 flake input/module import、lock 节点、WSL import、独立模块删除这些 staged 内容。nix flake check 通过来自用户报告，不是此前整理执行。

### 证据缺口

原始工作阶段的完整项目快照存在恢复限制. 新来源只保留有支持的归纳, 不根据当前 HEAD 或附近提交猜测旧环境.
