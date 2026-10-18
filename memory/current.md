# 当前项目记忆

## 项目目标与维护入口

维护可组合的声明式 NixOS 与 Home Manager 配置, 将最终系统组装, 业务实现, 静态 metadata 和内部接口分开. 当前没有待继续的历史整理任务, 也没有已接续的新实现任务. 后续按具体需求维护项目, 从本文件恢复当前状态, 从 [architecture.md](architecture.md) 查阅约束与理由, 从 [consolidation.md](consolidation.md) 按需追溯历史知识来源.

当前静态事实基线为普通项目已提交的 `48c7f0fc403d525ce982d11e613008042cf1e456`. 本记忆只采用该提交中的项目内容; 后续更新需要重新核对所选基线. Formal GAW 使用 `_agents`, 没有活动 Auxiliary 分支; 历史来源已由 Formal ancestry 保留.

## 已实现的范围

`flake.nix` 是最终组装入口, 提供以下 `x86_64-linux` 系统. 配置存在不代表对应机器已经部署到此提交.

| 系统输出 | Host profile | User profile | 主要配置范围 |
| --- | --- | --- | --- |
| `nixos` | `thinkbook` | `lingyu` | Niri/Noctalia, IceWM fallback, 桌面应用, Flatpak, VM, WBO |
| `nixos-matebook` | `matebook` | `lingyu` | Niri/Noctalia, 编辑器与桌面工具 |
| `nixos-server` | `aliyun` | `lingyu-minimal` | Shell, SOPS, Caddy workload |
| `nixos-wsl` | `wsl` | `lingyu` | NixOS-WSL, 编辑器与终端工具 |

实现入口为 `flake.nix`, 公共库在 `lib/`, 业务模块在 `modules/`, 本地包在 `pkgs/`. 关键接口与消费者的源码路径见 architecture.md. Flake 另提供 `legacyPackages`, overlays, OS/HM modules, `deploy`/`secret` devShells, treefmt formatter 和 checks.

## 实现与验证状态

本轮重新核对已提交的组装入口, README, 库和关键消费者, 包括 FileChooser, agent provider, Codex/Pi/rage-armored 包及 Noctalia 设置. 结论是静态实现事实, 未执行 Nix eval/check/build, 系统部署或运行时应用验证. 历史 session 的成功报告只覆盖当时工作区, 不能替代本基线验证.

`tests/default.nix` 注册六类 checks: `lib-types`, `exist-module-assertions`, `host-functions`, `module-composition`, `configuration-adapter`, `sops-functions`. 覆盖类型与实现见证, 唯一 host/monitor, UID 与 feature 组合负例, 配置适配及 SOPS 输入处理; treefmt 另提供格式检查. `nix flake check` 是 README 所列验证入口, 实际运行仍按宿主授权规则进行.

## 已知限制与后续决策

- FileChooser/跨会话应用, Clash geodata 实际加载, Noctalia runtime settings/多显示器, fbset/kmscon 模式恢复, rage-armored 行为仍缺当前运行证据. 这些是历史留下的验证边界, 不等于全部仍可复现的当前 bug.
- `README.org` 的 `functionTo` 示例仍用 `emacs31-pgtk`, 而 `flake.nix` 当前桌面配置使用 `emacs-pgtk`. 后续编辑器或文档维护时可同步示例; 尚未修改 README.
- 后续实现需求, 相关 Issues/PRs 和部署状态以实际检查为准, 当前未建立外部跟踪结论. 过去的整理进度与清理操作已退出当前维护入口, 需要审计时查 Formal first-parent 历史.
