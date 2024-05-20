import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	static targets = ["target", "condition"];
	static values = {
		pin: String,
	};

	connect() {
		this.toggle;
	}

	allergy() {
		const allergy = this.conditionTarget.value;
		const target = this.targetTarget;

		switch (allergy) {
			case "なし":
				target.value = "なし";
				target.readOnly = true;
				break;
			case "有":
				target.removeAttribute("readOnly");
				target.value = "";
				break;
			default:
				target.value = null;
				target.readOnly = true;
				break;
		}
	}

	allowSubmit() {
		const condition = this.conditionTarget.checked;
		const target = this.targetTarget;

		if (condition) {
			target.removeAttribute("disabled");
		} else {
			target.setAttribute("disabled", true);
		}
	}

	pin() {
		const pin = this.conditionTarget.value;
		if (pin !== this.pinValue) {
			return;
		}

		for (const target of this.targetTargets) {
			target.classList.toggle("d-none");

			// Auto-hide after 10min
			setTimeout(() => {
				target.classList.toggle("d-none");
			}, 600000);
		}
	}
}
