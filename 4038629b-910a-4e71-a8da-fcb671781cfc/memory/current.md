# ThinkBook fbset 与 kmscon 生命周期评估

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 当前服务

仅ThinkBook启用时生效；fbset-xedrmfb oneshot只在fb0为xedrmfb时设置3072×1920/32bit，display-manager前运行，fb0 add的udev覆盖较晚出现设备。

### 历史与provenance

历史归纳记载曾只读审阅明确的项目版本. 该事实不证明相邻脏工作区或整个会话对应同一提交. 本次仅保留审阅结论和限制, 不继承此前历史的 parent 关系.

### 风险评估

旧DRM card0 change触发可能与kmscon模式管理竞争，不是直接systemd单元冲突；fbcon几何与kmscon自管KMS/字体行列数不同。

### 生命周期

Before/After只给同一事务排序，Requires/Wants拉起依赖，Conflicts启动一方会停止另一方且不自动恢复。oneshot通常已退出，无常驻进程可杀；停止服务不会撤销framebuffer geometry。

### 处置状态

先后考虑启动前依赖fbset、ExecStartPre/StopPost等，但多kmsconVT并发仍需考虑。不把讨论中的示例当作采纳/已实现方案；用户最后问Conflicts可行性后，没有授权修改或runtime测试记录。

### 验证

本源只读文件/历史和公开资料，没有实际运行fbset、kmscon或systemd mutation。
