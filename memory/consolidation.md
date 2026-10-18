# 清洁重建、整合与退役

## 动机与边界

原先直接关联原始日志的方案因审阅成本和保留风险而撤回. 新来源从旧 memory 归纳恢复知识, 不复制原始材料, 不关联旧 Auxiliary commits, 不回填事件时间. 旧来源只是迁移临时证据, 必须在新知识验收后进入经单独确认的退役与清理流程, 不以永久保留旧分支作为完成状态.

本次 82 个旧归纳状态选择为 52 个独立恢复边界, 分布于 18 个新 Auxiliary. 选择保留目标、动机、替代方案、结果、验证限制与未决事项; 合并仅有增量意义的状态. 重叠架构背景不算独立验证. 模块重构来源原本只有可见对话摘要, 其证据强度不提高为原始日志.

## 来源覆盖与状态

下列路径相对于对应清洁 Auxiliary 的 Git tree root; 可经实际整合 checkpoint 的 Git parents 定位, 不依赖分支名或本机 worktree. source.md 说明整个来源范围, current.md 的 first-parent 历史表示选定知识演化.

| 主题 | 清洁来源路径 | 状态数 | 内容审查 | 知识处理 | 完整历史保留 | 证据限制 |
| --- | --- | ---: | --- | --- | --- | --- |
| monitor-host-x11 | `d1ecfe98-8d70-4ed0-8fe9-086bfb5721fc/memory/source.md` 与同目录 `current.md` | 3 | 所有拟提交版本及 ancestry 已审查 | 已处理主题阶段 3; 其余历史细节留在来源 | tip 已纳入当前 Formal ancestry | 知识归纳, 原始材料未长期保留 |
| file-manager-terminal-portal | `7cc5b1b0-9ad0-47a3-8e9e-afeb342bd6e9/memory/source.md` 与同目录 `current.md` | 3 | 所有拟提交版本及 ancestry 已审查 | 已处理主题阶段 3; 其余历史细节留在来源 | tip 已纳入当前 Formal ancestry | 知识归纳, 原始材料未长期保留 |
| metadata-claims | `bd1cbfba-87f8-40ff-8170-07cf548cca1e/memory/source.md` 与同目录 `current.md` | 3 | 所有拟提交版本及 ancestry 已审查 | 已处理主题阶段 2; 其余历史细节留在来源 | tip 已纳入当前 Formal ancestry | 知识归纳, 原始材料未长期保留 |
| registry-nix-app | `3ae570e4-1a6f-4eb5-a587-fef91898260a/memory/source.md` 与同目录 `current.md` | 1 | 所有拟提交版本及 ancestry 已审查 | 已处理主题阶段 1; 其余历史细节留在来源 | tip 已纳入当前 Formal ancestry | 知识归纳, 原始材料未长期保留 |
| framebuffer-kmscon | `4038629b-910a-4e71-a8da-fcb671781cfc/memory/source.md` 与同目录 `current.md` | 1 | 所有拟提交版本及 ancestry 已审查 | 已处理主题阶段 3; 其余历史细节留在来源 | tip 已纳入当前 Formal ancestry | 知识归纳, 原始材料未长期保留 |
| module-composition | `ab0e5495-e6c7-449b-a798-4b7453eb9319/memory/source.md` 与同目录 `current.md` | 6 | 所有拟提交版本及 ancestry 已审查 | 已处理主题阶段 1,2; 其余历史细节留在来源 | tip 已纳入当前 Formal ancestry | 知识归纳, 原始材料未长期保留 |
| pi-skills | `67b1954b-f1df-49fa-9d6d-90f7779239e2/memory/source.md` 与同目录 `current.md` | 3 | 所有拟提交版本及 ancestry 已审查 | 已处理主题阶段 4; 其余历史细节留在来源 | tip 已纳入当前 Formal ancestry | 知识归纳, 原始材料未长期保留 |
| flake-parts-introduction | `556edc63-3a28-4090-9d6f-12d884625a5a/memory/source.md` 与同目录 `current.md` | 2 | 所有拟提交版本及 ancestry 已审查 | 已处理主题阶段 1; 其余历史细节留在来源 | tip 已纳入当前 Formal ancestry | 知识归纳, 原始材料未长期保留 |
| identity-secrets-armor | `8536cd94-a761-42a6-9ebd-517e37d30423/memory/source.md` 与同目录 `current.md` | 5 | 所有拟提交版本及 ancestry 已审查 | 已处理主题阶段 2,4; 其余历史细节留在来源 | tip 已纳入当前 Formal ancestry | 知识归纳, 原始材料未长期保留 |
| cfg-aliases | `cc157a3b-d374-4edf-b3f1-284a0f7a8fab/memory/source.md` 与同目录 `current.md` | 2 | 所有拟提交版本及 ancestry 已审查 | 已处理主题阶段 1; 其余历史细节留在来源 | tip 已纳入当前 Formal ancestry | 知识归纳, 原始材料未长期保留 |
| agent-providers | `d39e1ab2-c94e-4ec6-b7b9-eb5d16a54dec/memory/source.md` 与同目录 `current.md` | 2 | 所有拟提交版本及 ancestry 已审查 | 已处理主题阶段 4; 其余历史细节留在来源 | tip 已纳入当前 Formal ancestry | 知识归纳, 原始材料未长期保留 |
| readonly-host-packages | `01d8e08d-e649-4b6a-989b-01c1f8f3b71a/memory/source.md` 与同目录 `current.md` | 4 | 所有拟提交版本及 ancestry 已审查 | 已处理主题阶段 1,4; 其余历史细节留在来源 | tip 已纳入当前 Formal ancestry | 知识归纳, 原始材料未长期保留 |
| flake-parts-module-refactor | `ddc19bb1-dbb6-463a-8201-f286531af917/memory/source.md` 与同目录 `current.md` | 4 | 所有拟提交版本及 ancestry 已审查 | 已处理主题阶段 1; 其余历史细节留在来源 | tip 已纳入当前 Formal ancestry | 仅可见对话归纳, 非原始日志 |
| clash-geodata | `ee5ea724-542e-4a38-a6a0-d7aee9717cc0/memory/source.md` 与同目录 `current.md` | 2 | 所有拟提交版本及 ancestry 已审查 | 已处理主题阶段 4; 其余历史细节留在来源 | tip 已纳入当前 Formal ancestry | 知识归纳, 原始材料未长期保留 |
| icewm-fallback | `2b6c7939-aeff-4f1a-adcb-2a578653020a/memory/source.md` 与同目录 `current.md` | 2 | 所有拟提交版本及 ancestry 已审查 | 已处理主题阶段 3; 其余历史细节留在来源 | tip 已纳入当前 Formal ancestry | 知识归纳, 原始材料未长期保留 |
| wsl-removal-commit-semantics | `602000f2-8797-4731-acf7-02ac8d0ba8e1/memory/source.md` 与同目录 `current.md` | 3 | 所有拟提交版本及 ancestry 已审查 | 已处理主题阶段 4; 其余历史细节留在来源 | tip 已纳入当前 Formal ancestry | 知识归纳, 原始材料未长期保留 |
| noctalia-lockscreen | `dacd12b8-abff-441e-a495-ccaa2e8d6c65/memory/source.md` 与同目录 `current.md` | 3 | 所有拟提交版本及 ancestry 已审查 | 已处理主题阶段 3; 其余历史细节留在来源 | tip 已纳入当前 Formal ancestry | 知识归纳, 原始材料未长期保留 |
| wireguard-evolution | `8a007c91-445c-4409-9af8-c574fe2663a3/memory/source.md` 与同目录 `current.md` | 3 | 所有拟提交版本及 ancestry 已审查 | 已处理主题阶段 2; 其余历史细节留在来源 | tip 已纳入当前 Formal ancestry | 知识归纳, 原始材料未长期保留 |

## 关联的含义

Knowledge provenance 关联实际阅读且支持本次判断的精确清洁 checkpoint; source retention 保留经审阅的完整 tip. 本轮所选 tip 的累计归纳实际用于相应主题, 同时保留其前序状态. 两项目的均由现有 additional parents 表达, 不增加 parent 位置角色或持久协议. 来源可达不代表每个历史事实已验证或全部采纳.

本次所有新来源都是独立 roots, 没有关联旧 Auxiliary 或普通项目 ancestry. 已审阅 source.md/current.md 的所有拟提交状态, 清理失效归档路径、原始行号依赖和旧对象标识; 没有原始日志、密文载荷、密钥值或完整工具输出文件. 公开 CLI 固定的 Initialize GAW root 信息已获用户明确例外许可, 后续知识 checkpoints 使用当前 git-maintenance 规范.

## 裁决、纠错和证据缺口

当前实现优先于历史提议. self.modules、早期 UID helper、旧声明文件名和 interconnect claims 不恢复为当前 API. UID 单向归属与不同测试夹具按实际阶段解释; internal 不作为权限隔离. 历史检查、用户运行报告、本次静态核对和未验证行为分别记载, 不从摘要一致性制造独立证明.

Noctalia 原摘要遗漏用户最后一次修改: 天气曾试开, 最终 staged 内容已经关闭. 清洁来源与当前源码均明确 show_weather=false、show_unlock_hint=true. 这项纠错不构成重新运行锁屏的验证.

对未完整保存的旧工作区、截断输出、未复现运行行为和仅摘要来源不补造证据. 新历史不声称逐字节原文保真. 临时原始材料曾用于解决这一重要歧义, 但不成为新来源长期依赖.

## 旧历史退役及本地清理结果

知识与来源验收后, 用户单独授权清理, 并分别确认全部不可达 commits 与独立 blob/tree 均可不备份删除. 原始 18 条和弃用试建 18 条共 36 个 branches/worktrees 已退役. 移除前重新检查 tips, worktrees, 完整 index, untracked 和进行中的操作; 未用强制 worktree 删除丢弃改动. 分支通过公共 `git gaw branch -D` 显式放弃, 未手动修改 refs.

重新核对保留关系后, 仅过期不可达 reflog 条目, 保留可达 reflog 历史, 并执行 `git gc --prune=now`; GC 本身禁止额外过期 reflog. 未制作恢复包. 清理前不可达集合为 276 commits, 702 trees, 681 blobs, 包括 187 个指定退役 commits 和用户允许丢弃的 89 个其他不可达 commits. 原预检中不归属这些 commits 闭包的 469 blobs 与 22 trees 亦获得明确丢弃授权.

清理后逐个检查 187 个旧/试建 commits, 17 个原始 rollout blobs 及原预检的 936 个非目标对象, 全部已无法读取. 完整不可达对象检查为空. 上轮清理后, 36 个指定 refs/worktrees 不存在, 当时保留 18 个清洁 Auxiliary 和共 20 个 worktrees; 所有清洁 tips 仍可从 Formal ancestry 到达. 普通项目分支及原有未暂存 lockfile 保持不变, 未 push 或改写普通项目历史.

已有 commit-graph 派生缓存引用四个失效条目; 通过公开 `git commit-graph write --reachable --split=replace` 重建后, 默认完整对象检查及 GC 后检查通过. 共享且仍由合法历史引用的对象继续保留, 不将其误报为清理失败.

上述结果仅针对目标本地仓库中的 Git 对象和指定 worktrees. 不保证外部副本或物理存储残留清除. 仓库外原始 Codex 会话与隔离审阅副本未删除, 忽略目录内临时材料也未自动清空; 它们不是 Formal 的长期恢复依赖.

## 已整合清洁来源的安全退役

在上述旧历史 GC 完成后, 用户明确接受来源中保留的个人配置背景, 并授权退役全部 18 条清洁 Auxiliary 的活动分支. 退役前重新确认完整 tips 已进入 Formal ancestry, 所有 worktrees/index/untracked 干净且无进行中的操作. 顺序为移除对应 worktree, 复查 `git gaw aux check`, 再使用公共 `git gaw branch -d` 安全删除; 不使用 `-D`.

验收结果: Auxiliary branches 为零, worktrees 只剩普通项目与 Formal 两个. 18 条清洁来源的全部 70 个 commits 仍从 Formal 可达, 包括 52 个知识 checkpoints 与 18 个初始化 roots. UUID-relative 来源表及 Formal 整合 parents 保留, 删除活动分支不删除这些历史. 可从相关 Formal 整合 checkpoint 的 parents 检查对应 UUID tree, 再按表中路径读取 source.md/current.md 及其 first-parent 演化; 不依赖已删除分支名或本机 worktree 路径. 本轮未执行 GC 或 push, 普通项目 refs 与原有 lockfile 修改保持, 完整 fsck 通过.

敏感性复查覆盖当时 Formal 可达的 80 个 commits 和 93 个文件内容版本, 未发现凭据值或原始日志. 部分来源包含用户名及个人配置背景, 用户明确接受保留; 这不等于绝对排除所有未识别风险.

## 工作流经验与恢复

未来在创建 Auxiliary 前确认材料范围、访问授权和持久保留目的, 完成敏感性审阅后再建历史; 实际提交前核对最终文件和审阅材料一致, 运行中 session 的新增事件不能沿用旧覆盖结论. 后续整合复核有效审阅结果及新风险信号, 无理由不重复完整审阅. 这些是后续 skill 设计事项, 本次没有修改 bundled skill 或 CLI.

重要重建、整合和退役行为按恢复价值记录, 不逐条记录 CLI. 恢复时先读当前 Formal, 再按来源路径和 ancestry 查阅新来源; 不依赖临时报告文件或此前聊天上下文.

## 当前恢复入口

本次清洁重建、主题整合和获准清理均已验收. Formal 保存当前知识、历史动机、纠错、来源覆盖与证据限制; 清洁 Auxiliary 保存经审阅的选定知识演化, 不含原始 archive. 18 个清洁 tips 已安全保留, 不需要依赖退役分支、旧对象或临时报告继续工作. 运行时证据缺口仍按 current.md 和 architecture.md 处理, 不因历史维护完成而标记为已验证.

## 本次重建过程的纠正

初次试建的提交正文保留了中文顿号, 半角标点检查漏检. 随后修正正文和检查规则, 通过公开 CLI 另建独立 roots, 没有 reword 或改写历史. 首批试建未作为整合来源, 已随本轮授权退役和 GC 清理. 当前知识关联只使用最终审阅通过的 18 条来源. 公开 CLI 固定初始化信息之外, 后续知识和整合提交遵循 git-maintenance 规范.
