# 当前项目架构与约束

## 当前实现基线

这是声明式 NixOS 与 Home Manager 配置仓库. `flake.nix` 通过 flake-parts 建立外层配置, 定义 `nixosBuilder`、`moduleRegistry` 与 `nixosConfigurations`, 再调用 `llib.flakeParts.mkNixosConfigurations` 生成系统集合. 当前四个系统配置为 `nixos`、`nixos-matebook`、`nixos-server`、`nixos-wsl`, 均使用 `x86_64-linux`.

业务按 hosts、users、features、workloads 组织; share 提供公共 OS/HM 配置. 原始材料未保留在清洁来源中, 历史归纳不能替代当前实现. 本文件的当前结论来自实际源码静态核对; 历史理由仅在相应主题整合后补入.

测试由 `tests/default.nix` 注册, 包括类型、实现见证断言、host 函数、模块组合、configuration adapter 和 SOPS 函数六类. 测试代码存在不等于当前版本已经执行通过. 本次未运行 Nix 检查或构建.

## 模块构造、声明与职责

最终配置负责 enable、UID 绑定和外部依赖注入; 模块检查依赖, 不通过互相启用来编排依赖. 目录发现以 `os/default.nix` 或 `hm/default.nix` 为实现依据, 根 `default.nix` 可选, 不允许嵌套业务模块. 外层 flake-parts 先选择业务模块, 再生成 NixOS/HM imports; 不能把这种外层选择误判成同层递归 imports.

`_options.fp.nix` 沿路径前缀提供 configuration/metadata schema; `_metadata.nix` 保存静态值. `os/_options.os.nix` 是原生 NixOS declaration module, `hm/_options.hm.nix` 保留模块名与 HM 上下文的片段函数接口. 后缀表达解释环境, 不要求三个接口返回相同结构. 私有声明生成函数位于构建库, OS 声明进入系统 modules, HM 声明进入 sharedModules, 不依赖 share.enable. 静态路径已核对, 本次未执行 share 关闭场景的行为测试.

适配器只按 option 声明处理 functionTo 和 submodule, 不猜测执行任意函数值. 经适配的 configuration 与 metadata 合并为只读 `config.modules`; HM 从 `osConfig.modules` 读取. OS 内部状态用 moduleInternals, HM 每用户通信使用 moduleInterfaces; 声明注册不等于相应业务功能启用.

`llib` 按 types、modules、hosts、features.sops、packages、flakeParts 划分职责. 通用目录发现与系统构造分开; 集合入口内部映射到单系统构造器. 原 groupImportsByUid 已移除, 旧 self.modules registry、早期 base 身份去重和声明文件名只作为演化背景, 不恢复为当前 API. Package namespace 合并显式拒绝将 derivation 当作 namespace.

internal 表达生产与声明边界, 不是访问控制. unique 的类型合并语义不同于 readOnly 的定义数量限制; 不能机械互换, 默认值也可能成为第二个定义. UID 由最终组装赋值, 不因其他内部派生选项使用 readOnly 而改变其输入职责. cfg 只缩写自身 option 的读取, 不改定义路径、跨模块读取或诊断路径.

### 历史理由与纠错

曾考虑将所有策略推入 host 或把组合职责全面下放, 因改变同级模块所有权而撤回. 早期 share 声明聚合器导入自身导致递归, 后来先迁出同名声明文件, 再私有化到构建库. session-wrapper 默认 null 与实现值冲突, 最终删除中转 options, 由 provider 直接贡献 greeter.sessionPackages. 这些历史原因来自已审阅的清洁归纳, 不声称当前重新复现失败.

Registry 曾采用自定义 self.modules 并接受输出 schema 警告; 当前采用 flake-parts options, 不能把当年的折中当作当前目标. nixos-anywhere 的旧 app 包装属于历史; 当前代码通过部署 devShell 提供工具. 不为工具警告自动迁移 Nix 实现, 也不据早期判断推断今天的上游兼容性.
