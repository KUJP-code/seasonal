import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["full", "slot"];

  connect() {
    if (!this.hasFullTarget) return;

    if (this.slotTargets.length < 2) {
      const row = this.fullTarget.closest(".full-day");
      if (row) row.classList.add("d-none");
      return;
    }

    this.syncFromSlots();
  }

  toggleFromFull(event) {
    const checked = this.fullTarget.checked;

    this.slotTargets.forEach((el) => {
      if (el.checked !== checked) el.click();
    });
  }

  syncFromSlots() {
    if (!this.hasFullTarget || !this.slotTargets.length) return;
    const allOn = this.slotTargets.every((el) => el.checked);
    this.fullTarget.checked = allOn;
  }
}
