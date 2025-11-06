import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["allergyInput", "ownSnackField"];

  connect() {
    this.allergyInputTarget.parentNode.before(this.allergySelect());
    this.allergyInputTarget.readOnly = true;

    // Attach a submit event listener to the parent form
    const form = this.allergyInputTarget.closest("form");
    if (form) {
      form.addEventListener("submit", this.handleSubmit.bind(this));
    }

    if (this.ownSnackFieldTarget && this.ownSnackFieldTarget.value === "") {
      this.ownSnackFieldTarget.value = "0";
    }

    const preset = (this.allergyInputTarget.value || "").trim();
    if (preset && preset !== "なし") {
      this.insertFoodContainer();
      this.insertEpipenContainer();
    }
  }

  handleSubmit(event) {
    if (this.epipenSelect && this.epipenSelect.value === "はい") {
      event.preventDefault();
      this.epipenSelect.setCustomValidity(
        "エピペンをお持ちの場合、登録は行えません。",
      );
      this.epipenSelect.reportValidity();
      return;
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
        this.allergyInputTarget.readOnly = true;
        this.allergyInputTarget.value = "なし";
        this.removeFoodContainer();
        this.removeEpipenContainer();
        this.setOwnSnack(false); // NEW: force false
        break;

      case "有":
        this.allergyInputTarget.readOnly = false;
        if (this.allergyInputTarget.value === "なし") {
          this.allergyInputTarget.value = "";
        }
        this.insertFoodContainer();
        this.insertEpipenContainer();
        break;

      default:
        this.allergyInputTarget.readOnly = true;
        this.allergyInputTarget.value = "";
        this.removeFoodContainer();
        this.removeEpipenContainer();
        this.setOwnSnack(false);
        break;
    }
  }

  insertFoodContainer() {
    if (this.foodContainer) return;

    const container = document.createElement("div");
    container.classList.add("food-allergy-container");
    container.style.marginTop = "0.5rem";

    const label = document.createElement("p");
    label.textContent = "そのアレルギーは食べ物ですか？";
    label.style.marginBottom = "0.5rem";
    container.appendChild(label);

    const select = document.createElement("select");
    select.classList.add("form-select");
    const options = [
      { v: "", t: "" },
      { v: "no", t: "いいえ" },
      {
        v: "yes",
        t: "はい（午後のコースにご参加される場合は、おやつをご持参ください）",
      },
    ];
    options.forEach(({ v, t }) => {
      const opt = document.createElement("option");
      opt.value = v;
      opt.textContent = t;
      select.appendChild(opt);
    });

    select.addEventListener("change", (e) => {
      this.foodSelectionChanged(e.target.value);
    });

    container.appendChild(select);
    this.foodSelect = select;

    const formFloating = this.allergyInputTarget.closest(".form-floating");
    formFloating.insertAdjacentElement("beforebegin", container);

    this.foodContainer = container;

    this.setOwnSnack(false);
  }

  removeFoodContainer() {
    if (this.foodContainer) {
      this.foodContainer.remove();
      this.foodContainer = null;
      this.foodSelect = null;
    }
  }

  foodSelectionChanged(value) {
    this.setOwnSnack(value === "yes");
  }

  setOwnSnack(val) {
    if (this.ownSnackFieldTarget) {
      this.ownSnackFieldTarget.value = val ? "1" : "0";
    }
  }

  insertEpipenContainer() {
    if (!this.epipenContainer) {
      this.epipenContainer = this.createEpipenContainer();
      const formFloating = this.allergyInputTarget.closest(".form-floating");
      formFloating.insertAdjacentElement("beforebegin", this.epipenContainer);
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
    warning.style.overflowWrap = "break-word";
    warning.style.width = "100%";
    if (window.innerWidth > 768) {
      warning.style.whiteSpace = "pre-wrap";
    } else {
      warning.style.whiteSpace = "normal";
    }
    warning.textContent =
      "誠に申し訳ございませんが、キッズアップではお子様の安全を最優先に考えておりますため、\nエピペンをお持ちのお子様のお預かりは致しかねます。\n何卒ご理解いただけますようお願い申し上げます。";
    container.appendChild(warning);
    this.epipenWarning = warning;

    return container;
  }

  epipenSelectionChanged(value) {
    if (value === "はい") {
      this.epipenWarning.style.display = "block";
      this.epipenSelect.setCustomValidity(
        "エピペンをお持ちの場合、登録は行えません。",
      );
    } else {
      this.epipenWarning.style.display = "none";
      this.epipenSelect.setCustomValidity("");
    }
  }
}
