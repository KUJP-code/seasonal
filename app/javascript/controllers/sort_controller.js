import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["toggle"];
  static values = { col: String, event: String, type: String };

  cellValue(row, colValue) {
    const cell = row.querySelector(colValue);
    if (!cell) return "";

    return (cell.dataset.sortValue || cell.textContent || "").trim();
  }

  textValue(row, colValue) {
    return this.cellValue(row, colValue);
  }

  numberValue(row, colValue) {
    const rawValue = this.cellValue(row, colValue);
    const normalized = rawValue.replace(/[^\d.-]/g, "");
    const parsed = parseFloat(normalized);

    return Number.isNaN(parsed) ? 0 : parsed;
  }

  dateValue(row, colValue) {
    const rawValue = this.cellValue(row, colValue);
    if (!rawValue) return 0;

    const numeric = Number(rawValue);
    if (!Number.isNaN(numeric)) return numeric;

    const parsed = Date.parse(rawValue);
    return Number.isNaN(parsed) ? 0 : parsed;
  }

  inferType(colValue) {
    const textCols = [".school", ".name", ".en-name", ".ssid"];
    return textCols.includes(colValue) ? "text" : "number";
  }

  ascending(tableBody, colValue, rows) {
    const sortType = this.typeValue || this.inferType(colValue);

    if (sortType === "text") {
      rows.sort((a, b) => {
        const A = this.textValue(a, colValue);
        const B = this.textValue(b, colValue);
        return A.localeCompare(B);
      });
    } else if (sortType === "date") {
      rows.sort((a, b) => this.dateValue(a, colValue) - this.dateValue(b, colValue));
    } else {
      rows.sort((a, b) => this.numberValue(a, colValue) - this.numberValue(b, colValue));
    }

    for (let i = 0; i < rows.length; ++i) tableBody.appendChild(rows[i]);
  }

  descending(tableBody, colValue, rows) {
    const sortType = this.typeValue || this.inferType(colValue);

    if (sortType === "text") {
      rows.sort((a, b) => {
        const A = this.textValue(a, colValue);
        const B = this.textValue(b, colValue);
        return B.localeCompare(A);
      });
    } else if (sortType === "date") {
      rows.sort((a, b) => this.dateValue(b, colValue) - this.dateValue(a, colValue));
    } else {
      rows.sort((a, b) => this.numberValue(b, colValue) - this.numberValue(a, colValue));
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
