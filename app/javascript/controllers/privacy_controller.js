import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	static targets = ["checkbox", "submit"];

	connect() {
		this.submitTarget.disabled = true;
	}

	allowSubmit() {
		if (this.checkboxTarget.checked) {
			this.submitTarget.disabled = false;
		} else {
			this.submitTarget.disabled = true;
		}
	}
}
