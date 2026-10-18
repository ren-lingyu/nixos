# 模块组合协议、HM interfaces、UID 与公共 llib 演进

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 架构契约

用户明确inputs只在flake.nix，那里是外部适配与最终composition root。base是所有profile公共依赖；features/hosts/users彼此平级，各管内部事务。把所有features和策略移入self.modules.hosts会改变所有权，用户已撤销。

### 事实修正

editor wrapper补显式base依赖，remote.existModule.os=false匹配仅HM实现。模块化程度评分与把flake过重当缺陷的初评已被设计说明取代。

### 验证

这一阶段diff检查/草稿通过，无后续Nix检查证据。

### existModule

初版无条件把所有目录与false默认值比较，在WSL未导入Niri时失败。改os/hm为nullOr bool、default null；null表示未导入，显式true/false才核对文件。两侧同时声明或同时null，启用要求已声明；HM条件显式==true。

### 职责边界

features可高度定制，不以是否第三方通用判断；users可保留模块化成本高、随用户总启用的功能。拆分需稳定通信边界，不为纯概念整洁过度拆terminal/langs。

### HM interface

自动发现从features/default移到modules/default，覆盖moduleTypes；修正内层readDir必须扫描当前moduleType目录及listToAttrs缺失。接口始终在每HM scope，非注册一套全局用户数据。

### Secret分层

用户持密文和inventory，secret消费接口转SOPS；不暴露overlay/sops-lib函数到用户输入。sops/defaultSopsFile无通用默认，format当时默认yaml；模板/structure等默认按此阶段原语义。age.keyFile是系统到HM的桥梁，不应当作普通用户secret随意移走。

### 运维边界

保留可禁用secret feature，因为sops-install-secrets下载/Go构建可能阻塞rebuild；彻底分散到hosts/users的建议已撤回。

### Secret桥梁

更正早期单一个人密钥解释：age.keyFile是唯一系统引导桥梁，与单/多用户无关；不把UID写进SOPS key结构、不map成相同secret名。最终直接sops.secrets、root:sops-decrypt 0440，allowUidList映射用户名作为组members。初名sops-age-key后改sops-decrypt。保留局部llib入口是用户约定，不构成提交阻塞。

### UID registry

最终仅要求enabled user UIDs属于enabled host registry，registry允许预留未用UID；撤销之前双向集合相等约束。Feature allowUidList默认直接来自启用用户，不再固定1000或要求feature校验host绑定。

### 运行验证

用户check通过。当rebuild后HM/sops失败，日志keyfile Permission denied且旧user-manager仍运行；NSS id/getent有新组，不代表当前进程取得新凭据。用户boot重启后恢复，oneshot inactive且status0/SUCCESS不是失败。这里是源中诊断和用户运行结果，此前整理未执行系统命令。

### Remote

讨论过保留remote+moduleInterfaces透传，但HM原生rclone接口已足够；最终删除remote feature，把rclone配置移users/lingyu/hm/rclone.nix并补导入。rclone始终启用，secret关闭只跳过凭据remotes；requiresUnit=sops-nix.service的移除是用户有意行为。

### 用户模型

modules.users.<profile>目录发现，enable只表示启用，不等于import或最终选择。启用必须绑定非null UID，禁用可预绑定；username/homeDirectory默认可覆盖，移除home.enable/manager.enable/source。启用用户生成NixOS/HM配置，UID绑定由flake引用hostregistry。

### Secret边界

OS secret不直接依赖原生users.users的UID-keyed实现细节；根wrapper通过modules.users推导allowUsernameList内部唯一option，os侧只消费它。

### 最小profile

先试lingyu-server后按用户偏好改回规模命名lingyu-minimal，空私有配置仍接受最终启用公共features；不是禁用HM或无用户管理。
