# Clash Verge geodata 来源排查

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 问题

Clash Verge 配置校验报 list gfw not found in geosite.dat；fallback-filter.geosite 弃用 warning 不是同一个直接错误。

### 包修改

agent 初版通过 linkFarm 适配 v2ray-rules-dat，只跑 nix eval 得到 clash-verge-rev-2.5.1 drv，未 build。用户报告初版 rebuild 失败，改为 clash-verge-rev.override { v2ray-domain-list-community = pkgs.v2ray-rules-dat; } 后 rebuild 成功；该简化版本已 staged。

### 验证边界

最后没有错误消失的记录；不宣称彻底修复，不从时间邻近选择 project parent。

### 诊断事实

进程路径是 rebuild 后的新 Nix package；跟随 symlink 后找到包内 geosite.dat/geoip.dat。用户数据目录另有独立普通 geodata 文件，mtime 早于报错；生成配置仍包含 fallback-filter.geosite 的 gfw。

### 未证实之处

用户缓存优先加载是有线索的解释，不是直接观察到进程打开的文件；/proc/exe 查询失败、fd 访问 Permission denied。不要把推测升级为证实因果。

### 读取范围失误

历史诊断曾因宽泛匹配读到预期之外的应用配置. 后续应采用明确文件白名单和脱敏输出; 本次不携带那些工具日志或应用数据.

### 处置状态

停止在建议阶段：核实 geoip.dat 与 geoip.metadb 的具体需求、更新设置和 runtime 数据路径；备份/链接、关闭自动下载或重启都未在此实验执行。

### 新增故障

用户报告下载 MetaCubeX 的 geoip.metadb 时 EOF。这是 MMDB/GeoIP 下载失败，不能等同于此前 geosite 缺 gfw。包内 override 并不保证 GUI 最终使用这些数据，也可能由应用自动更新/补齐。
