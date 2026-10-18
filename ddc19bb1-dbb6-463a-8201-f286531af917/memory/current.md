# 模块重构: 声明聚合独立于 share

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

## 架构与 API

flake-parts configuration 显式选择 profile、UID 绑定和外部集成; 外层先完成 enable 决策, 构造器再生成 NixOS/HM imports. `os/default.nix`、`hm/default.nix` 是统一实现约定, 可选模块根 default.nix 承载补充状态或断言. 模块不能启用依赖.

configuration/metadata schema 此时仍在 `_options.nix`, 静态值在 `_metadata.nix`. configuration 经 functionTo/submodule 适配后与 metadata 合并为只读 config.modules, HM 用 osConfig.modules 读取. 父关闭时子选项不会单独生效; 冗余父子 enable 断言是非阻塞清理项.

lib 公共命名空间为 types、modules (包含 modules.assertions)、hosts、features.sops、packages 和 flakeParts (包含 flakeParts.types). 保留函数名, 去掉 moduleFunctions/packageFunctions/default 组织层. flakeParts 直接导出 mkNixosSystem、mkNixosConfigurations 和适配入口, 不额外套 configurations namespace. groupImportsByUid 及其旧测试已删除. 集合入口内部映射到单系统构造器.

## 已采用的声明注册方案

目标是将内部/接口 options 的注册从 share 公共配置撤回, 不依赖 share.enable, 同时保留两套不同的声明接口.

`lib/flakeParts.configurations.nix` 的 let 中新增私有函数:

- mkInternalOptionsModules: 根据发现结果返回各模块 `os/internal-options.nix` 的列表; 文件本身是原生 NixOS module.
- mkInterfaceOptionsModule: 返回一个 HM module, 在每个用户的 HM 上下文中读取 options、config、osConfig、pkgs、lib、llib, 调用各模块 `hm/interface-options.nix` 的原有片段函数, 将结果置于 moduleInterfaces option tree.
- mkDeclarationModules: 统一返回 nixosModules/homeModules 两侧声明模块, 由 mkNixosSystem 调用.

两个具体生成函数和统一接口均不导出到 llib. mkNixosSystem 将 OS 声明模块放进系统 modules, 将 HM 声明模块放进 home-manager.sharedModules, 与已启用业务模块的送达独立. share 的 OS/HM default.nix 只保留公共业务配置, 删除相关聚合代码和不再使用的参数.

曾实施的 builder.nixosModules/homeModules options 加上 flake.nix 内联声明聚合只是中间方案, 用户随后采用固定库机制; 两个新增 builder options 和 flake 内联代码已撤销, 不属于最终 API.

## 保留的修复与验证限制

早期递归 imports 来自聚合文件选中了自己, 曾将聚合移至 share/default.nix 修复; 此阶段进一步把机制私有化到构建库. 不再创建名为声明文件的聚合器.

session-wrapper 中转 options 已删, niri/x11-session 局部构造包并贡献 greeter.sessionPackages, niri 保留 mkBefore; greeter 校验非空 meta.mainProgram. 组合测试用 UID 1001 验证未登记用户, 避免 recursiveUpdate 空集合不清空旧用户的问题.

早期修复和会话包贡献阶段实际有两次 nix flake check 成功. lib 整理和本阶段声明迁出后仅做定向搜索、完整 diff 审查与 git diff --check; 没有后续完整 Nix 验证. 不将之前成功推广到此阶段.

## README 与交付

README 已按当时工作区同步: flake-parts schema/registry/builder、metadata、UID 绑定、HM 送达、functionTo 适配、私有声明聚合、lib 命名空间, 以及目录、inputs、本地包和 tests 说明. 移除旧 wrappers、extra-options.nix 和 modules/default.nix 的有效结构描述, 保留真实存在的功能配置说明. 文档操作没有运行 formatter 或 Nix 检查.

agent 仅根据 staged diff 准备提交草稿, 没有普通项目 Git 写操作. 后续需保持“声明注册独立于业务启用”和“函数接口不必统一”的边界; 若要继续验证, 使用新证据而非旧工作区的检查结果.
