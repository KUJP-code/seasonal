import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { slotIds: Array }
  static targets = ["switch"]

  // scope to closest details
  get scopeEl() {
    return this.element.closest("details") || document;
  }

  toggle() {
    const checked = this.switchTarget.checked;

    this.slotIdsValue.forEach((id) => {
      const input = this.scopeEl.querySelector(`#m_slot${id}`);
      if (input && input.checked !== checked) {
        input.click();
      }
    });
  }

  sync() {
    const allChecked = this.slotIdsValue.every((id) => {
      const input = this.scopeEl.querySelector(`#m_slot${id}`);
      return input && input.checked;
    });
    if (this.hasSwitchTarget) this.switchTarget.checked = allChecked;
  }
}
