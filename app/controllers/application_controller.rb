# frozen_string_literal: true

# アプリケーション全体の共通処理を扱うコントローラ
class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end
