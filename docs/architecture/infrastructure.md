# インフラ設計

## 1. 概要

* 自分専用のRoRアプリケーション。
* **Cloudflare**をリバースプロキシ（CDN）として活用し、インフラ構成を最小化。
  * SSL終端、DDoS対策、IP制限などのセキュリティ機能をCloudflareに委ねる
  * サーバー側は**Docker Compose**（Puma直受け）でシンプルに構築する。

## 2. 構成

### 構成図

```mermaid
graph LR
    subgraph Internet
        User((自分))
    end

    subgraph Edge_Service["Cloudflare (WAF/SSL)"]
        CF[Cloudflare Proxy]
    end

    subgraph AWS_Lightsail["AWS Lightsail Instance"]
        FW[Firewall: Port 80, 443]
        subgraph Docker_Compose["Docker Compose"]
            App[Rails Container: Puma]
            DB[(PostgreSQL Container)]
        end
    end
    
    User -- HTTPS --> CF
    CF -- "HTTPS (Flexible/Full)" --> FW
    FW --> App
    App --> DB

    %% ノートの代わりとしての注釈
    style Edge_Service fill:#f9f,stroke:#333,stroke-width:2px

```

### 選定理由

| コンポーネント | 選定内容 | 備考 |
| --- | --- | --- |
| **Proxy / SSL** | **Cloudflare (Freeプラン)** | 証明書管理が不要。WAF（アクセス制限）もGUIで完結。 |
| **Compute** | Lightsail (Ubuntu) | Docker Engineを動かすホスト。 |
| **App Server** | **Puma (Rails直受け)** | Nginxを挟まないことでメモリ消費と管理対象を削減。 |
| **Database** | PostgreSQL (Container) | コンテナ内にデータを保持。 |

## 3. 詳細スペック

| 項目 | 設定内容 | 備考 |
| --- | --- | --- |
| **プラットフォーム** | Amazon Lightsail | 月額 $3.5〜$5.0 程度のプラン。 |
| **OS** | Ubuntu 22.04 LTS | Dockerのインストールが容易で情報が多い |
| **プラン** | 1GB RAM / 2 vCPUs | **Dockerエンジンとビルド時のメモリ消費**を考慮 |
| **Storage** | 40 GB SSD | 未使用イメージを定期削除（Prune）すれば十分な容量 |
| **Swap領域** | **2GB設定必須** | Dockerビルド時のメモリ不足を防止。 |
| **HTTPS化** | Cloudflare Flexible/Full SSL | サーバー側に複雑なSSL設定（Certbot等）が不要。 |

| **静的ファイル** | Rails (Puma) 配信 | `RAILS_SERVE_STATIC_FILES=true` に設定。 |

## 4. セキュリティ

「自分専用」を守るための設定をCloudflareとRailsの両層で行います。

### Cloudflare層（WAF設定）

* **アクセス制限:** Cloudflareの「WAF Custom Rules」を使用し、**自分のIPv4/IPv6アドレス以外からのアクセスをブロック**する。動的IPの場合は、代わりに「自分だけが知るカスタムヘッダー（例: `X-Private-Access`）必須」ルールを使う。
* **Bot遮断:** 既知のクローラーや攻撃Botをエッジで遮断。

### ネットワーク層（ファイアウォール）

Lightsailの管理画面で以下の方針をとります。

* **IPv6:** 不要なので無効化（Cloudflare / Lightsail 双方で IPv4 に絞る）。
* **SSH (22):** インターネットからは閉じ、**Lightsailブラウザコンソールのみ許可**とする。
* **Port 80:** 一般公開する場合は Cloudflare 経由のみを想定し、Cloudflareの公開IPv4レンジ以外からのアクセスは拒否する（必要に応じてセキュリティグループやネットワークACLで制御）。

### アプリケーション層（認証・認可）

* **MFA(多要素認証):** Rails側で `devise-two-factor` を実装。
* **Basic認証:** 必要に応じて `config/environments/production.rb` で設定。

### 秘密情報の管理

* **Docker Secrets / Env:** `docker-compose.yml` で環境変数を管理。
* **Credentials:** Railsの `master.key` はホストOS上の環境変数、またはコンテナ外のボリュームからマウント。

## 5. 運用手順

### デプロイ

1. ローカルで開発・テスト。
2. GitHubへPush。
3. サーバーへSSHログイン（ブラウザコンソール推奨）。
4. Lightsail上で `git pull`。
5. `docker compose up --build -d`（Pumaコンテナの更新と再起動）。
7. `docker compose exec app bundle exec rails db:migrate`。

### バックアップと復旧

* **スナップショット:** Lightsailの自動スナップショット（毎日1回）。
* **DBダンプ:** `docker compose exec db pg_dump` コマンドを使用して定期的にエクスポート。

### メンテナンス

* **Cloudflare管理:** 証明書の更新などはCloudflareが自動で行うため、ユーザー側の作業はゼロ。
* **キャッシュ削除:** フロントエンド（CSS/JS）を更新した際、Cloudflareの管理画面から「Purge Cache」を実行。

### 保守タスク（月1回推奨）

* **クリーンアップ:** `docker system prune -f` （未使用イメージ・ボリュームの削除）。
* **イメージ更新:** `docker compose pull` でベースイメージを最新化。

### 補足：JCOM（動的IP）環境でのSSH接続のコツ

- IP変動を気にせず済むよう、Lightsailブラウザコンソールを活用する
  - SSHクライアントの設定不要で、どこからでも安全に作業可能です。

## 6. 現状の運用フェーズについて

- 本ドキュメントに記載している構成は、**本番運用時のターゲット構成** を示すものであり、現時点ではローカル開発環境のみで動作している。
- 実際に Lightsail / Cloudflare 構成へ移行する際は、本ファイルと `docker-compose.yml`・`config/environments/production.rb` などの設定が一致しているかを確認し、差分があればドキュメントを更新する。

## 実装メモ

Railsの `config/environments/production.rb` で以下の設定を忘れずに

1. **HTTPSの強制:**
```ruby
config.force_ssl = true

```
Cloudflareから見てHTTPSであれば、Rails側でもHTTPSとして振る舞うようにします。

2. **プロキシの信頼設定:**
Cloudflareはリバースプロキシとして動作するため、Rails側でCloudflareのIPを「信頼できるプロキシ」として登録しておくと、ログに正しいクライアントIP（自分のIP）が記録されるようになります（`rack-cloudflare` などのGemを使うと楽です）。

