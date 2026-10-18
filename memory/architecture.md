# 当前项目架构与约束

## 当前实现基线

这是声明式 NixOS 与 Home Manager 配置仓库. `flake.nix` 通过 flake-parts 建立外层配置, 定义 `nixosBuilder`、`moduleRegistry` 与 `nixosConfigurations`, 再调用 `llib.flakeParts.mkNixosConfigurations` 生成系统集合. 当前四个系统配置为 `nixos`、`nixos-matebook`、`nixos-server`、`nixos-wsl`, 均使用 `x86_64-linux`.

业务按 hosts、users、features、workloads 组织; share 提供公共 OS/HM 配置. 原始材料未保留在清洁来源中, 历史归纳不能替代当前实现. 本文件的当前结论来自实际源码静态核对; 历史理由仅在相应主题整合后补入.

测试由 `tests/default.nix` 注册, 包括类型、实现见证断言、host 函数、模块组合、configuration adapter 和 SOPS 函数六类. 测试代码存在不等于当前版本已经执行通过. 本次未运行 Nix 检查或构建.
