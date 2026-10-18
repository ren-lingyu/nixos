# 模块组合协议、HM interfaces、UID 与公共 llib 演进

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 架构契约

用户明确inputs只在flake.nix，那里是外部适配与最终composition root。base是所有profile公共依赖；features/hosts/users彼此平级，各管内部事务。把所有features和策略移入self.modules.hosts会改变所有权，用户已撤销。

### 事实修正

editor wrapper补显式base依赖，remote.existModule.os=false匹配仅HM实现。模块化程度评分与把flake过重当缺陷的初评已被设计说明取代。

### 验证

用户shell check Exit0覆盖当时三套NixOS配置与其他outputs；不能用此结果覆盖之后接口/用户重构。

### existModule

初版无条件把所有目录与false默认值比较，在WSL未导入Niri时失败。改os/hm为nullOr bool、default null；null表示未导入，显式true/false才核对文件。两侧同时声明或同时null，启用要求已声明；HM条件显式==true。
