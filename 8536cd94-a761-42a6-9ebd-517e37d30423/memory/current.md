# Secrets 分层、host identity 与 rage-armored

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 安全审查

历史记录 授权后，历史 agent 审阅 SOPS 文件，报告业务叶子是 ENC[...]，recipient 与 .sops.yaml 公钥一致，未发现明文。0644 对密文/公钥可接受，但该检查不证明私钥保管、recipient 私钥安全或当前文件内容。未解密。

### Host 公钥模型

已由 publicHostKey 迁到 identityKeys.<format>.{public,private}.{key,path}；key 是内容或材料载体，path 是 runtime 位置。private.key 为 nullOr(either path nonEmptyStr)，metadata 显式展开结构。仓库不应放明文私钥；类型本身不能强制加密。

### 验证与状态

最终 wrapper 只有源码与 diff 审查，未 build/eval；不能宣称 runtime wrapper、armor/rekey 已验证。很早的 assistant 回答对 placeholder scope 的解释自相矛盾，已被后续 token substitution 方案取代，不应当作可靠 Nix 教程。

### Secrets 分层

用户要引入 agenix 作为 OS 基础设施；sops-nix 保留为可选、可组合的 feature。这不是全面替换 sops-nix。

### SOPS 迁移

secret→sops 同步 option、moduleInterfaces、moduleFunctions、flake 和引用，压平重复 sops.sops。首次用户 nix flake check 失败是 tests/secret-functions 仍引用旧 helper；历史记录 更新为 sops-functions，历史记录 用户 shell 记录 Exit code 0。

### SSH 与 age

用户把 SSH host key 定为 host 身份；age recipient 是派生表示，迁为 identityKeys.ssh.public.ageRecipient，移除把 identityKeys.age 当独立 host 身份的结构。

### OS 设施动机

agenix/rekey 用于 OS 基础秘密，降低 rebuild 受 sops-nix Go 构建/网络阻塞时失去秘密部署能力的风险；HM/应用 secrets 继续用可选 SOPS。

### 唯一 host helper

getUniqueEnabledHost 在本会话此时仍非唯一返回 {}；但全局 host assertion 已从 <=1 改成 ==1。最小 host 仍是具有身份的 profile，并不等于无 host。

### 消费和风格

greeter/interconnect/niri 改用 helper；此阶段消费端显式判断 enabledHost_ != {}。条件加括号；跨行赋值通过外层括号让等号行与结束分号行同缩进。

### 消费和断言

greeter/niri/interconnect 删除重复数量断言及空 host 分支，直接读所需字段；users 的 enabled-host 用户归属检查有独立意义，保留。此设计的后续求值风险由另一个八月 session 发现，当前阶段不能声称已发现或已修复。

### 测试

module-composition 增加 0/1/多个 host 真值覆盖；missing-UID fixture 显式启用 thinkbook，unregistered-UID fixture 补 existModule。记录是测试代码调整，未在此区间运行检查。

### OS 接线

flake.nix 导入 agenix/rekey 外部模块与 flakeModule；实际 age 配置经用户移动到 modules/default.nix。identityPaths 来自 SSH private runtime path；最终 历史记录 审阅中 hostPubkey 已是 SSH public.key，不再把较早 ageRecipient wiring 当作最终实现。

### Master identity

age.rekey.masterIdentities 是单独的 master identity 配置，不是从 host identity 派生；历史提交草稿遗漏后已专门补充。

### WireGuard 私钥

interconnect hub/spoke 使用 age.secrets 与 rekeyFile，新增 ingress-hub.age / ingress-spoke.age；重复 mkIf 被用户移除。stage 变更被评估为一个连贯迁移，不等于已经执行 commit。

### 纯文本 Git 策略

用户明确不接受非纯文本文件进入 Git；agenix-rekey 默认 age ciphertext 是二进制，这不是加密失败。采用专用于 rekey 的 rage-armored，不覆盖全局 rage。

### Wrapper 最终形态

用户提取 pkgs/rage-armored；flake packages 通过 import ./pkgs 暴露，再给 agenix-rekey.agePackage 使用。基于 rage.overrideAttrs 保留 old.postInstall，原程序移为 rage-unwrapped。wrapper.scm 是纯 Scheme body；Nix prepend Guile shebang 与 --no-auto-compile。用 @rage-unwrapped@ 和 substituteInPlace --replace-fail 注入路径，运行时不靠 makeWrapper 或环境变量。仅 encrypt 且未 armor/decrypt 时追加 --armor。

### 最后修复

历史记录 发现把 ${./wrapper.scm} 放进脚本会插入 store 路径而非 Scheme 源码，已改为 builtins.readFile ./wrapper.scm。保留 concatStringsSep，已讨论路径转义和 $out 展开。
