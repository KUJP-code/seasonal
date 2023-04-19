import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["target", "condition"];
  static values = {
    pin: String,
  };

  connect() {
    this.toggle;
  }

  allergy() {
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

  pin() {
    const pin = this.conditionTarget.value;

    console.log(this.pinValue);

    if (pin !== this.pinValue) {
      return;
    }

    this.targetTargets.forEach((target) => {
      target.classList.toggle("d-none");
    });
  }
}
