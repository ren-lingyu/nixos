# 模块重构: 组装约定与故障修复阶段

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

## 目标与已采用的职责边界

用户希望用 flake-parts 的 options 描述最终配置, 据此在调用 NixOS 构造器前生成 OS/HM imports, 删除旧 `self.modules.*` wrappers 与重复聚合逻辑.

- 最终配置决定 profile 的 enable、UID 绑定和外部集成. 模块仅检查依赖是否满足, 不能启用其他 profile.
- `os/default.nix` 与 `hm/default.nix` 是统一目录约定. 中央发现并聚合这两侧是合理公共职责, 不需要为“模块自治”另建编排层.
- configuration、静态 metadata 与 NixOS 求值期内部状态分离. 此时 `_options.nix` 提供 configuration/metadata schema, `_metadata.nix` 提供静态值.
- 实际 imports 列表由外层 flake-parts options 生成; 不应误把同层 `config.modules` 决定 imports 的循环问题归咎于这条已有构造路径.

## 困难发现与修复

1. WSL 求值栈溢出的完整 trace 指向 imports 收集, 有约两万个重复帧. `share/os/internal-options.nix` 聚合所有模块的同名文件时也选中了自己. 将 OS 聚合移至 `share/os/default.nix`, HM 聚合移至 `share/hm/default.nix`, 删除作为聚合器的两个中转文件, 消除自导入.
2. niri、x11-session 的只读 session-wrapper options 同时提供默认 null 和实现值, 导致 read-only 多次定义错误. 当时移除默认值后消除了冲突.
3. 模块组合测试用 recursiveUpdate 将主机 users 覆盖成空集合, 实际保留已登记 UID 1000. 将负向场景改用未登记的 UID 1001, 继续验证真实的未注册 UID.
4. 进一步去掉两个 session-wrapper options 和相关 null 状态断言. wrapper 作为模块局部值, niri 和 x11-session 直接贡献 `moduleInternals.features.greeter.sessionPackages`; niri 保留 mkBefore. greeter 统一校验非空 meta.mainProgram. 不因注册会话而启用 greeter.

## 被纠正的判断

agent 最初建议把组合职责全面下放并允许跨模块依赖编排, 被用户明确否定. 后来还将外层 imports 误判成缺少 specialArgs 配置入口, 已纠正. 这些不是未完成目标.

父 enable 为 false 时业务模块不导入, 子 enable 为 true 也不会单独启用实现. `!child.enable || parent.enable` 若只在父模块启用时导入, 就是冗余断言, 不是重构阻塞或已证实功能缺陷. 用户接受其作为非阻塞中间状态; 只有将这种配置定义为非法时, 才有必要在外层设置可达校验.

## 验证与状态

- session 内实际运行 Nix 诊断并复现了栈溢出; 沙箱缓存访问失败后经用户批准使用沙箱外执行.
- 修复 read-only 冲突和测试夹具后, `nix flake check` exit 0, 四台 NixOS 配置通过求值, 最终输出 all checks passed.
- 直接会话包贡献修改后再次运行 `nix flake check`, 也 exit 0 并输出 all checks passed.
- 这些结果仅对应当时的修改工作区, 不关联后续提交或未来改动.

## 当时下一步

主体重构已可用. 后续讨论 lib 的 API 与命名空间整理、构造整个 configurations 集合的入口和旧 helper 清理; 不能为了笼统的“自治”再次扩大职责或自动启用依赖.
