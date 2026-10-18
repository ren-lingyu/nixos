# 模块系统重构 session: 最终恢复摘要

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

## 目标与最终决策

用 flake-parts options 描述系统, 在调用 nixosSystem 前完成业务模块选择, 简化旧自定义聚合系统. 最终配置负责 enable、UID 绑定和外部依赖注入. 模块只检查自己的依赖是否满足, 不启用依赖. `os/default.nix` 与 `hm/default.nix` 是整个系统遵循的实现约定, 中央按约定聚合是合理公共职责.

configuration 与静态 metadata 分离; 适配器仅按 option 类型处理 functionTo 和 submodule, 不猜测并执行任意函数值. NixOS 的 config.modules 为经适配后与 metadata 合并的只读视图, HM 读取 osConfig.modules. 父关闭时子开关不会单独启用实现; 条件导入后不再产生实际约束的父子 enable 断言可后续清理, 用户不将其视为阻塞或功能故障.

## 库与构造入口

- `llib.types`: existModule、monitor、monitors.
- `llib.modules`: discoverModules、mkOptionName、mkOptionTree、mkOptionModules, 以及 modules.assertions.existModule.
- `llib.hosts`、`llib.features.sops`、`llib.packages`: 对应领域工具, 保持原有函数名.
- `llib.flakeParts`: 配置适配和 mkNixosSystem、mkNixosConfigurations; 保留 flakeParts.types, 不增加 configurations namespace 层.

库文件按职责命名. flake 调用 mkNixosConfigurations 生成整个配置集合, 函数内部映射到 mkNixosSystem. 无生产调用的 groupImportsByUid 定义、导出、旧测试及注册入口已删除. 本轮没有全面缩小原 helper 的导出面.

## 声明注册和业务送达

`lib/flakeParts.configurations.nix` 的 let 中保留两个私有生成函数 mkInternalOptionsModules、mkInterfaceOptionsModule, 通过私有 mkDeclarationModules 返回 nixosModules/homeModules 统一交给 mkNixosSystem. OS 声明进入系统 modules, HM 声明进入每用户 sharedModules. 不依赖 share.enable, 也不表示声明所属功能已开启.

share 只提供公共 OS/HM 配置. 曾新增的 builder.nixosModules/homeModules 和 flake 内联聚合方案已经撤回, 不能当作最终 API. user HM 实现送达绑定 UID, feature 按 allowUidList 送达, 其他类别 HM 实现及 registry 集成通过 sharedModules 送达. moduleInternals 与 moduleInterfaces 的值、类型和合并语义保持既有机制.

## 最终声明文件协议

用户提交并要求实施 `_options.<system>.nix` 命名方案. 这是本仓库自动发现约定, 不是三种 module system 的原生自动加载规则. 后缀标识解释环境, 不固化具体 option namespace; 不统一返回值和函数接口.

| 文件 | 接口与注册方式 |
| --- | --- |
| `_options.fp.nix` | 沿模块路径前缀发现, 保留 configuration/metadata schema 分支和 metadata 注入 |
| `os/_options.os.nix` | 原生 NixOS declaration module, 由私有构建逻辑注册 |
| `hm/_options.hm.nix` | 原有以模块名与 HM 求值上下文为参数的声明片段, 注册 moduleInterfaces |

_metadata.nix 保存静态数据, 名称不变. default.nix 的含义、发现规则和 enable/allowUidList 选择语义不变. 没有旧文件名兼容回退.

实际重命名 18 个文件: 12 个 FP、4 个 OS、2 个 HM. 更新 lib/modules.nix 的 FP schema 路径, 以及 lib/flakeParts.configurations.nix 的 OS/HM pathExists 和 import 路径. 新旧文件内容逐个与原项目 HEAD 对照, 18 个声明文件字节未变; 原有测试无旧声明文件路径引用, 因而没有为了改名更改测试内容.

README 已维护新协议、三种接口差异、声明位置和目录树. 此前同步过 configuration/registry/builder、UID、functionTo、namespace、share、inputs、本地包和 tests 的说明. 本轮没有改变 options、moduleInternals 或 moduleInterfaces 属性名称.

## 困难发现及保留的修复

- 最初 stack overflow 来自 share 的声明聚合器将自身加入 imports, 不是 adapter 递归. trace 发生在 imports 收集, 省略约两万个重复帧. 最终聚合固定在库的私有生成函数中, 不在被发现的声明文件中.
- session-wrapper 只读 options 的默认 null 与实现值冲突, 后续删除两个中转 options. niri/x11-session 用局部 wrapper 直接贡献 greeter.sessionPackages; niri 用 mkBefore, greeter 校验非空 meta.mainProgram. 注册会话不自动启用 greeter.
- 负向 UID 测试不再用 recursiveUpdate 的空 users 集合假装清空 registry, 改用未登记的 UID 1001.
- agent 曾将中央聚合职责视为需要全面下放, 并将外层选择误判成同层 imports 循环, 均已根据用户澄清纠正; 不应重新引入相应扩展任务.

## 验证证据与限制

1. 初期实际跑过 WSL 完整 trace 诊断并复现栈溢出. read-only 冲突与夹具修复后, nix flake check 成功, 四台配置可求值.
2. 直接会话包贡献修改后再次 nix flake check 成功. 两次结果仅覆盖各自当时的脏工作区.
3. 后续 helper 清理、集合入口、namespace 迁移、声明私有化和 README 修改仅有定向搜索、diff 审查与 git diff --check 证据, 没有新 Nix 验证.
4. 最终文件改名完成内容一致性检查、旧命名/路径无残留搜索和 diff --check. 用户随后 stage 的 diff 显示全部 18 个 rename 为 100% 相似, loader 与 README 更新配套. 最后已知普通工作区无未暂存改动, agent 仅维护提交草稿, 没有替用户提交.
5. session 内没有证明改名后 nix flake check --show-trace 或“share 关闭仍注册”的行为测试通过. 不可把早期 all checks passed 当作这些后续状态的验证. 不附加未经证实的 project parents.
