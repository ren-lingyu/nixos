# Agent provider interface 与 SOPS 解耦

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 接口

opencode.providers.deepseek与pi.providers.deepseek，enable默认false，apiKey为非空密钥文件路径字符串，unique冲突语义。用户修apiKey大小写；嵌套mapAttrs生成，以agent_命名，不改成providers.<agent>误导归属。

### 文件形态

用户要求feature_: {options,config,osConfig,pkgs,lib,llib,…}: {...}，无let/in；保留agent-first namespace。

### 验证

三文件接口/消费/用户数据配套staged、无unstaged，草稿更新，未Nix检查或build。这里的旧default/unique设计不能提前套用后续readOnly迁移。

### SOPS解耦

agent只消费apiKey文件路径，可来自任意secretmanager，移除全局SOPS assertion。Lingyu实际用SOPS，所以其provider输入用SOPS mkIf守卫；不要求agent feature了解密钥来源。

### 模型方案修正

曾试nullable model/smallModel interface，用户要求撤销；最终根据DeepSeek provider enable自动设置默认model/small_model，未启用则省略非必需字段，不再公开模型接口。enabled_providers始终显式生成，空列表不代表放行其他provider。

### 完整staging

中途agent变更staged但Lingyu guard unstaged，草稿拒绝不完整集合；历史记录最终集合无unstaged并通过cached diff检查。没有check/build/实际commit记录；scope围绕核心agent行为而非枚举每个受影响目录。
