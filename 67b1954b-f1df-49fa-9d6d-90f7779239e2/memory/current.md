# Pi package 包装、启动依赖与共享 Git skill

这是历史知识的清洁重建状态, 不是当前项目权威. 来源范围和证据限制见 `source.md`. 以下描述所选历史阶段; 本次新增核实或纠错另行标注.

## 历史可恢复状态

### 目标

用户最终要求只给Pi设置启动离线变量并保留原包outputs/metadata/文件树；只含命令的wrapper不能等价保留，symlinkJoin不保留multioutput语义，最终试用overrideAttrs。

### 实现

postFixup保留old内容，用getBin/getExe/outputName推导目标输出和相对主程序；makeWrapper提供wrapProgram。postFixup以concatStringsSep拼接。路径prefix不匹配时局部throw，不依赖module assertions到太晚才失败。

### Pi离线

历史源码审阅称PI_OFFLINE/--offline抑制启动更新/telemetry/缺工具下载，不表示禁用模型API请求。其具体版本行为仅为源会话报告，本次未重新查文档或运行Pi。

### 验证

本阶段没有eval/build，不能声称override已工作。
