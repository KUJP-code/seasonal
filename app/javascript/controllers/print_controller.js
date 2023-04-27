import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["print"];

  print() {
    const divs = document.querySelectorAll(".slot_attendance");
    // Hide all other attendance tables
    for (let div of divs) {
      div.classList.add("d-none");
    }
    // Hide navbar
    const navbar = document.querySelector(".navbar");
    navbar.classList.add("d-none");

    // Reveal target table and heading, then print
    this.printTarget.classList.remove("d-none");
    window.print();

    // Make all attendance tables visible
    for (let div of divs) {
      div.classList.remove("d-none");
    }
  }
}
