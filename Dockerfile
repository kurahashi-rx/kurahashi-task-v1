FROM ruby:3.2.2

# 必要なパッケージのインストール
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# 作業ディレクトリを docker-compose と合わせる
WORKDIR /app

# Gemのインストール
COPY Gemfile Gemfile.lock ./
RUN bundle install

# アプリケーション全ファイルのコピー
COPY . .

# 本番環境のアセットをビルド（RAILS_ENV は起動時の環境変数に依存）
RUN bundle exec rails assets:precompile

# サーバー起動スクリプトを実行可能に
RUN chmod +x bin/server

EXPOSE 3000
CMD ["./bin/server"]