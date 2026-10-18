# Clash Verge geodata 来源排查

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 问题

Clash Verge 配置校验报 list gfw not found in geosite.dat；fallback-filter.geosite 弃用 warning 不是同一个直接错误。

### 包修改

agent 初版通过 linkFarm 适配 v2ray-rules-dat，只跑 nix eval 得到 clash-verge-rev-2.5.1 drv，未 build。用户报告初版 rebuild 失败，改为 clash-verge-rev.override { v2ray-domain-list-community = pkgs.v2ray-rules-dat; } 后 rebuild 成功；该简化版本已 staged。

### 验证边界

初版 eval 成功不能证明构建成功。用户新版 rebuild 通过是用户报告，不能归功于 agent 初版。没有已证实的 exact 修改后 commit parent。
