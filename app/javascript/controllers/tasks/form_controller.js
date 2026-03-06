import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // ターゲットの定義：HTML側の data-tasks--form-target と紐付きます
  static targets = ["status", "completedOn"]

  connect() {
    console.log("Tasks Form Controller connected!")
  }

  // ステータス変更時に実行されるメソッド
  updateCompletedDate() {
    const status = this.statusTarget.value
    const dateField = this.completedOnTarget

    // 完了(done)が選択された場合
    if (status === "done") {
      // 既に日付が入っている場合は上書きしない（親切設計）
      if (!dateField.value) {
        const today = new Date().toISOString().split('T')[0]
        dateField.value = today
      }
    } else {
      // 完了以外（backlog, ready, sprint）に戻された時に日付を消す
      dateField.value = ""
    }
  }
}