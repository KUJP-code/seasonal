import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	static targets = ["target", "condition"];
	static values = {
		pin: String,
	};

	connect() {
		this.toggle;
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
