import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="dialog"
export default class extends Controller {
	static values = { dialog: String, frame: String, src: String };

	connect() {
		this.dialog = document.getElementById(this.dialogValue);
		this.frame = document.getElementById(this.frameValue);
	}

	open(e) {
		this.frame.src = this.srcValue;
		this.dialog.showModal();
		e.stopPropagation();
		document.addEventListener("click", (e) => this.close(e));
	}

	close(e) {
		// hilariously enough, clicking 'outside' the dialog registers
		// as clicking the dialog becuase of the ::backdrop element
		if (e.target === this.dialog) {
			this.frame.innerHTML = "";
			this.dialog.close();
		}
	}
}
