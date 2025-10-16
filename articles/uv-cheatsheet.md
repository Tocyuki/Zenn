---
title: "uvコマンドチートシート"
emoji: "⚡"
type: "tech"
topics: ["python", "uv"]
published: true
publication_name: "studypocket"
---

## はじめに

スタディポケットでソフトウェアエンジニア / SRE として働いている[@Tocyuki](https://x.com/Tocyuki)です。

弊社プロダクトのバックエンドは FastAPI で書かれており、パッケージマネージャーにはもちろん(?) uv を使っています。

https://docs.astral.sh/uv/

普段よく使うコマンドなので、n番煎じ感満載ですが Python が久しぶりで uv 素人な自分のためにチートシート記事を書きました。


## uv とは

uv は Rust で書かれた高速な Python パッケージマネージャーです。Astral 社が開発しています。

公式では以下のように説明されています：

> 🚀 A single tool to replace `pip`, `pip-tools`, `pipx`, `poetry`, `pyenv`, `twine`, `virtualenv`, and more.
>
> *出典: [uv公式リポジトリ](https://github.com/astral-sh/uv)*

従来の Python エコシステムでは、pip、pip-tools、pipx、poetry、pyenv、virtualenv など複数のツールを使い分ける必要がありましたが、uv はこれらの機能を 1 つに統合しています。

**主な特徴：**
- 既存ツールの 10-100 倍の速度（Rust 実装のおかげ）
- pip、pip-tools、pipx、poetry、pyenv、virtualenv などの機能を 1 つのツールで実現
- PEP 621 などの Python 標準仕様に準拠

### 主な機能

**pyproject.toml によるプロジェクト管理**
uv は `pyproject.toml` でプロジェクトの情報や依存関係を管理します。

```toml
[project]
name = "myproject"
version = "0.1.0"
dependencies = [
    "requests>=2.31.0",
    "fastapi>=0.100.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "ruff>=0.1.0",
]
```

**uv.lock による環境の再現**
`uv lock` コマンドでロックファイル（`uv.lock`）を生成します。これにより、チーム全体や CI/CD で同じバージョンの依存関係を使えます。

**ユニバーサル依存解決**
複数のプラットフォーム（Linux、macOS、Windows）や Python バージョンに対応した依存関係を 1 つのロックファイルで管理できます。

**グローバルキャッシュ**
ダウンロードしたパッケージをキャッシュするので、複数のプロジェクトで同じパッケージを再利用できます。

### 従来ツールとの比較

| 機能 | pip | poetry | uv |
|------|-----|--------|-----|
| パッケージインストール | ○ | ○ | ○ |
| 依存関係解決 | △（遅い） | ○ | ◎（高速） |
| ロックファイル | × | ○ | ○ |
| Python バージョン管理 | × | × | ○ |
| ツール実行 | × | × | ○ |
| プロジェクト管理 | × | ○ | ○ |
| 速度 | 遅い | 普通 | 非常に高速 |

## チートシート

というわけでチートシートセクションを始めていきます。

### 🧱 プロジェクトの作成

プロジェクトの初期化に関するコマンドです。

```bash
# カレントディレクトリにプロジェクトを初期化
uv init

# 指定したディレクトリにプロジェクトを初期化
uv init myproj

# パッケージ化可能なアプリケーションとして初期化
uv init --app --package

# パッケージ化可能なライブラリとして初期化
uv init --lib --package

# 特定のPythonバージョンを指定してプロジェクトを初期化
uv init --python 3.12
```

### 🧩 プロジェクトの依存関係管理

依存パッケージの追加、削除、確認に関するコマンドです。`uv add` や `uv remove` を実行すると、`pyproject.toml` が自動的に更新されます。

```bash
# 依存関係を追加
uv add requests

# 複数の依存関係を一度に追加
uv add A B C

# requirements.txtから依存関係を追加
uv add -r requirements.txt

# 開発用の依存関係を追加
uv add --dev pytest

# 依存関係を削除
uv remove requests

# プロジェクトの依存関係ツリーを表示
uv tree

# ロックファイル（uv.lock）を生成・更新
uv lock

# すべての依存関係を最新バージョンにアップグレード
uv lock --upgrade

# 特定のパッケージのみを最新バージョンにアップグレード
uv lock --upgrade-package requests

# ロックファイルに基づいて依存関係をインストール
uv sync

# 開発用依存関係を除外してインストール
uv sync --no-dev
```

:::message
**`uv lock` と `uv lock --upgrade` の違い**

- `uv lock`: 既存のロックファイルがある場合、**以前のバージョンを維持**します。pyproject.toml の制約が変更されて既存バージョンが使えなくなった場合のみバージョンが変わります。
- `uv lock --upgrade`: **すべてのパッケージを最新バージョン**にアップグレードします（依存関係制約の範囲内で）。

新しいバージョンのパッケージがリリースされても、`uv lock` だけでは自動的にアップグレードされません。

**意図的にアップグレードする方法：**
1. `uv lock --upgrade` または `uv lock --upgrade-package <package>` を実行
2. `pyproject.toml` のバージョン制約を更新（例：`requests>=2.0.0` → `requests>=2.31.0`）してから `uv lock` を実行

**`uv sync` の役割：**
`uv sync` は、ロックファイル（uv.lock）に記録されたバージョンをプロジェクト環境にインストールします。これにより、チームメンバー全員が同じバージョンの依存関係を使用できます。
`uv run` や `uv add` は自動的に sync を実行しますが、エディタで最新の依存関係を認識させたい場合などに明示的に実行すると便利です。
:::

### 🏃 プロジェクトでのコマンド実行

プロジェクトのコンテキストでコマンドやスクリプトを実行するコマンドです。

`uv run` は、プロジェクトの `pyproject.toml` がある環境で実行すると、プロジェクト自体とその依存関係がインストールされた環境でコマンドを実行します。
これは、pytest や mypy など、プロジェクトのコードや依存関係にアクセスする必要があるツールを実行する際に使用します。

```bash
# プロジェクト環境でpytestを実行
uv run pytest

# プロジェクト環境でPythonスクリプトを実行
uv run python script.py

# プロジェクト環境でmypyを実行
uv run mypy src/

# プロジェクト環境で任意のコマンドを実行
uv run python -c "import requests; print(requests.__version__)"
```

:::message
**`uv run` と `uv tool run` (uvx) の違い**

- `uv run`: プロジェクトの依存関係を含む環境でコマンドを実行（プロジェクトのコードにアクセス可能）
- `uvx` / `uv tool run`: プロジェクトから完全に独立した一時的な環境でツールを実行

プロジェクトに依存するツール（pytest、mypy など）は `uv run` を使用し、グローバルなツール（ruff、black など）は `uvx` を使用します。
:::

### 🔄 プロジェクトのライフサイクル管理

プロジェクトのビルド、公開、バージョン管理に関するコマンドです。

```bash
# パッケージ化可能なプロジェクトをビルド
uv build

# プロジェクトをPyPIに公開
uv publish

# プロジェクトのバージョンを確認
uv version
```

バージョンのバンプ (更新) コマンドも用意されています：
- メジャーバージョン、マイナーバージョンの更新
- ベータ版、RC 版、安定版リリースへの更新

### ⚒️ ツールの管理

グローバルツールのインストールと実行に関するコマンドです。

`uv tool run` (または `uvx`) は、プロジェクトから完全に独立した一時的な環境でツールを実行します。プロジェクトの依存関係やコードにアクセスする必要がないツール（ruff、black など）を実行する際に使用します。

```bash
# 独立した環境でツールを実行
uv tool run ruff

# uv tool runのエイリアス
uvx ruff

# ツールをグローバルにインストール
uv tool install ruff

# インストール済みツールの一覧を表示
uv tool list

# ツールをアップグレード
uv tool upgrade ruff

# すべてのツールをアップグレード
uv tool upgrade --all

# 現在のプロジェクトを編集可能モードでインストール
uv tool install -e .
```

### 📜 スクリプトの操作

Python スクリプトの初期化と実行に関するコマンドです。

```bash
# スクリプトを初期化
uv init --script myscript.py

# スクリプトに依存関係を追加
uv add click --script myscript.py

# スクリプトを実行
uv run myscript.py
```

:::details 実行可能なスクリプトを作成するための Tips
スクリプトファイルの先頭に以下の shebang を追加すると、直接実行できるようになります。

```python
#!/usr/bin/env -S uv run
```

実行権限を付与すれば、`./myscript.py` で直接実行可能になります。

```bash
chmod +x myscript.py
./myscript.py
```
:::

### 🐍 Python バージョンの管理

Python バージョンの確認とインストールに関するコマンドです。

```bash
# 利用可能なPythonバージョンの一覧を表示
uv python list

# 特定のPythonバージョンをインストール
uv python install 3.12

# デフォルトのPythonバージョンを設定
uv python pin 3.12
```

## まとめ

uv は高速で、使いやすいコマンド体系を持っています。チートシートとして、この記事をブックマークしておくと便利かもしれません（ワイが）。

詳しい情報は当然の如く、[uv公式ドキュメント](https://docs.astral.sh/uv/)をご覧ください。

## 参考リンク

- [uv公式ドキュメント](https://docs.astral.sh/uv/)
- [uvのGitHubリポジトリ](https://github.com/astral-sh/uv)

