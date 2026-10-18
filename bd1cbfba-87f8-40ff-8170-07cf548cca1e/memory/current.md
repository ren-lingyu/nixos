# Host metadata 生命周期与 interconnect 生成器

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### Metadata生命周期

用户定义的是host静态能力/事实，不是shared消费者视角；metadata.nix无enable守卫加载users UIDslot和monitors等，不产生激活副作用。default.nix保留enable/existModule等激活见证；各metadata完整保留host_:module函数签名。

### 断言

disabled host元数据也需数据完整性，host层default monitor最多一个，headless可空；具体GUI消费者要求唯一default，不能把host数据层收紧成恰好一个。

### 测试修正

自动metadata使1000已登记，旧未登记UID负测失效；先换1001被用户否决，最终fixture明确mkForce host.users={}，继续测1000，避免未来新用户破坏反例。

### 验证

源check曾因旧fixture失败；修复后未重跑check，但用户nix eval hosts显示disabled Aliyun/WSL仍有UIDslot、existModule=null，符合静态/激活分离。
