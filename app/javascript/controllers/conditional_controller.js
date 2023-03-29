import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["target", "condition"];

  connect() {
    this.toggle;
  }

  toggle() {
    if (this.conditionTarget.checked) {
      const target = this.targetTarget;
      target.removeAttribute("readOnly");
      target.value = "";
    } else {
      const target = this.targetTarget;
      target.value = "なし";
      target.readOnly = true;
    }
  }
}
