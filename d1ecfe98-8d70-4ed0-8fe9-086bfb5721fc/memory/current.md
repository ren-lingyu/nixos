# Monitor schema、host namespace 与 X11 fallback 初版

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 目标与分层

用户要求 hosts 管 monitor 数据不变量，niri/greeter 启用时才要求 default monitor。逻辑 attr key 可以不同于真实 output name；真实 name 重复会导致 outputs 静默覆盖，应约束。

### Monitor 模型

mode宽高用正整数，refresh/scale非null为正浮点。hosts 约束真实 name 非空/唯一、default最多一个；niri/greeter启用要求恰好一个default。Greeter推导先检查唯一性，不直接head空列表。

### 验证

用户 rebuild test 后，历史agent eval确认thinkbook开启、旧modules.hosts.monitors消失、greeter output及Niri生成配置符合预期。历史曾审阅部分已提交版本, 但不能据此为修改后的脏工作区建立精确关联。

### 风格

局部 type/helper/断言的 let 紧邻其消费属性，不把一次性局部值提升为全局；断言 message 保留完整 option 路径。

### Host 模型

modules.hosts 改为 attrsOf submodule，各host有 enable/monitors/packageGroups；host根入口导入即声明自身enable=true。当前阶段允许零个、至多一个enabled host；图形feature另要求唯一host/default monitor。不要提前套用七月后段的全局恰好一个设计。

### 消费边界

硬件/OS普通配置以自身enable守卫；imports保持模块顶层，不能放进config.mkIf。ThinkBook packageGroups迁到hostnamespace；niri.monitors为内部唯一值，由启用host派生。
