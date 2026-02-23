import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "overlay"]

  open(event) {
    if (event) event.preventDefault()
    this.containerTarget.classList.remove("translate-x-full")
    this.overlayTarget.classList.remove("hidden")
  }

  close(event) {
    if (event) event.preventDefault()
    this.containerTarget.classList.add("translate-x-full")
    this.overlayTarget.classList.add("hidden")
  }
}
