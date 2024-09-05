import { Controller } from "@hotwired/stimulus";

// Toggles registration buttons from registered to unregistered when clicked
// Connects to data-controller="new-register"
export default class extends Controller {
	static targets = ["button", "name"];
	static values = {
		child: String,
		cost: String,
		id: String,
		modifier: String,
		name: String,
		snack: String,
		type: String,
	};

	toggle(e) {
		e.preventDefault();

		const child = this.childValue;
		const checked = this.buttonTarget.checked;
		const cost = this.costValue;
		const id = this.idValue;
		const modifier = this.modifierValue;
		const name = this.nameValue;
		const siblings = getSiblings(this.element);
		const snack = this.snackValue;
		const type = this.typeValue;

		if (checked) {
			this.buttonTarget.classList.add("registered");
		} else {
			this.buttonTarget.classList.remove("registered");
		}

		this.dispatch("toggle", {
			detail: {
				child: child,
				checked: checked,
				cost: cost,
				id: id,
				modifier: modifier,
				name: name,
				siblings: siblings,
				snack: snack,
				type: type,
			},
		});
	}
}

// Gets me the other options when a radio button is checked
var getSiblings = function (elem) {
	// Setup siblings array and get the first sibling
	var siblings = [];
	var sibling = elem.parentNode.firstChild;

	// Loop through each sibling and push to the array
	while (sibling) {
		if (sibling.tagName === "DIV" && sibling !== elem) {
			siblings.push(sibling);
		}
		sibling = sibling.nextSibling;
	}

	return siblings;
};
