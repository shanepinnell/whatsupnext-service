import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { autoDismiss: Boolean, delay: { type: Number, default: 5000 } }

  connect() {
    if (this.autoDismissValue) {
      this.timeout = setTimeout(() => this.dismiss(), this.delayValue)
    }
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.classList.add("transition-opacity", "duration-500", "opacity-0")
    this.element.addEventListener("transitionend", () => this.element.remove(), { once: true })
  }
}
