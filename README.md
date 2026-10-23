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

* 把入口放到目标项目根目录后运行，目标始终是脚本所在目录；精确输入 `YES` 才下载并替换。需要 Python 3 与 Git。
* `--dry-run` / `DRY_RUN=1` 只显示目标和来源，不联网、不写文件；非交互写入会被拒绝。
* 先浅克隆到同盘临时目录，禁用 Git hooks 与隐式子模块递归，并限制下载为 180 秒。克隆失败不改变旧 `.vscode`。
* 只接受非空、非符号链接的四份 UTF-8 配置：`settings.json`、`extensions.json`、`launch.json`、`tasks.json`。保留 JSONC 注释与尾逗号，不把 README、脚本或仓库元数据装进配置目录。
* 下载和复制完成后，把原目录移动到唯一的 `.vscode-backup-*/.vscode`，再重命名新目录。发布失败会尝试恢复原目录；若目标被其它程序占用，保留备份并报告位置。
* 备份保留在项目内，核对新配置后自行归档。目标 `.vscode` 为符号链接、外部 Git 定位变量或配置缺失时停止；不要在运行期间同时编辑该目录。

```sh
./【MacOS】💉VSCode配置注入@当前项目.command --dry-run
```

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
