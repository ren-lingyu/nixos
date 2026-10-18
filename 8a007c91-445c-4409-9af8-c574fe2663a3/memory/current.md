# Interconnect 原型到 host WireGuard builder

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 动机

云服务器作为固定入口，经WireGuard让仓库管理的主机可互达；DNS/Cloudflare/HTTP发布是后续上层能力，不绑进网络原型。当前Aliyun/ThinkBook是实例，不应固化通用server/client模型。

### 保守边界

只私网路由，不接管普通互联网；peer离线不阻塞系统，接口不整体trusted，服务端口显式开放；暂不secret设计、自动topology或复杂inventory。名称选interconnect，不把当前backend写进feature名。

### 实现

interconnect聚合所有metadata，当前启用host派生claimed，内部ingress hub/spoke状态与WireGuard wg0；用户暂缓同host多node接口冲突校验，不能声称已支持。第一版实现移除整体trust策略，是否通网未实测。

### Claims模型

经过closure-local/role-instance等讨论，当前收敛为稳定host membership、具体唯一node；host元数据intranetClaims.<net>=[node]，通用publicIpAddress等fact不由feature schema强耦合提供。OS不仿造HM独立scope。

### HEAD证据

历史归纳记载曾只读审阅明确的项目版本. 该事实不证明相邻脏工作区或整个会话对应同一提交. 本次仅保留审阅结论和限制, 不继承此前历史的 parent 关系.

### 验证

地址范围等额外检查用户暂缓；没有后段运行检查或network试验成功记录。

### 地址模型

从host全局intraIpAddress过渡到稳定number，避免同host多个网络只能一个IP。number为正整数，非字符串；内部netIds_.ingress=0，地址10.100.<netId>.<hostNumber>，不按列表顺序自动分配以免重排换地址。

### 生成器

mkNode保持三个柯里化参数；claimed独立始终有值，只有唯一claimant时optionalAttrs派生公共地址与node特有字段。防火墙不再硬写旧hubIP。

### Topology

intranetDefs内部只读含network number0..255与nodes，schema和地址都读取它，移除重复netIds/topology。用户报告无递归问题；未知claims按defs校验，network number和node名各自唯一。

### Claim数量

实现只支持唯一claimant派生单值字段，当前min/max都readOnly默认1/1；用户保留constraints是为未来扩展，不是假装已支持多个claim。未来放开必须连同生成器/地址/key/peer模型一起改。

### Orchestration

后续staged有hub/spoke containers、feature注册与闭包启用；只记录审阅阶段，不补造服务部署成功。
