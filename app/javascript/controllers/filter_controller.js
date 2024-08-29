import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	static targets = ["input"];
	static values = {
		col: String,
		siblings: Boolean,
	};

	change() {
		const filter = this.inputTarget.value;
		const cells = document.querySelectorAll(this.colValue);

		// If filter doesn't match cell value, hide parent row
		for (let i = cells.length; i--;) {
			if (
				cells[i].innerText.toLowerCase().indexOf(filter.toLowerCase()) === -1
			) {
				cells[i].parentNode.classList.add("d-none");
				if (this.siblingsValue) {
					const parentId = cells[i].parentNode.classList[0];
					this.hideSiblings(parentId);
				}
			} else {
				cells[i].parentNode.classList.remove("d-none");
				if (this.siblingsValue) {
					const parentId = cells[i].parentNode.classList[0];
					this.showSiblings(parentId);
				}
			}
		}
	}

	hideSiblings(parentId) {
		// Get siblings by finding elements with parentId in classList
		const siblings = document.querySelectorAll(`.${parentId}`);

		// Hide siblings
		for (let i = siblings.length; i--;) {
			siblings[i].classList.add("d-none");
		}
	}

	showSiblings(parentId) {
		// Get siblings by finding elements with parentId in classList
		const siblings = document.querySelectorAll(`.${parentId}`);

		// Show siblings
		for (let i = siblings.length; i--;) {
			siblings[i].classList.remove("d-none");
		}
	}
}
