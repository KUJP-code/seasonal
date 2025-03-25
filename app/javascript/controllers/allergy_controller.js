import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["allergyInput"];

  connect() {
    this.allergyInputTarget.parentNode.before(this.allergySelect());
    this.allergyInputTarget.readOnly = true;

    // Attach a submit event listener to the parent form
    const form = this.allergyInputTarget.closest("form");
    if (form) {
      form.addEventListener("submit", this.handleSubmit.bind(this));
    }
  }

  handleSubmit(event) {
    if (this.epipenSelect && this.epipenSelect.value === "はい") {
      event.preventDefault();
      // Mark the field as invalid and trigger the browser’s validation UI
      this.epipenSelect.setCustomValidity(
        "エピペンをお持ちの場合、登録は行えません。"
      );
      this.epipenSelect.reportValidity();
      return;
    }
  }

  epipenSelectionChanged(value) {
    if (value === "はい") {
      this.epipenWarning.style.display = "block";
      // Set the field to be invalid
      this.epipenSelect.setCustomValidity(
        "エピペンをお持ちの場合、登録は行えません。"
      );
    } else {
      this.epipenWarning.style.display = "none";
      // Clear any custom validity messages so the field becomes valid
      this.epipenSelect.setCustomValidity("");
    }
  }

  allergySelect() {
    const element = document.createElement("select");
    element.classList.add("form-select");
    const allergyOptions = ["", " なし", "有"];
    element.addEventListener("change", (e) => {
      this.selectionChanged(e.target.value);
    });

    for (const option of allergyOptions) {
      const optionElement = document.createElement("option");
      optionElement.value = option;
      optionElement.textContent = option;
      element.appendChild(optionElement);
    }

    return element;
  }

  selectionChanged(selection) {
    switch (selection) {
      case " なし":
        // No allergy: make the input read-only and remove the epipen section
        this.allergyInputTarget.readOnly = true;
        this.allergyInputTarget.value = "なし";
        this.removeEpipenContainer();
        break;
      case "有":
        // Has allergy: allow editing and show the epipen question
        this.allergyInputTarget.readOnly = false;
        this.allergyInputTarget.value = "";
        if (!this.epipenContainer) {
          this.epipenContainer = this.createEpipenContainer();
          // Insert the epipen container above the closest .form-floating container.
          const formFloating =
            this.allergyInputTarget.closest(".form-floating");
          formFloating.insertAdjacentElement(
            "beforebegin",
            this.epipenContainer
          );
        }
        break;
      default:
        this.allergyInputTarget.readOnly = true;
        this.allergyInputTarget.value = "";
        this.removeEpipenContainer();
        break;
    }
  }

  removeEpipenContainer() {
    if (this.epipenContainer) {
      this.epipenContainer.remove();
      this.epipenContainer = null;
      this.epipenSelect = null;
      this.epipenWarning = null;
    }
  }

  createEpipenContainer() {
    const container = document.createElement("div");
    container.classList.add("epipen-container");

    const label = document.createElement("p");
    label.textContent = "エピペンはお持ちですか？";
    label.style.marginBottom = "0.5rem";
    container.appendChild(label);

    const select = document.createElement("select");
    select.classList.add("form-select");
    select.required = true;
    const epipenOptions = ["", "いいえ", "はい"];
    epipenOptions.forEach((optionText) => {
      const optionElement = document.createElement("option");
      optionElement.value = optionText;
      optionElement.textContent = optionText;
      select.appendChild(optionElement);
    });
    select.addEventListener("change", (e) => {
      this.epipenSelectionChanged(e.target.value);
    });
    container.appendChild(select);
    this.epipenSelect = select;

    const warning = document.createElement("div");
    warning.classList.add("epipen-warning");
    warning.style.display = "none";
    warning.style.color = "red";
    warning.style.whiteSpace = "normal";
    warning.style.overflowWrap = "break-word";
    warning.style.width = "100%";
    warning.textContent =
      "誠に申し訳ございませんが、キッズアップではお子様の安全を最優先に考えておりますため、エピペンをお持ちのお子様のお預かりは致しかねます。何卒ご理解いただけますようお願い申し上げます。";
    container.appendChild(warning);
    this.epipenWarning = warning;

    return container;
  }

  epipenSelectionChanged(value) {
    if (value === "はい") {
      this.epipenWarning.style.display = "block";
    } else {
      this.epipenWarning.style.display = "none";
    }
  }
}
