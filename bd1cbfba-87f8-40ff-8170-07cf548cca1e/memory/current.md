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

改动后仅diff检查，无求值/构建成功记录。

### 生成器

mkNet多轮调整，从回调六个上下文参数收窄为claimantHost，避免暴露冗余内部状态。配置保持普通attrset，existModule不由net函数生成；不滥用mkMerge，列表用concatLists。

### 内部状态

claimantNames不为断言暴露成option；辅助assertion函数统一生成唯一检查，特殊hubIP检查最终结果。claimed独立布尔，唯一claimant时才optionalAttrs派生，避免head[]抢先失败；缺省值来自schema，不伪造else{}状态。

### Schema

外层mapAttrs <net>=[nodes]，内层listToAttrs/map，公共option直接在value，hub.ip用optionalAttrs；动态message/description用net/node名。没有为了局部重复再造大通用函数。

### 公网地址

publicIpAddress提升为所有host通用internal nullable string/default null，移除Aliyun专属option，值不改；interconnect直接读claimantHost.publicIpAddress。null语义由schema而非读取fallback。

### Claims

按最终net/node集合生成通用结构/唯一性断言，特定hubIP要求仍显式。旧版本尚无通用覆盖机制，不能把unique内部值当可自由合并公共API。

### Claim语义

claim只声明membership，不证明runtime在线独占。共用key/IP会导致WireGuard身份/路由冲突，secret管理不会自动解决；协调策略不由通用层猜测。

### 数量约束

constraints.claimantCount.{min,max}统一命名空间，0分别表示该方向不限制，不能表达恰好0。当前hub1/1，spoke默认0/0；计数是所有hostmetadata申领者，不是当前claimed布尔。

### 实现边界

源已实现数量/未知net-node校验、hubIP单独检查，避免异常head[]。但多claim派生配置仍局限，不能据schema表达力声称多claim生成完整支持；具体os配置未大改。

### 最终生成器

mkNet改三参数mkNode_ netName_ nodeName_ derive_；claimed看当前闭包唯一enabled host，derive看全局唯一claimant的metadata。约束直接写最终intranets，不放进控制spec；无特有字段spoke仍空函数。

### 断言与状态

一次性claimantCountAssertions函数移除，直接mapAttrsToList里生成。最终修改叠在staged版本上，有unstaged；仅git diff --check通过，未Nix求值/构建。多claim且需派生属性仍明确暂缓。
