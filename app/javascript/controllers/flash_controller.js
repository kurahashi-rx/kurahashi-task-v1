import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // 3秒後にフェードアウトさせてから削除
    setTimeout(() => {
      this.element.style.opacity = '0'
      this.element.style.transition = 'opacity 0.5s ease'
      setTimeout(() => this.element.remove(), 500)
    }, 3000)
  }
}