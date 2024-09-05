import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="expand"
export default class extends Controller {
	static targets = ["expandedElement"];

	listen(e) {
		if (
			e.detail.id ===
			this.element.querySelector(".add_reg").dataset.newRegisterIdValue
		) {
			this.toggle();
		}
	}

	toggle() {
		this.expandedElementTarget.classList.toggle("hidden");
	}
}
