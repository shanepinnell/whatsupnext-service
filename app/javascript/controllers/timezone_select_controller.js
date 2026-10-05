import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select"]

  connect() {
    if (this.selectTarget.value) return

    const detected = Intl.DateTimeFormat().resolvedOptions().timeZone
    const option = Array.from(this.selectTarget.options).find((option) => option.value === detected)
    if (option) this.selectTarget.value = detected
  }
}
