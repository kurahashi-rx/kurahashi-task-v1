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

