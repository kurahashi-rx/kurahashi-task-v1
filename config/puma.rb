# Puma starts a configurable number of processes (workers) and each process
# serves each request in a thread from an internal thread pool.
#
# The ideal number of threads per worker depends both on how much time the
# application spends waiting for IO operations and on how much you wish to
# prioritize throughput over latency.
#
# As a rule of thumb, increasing the number of threads will increase how much
# traffic a given process can handle (throughput), but due to CRuby's
# Global VM Lock (GVL) it has diminishing returns and will degrade the
# response time (latency) of the application.
#
# The default is set to 3 threads as it's deemed a decent compromise between
# throughput and latency for the average Rails application.
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

# Puma workers (processes).
# t4g.nano (0.5GB) ではメモリ節約のためデフォルト 1。
# t4g.micro (1GB) では WEB_CONCURRENCY=2 に増やせる。
workers ENV.fetch("WEB_CONCURRENCY", 1).to_i

# アプリをフォーク前にロードしてメモリを節約（workers >= 2 で効果大）
preload_app!

# バインドアドレス。Cloudflare Tunnel から直接 HTTP で受け取る。
bind "tcp://0.0.0.0:#{ENV.fetch("PORT", 3000)}"

# RAILS_ENV を読み込む
environment ENV.fetch("RAILS_ENV", "development")

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

# Tailwind CSS watch（開発時のみ）
plugin :tailwindcss if ENV.fetch("RAILS_ENV", "development") == "development"

# Specify the PID file. Defaults to tmp/pids/server.pid in development.
# In other environments, only set the PID file if requested.
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
