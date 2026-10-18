# 模块重构: lib 命名空间与构造入口整理后

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

## 已采用的架构

最终配置在 flake-parts 层决定 enable、UID 绑定及外部集成, 再由构造函数生成 NixOS/HM 模块列表. OS/HM 是统一目录约定; 模块只校验依赖, 不能启用其他 profile. configuration 与 metadata 在外层分离, 到 NixOS 中适配后合并为只读 `config.modules`; HM 读取 `osConfig.modules`.

此时声明文件仍使用 `_options.nix`、`os/internal-options.nix`、`hm/interface-options.nix`. `_metadata.nix` 只保存静态值. OS 内部状态使用 moduleInternals, HM 用户通信使用 moduleInterfaces.

## lib API 整理

用户要求尽量保持函数名, 重新组织 namespace 并减少无意义嵌套, 保留逻辑关系. 已实施:

- `moduleFunctions.default` → `modules`, 包含 discoverModules、mkOptionName、mkOptionTree 和 mkOptionModules.
- 根 assertions 中的 existModule → `modules.assertions.existModule`.
- `moduleFunctions.hosts.default` → `hosts`.
- `moduleFunctions.features.sops` → `features.sops`.
- `packageFunctions` → `packages`.
- `moduleFunctions.configuration` 的构造与适配函数直接放入 `flakeParts`, 不增加 configurations namespace 层.
- 原 `flake-parts.types` → `flakeParts.types`.

库文件按职责改名为 modules.nix、modules.assertions.exist-module.nix、hosts.nix、features.sops.nix、packages.nix、flakeParts.configurations.nix 和 flakeParts.types.nix. lib/default.nix 聚合这些实现. flake、modules、pkgs 和 tests 的调用全部随之调整. 保留既有 helper 的导出范围; 此轮不额外改造 adapter 或统一函数接口.

## 构造入口与清理

- 新增 mkNixosConfigurations, 接受 rootPath、builder、registry 和 configurations, 内部用 mapAttrs 调用 mkNixosSystem. flake 只调用该集合入口. 这是封装生成职责, 不是消除映射操作.
- groupImportsByUid 已没有生产调用, 只剩旧测试. 按用户要求删除其定义文件、lib 导出、feature-import-grouping 测试文件及注册入口.
- 不为函数名或无效冗余断言扩大重构. mkOptionName 继续保留; 模块结构发现与系统构造属于不同逻辑职责.

## 仍有效的故障修复与约束

之前的栈溢出来自声明聚合器导入自己, 已通过将聚合移到 share 的 default.nix 消除. session-wrapper 只读默认值冲突已通过移除中转 options 彻底消除; 提供者直接向 greeter.sessionPackages 贡献包, niri 使用 mkBefore, greeter 统一校验 meta.mainProgram. 未登记 UID 的测试使用 1001, 不用 recursiveUpdate 的空 users 集合假装覆盖.

父关闭时子开关被忽略, `!child.enable || parent.enable` 若只在父启用时加载就没有实际约束作用. 用户接受它作为非阻塞清理项, 不是功能缺陷.

## 验证边界

模块修复和会话包贡献阶段确有两次 nix flake check 通过, 仅验证当时工作区. 本阶段的 helper 删除、集合入口和 namespace 迁移只完成定向引用检查与 git diff --check; 没有运行新的 Nix 求值或构建. 新路径最初未被跟踪, agent 未替用户 stage.

## 当时下一步

主体重构和命名空间整理已完成. 需要单独审视声明注册对 share 的依赖, 同步 README 中旧 wrappers、extra-options.nix、目录及输入说明. 若要声明新状态通过完整检查, 必须另有相应 Nix 检查结果, 不能沿用前阶段成功记录.
