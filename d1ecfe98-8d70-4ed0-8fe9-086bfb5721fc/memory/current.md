# Monitor schema、host namespace 与 X11 fallback 初版

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 目标与分层

用户要求 hosts 管 monitor 数据不变量，niri/greeter 启用时才要求 default monitor。逻辑 attr key 可以不同于真实 output name；真实 name 重复会导致 outputs 静默覆盖，应约束。

### Monitor 模型

mode宽高用正整数，refresh/scale非null为正浮点。hosts 约束真实 name 非空/唯一、default最多一个；niri/greeter启用要求恰好一个default。Greeter推导先检查唯一性，不直接head空列表。

### 验证

源历史记录报告nixos/server/wsl求值检查通过及diff格式通过；没有新增构建或runtime登录验证。提交草稿只描述各host下共同options保持，顶层生成结构确有变化。

### 风格

局部 type/helper/断言的 let 紧邻其消费属性，不把一次性局部值提升为全局；断言 message 保留完整 option 路径。

### Host 模型

最终hosts schema由modules/hosts/*/default.nix直接目录生成固定namespace，不再开放任意attrsOf hostkey；保留共同enable/monitors/packageGroups/flatpak，并加载每host extra-options。仍是至多一个enabled host。

### 消费边界

硬件/OS普通配置以自身enable守卫；imports保持模块顶层，不能放进config.mkIf。ThinkBook packageGroups迁到hostnamespace；niri.monitors为内部唯一值，由启用host派生。

### X11 fallback

最初用startx+XFCE，目的是让wemeet等应用有稳定少配置的原生X11环境，不追求极端最小。发现wrapper把$out留到runtime导致无法启动，已改为构建时绝对路径，同时改用pkgs.xfce4-session/pkgs.xinit。

### Overlay

modules/overlays按子目录default.nix自动发现，生成enable并支持extra-options；Tencent overlay显式守卫，由thinkbook最终组合启用。

### 保留断言

用户明确要求保留enabled host对应default.nix存在的防御性检查；不是因为新schema可阻止拼写错误就擅自删去。monitor与flatpak相关检查保留。
