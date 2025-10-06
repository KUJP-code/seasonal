import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["toggle"];
  static values = { col: String, event: String };

  ascending(tableBody, colValue, rows) {
    const isTextCol =
      colValue === ".school" ||
      colValue === ".name" ||
      colValue === ".en-name" ||
      colValue === ".ssid";

    if (isTextCol) {
      rows.sort(function (a, b) {
        const A = a.querySelector(colValue).textContent.trim();
        const B = b.querySelector(colValue).textContent.trim();
        return A === B ? 0 : A > B ? 1 : -1;
      });
    } else {
      rows.sort(function (a, b) {
        let numA = parseInt(
          a.querySelector(colValue).textContent.replace(/[円,%]/g, ""),
        );
        let numB = parseInt(
          b.querySelector(colValue).textContent.replace(/[円,%]/g, ""),
        );
        return numA == numB ? 0 : numA > numB ? 1 : -1;
      });
    }

    for (let i = 0; i < rows.length; ++i) tableBody.appendChild(rows[i]);
  }

  descending(tableBody, colValue, rows) {
    const isTextCol =
      colValue === ".school" ||
      colValue === ".name" ||
      colValue === ".en-name" ||
      colValue === ".ssid";

    if (isTextCol) {
      rows.sort(function (a, b) {
        const A = a.querySelector(colValue).textContent.trim();
        const B = b.querySelector(colValue).textContent.trim();
        return A === B ? 0 : A > B ? -1 : 1;
      });
    } else {
      rows.sort(function (a, b) {
        let numA = parseInt(
          a.querySelector(colValue).textContent.replace(/[円,%]/g, ""),
        );
        let numB = parseInt(
          b.querySelector(colValue).textContent.replace(/[円,%]/g, ""),
        );
        return numA == numB ? 0 : numA > numB ? -1 : 1;
      });
    }

    for (let i = 0; i < rows.length; ++i) tableBody.appendChild(rows[i]);
  }

  sort() {
    const tableBody = document.getElementById(this.eventValue);
    const colValue = this.colValue;

    let rows = Array.from(tableBody.children).filter((row) =>
      row.querySelector(colValue),
    );

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
