# 模块组合协议、HM interfaces、UID 与公共 llib 演进

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 架构契约

用户明确inputs只在flake.nix，那里是外部适配与最终composition root。base是所有profile公共依赖；features/hosts/users彼此平级，各管内部事务。把所有features和策略移入self.modules.hosts会改变所有权，用户已撤销。

### 事实修正

editor wrapper补显式base依赖，remote.existModule.os=false匹配仅HM实现。模块化程度评分与把flake过重当缺陷的初评已被设计说明取代。

### 验证

先有4组check通过，再有历史记录用户check Exit0、新module-composition构建成功；三套NixOS配置同时求值通过。仅证明当时源码，不是跨session的最终项目状态。

### existModule

llib.types.existModule统一os/hm的unique nullOr bool/default null；llib.assertions.existModule生成文件一致性、配对声明、启用见证断言。移除subject冗余参数，type只用optionPath；调用方保留实际paths和上下文message。

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

### 目录与模块性质

profile根default是NixOS协调入口，OS静态import、HM按existModule.hm送达；enable控制效果。existModule只声明私有os/hm文件是否存在，不决定用户是否有HM。hosts/users与features统一声明配对、启用见证、文件一致性断言。minimal可无私有HM仍生成HM用户。

### 集合契约位置

options/assertions仍留modules/<type>/default.nix，不因统一而搬到modules根；OS imports不能依赖config，接受两侧导入机制不对称。

### Greeter补全

sessionPackages内部unique、有default=[]和描述；保留options探测接口是否存在，再检查最终config wrapper非null，避免未导入provider路径失败；greeter启用要求非空，Niri guard与feature启用语义对齐。

### 公共llib

根lib/作为flake output，以当前模块系统nixpkgs lib实例化self.lib {inherit lib;}。NixOS经_module.args，HM经extraSpecialArgs。secret函数迁入llib.moduleFunctions.features.secret，不把固定仓库父路径塞进modules子目录。

### 迁移失败与修正

早期check因users参数遮蔽失败，后用户撤销导致遮蔽的commit。抽monitor后暴露匿名base重复导入导致_module.args.llib多定义；最终base保留函数参数并显式稳定key/_file去重。不是仅改成attrset就可靠去重。

### 共享type

monitor.name非空约束移入共享type，删除hosts重复非空assertion，补空名负向测试；修正role/scale/name描述。shell package选项补unique消息、example/description。

### 手工边界

module args不会自动流入普通import函数应用；补host/feature extra-options、HM interface-options显式传llib，既存函数签名也补上，即使未用。

### UID imports聚合

最终函数groupImportsByUid=getUids:getImports:items:…，两个selector均取name和value。公共库仅遍历attrset、UID字符串化及按原顺序累积imports；不知enable/existModule/allowUidList或/hm布局。调用方负责过滤和生成path。

### 算法与风格

保留双层fold和直接构造UID属性集；不为替换fold引入mkMerge，不把一次性具体network/module逻辑全藏let。两个selector避免回调必须返回{uids,imports}的隐式结构契约。

### 测试

tests/default聚合，每类别runCommand derivation，经perSystem.checks；覆盖monitor/existModule/groupImportsByUid/SOPS生成。再加真实module组合负例：user无UID、UID未注册、feature指向未启用user。测试读取真实assertions，不重写规则。

### 诊断文案

greeter monitor错误路径及SOPS接口sops.secretsInput/defaultSopsFormat/defaultSopsFile路径笔误均逐步纠正，后者到历史记录才修完。

### 文档

初次推倒README被用户撤销；最终保留原逐目录章节，增架构约定/Option和组装协议并移到结构前，更新旧overlays/remote、minimal、lib/tests及OS/HM不对称说明。代码注释与README共同记录同一契约。只为措辞覆盖面更好不建议改已提交历史。

### 最终验证与待办

后段类型/文档/shell只有diff静态检查，没有新flake check；源最后判断架构基本完备。Niri session-wrapper.package错误路径及unique文案统一仍属后续可选维护，不声称全部修完。
