import { Controller } from "@hotwired/stimulus";
// This controller can be removed after halloween 2025, or left for legacy reference in case we do it again.
export default class extends Controller {
  static values = { slotIds: Array }
  static targets = ["switch"]

  get writeScopeEl() {
    return this.element.closest("details") || document;
  }

  statusFor(id) {
    const input = document.querySelector(`#m_slot${id}`);
    return input ? !!input.checked : false;
  }

  connect() {
    this.sync();

    this._onChange = (e) => {
      if (!(e.target instanceof HTMLInputElement)) return;
      const isMember = this.slotIdsValue.some((id) => e.target.id === `m_slot${id}`);
      if (isMember) this.sync();
    };
    document.addEventListener("change", this._onChange);
  }

  disconnect() {
    if (this._onChange) document.removeEventListener("change", this._onChange);
  }

  toggle() {
    const checked = this.switchTarget.checked;

    this.slotIdsValue.forEach((id) => {
      const input = this.writeScopeEl.querySelector(`#m_slot${id}`);
      if (input && input.checked !== checked) input.click();
    });

    this.sync();
  }

  sync() {
    const allChecked = this.slotIdsValue.every((id) => this.statusFor(id));
    if (this.hasSwitchTarget) {
      this.switchTarget.checked = allChecked;
      this.switchTarget.indeterminate = false;
  }
}}
