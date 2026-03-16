## 本番デプロイ手順（Lightsail + Cloudflare）

### 前提

- AWS Lightsail 上に Ubuntu 22.04 LTS インスタンスを作成済み（1GB RAM / 2 vCPUs / 40GB SSD）
- インスタンスに Docker / docker compose v2 がインストール済み
- Cloudflare にドメインを登録し、DNS を Lightsail のパブリックIPへ向け済み
- アプリの Git リポジトリを `/var/www/kurahashi-task` など任意ディレクトリに clone 済み
- ホストOS上に `.env.production` を作成し、以下のような内容を設定済み

```bash
RAILS_ENV=production
RAILS_MASTER_KEY=********
APP_DATABASE_PASSWORD=********
RAILS_SERVE_STATIC_FILES=1
RAILS_LOG_LEVEL=info
APP_HOST=example.com
```

### 初回デプロイ

```bash
cd /var/www/kurahashi-task
git pull

# 環境変数を読み込む（シェルの設定に応じて変更）
set -a
source .env.production
set +a

# 本番起動（開発用 compose と本番用 compose をマージ）
docker compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d

# DB マイグレーション
docker compose -f docker-compose.yml -f docker-compose.prod.yml exec app bundle exec rails db:migrate
```

ブラウザで `https://APP_HOST` にアクセスし、Cloudflare 経由でアプリが表示されることを確認します。

### 更新デプロイ

```bash
cd /var/www/kurahashi-task
git pull
docker compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d
docker compose -f docker-compose.yml -f docker-compose.prod.yml exec app bundle exec rails db:migrate
```

### Cloudflare キャッシュクリア

CSS/JS が更新されても反映されない場合は、Cloudflare ダッシュボードから対象ドメインを選択し、  
`Caching > Configuration > Purge Cache` で `Purge Everything` を実行します。

### Cloudflare WAF / Lightsail ファイアウォール設定メモ

#### Cloudflare WAF（自分以外をブロック）

- Cloudflareダッシュボード → 対象ドメイン → `Security` → `WAF` → `Custom rules` からルールを作成。
- 例（自分のIPv4/IPv6以外をブロックする場合）:
  - Expression: `ip.src ne { <自分のIPv4>/32 <自分のIPv6>/128 }`
  - Action: `Block`
- もし今後、動的IPで運用する場合は、代わりに「カスタムヘッダー必須」ルールを使う:
  - Expression: `http.request.headers["x-private-access"] ne "自分だけが知るトークン"`
  - Action: `Block`

#### Lightsail ファイアウォール

- IPv4:
  - `HTTP (TCP 80)`: Cloudflare経由のアクセスのみを想定し、Cloudflare公開IPv4レンジからのアクセスを許可。それ以外は拒否。
  - `SSH (TCP 22)`: インターネットからは閉じ、基本的に Lightsail ブラウザコンソールでのみ操作する。
- IPv6:
  - 不要なのでLightsail側の「IPv6 ネットワーキング」を無効化しておき、Cloudflare側も IPv4 のみで運用する。

