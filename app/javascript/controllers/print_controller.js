import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["print"];

  print() {
    // List all other attendance tables
    const sheets = document.querySelectorAll(".slot_attendance");

    // Hide all other attendance tables
    for (let sheet of sheets) {
      sheet.classList.add("d-none");
    }
    // List all other cards (for User#profile)
    const cards = document.querySelectorAll(".card");
    // Hide all other cards (for User#profile)
    for (let card of cards) {
      card.classList.add("d-none");
    }
    // Hide navbar
    const navbar = document.querySelector(".navbar");
    navbar.classList.add("d-none");
    // Hide print button
    const printButton = document.querySelector(".print");
    printButton.classList.add("d-none");
    // Hide search bar
    const search = document.querySelectorAll(".search");
    if (search) {
      search.forEach((row) => {
        row.classList.add("d-none");
      });
    }

    // Reveal target table and heading, then print
    this.printTarget.classList.remove("d-none");
    // Reveal cards inside the print target (for User#profile)
    const cardsInside = this.printTarget.querySelectorAll(".card");
    for (let card of cardsInside) {
      card.classList.remove("d-none");
    }
    window.print();

    // Reveal all attendance tables
    for (let sheet of sheets) {
      sheet.classList.remove("d-none");
    }
    // Reveal all cards (for User#profile)
    for (let card of cards) {
      card.classList.remove("d-none");
    }

    // Reveal navbar
    navbar.classList.remove("d-none");
    // Reveal print button
    printButton.classList.remove("d-none");
    // Reveal search bar
    if (search) {
      search.forEach((row) => {
        row.classList.remove("d-none");
      });
    }
  }
}
