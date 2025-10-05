---
title: "tmuxでディレクトリ移動時にウィンドウ名を自動更新する方法"
emoji: "🖥️"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["tmux", "zsh", "terminal"]
published: true
---

## 概要

tmuxで複数のプロジェクトを開いている際、どのウィンドウがどのプロジェクトか一目で判別したいことがあります。通常、ウィンドウ名を設定するには `rename-window` コマンドを手動で実行する必要があり、プロジェクト間を移動するたびに操作が必要になります。

この記事では、ディレクトリ移動時にウィンドウ名を自動的に更新する仕組みを実装する方法を紹介します。

## 実装内容

### tmux設定 (.tmux.conf)

以下のパラメーターを `.tmux.conf` へ追加します。

```conf
## ウィンドウ名のリネーム設定（シェル側から制御）
set-window-option -g allow-rename on
set-window-option -g automatic-rename off
```

### zsh設定 (.zshrc)

```bash
# ==============================
# tmux: ディレクトリ変更時にウィンドウ名を更新
# ==============================
if [ -n "$TMUX" ]; then
  function tmux_rename_window() {
    # Gitリポジトリのルートディレクトリを取得
    local git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ -n "$git_root" ]; then
      # リポジトリ名を取得
      local repo_name=$(basename "$git_root")
      tmux rename-window "$repo_name"
    else
      # Gitリポジトリでない場合はカレントディレクトリ名
      tmux rename-window "$(basename "$PWD")"
    fi
  }

  # ディレクトリ変更時に自動実行
  add-zsh-hook chpwd tmux_rename_window

  # 初回起動時にも実行
  tmux_rename_window
fi
```

## 動作

- tmux内でディレクトリを移動（`cd`コマンド）すると、ウィンドウ名が自動的に更新される
- Gitリポジトリの場合はリポジトリ名、それ以外はカレントディレクトリ名が設定される

## 実行例

```bash
cd ~/ghq/github.com/Tocyuki/dotfiles
# → ウィンドウ名が "dotfiles" に自動変更

cd ~/Documents
# → ウィンドウ名が "Documents" に自動変更
```

## メリット

- 複数のプロジェクトを開いている際に、ウィンドウ名でどのプロジェクトか一目で判別可能
- 手動でウィンドウ名を変更する手間が不要
- ディレクトリ移動のたびに自動更新されるため、常に最新の状態を反映

## 補足

### zshのchpwdフック

[`chpwd`](https://zsh.sourceforge.io/Doc/Release/Functions.html)は、カレントディレクトリが変更されるたびに実行されるzshのフック関数です。[`add-zsh-hook`](https://zsh.sourceforge.io/Doc/Release/User-Contributions.html)コマンドを使用することで、複数のフック関数を登録できます。

### tmuxの設定について

- [`allow-rename on`](https://man7.org/linux/man-pages/man1/tmux.1.html): シェルからエスケープシーケンスを使ってウィンドウ名を変更することを許可する
- [`automatic-rename off`](https://man7.org/linux/man-pages/man1/tmux.1.html): tmux側の自動リネーム機能を無効化し、シェル側で完全に制御できるようにする

この設定により、シェルスクリプトから`tmux rename-window`コマンドでウィンドウ名を変更できるようになります。

## まとめ

tmuxとzshのフック機能を組み合わせることで、ディレクトリ移動時にウィンドウ名を自動的に更新できます。Gitリポジトリでの作業が多い場合、リポジトリ名が自動的にウィンドウ名に反映されるため、作業効率が向上します。

この記事で紹介した設定は、筆者のdotfilesリポジトリでも公開しています。他の便利な設定も含まれているので、よろしければ参考にしてください。

https://github.com/Tocyuki/dotfiles
