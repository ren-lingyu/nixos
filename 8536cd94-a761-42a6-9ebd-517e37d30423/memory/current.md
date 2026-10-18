# Secrets 分层、host identity 与 rage-armored

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 安全审查

历史记录 授权后，历史 agent 审阅 SOPS 文件，报告业务叶子是 ENC[...]，recipient 与 .sops.yaml 公钥一致，未发现明文。0644 对密文/公钥可接受，但该检查不证明私钥保管、recipient 私钥安全或当前文件内容。未解密。

### Host 公钥模型

已由 publicHostKey 迁到 identityKeys.<format>.{public,private}.{key,path}；key 是内容或材料载体，path 是 runtime 位置。private.key 为 nullOr(either path nonEmptyStr)，metadata 显式展开结构。仓库不应放明文私钥；类型本身不能强制加密。

### 验证与状态

历史记录 提交草稿只覆盖 staged host metadata；flake.nix 仍 unstaged，不能把二者描述成一个已提交状态。

### Secrets 分层

用户要引入 agenix 作为 OS 基础设施；sops-nix 保留为可选、可组合的 feature。这不是全面替换 sops-nix。

### SOPS 迁移

secret→sops 同步 option、moduleInterfaces、moduleFunctions、flake 和引用，压平重复 sops.sops。首次用户 nix flake check 失败是 tests/secret-functions 仍引用旧 helper；历史记录 更新为 sops-functions，历史记录 用户 shell 记录 Exit code 0。

### SSH 与 age

用户把 SSH host key 定为 host 身份；age recipient 是派生表示，迁为 identityKeys.ssh.public.ageRecipient，移除把 identityKeys.age 当独立 host 身份的结构。

### OS 设施动机

agenix/rekey 用于 OS 基础秘密，降低 rebuild 受 sops-nix Go 构建/网络阻塞时失去秘密部署能力的风险；HM/应用 secrets 继续用可选 SOPS。
