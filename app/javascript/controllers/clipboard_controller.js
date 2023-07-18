import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["button", "source"];
  static values = {
    successDuration: {
      type: Number,
      default: 2000,
    },
  };

  connect() {
    if (!this.hasButtonTarget) return;

    this.originalContent = this.buttonTarget.innerHTML;
  }

  copy(event) {
    event.preventDefault();

    const text = this.sourceTarget.innerHTML || this.sourceTarget.value;
    const strippedText = text
      .replace(/(<([^>]+)>)/gi, "")
      .replace("コピー", "")
      .replace("\t", "")
      .split("\n")
      .map((line) => {
        return line.trim();
      })
      .join("\n")
      .trim();

    navigator.clipboard.writeText(strippedText).then(() => this.copied());
  }

  copied() {
    if (!this.hasButtonTarget) return;

    if (this.timeout) {
      clearTimeout(this.timeout);
    }

    this.buttonTarget.innerHTML = this.data.get("successContent");

    this.timeout = setTimeout(() => {
      this.buttonTarget.innerHTML = this.originalContent;
    }, this.successDurationValue);
  }
}
