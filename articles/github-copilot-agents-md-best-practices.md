---
title: "GitHub Copilot カスタムエージェントのための agents.md 作成ベストプラクティス"
emoji: "🤖"
type: "tech"
topics: ["github", "githubcopilot", "ai", "agents"]
published: true
publication_name: "studypocket"
---

## はじめに

スタディポケットでソフトウェアエンジニア / SRE として働いている[@Tocyuki](https://x.com/Tocyuki)です。

先日 GitHub Copilot にカスタムエージェント機能が登場し、これは面白そうだと思い早速試してみました。

https://github.blog/changelog/2025-10-28-custom-agents-for-github-copilot/

`.github/agents/` ディレクトリに agents.md ファイルを配置することで、カスタムエージェントを定義し、Issue に定義したカスタムエージェントをアサインできるようになっています。従来の汎用アシスタントではなく、バックエンド専用の `@backend-specialist`、フロントエンド専用の `@frontend-specialist`、SRE専用の `@sre-specialist` など、専門性を持ったエージェントチームを構築できるのが最高に良いですね。

https://docs.github.com/ja/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents

また、GitHub が 2,500 以上のリポジトリを分析して得られた知見をまとめた記事が公開されていたので、それをもとに効果的な agents.md ファイルの書き方を自分なりに整理してみました。

https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/

## agents.md とは

ここで言う agents.md は、GitHub Copilot のカスタムエージェントを定義するための設定ファイルで、 `.github/agents/` 配下にファイルを配置します。
エージェントのペルソナ、対応する技術スタック、プロジェクト構造、ワークフロー、実行可能なコマンド、コードスタイルの例、そして「やってはいけないこと」の境界線などを定義できます。



```
## ファイルの配置場所

.github/
└── agents/
    ├── backend-specialist.agent.md
    ├── frontend-specialist.agent.md
    └── sre-specialist.agent.md
```


:::message
prompt の max length は30000文字なので注意しましょう。
![prompt exceeds max length of 30000 エラー](/images/github-copilot-agents-md-best-practices/prompt-max-length-error.png)
:::


リポジトリのルートに単一の `AGENTS.md` ファイルを配置しても GitHub Copilot は解釈できるので OK です。プロジェクトの特定の部分にのみ適用したい場合は、該当ディレクトリにネストした `AGENTS.md` ファイルを配置することも可能です。

https://agents.md/

https://github.blog/changelog/2025-08-28-copilot-coding-agent-now-supports-agents-md-custom-instructions/

## YAML フロントマターの設定項目

https://docs.github.com/ja/copilot/reference/custom-agents-configuration

agents.md ファイルの冒頭には、YAML フロントマターでエージェントのメタデータを定義します。以下は設定可能なプロパティの一覧です。

```yaml
---
name: test-agent
description: テストコードを作成する専門エージェントです。Jest と React Testing Library を使用します。
tools: ['read', 'search', 'edit']
---
```

### 基本プロパティ

| プロパティ | 必須 | 説明 |
|-----------|------|------|
| `name` | 任意 | エージェントの表示名。省略時はファイル名（`.agent.md` を除いた部分）が使用される |
| `description` | **必須** | エージェントの目的や専門領域を説明する簡潔な文 |

### 環境・ツール設定

| プロパティ | 説明 |
|-----------|------|
| `target` | エージェントを使用する環境を制限。`vscode` または `github-copilot` を指定。省略時は両方で利用可能 |
| `tools` | エージェントが使用できるツールのリスト。省略時はすべてのツールが有効 |
| `model` | 使用する AI モデルを指定（VS Code、JetBrains IDE、Eclipse、Xcode で利用可能） |

### tools プロパティの詳細

`tools` プロパティでは、以下のエイリアスが使用できます。

| エイリアス | 用途 |
|-----------|------|
| `shell` | シェルコマンドの実行（`bash`, `powershell`） |
| `read` | ファイル内容の読み取り |
| `edit` | ファイルの編集・作成 |
| `search` | ファイルやテキストの検索（`grep`, `glob`） |
| `web` | Web コンテンツの取得・検索 |
| `custom-agent` | 他のカスタムエージェントの呼び出し |

```yaml
# すべてのツールを有効化（デフォルト）
tools: ["*"]

# 特定のツールのみ有効化
tools: ["read", "search", "edit"]

# すべてのツールを無効化
tools: []

# MCP サーバーのツールを指定
tools: ["read", "github/get_issue", "playwright/*"]
```

### handoffs プロパティ（エージェント間連携）

`handoffs` は VS Code などの IDE 環境で、エージェント間でタスクを引き継ぐ際の設定です。GitHub.com のコーディングエージェントでは現在サポートされていません。

```yaml
handoffs:
  - label: 実装を開始する
    agent: implementation
    prompt: テストを合格させるコードを実装してください。
    send: false
```

| プロパティ | 説明 |
|-----------|------|
| `label` | ユーザーに表示される引き継ぎオプションのラベル |
| `agent` | 引き継ぎ先のエージェント名（ファイル名から `.agent.md` を除いた部分） |
| `prompt` | 引き継ぎ時に渡すプロンプト |
| `send` | `true` の場合、ユーザーの確認なしに自動的に引き継ぎを実行 |

### MCP サーバーの設定

カスタムエージェントは MCP（Model Context Protocol）サーバーのツールを利用できます。

**リポジトリレベルのエージェント**では、エージェントプロファイル内で直接 MCP サーバーを設定できません。リポジトリ設定で設定した MCP サーバーのツールを `tools` プロパティで指定して使用します。

https://docs.github.com/ja/copilot/how-tos/use-copilot-agents/coding-agent/extend-coding-agent-with-mcp

```yaml
# リポジトリ設定で構成した MCP サーバーのツールを使用
tools: ["read", "edit", "custom-mcp/tool-1", "custom-mcp/*"]
```

**組織/エンタープライズレベルのエージェント**では、`mcp-servers` プロパティで直接設定できます。

```yaml
---
name: my-custom-agent-with-mcp
description: MCP サーバーを使用するカスタムエージェント
tools: ['read', 'edit', 'custom-mcp/tool-1']
mcp-servers:
  custom-mcp:
    type: 'local'
    command: 'some-command'
    args: ['--arg1', '--arg2']
    env:
      API_KEY: ${{ secrets.API_KEY }}
---
```

また、GitHub.com のコーディングエージェントでは以下の MCP サーバーがデフォルトで利用可能です。

| MCP サーバー | 説明 |
|-------------|------|
| `github` | GitHub API の読み取り専用ツール。`github/*` で全ツール、`github/get_issue` のように個別指定も可能 |
| `playwright` | ブラウザ自動化ツール（localhost のみアクセス可能）。`playwright/*` で全ツール利用可能 |


## 優れた agents.md に必要な 6 つの要素

ようやく本題ですが GitHub の分析を見てみると、効果的な agents.md ファイルには以下の 6 つの要素が含まれているとのことです。

### 1. コマンド（Commands）

エージェントが実行できる具体的なコマンドを明記します。フラグやオプションも含めて正確に記述するのが大事ですね。

```markdown
## 実行可能なコマンド

- テスト実行: `npm test --coverage`
- リント: `npm run lint --fix`
- 型チェック: `npm run typecheck`
- ビルド: `npm run build`
```

曖昧な「テストを実行してください」ではなく、実際に叩くべきコマンドを明示しましょう。

### 2. テスト（Testing）

使用しているテストフレームワークと、テストの実行方法を具体的に記述します。

```markdown
## テスト

- フレームワーク: Jest + React Testing Library
- テスト実行: `npm test`
- カバレッジレポート: `npm test -- --coverage`
- 特定ファイルのテスト: `npm test -- path/to/file.test.ts`
- テストファイルの配置: `__tests__/` ディレクトリまたは `*.test.ts` ファイル
```

### 3. プロジェクト構造（Project Structure）

ディレクトリ構成と各ディレクトリの役割を記述しておくといいです。

```markdown
## プロジェクト構造

src/
├── components/     # React コンポーネント
├── hooks/          # カスタムフック
├── services/       # API クライアント
├── types/          # TypeScript 型定義
└── utils/          # ユーティリティ関数
tests/              # テストファイル
docs/               # ドキュメント
```

### 4. コードスタイル（Code Style）

長い説明文よりも、実際のコード例で示すほうが効果的ですね。

#### 良い例

```typescript
// コンポーネントは関数宣言で定義
export function Button({ label, onClick }: ButtonProps) {
  return (
    <button onClick={onClick} className="btn-primary">
      {label}
    </button>
  );
}
```

#### 避けるべき例

```typescript
// アロー関数でのコンポーネント定義は使用しない
const Button = ({ label, onClick }: ButtonProps) => {
  // ...
};
```

### 5. Git ワークフロー（Git Workflow）

ブランチ命名規則やコミットメッセージのフォーマットを定義しておきましょう。

```markdown
## Git ワークフロー

- ブランチ命名: `feature/`, `fix/`, `docs/` プレフィックスを使用
- コミットメッセージ: Conventional Commits 形式
  - `feat:` 新機能
  - `fix:` バグ修正
  - `docs:` ドキュメント
  - `test:` テスト追加・修正
- PR 作成前に必ず `npm run lint && npm test` を実行
```

### 6. 境界線（Boundaries）

エージェントがやるべきこと、確認が必要なこと、絶対にやってはいけないことを 3 段階で明確にしておくと安心です。

```markdown
### 常に行うこと (Always Do)
- 変更前にテストを実行する
- 型チェックをパスすることを確認する
- 既存のコードスタイルに従う

### 確認が必要なこと (Ask First)
- データベーススキーマの変更
- 新しい依存パッケージの追加
- API エンドポイントの変更

### 絶対にやらないこと (Never Do)
- 本番環境の設定ファイルを変更しない
- シークレットやクレデンシャルをコミットしない
- 失敗するテストを削除しない
- ソースコードのロジックを変更せずにテストを通そうとしない
```

## 失敗する agents.md の共通点

反対に GitHub の分析で明らかになった、うまく機能しない agents.md の特徴が以下となります。

### 曖昧な定義

```markdown
# NG: 曖昧すぎる
あなたは親切なコーディングアシスタントです。

# OK: 具体的で明確
あなたは React コンポーネントのテストを書くテストエンジニアです。
Jest と React Testing Library を使用し、__tests__ ディレクトリにテストを配置します。
ソースコードは変更せず、テストコードのみを書きます。
```

汎用的な説明だとうまく機能しないんですよね。エージェントの役割、使用する技術、対象となるファイル、禁止事項を具体的に記述するのがポイントです。

### 過度に複雑な設計

最初から「何でもできるエージェント」を作ろうとして情報を詰め込みすぎると、失敗しがちです。

## 段階的に改善する

完璧な agents.md を最初から作ろうとする必要はないです。

### Step 1: 最小限からスタート

```markdown
---
name: test-agent
description: テストを書くエージェント
---

あなたはテストを書くエンジニアです。
テストフレームワークは Jest を使います。
```

### Step 2: 問題が起きたら追記

エージェントが意図しない動作をしたら、その経験をもとに境界線やルールを追加していきましょう。

```markdown
## 追加したルール（実際の問題から学んだこと）

- テストファイルは `*.test.ts` の命名規則に従う
- モックは `__mocks__` ディレクトリに配置する
- 非同期テストには必ず `await` を使用する
```

## まとめ

というわけで、 GitHub の分析結果から効果的な agents.md を作成するためのポイントをまとめてみました。

そして、カスタムエージェントを使う利点の一つは **Issue にアサインして並列実装ができること** です。複数の Issue に適切なカスタムエージェントをアサインすることで、同時に複数の開発タスクを効率的にクラウド上で進められます。

https://x.com/Tocyuki/status/1990681272231018741

ただし、エージェントが適切に動作するためには、Issue に必要な情報が揃っていることが大前提です。Issue Template を整備して、背景・要件・受け入れ条件などを漏れなく記載する習慣をつけましょう。agents.md でどれだけ良い指示を書いても、Issue の情報が不足していては効果が薄れてしまいます。

さらに、Issue Template の作成や Issue 自体の作成もエージェントに任せるのがおすすめです。エージェントが作りやすい Issue をエージェントに作らせることで、必要な情報が漏れなく記載され、実装時の精度も上がります。

https://x.com/Tocyuki/status/1988830378719646106

エージェントは最初から完璧である必要はないので、シンプルに始めて実際の運用から改善を重ねていくことで、プロジェクトに最適化されたエージェントが育っていきます。

それでは良きAIオーケストレーションライフを✌️

## 参考リンク

https://github.blog/ai-and-ml/github-copilot/5-tips-for-writing-better-custom-instructions-for-copilot/

https://docs.github.com/ja/copilot/how-tos/agents/copilot-coding-agent/best-practices-for-using-copilot-to-work-on-tasks

