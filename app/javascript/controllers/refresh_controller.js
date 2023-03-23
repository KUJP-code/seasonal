import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["counter"];

  connect() {
    this.resetTimer();
  }

  startTimer(timer) {
    setInterval(() => {
      timer -= 100;
      if (timer < 0) {
        return;
      }
      const minutes = Math.floor(timer / 60000);
      const seconds = Math.floor((timer % 60000) / 1000)
        .toString()
        .padStart(2, "0");

      this.counterTarget.innerHTML = `${minutes}:${seconds}`;
    }, 100);
  }

  refresh() {
    location.reload();
  }

  resetTimer() {
    this.startTimer(1200000);
    setTimeout(() => {
      this.refresh();
    }, 1200000);
  }
}
