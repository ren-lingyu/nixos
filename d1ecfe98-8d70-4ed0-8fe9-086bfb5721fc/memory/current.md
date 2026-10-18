# Monitor schema、host namespace 与 X11 fallback 初版

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 目标与分层

用户要求 hosts 管 monitor 数据不变量，niri/greeter 启用时才要求 default monitor。逻辑 attr key 可以不同于真实 output name；真实 name 重复会导致 outputs 静默覆盖，应约束。

### Monitor 模型

mode宽高用正整数，refresh/scale非null为正浮点。hosts 约束真实 name 非空/唯一、default最多一个；niri/greeter启用要求恰好一个default。Greeter推导先检查唯一性，不直接head空列表。

### 验证

staged 版本经静态审查和 toplevel drvPath eval 成功，原有 Niri provider 互斥/依赖约束保留。先前 mode 阶段的 check 与本阶段 eval 分开记录；本次未重跑项目检查。

### 风格

局部 type/helper/断言的 let 紧邻其消费属性，不把一次性局部值提升为全局；断言 message 保留完整 option 路径。
