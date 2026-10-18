# Flake registry 与 app metadata

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 模块 registry

用户把 self.modules 视作公开稳定的 registry，偏好非必要不用 let/in。初始建议直接把深层 modules 改为 nixosModules 不适配此结构；随后已撤回这种简单重命名建议。

### Nix 实现选择

历史会话查阅公开文档并评估仓库，建议继续用上游 Nix、接受未知 modules output 的 warning，不为这一警告迁移 Determinate Nix。用户在 历史记录 明确认可建议；没有切换 Nix 实现。有关 schema 支持的说法仅记录为当时结论，本次未重新验证。

### 验证边界

会话仅以 git diff 核对该修改，未运行 nix flake check，也未记录提交。起始 metadata 的 project hash 不能代表有既有修改及新增描述后的精确工作树。

### App metadata

用户授权修改 flake.nix；历史记录 的修改与 diff 确认给 apps.x86_64-linux.nixos-anywhere 添加英文 meta.description：Run nixos-anywhere from this flake。
