import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["toggle"];
  static values = {
    col: String,
  };

  ascending(tableBody, colValue, rows) {
    rows.sort(function (a, b) {
      return a.querySelector(colValue).innerHTML ==
        b.querySelector(colValue).innerHTML
        ? 0
        : a.querySelector(colValue).innerHTML >
          b.querySelector(colValue).innerHTML
        ? 1
        : -1;
    });

    for (let i = 0; i < rows.length; ++i) {
      tableBody.appendChild(rows[i]);
    }
  }

  descending(tableBody, colValue, rows) {
    rows.sort(function (a, b) {
      return a.querySelector(colValue).innerHTML ==
        b.querySelector(colValue).innerHTML
        ? 0
        : a.querySelector(colValue).innerHTML >
          b.querySelector(colValue).innerHTML
        ? -1
        : 1;
    });

    for (let i = 0; i < rows.length; ++i) {
      tableBody.appendChild(rows[i]);
    }
  }

  sort() {
    const tableBody = document.getElementById("condensed_stats");
    const colValue = this.colValue;

    let rows = [...tableBody.children];

    if (this.toggleTarget.classList.contains("ascending")) {
      this.toggleTarget.classList.add("descending");
      this.toggleTarget.classList.remove("ascending");
      this.descending(tableBody, colValue, rows);
    } else {
      this.toggleTarget.classList.add("ascending");
      this.toggleTarget.classList.remove("descending");
      this.ascending(tableBody, colValue, rows);
    }
  }
}
