import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // HTML上の 'data-navbar-target' と紐付けるターゲットの定義
  static targets = ["menu", "button"]

  connect() {
    // コンポーネントが読み込まれた際の初期状態（閉じた状態）
    this.open = false
  }

  // ボタンクリック時に実行される処理
  toggle() {
    this.open = !this.open
    // 'hidden'クラスを付け外しすることで表示/非表示を切り替える
    this.menuTarget.classList.toggle("hidden", !this.open)
    
    // アクセシビリティ（読み上げソフト等）向けに状態を更新
    if (this.buttonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", String(this.open))
    }
  }
}