# Secrets 分层、host identity 与 rage-armored

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 安全审查

历史记录 授权后，历史 agent 审阅 SOPS 文件，报告业务叶子是 ENC[...]，recipient 与 .sops.yaml 公钥一致，未发现明文。0644 对密文/公钥可接受，但该检查不证明私钥保管、recipient 私钥安全或当前文件内容。未解密。

### Host 公钥模型

publicSshKey 实际存 age recipient，命名误导。用户采纳 publicHostKey = unique(submodule …)，用 map 生成 age/ssh 子 option；三个 host metadata 改成 publicHostKey.age。历史记录 删除多余 formats 局部列表，改为内联。

### 验证与状态

四个相关文件是 MM（旧 index 与新 worktree 不同），没有 build/eval；vaultix 已撤销，不应把未来恢复设想当成已实现。
