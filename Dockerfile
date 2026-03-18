FROM ruby:3.2.2-slim

# 必要なパッケージのインストール
# nodejs は tailwindcss-rails がスタンドアロンバイナリを同梱するため不要
RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends \
     build-essential \
     libpq-dev \
     curl \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Gemfile先行コピーでbundle installをレイヤーキャッシュ
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test \
  && bundle clean --force \
  && rm -rf /usr/local/bundle/cache

# アプリケーション全ファイルのコピー
COPY . .

# アセットのプリコンパイル（Tailwind CSSビルドを含む）
# SECRET_KEY_BASE はビルド時のダミー値（実行時は環境変数から注入）
RUN RAILS_ENV=production SECRET_KEY_BASE=dummy_for_assets_precompile \
    bundle exec rails assets:precompile \
  && rm -rf tmp/cache

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
