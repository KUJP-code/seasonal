import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["target", "condition"];

  connect() {
    this.toggle;
  }

  toggle() {
    const allergy = this.conditionTarget.value;
    const target = this.targetTarget;

    switch (allergy) {
      case "なし":
        target.value = "なし";
        target.readOnly = true;
        break;
      case "はい":
        target.removeAttribute("readOnly");
        target.value = "";
        break;
      default:
        target.value = null;
        target.readOnly = true;
        break;
    }
  }
}
