import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="document-uploads"
export default class extends Controller {
	static targets = ["otherDescription"];

	connect() {
		this.hideOtherDescription();
	}

	toggleOtherDescription(e) {
		if (e.target.value !== "other") {
			this.hideOtherDescription();
		} else {
			this.showOtherDescription();
		}
	}

	hideOtherDescription() {
		this.otherDescriptionTarget.disabled = true;
		this.otherDescriptionTarget.required = false;
		this.otherDescriptionTarget.parentNode.classList.add("d-none");
	}

	showOtherDescription() {
		this.otherDescriptionTarget.disabled = false;
		this.otherDescriptionTarget.required = true;
		this.otherDescriptionTarget.parentNode.classList.remove("d-none");
	}
}
