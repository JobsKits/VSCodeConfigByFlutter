#!/bin/zsh
# shell: zsh
# 下载完成并校验四份配置后才替换 .vscode；原目录保留为独立备份。
SCRIPT_SOURCE="${(%):-%x}"
SCRIPT_DIR="${SCRIPT_SOURCE:A:h}"

main() {
  command -v python3 >/dev/null || { print -u2 -- '需要 Python 3；不会自动安装。'; return 1; }
  local injector_code
  injector_code="$(cat <<'PYTHON'
import argparse
import os
from pathlib import Path
import shutil
import stat
import subprocess
import sys
import tempfile

REPO_URL = 'https://github.com/JobsKits/VScodeConfigByFlutter.git'
CONFIG_FILES = ('settings.json', 'extensions.json', 'launch.json', 'tasks.json')
ROOT = Path(sys.argv[1]).resolve(strict=True)


def inject(dry_run):
    target = ROOT / '.vscode'
    if target.is_symlink() or (target.exists() and not target.is_dir()):
        raise RuntimeError('.vscode 必须是实际目录；不跟随符号链接。')
    print('目标：' + str(target), flush=True)
    print('来源：' + REPO_URL, flush=True)
    print('仅导入 settings / extensions / launch / tasks.json；旧 .vscode 将完整保留为备份。', flush=True)
    if dry_run:
        print('预览结束，未联网、未修改文件。')
        return
    if not sys.stdin.isatty():
        raise RuntimeError('写入需交互终端确认；非交互检查请使用 --dry-run。')
    if input('精确输入 YES 下载并替换；其它输入取消：') != 'YES':
        print('已取消。')
        return
    for variable in ('GIT_DIR', 'GIT_WORK_TREE', 'GIT_INDEX_FILE', 'GIT_COMMON_DIR'):
        if os.environ.get(variable):
            raise RuntimeError('请清除外部 Git 定位变量：' + variable)
    if not shutil.which('git'):
        raise RuntimeError('未找到 Git。')
    backup = None
    # 临时目录与目标同盘，提交新目录时使用 rename；网络和复制失败不触碰旧目录。
    with tempfile.TemporaryDirectory(prefix='.jobs-vscode-stage-', dir=ROOT) as temporary:
        stage = Path(temporary)
        environment = dict(os.environ, GIT_TERMINAL_PROMPT='0')
        subprocess.run(['git', '-c', 'core.hooksPath=/dev/null', '-c', 'core.fsmonitor=false',
                        'clone', '--depth=1', '--no-recurse-submodules', '--', REPO_URL,
                        str(stage / 'repo')], env=environment, check=True, timeout=180)
        ready = stage / 'ready'
        ready.mkdir()
        for name in CONFIG_FILES:
            source = stage / 'repo' / name
            metadata = source.lstat()
            if not stat.S_ISREG(metadata.st_mode) or not metadata.st_size:
                raise RuntimeError('缺少有效的普通配置文件：' + name)
            # VS Code 使用 JSONC，保留注释与尾逗号，不强制改写为 JSON。
            source.read_text(encoding='utf-8-sig')
            shutil.copy2(source, ready / name)
        if target.is_symlink() or (target.exists() and not target.is_dir()):
            raise RuntimeError('下载期间 .vscode 类型发生变化，已停止。')
        try:
            if target.exists():
                backup = Path(tempfile.mkdtemp(prefix='.vscode-backup-', dir=ROOT)) / '.vscode'
                target.rename(backup)
                print('原配置备份：' + str(backup), flush=True)
            ready.rename(target)
        except BaseException:
            if backup is not None and backup.exists():
                if not target.exists() and not target.is_symlink():
                    backup.rename(target)
                    backup.parent.rmdir()
                    print('替换失败，已恢复原配置。', file=sys.stderr)
                else:
                    print('替换失败，原配置保留于：' + str(backup), file=sys.stderr)
            raise
    print('完成：' + str(target))
    if backup is not None:
        print('确认新配置可用后可自行归档备份：' + str(backup))


parser = argparse.ArgumentParser(description='安全下载并替换脚本所在目录的 VS Code 配置')
parser.add_argument('--dry-run', action='store_true')
args = parser.parse_args(sys.argv[2:])
dry_run = os.environ.get('DRY_RUN', '0')
if dry_run not in {'0', '1'}:
    parser.error('DRY_RUN 只能为 0 或 1')
try:
    inject(args.dry_run or dry_run == '1')
except (KeyboardInterrupt, EOFError):
    print('已取消；如已显示备份路径，请核对该目录。', file=sys.stderr)
    sys.exit(130)
except (OSError, RuntimeError, UnicodeError, subprocess.SubprocessError) as error:
    print('配置注入失败：' + str(error), file=sys.stderr)
    sys.exit(1)
PYTHON
)"
  command python3 -c "$injector_code" "$SCRIPT_DIR" "$@"
}

main "$@"
