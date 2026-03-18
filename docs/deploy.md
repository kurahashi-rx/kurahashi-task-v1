## デプロイ・起動手順

---

### ローカル開発環境

#### 初回セットアップ

```bash
# プロジェクトルートへ移動
cd ~/projects/kurahashi-task

# 環境変数ファイルを作成して値を確認・編集
cp .env.example .env

# コンテナ起動（開発用）
docker compose -f docker-compose.dev.yml up -d

# DB 作成 & マイグレーション
docker compose -f docker-compose.dev.yml exec app bundle exec rails db:create db:migrate
```

#### 起動・停止

```bash
# プロジェクトルートへ移動
cd ~/projects/kurahashi-task

# 起動
docker compose -f docker-compose.dev.yml up -d

# ログ確認
docker compose -f docker-compose.dev.yml logs -f app

# 停止
docker compose -f docker-compose.dev.yml down
```

ブラウザで `http://localhost:3000` にアクセスして動作確認します。

---

### 本番デプロイ（EC2 + Cloudflare Tunnel）

#### 前提

- AWS EC2（t4g.nano/micro）上に Ubuntu 24.04 LTS (ARM64) インスタンスを作成済み
- インスタンスに Docker / docker compose v2 がインストール済み
- Swap 2GB が設定済み（nano はビルド時のメモリ不足防止のため必須）
- アプリの Git リポジトリを `/var/www/kurahashi-task` などに clone 済み
- Cloudflare Zero Trust でトンネルを作成し、`TUNNEL_TOKEN` を取得済み

#### 環境変数ファイルの作成

```bash
cd /var/www/kurahashi-task

# テンプレートをコピーして値を埋める
cp .env.production.example .env.production
vi .env.production
```

`.env.production` の記載例:

```
POSTGRES_USER=postgres
POSTGRES_PASSWORD=強固なパスワード
POSTGRES_DB=kurahashi_task_production
SECRET_KEY_BASE=（bundle exec rails secret で生成した値）
TUNNEL_TOKEN=（Cloudflare Zero Trust で取得したトークン）
```

#### 初回デプロイ

```bash
cd /var/www/kurahashi-task
git pull

# 本番起動
docker compose --env-file .env.production up --build -d

# DB マイグレーション
docker compose --env-file .env.production exec app bundle exec rails db:migrate
```

ブラウザで `https://<ドメイン>` にアクセスし、Cloudflare 経由でアプリが表示されることを確認します。

#### 更新デプロイ

```bash
cd /var/www/kurahashi-task
git pull

docker compose --env-file .env.production up --build -d
docker compose --env-file .env.production exec app bundle exec rails db:migrate
```

#### 停止

```bash
docker compose --env-file .env.production down
```

---

### Cloudflare キャッシュクリア

CSS/JS が更新されても反映されない場合は、Cloudflare ダッシュボードから対象ドメインを選択し、
`Caching > Configuration > Purge Cache` で `Purge Everything` を実行します。

---

### Cloudflare WAF / EC2 ファイアウォール設定メモ

#### Cloudflare WAF（自分以外をブロック）

- Cloudflare ダッシュボード → 対象ドメイン → `Security` → `WAF` → `Custom rules` からルールを作成。
- 例（自分の IP 以外をブロック）:
  - Expression: `ip.src ne { <自分のIPv4>/32 <自分のIPv6>/128 }`
  - Action: `Block`
- 動的 IP で運用する場合は「カスタムヘッダー必須」ルールを使う:
  - Expression: `http.request.headers["x-private-access"] ne "自分だけが知るトークン"`
  - Action: `Block`

#### EC2 セキュリティグループ

- EC2 のインバウンドは**全ポート閉鎖**（SSH 含む）。
- 外部アクセスは Cloudflare Tunnel 経由のみ（アウトバウンドのみ）。
- EC2 操作が必要な場合は AWS Systems Manager Session Manager を使用する。
