import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["counter"];

  connect() {
    let timer = null;
    const interval = 1200000;

    function resetTimer(counter, target) {
      clearInterval(timer);
      timer = setInterval(() => {
        counter -= 100;
        if (counter < 0) {
          clearInterval(timer);
          return location.reload();
        }

        const minutes = Math.floor(counter / 60000);
        const seconds = Math.floor((counter % 60000) / 1000)
          .toString()
          .padStart(2, "0");

        target.innerHTML = `${minutes}:${seconds}`;
      }, 100);
    }

    ["click", "mousemove", "scroll", "keydown"].forEach((event) =>
      document.addEventListener(event, () =>
        resetTimer(interval, this.counterTarget)
      )
    );

    resetTimer(interval, this.counterTarget);
  }
}
