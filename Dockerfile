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

# サーバー起動
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]