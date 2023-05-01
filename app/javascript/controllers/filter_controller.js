import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input"];
  static values = {
    col: String,
  };

  change() {
    const filter = this.inputTarget.value;
    const cells = document.querySelectorAll(this.colValue);

    // If filter doesn't match cell value, hide parent row
    for (let i = cells.length; i--; ) {
      if (
        cells[i].innerText.toLowerCase().indexOf(filter.toLowerCase()) === -1
      ) {
        cells[i].parentNode.style.display = "none";
      } else {
        cells[i].parentNode.style.display = "";
      }
    }
  }
}
