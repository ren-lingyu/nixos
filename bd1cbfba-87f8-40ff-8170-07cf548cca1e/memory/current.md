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

只静态检查，Aliyun旧extra-options曾AD index/worktree错位；不把worktree删除当index已接受。

### 生成器

mkNet多轮调整，从回调六个上下文参数收窄为claimantHost，避免暴露冗余内部状态。配置保持普通attrset，existModule不由net函数生成；不滥用mkMerge，列表用concatLists。

### 内部状态

claimantNames不为断言暴露成option；辅助assertion函数统一生成唯一检查，特殊hubIP检查最终结果。claimed独立布尔，唯一claimant时才optionalAttrs派生，避免head[]抢先失败；缺省值来自schema，不伪造else{}状态。

### Schema

intranets整体internal+unique；claimed可复用局部生成，unique本身不再额外抽helper。

### 公网地址

publicIpAddress提升为所有host通用internal nullable string/default null，移除Aliyun专属option，值不改；interconnect直接读claimantHost.publicIpAddress。null语义由schema而非读取fallback。

### Claims

按最终net/node集合生成通用结构/唯一性断言，特定hubIP要求仍显式。旧版本尚无通用覆盖机制，不能把unique内部值当可自由合并公共API。
