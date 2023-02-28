import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    'popup'
  ]

  listen(e) {
    if (e.detail.id === this.element.querySelector('.add_reg').dataset.registerIdValue) {
      this.toggle()
    }
  }

  toggle() {
    this.popupTarget.classList.toggle('hidden');
  }
}