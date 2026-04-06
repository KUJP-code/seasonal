import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	static targets = ["button", "panel"];

	connect() {
		this.show({ params: { panel: this.defaultPanel() } });
	}

	show({ params }) {
		const selectedPanel = params.panel;

		this.buttonTargets.forEach((button) => {
			const isActive = button.dataset.panelSelectorPanelParam === selectedPanel;
			button.classList.toggle("active", isActive);
			button.setAttribute("aria-pressed", isActive);
		});

		this.panelTargets.forEach((panel) => {
			panel.classList.toggle("d-none", panel.dataset.panel !== selectedPanel);
		});
	}

	defaultPanel() {
		return this.buttonTargets[0]?.dataset.panelSelectorPanelParam;
	}
}
