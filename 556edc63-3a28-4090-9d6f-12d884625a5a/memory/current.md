# 引入 flake-parts 并确定 self.modules registry

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 依赖决定

先新增root flake-parts input/lock，不让nixvim强制follows以减少兼容风险。重复flake-parts节点本身不是运行期重复包成本，也不等于必须合并。

### 状态

修改flake.nix后MM，旧index仍在；未运行Nix检查。嵌套nixosModules此时还未验证。

### Flake结构

用mkFlake；systems而非system。NixOS configurations保持顶层flake，不按system转置；nixos-anywhere仅为便捷调用，放apps而非提供packages。

### 可执行接口

采用inputs'的per-system投影，program用pkgs.lib.getExe'和显式nixos-anywhere名，避免手拼bin路径和mainProgram歧义。

### Schema问题

历史nix flake check失败报features.share缺失；会话定位nested nixosModules与flake-parts标准输出处理不匹配。相关原因解释是当时诊断，不在此前整理重验。

### Registry决定

用户拒绝扁平命名及把registry藏let，最终自己选择modules。保留self.modules.features/hosts/users层级；不是flake-parts约定，而是自定义输出。flakeModules已有生态含义，不采用。

### 验证与状态

最终staged只有flake.nix；草稿修正self.modules是自定义output的表述。没有本源最终rename后check成功记录，也没有app的meta.description（那在另一个已整理源中处理）。
