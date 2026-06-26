# デプロイメント・運用ガイド

Yagamo Style（Hugo + Hextra）の構成と運用フローのメモ。

## 構成スタック

| 要素 | 内容 |
|---|---|
| サイトジェネレータ | Hugo Extended 0.154.5（Docker イメージで実行） |
| Docker イメージ | `hugomods/hugo:reg-exts-0.154.5`（exts = Extended + reg = git 付き） |
| テーマ | [Hextra](https://github.com/imfing/hextra) v0.12.x（Hugo Modules で管理） |
| ホスティング | GitHub Pages（master ブランチ） |
| CI/CD | CircleCI（write → master 自動デプロイ） |
| 独自ドメイン | yagamo-style.com（`public/CNAME` で設定） |

## ブランチ構成

| ブランチ | 役割 |
|---|---|
| `master` | GitHub Pages 配信用。CircleCI が自動更新。**直接触らない** |
| `write` | 記事執筆・サイト本体の編集用。push すると CircleCI が走る |
| `article` | 記事執筆時に `write` から切る一時ブランチ。完成後 `write` にマージして削除 |

## ローカル開発

### 必要なもの
Docker Desktop（Hugo はすべて Docker コンテナで実行するため、Hugo / Go のローカルインストールは不要）。

### よく使うコマンド
```bash
./hugo-server.sh                       # 開発サーバ起動 http://localhost:1313/
./hugo-new.sh YYYY/post-name           # 新規記事作成（archetypes/default.md から）
./hugo-base.sh                         # ビルドのみ
./hugo-base.sh mod get -u              # Hextra テーマを最新化
```

### Hugo / テーマのバージョン更新
- Hugo: `hugo-base.sh` と `.circleci/config.yml` の Docker タグを差し替え
- Hextra: `./hugo-base.sh mod get -u github.com/imfing/hextra`（`go.mod` / `go.sum` が更新される）

## 記事執筆ワークフロー

```bash
# 1. write から article ブランチを切る
git checkout write
git checkout -b article

# 2. 記事を新規作成
./hugo-new.sh 2026/my-post

# 3. 執筆＆ローカル確認
./hugo-server.sh  # 別ターミナルで起動して、http://localhost:1313/ で確認

# 4. コミット
git add content/2026/my-post.md static/images/2026/my-post/
git commit -m "..."

# 5. write にマージ＆push（CircleCI が本番反映）
git checkout write
git merge article
git push origin write

# 6. 一時ブランチ削除
git branch -d article
```

## CircleCI（自動デプロイ）

### フロー
`write` に push されると `.circleci/config.yml` の build ジョブが走る:

1. **`openssh-client` インストール** — `hugomods/hugo` は最小イメージで ssh を含まないため
2. **checkout** — `write` ブランチを取得
3. **Git config** — コミット用の name/email 設定
4. **SSH 鍵追加** — `add_ssh_keys` で fingerprint 経由
5. **Build**
   - `hugo` ビルド → `public/` 生成
   - `public/CNAME` に独自ドメイン書き込み
   - `git add -f public; git commit` （`.gitignore` で除外しているので `-f` 必須）
   - `git clean -fdx`
6. **Push**
   - `master` ブランチをチェックアウト
   - 既存ファイルを消して `write` ブランチの `public/` の中身を展開
   - `[ci skip] publish` でコミット → `git push origin master`
7. GitHub Pages が master を配信 → https://yagamo-style.com/ 反映

### 設定の要点
- **Docker イメージ**: `hugomods/hugo:reg-exts-0.154.5`
- **ssh インストール**: `apk add --no-cache openssh-client`（push に必須）
- **public/ ステージ**: `git add -f public`（`.gitignore` 除外を強制突破）
- **SSH 鍵**: CircleCI プロジェクト設定の SSH Keys に登録、`add_ssh_keys` の fingerprints で参照

## テーマ（Hextra）

Hugo Modules で管理しているため `themes/` ディレクトリにはなし。`config.toml` の `[module]` セクションでインポート:

```toml
[module]
[[module.imports]]
path = "github.com/imfing/hextra"
```

`go.mod` / `go.sum` がモジュール解決のメタデータ。

## カスタム要素

### 独自 shortcode（`layouts/shortcodes/`）

| Shortcode | 用途 |
|---|---|
| `{{< latest-articles N >}}` | 最新 N 件の記事リスト（年セクション内すべて対象） |
| `{{< articles-in-year [YYYY] >}}` | 指定年（省略時は現在セクション）の全記事リスト |

### config.toml の重要設定

| キー | 目的 |
|---|---|
| `refLinksErrorLevel = "WARNING"` | `{{< ref ... >}}` で見つからないリンクをビルドエラーにしない |
| `[markup.goldmark.renderer] unsafe = true` | 記事中の生 HTML を許可 |
| `[permalinks]` 2018-2026 | 既存 URL `/:year/:month/:day/:filename/` を維持 |
| `[params] images = [...]` | サイト全体のデフォルト OG 画像 |
| `[params.author] name / email` | Hextra の OGP / RSS テンプレート用 |

### 年別ページ（`content/YYYY/_index.md`）の規約

```toml
+++
title = "2026"
weight = -2026        # 負数で降順表示（サイドバーで 2026 が一番上）
breadcrumbs = false   # H1 とブレッドクラムの二重表示を防ぐ
+++

{{< articles-in-year >}}
```

### OGP（SNS リンクプレビュー）

- サイトデフォルト画像: `config.toml` の `[params] images = ["images/open_graph_logo.png"]`
- 個別記事で上書き: フロントマターに `images = ["..."]`
- ⚠️ 旧 hugo-theme-learn の `ogimage = "..."` は無効（Hextra は Hugo 標準の `images` を見る）

## トラブルシューティング

### Hugo Modules が解決できない
→ Docker イメージは `hugomods/hugo:reg-exts-*`（git 入り）を使う。`exts-*`（git なし）だと失敗。

### `hugo mod download` が unknown command
→ そんなサブコマンドはない。`hugo` を実行すれば自動解決される。明示的にやるなら `hugo mod get`。

### CircleCI で `cannot run ssh: No such file or directory`
→ `hugomods/hugo` に ssh は入っていないので `apk add --no-cache openssh-client` を最初のステップで実行する。

### CircleCI で `git add public` が ignored
→ `.gitignore` で除外しているため、`-f` フラグで強制ステージする。

### `REF_NOT_FOUND` で 500 エラー
→ Hugo 0.144+ は ref shortcode の解決が厳格。`config.toml` に `refLinksErrorLevel = "WARNING"` を追加して緩める。

### `":filename" permalink token is deprecated` 警告
→ Hugo 0.144 で deprecated。将来 `:contentbasename` への置換が必要（意味は同じなので動作には影響なし）。

### Docker daemon に接続できない
→ Docker Desktop を起動してから `./hugo-server.sh` 等を再実行。

## 関連ファイル

| ファイル | 役割 |
|---|---|
| `config.toml` | Hugo / Hextra 設定の中心 |
| `hugo-base.sh` / `hugo-server.sh` / `hugo-new.sh` | Hugo を Docker 経由で実行するラッパー |
| `.circleci/config.yml` | CI/CD 設定 |
| `go.mod` / `go.sum` | Hugo Modules（テーマ依存）の管理 |
| `layouts/shortcodes/` | 独自 shortcode |
| `static/` | 画像・CSS などの静的ファイル |
| `archetypes/default.md` | 新規記事のテンプレート |
