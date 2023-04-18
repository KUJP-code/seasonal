import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["table", "heading"];

  print() {
    const tables = document.getElementsByTagName("table");
    const headings = document.getElementsByTagName("h1");
    // Hide all tables and headings
    for (let table of tables) {
      table.classList.add("d-none");
    }
    for (let heading of headings) {
      heading.classList.add("d-none");
    }
    // Reveal target table and heading
    this.tableTarget.classList.remove("d-none");
    this.headingTarget.classList.remove("d-none");
    // Print target table
    window.print();
    // Return all tables and headings to visible
    for (let table of tables) {
      table.classList.remove("d-none");
    }
    for (let heading of headings) {
      heading.classList.remove("d-none");
    }
  }
}
