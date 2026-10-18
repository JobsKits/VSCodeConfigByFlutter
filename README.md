# <span id="前言">🐦VScodeConfigByFlutter</span>

![Jobs出品，必属精品](https://picsum.photos/1500/400)

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [一、目录结构](#repository-layout)
- [二、配置注入脚本](#repository-script-flows)
  - [【MacOS】💉VSCode配置注入@当前项目.command](#jobs-toc-heading-3)

</details>
<!-- jobs-toc:end -->

[目录结构](#repository-layout) · [配置注入流程](#repository-script-flows)

本仓集中保存 Flutter 项目的 Visual Studio Code 配置与注入入口。

## 一、<span id="repository-layout">目录结构</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

```text
🐦VScodeConfigByFlutter/
├── README.md / LICENSE / icon.png
├── extensions.json                        # 扩展建议
├── launch.json                            # 调试启动配置
├── settings.json                          # 项目编辑设置
├── tasks.json                             # 项目任务
└── 【MacOS】💉VSCode配置注入@当前项目.command
```

## 二、<span id="repository-script-flows">配置注入脚本</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### <span id="jobs-toc-heading-3" data-jobs-toc="v2">[【MacOS】💉VSCode配置注入@当前项目.command](./【MacOS】💉VSCode配置注入@当前项目.command)</span><!-- jobs-toc:heading-end -->

> **目的：** 下载本仓指定的配置版本，并替换脚本所在目录的 `.vscode`。

* 把入口放到目标项目根目录后运行，阅读覆盖说明并确认；目标始终是脚本所在目录，不是终端当前目录。
* 检查 Git，删除目标已有 `.vscode` 并重新创建目录。
* 浅克隆脚本指定的 GitHub 配置仓库到临时目录。
  * 删除先于下载且没有备份；克隆失败时原 `.vscode` 也已被移除。
* 把下载仓库中的可见和隐藏内容复制到 `.vscode`，移除其中 `.git`、`.github` 与 `.gitignore`。
* 清理临时目录并输出完成结果；直接在本仓运行会替换本仓自己的 `.vscode`。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
