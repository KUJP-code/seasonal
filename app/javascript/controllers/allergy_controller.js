import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	static targets = ["allergyInput"];

	connect() {
		this.allergyInputTarget.parentNode.before(this.allergySelect());
		this.allergyInputTarget.readOnly = true;
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
				break;
			case "有":
				this.allergyInputTarget.readOnly = false;
				this.allergyInputTarget.value = "";
				break;
			default:
				this.allergyInputTarget.readOnly = true;
				this.allergyInputTarget.value = "";
				break;
		}
	}
}
