import { Controller } from "@hotwired/stimulus";

// Toggles registration buttons from registered to unregistered when clicked
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
    default: Boolean,
    siblingWarning: Boolean,
    siblingWarningMessage: String,
  };
  // Automatically tick photo service on for parties
  connect() {
    console.log("connected", {
      defaultValue: this.defaultValue,
      button: this.buttonTarget,
    });

    // added incase dom wasnt ready
    setTimeout(() => {
      if (this.defaultValue) {
        this.buttonTarget.checked = true;
        this.buttonTarget.classList.add("registered");
        this.dispatch("toggle", {
          detail: {
            child: this.childValue,
            checked: true,
            cost: this.costValue,
            id: this.idValue,
            modifier: this.modifierValue,
            name: this.nameValue,
            siblings: getSiblings(this.element),
            snack: this.snackValue,
            type: this.typeValue,
          },
        });
      }
    }, 0); // short delay for DOM readiness
  }

  toggle(e) {
    e.preventDefault();

    const child = this.childValue;
    const checked = this.buttonTarget.checked;
    const wasRegistered = this.buttonTarget.classList.contains("registered");
    const cost = this.costValue;
    const id = this.idValue;
    const modifier = this.modifierValue;
    const name = this.nameValue;
    const siblings = getSiblings(this.element);
    const snack = this.snackValue;
    const type = this.typeValue;

    if (this.siblingWarningValue && checked !== wasRegistered) {
      const warningMessage =
        this.siblingWarningMessageValue ||
        "兄弟姉妹のお申込内容にもフォトサービスが反映されます。続行しますか？";

      if (!window.confirm(warningMessage)) {
        this.buttonTarget.checked = wasRegistered;
        return;
      }
    }

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
