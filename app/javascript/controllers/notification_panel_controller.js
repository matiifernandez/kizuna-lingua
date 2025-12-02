import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="notification-panel"
export default class extends Controller {
  static targets = ["panel", "overlay", "count", "notifications"]

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    this.panelTarget.classList.toggle('active')
    this.overlayTarget.classList.toggle('active')
    document.body.classList.toggle('no-scroll')
  }
}
