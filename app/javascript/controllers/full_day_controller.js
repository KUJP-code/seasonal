import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["full", "slot", "extension"];

  connect() {
    this.initialized = false;

    if (!this.hasFullTarget) return;

    if (this.slotTargets.length < 2) {
      const row = this.fullTarget.closest(".full-day");
      if (row) row.classList.add("d-none");
      return;
    }

    this.syncFromSlots();
    this.initialized = true;
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
    const wasOn = this.fullTarget.checked;
    this.fullTarget.checked = allOn;

    if (this.initialized && allOn && !wasOn) {
      this.enableExtensions();
    }
  }

  enableExtensions() {
    if (!this.hasExtensionTarget) return;
    this.extensionTargets.forEach((el) => {
      if (!el.checked) el.click();
    });
  }
}
