import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    'popup'
  ]

  toggle() {
    this.popupTarget.classList.toggle('hidden');
  }
}