# dotfiles-linux

Linux 环境下的个人配置仓库，用于备份当前配置、将本机配置文件符号链接到仓库文件，并支持跨设备复用。

当前目标：

- 将常用 shell 配置托管到 GitHub
- 在新环境中快速安装依赖工具
- 把本机配置文件链接到仓库文件
- 借助 Git 历史回滚到之前的稳定版本

## Shell 优化软件

当前这套 shell 体验主要基于以下工具：

- `starship`：负责统一管理命令行提示符，提供目录、Git、语言版本、容器上下文等信息
- `zsh-autosuggestions`：根据历史命令和上下文提供输入建议
- Zsh 内建补全：通过 `compinit` 提供补全能力，并将补全缓存写入 XDG 目录

## 当前范围

目前主要管理这些配置：

- `~/.zshenv`
- `~/.zshrc`
- `~/.config/starship.toml`
- `~/.config/npm/npmrc`

当前方案以 Linux 为主，优先支持 Debian / Ubuntu。
macOS 会单独维护另一套仓库，避免为了强行跨平台兼容而让配置变得复杂混乱。

## 目录结构

```text
dotfiles-linux/
  config/
    npm/
      npmrc
    starship.toml
  scripts/
    init.sh
    restore.sh
  zsh/
    .zshenv
    .zshrc
```

## 脚本说明

### `scripts/init.sh`

用于 Linux 新环境初始化，负责：

- 安装基础工具
- 安装 `starship`
- 安装 `zsh-autosuggestions`
- 创建当前配置依赖的目录结构

当前仅支持：

- Linux
- Debian / Ubuntu `apt`

执行方式：

```sh
./scripts/init.sh
```

### `scripts/restore.sh`

用于备份当前本机配置，并建立指向仓库文件的符号链接，负责：

- 备份当前本机配置
- 将本机配置文件链接到仓库文件

当前会链接这些路径：

- `~/.zshenv`
- `~/.zshrc`
- `~/.config/starship.toml`
- `~/.config/npm/npmrc`

执行方式：

```sh
./scripts/restore.sh
```

备份位置：

```text
~/.local/state/dotfiles-linux-backups/<timestamp>/
```

## 推荐使用流程

### 新机器初始化

```sh
git clone <repo-url> ~/workspace/dotfiles-linux
cd ~/workspace/dotfiles-linux
./scripts/init.sh
./scripts/restore.sh
```

然后重新打开一个新的 `zsh` 会话，或者执行：

```sh
source ~/.zshenv
source ~/.zshrc
```

### 日常修改配置

推荐直接修改仓库中的文件，例如：

- `zsh/.zshenv`
- `zsh/.zshrc`
- `config/starship.toml`
- `config/npm/npmrc`

修改后通常不需要再执行 `./scripts/restore.sh`，因为本机配置文件已经链接到仓库文件。

如果希望让当前 shell 会话立即加载最新配置，可以执行：

```sh
source ~/.zshenv
source ~/.zshrc
```

由于本机配置文件已经链接到仓库文件，修改仓库中的配置后会直接影响系统实际生效的配置。

如果你手动改坏了本机链接，或者要在新机器上重新接入，再执行一次：

```sh
./scripts/restore.sh
```

## 回滚

如果某次配置修改导致问题，可以按不同场景处理。

### 临时验证旧版本

适合先切到历史提交验证配置是否正常，而不直接改动当前分支：

```sh
git log --oneline
git switch --detach <commit>
./scripts/restore.sh
```

验证完成后，再切回原来的分支继续工作。

### 正式回退

如果确认要把某个文件回退到历史版本，可以直接从指定提交恢复仓库文件：

```sh
git restore --source <commit> zsh/.zshrc
./scripts/restore.sh
```

其它配置文件也可以按同样方式回退。回退后如果本机链接被改坏，可以再执行一次 `./scripts/restore.sh`。

## 注意事项

- 不要把敏感信息提交到仓库
- 不要把缓存、历史记录、token、SSH 密钥提交到仓库
- 仓库中的配置文件应视为真源
- `restore.sh` 会把本机配置改为指向仓库文件的符号链接
- 如果仓库目录移动了位置，需要重新执行一次 `./scripts/restore.sh` 来修复链接
