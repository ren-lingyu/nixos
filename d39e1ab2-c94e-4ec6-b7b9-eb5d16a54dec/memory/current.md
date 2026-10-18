# Agent provider interface 与 SOPS 解耦

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 接口

opencode.providers.deepseek与pi.providers.deepseek，enable默认false，apiKey为非空密钥文件路径字符串，unique冲突语义。用户修apiKey大小写；嵌套mapAttrs生成，以agent_命名，不改成providers.<agent>误导归属。

### 文件形态

用户要求feature_: {options,config,osConfig,pkgs,lib,llib,…}: {...}，无let/in；保留agent-first namespace。

### 验证

三文件接口/消费/用户数据配套staged、无unstaged，草稿更新，未Nix检查或build。这里的旧default/unique设计不能提前套用后续readOnly迁移。
