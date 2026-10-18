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

定向diff和staged草稿检查完成，无该技能迁移后新build/eval证明。

### 外部工具

fd/ripgrep由programs.pi-coding-agent.extraPackages进入Pi PATH，取代手写--prefix PATH；override只管PI_OFFLINE。settings.packages是Pi资源包，不是系统CLI依赖。用户不希望Pi自行管理，未默认加npm/bun。

### 构建失败与修正

日志显示引用目标后少空格，导致wrapProgram尝试pi--set；修正空格后用户报告下一次rebuild成功。npm兼容/deprecated警告不是这次失败原因，不在HM层压制上游日志。

### 技能目录

删除旧OpenCode git-maintainer agent与commit-message command封装，通用git-maintenance移到agent/hm/skills；Pi与OpenCode消费同一根。最终OpenCode skills=./skills，agents/commands为空，去除compatibility:opencode。

### 权限

OpenCode保留permission=ask，技能不承担权限边界。旧agent重复workflow造成漂移的风险通过共享skill减少。

### 包装修正

prefix检查改为带/的storeoutput边界，显式builtins.throw。只用一次且无独立解释价值的let不新增。

### Extension设想

用户希望使用convco等成熟Git CLI，但只向agent暴露部分命令。建议skill描述原CLI名与语义，Pi extension在执行层拦截/裁剪bash能力，Nix管理extension路径。不要把命令存在或alias当作安全授权机制。

### 状态

最后只做可行性讨论；未实现extension、白名单或安全隔离，也未证明黑名单足以拦住任意shell语法。该计划不能视为已部署能力。
