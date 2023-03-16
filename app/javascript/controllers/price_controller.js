import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "child",
    "slotRegs",
    "optRegs",
    "optCost",
    "adjChange",
    "finalCost",
  ];

  static values = {
    memberPrice: Object,
    nonMemberPrice: Object,
  };

  // Base function called when fields added to form
  calculate() {
    const courseCost = this.isMember(this.childTarget)
      ? this.calcCourseCost(true)
      : this.calcCourseCost(false);

    const optionCost = this.optCostTargets
      .filter((cost) => cost.classList.contains("registered"))
      .reduce((sum, option) => sum + parseInt(option.innerHTML), 0);

    const adjustmentChange = this.calcAdjustments();

    const finalCost = optionCost + courseCost + adjustmentChange;
    this.finalCostTarget.innerHTML = `Total Cost: ${finalCost}円`;
  }

  // Finds the cheapest price for the given number of regs
  bestCourses(numRegs, courses) {
    if (numRegs >= 35) {
      return courses[30] + this.bestCourses(numRegs - 30, courses);
    }

    if (numRegs >= 5) {
      const bestCourse = this.nearestFive(numRegs);
      const cost = courses[bestCourse];
      return cost + this.bestCourses(numRegs - bestCourse, courses);
    }

    return this.spotUse(numRegs, courses);
  }

  // Get the course objects on connect so you don't have to parse before each calculation
  connect() {
    this.memberPrice = this.memberPriceValue;
    this.nonMemberPrice = this.nonMemberPriceValue;
  }

  // Calculates total change due to adjustments
  calcAdjustments() {
    return this.hasAdjChangeTarget
      ? this.adjChangeTargets.reduce(
          (sum, change) => sum + parseInt(change.innerHTML),
          0
        )
      : 0;
  }

  calcConnectCost(numRegs) {
    return Math.ceil(numRegs / 2) * 184;
  }

  // Calculates course costs if kids are both members/not
  calcCourseCost(member) {
    const courses = member ? this.memberPrice : this.nonMemberPrice;
    const id = parseInt(this.childTarget.children[0].innerHTML);
    const level = this.childTarget.querySelector(".level").innerHTML;

    const cost = this.slotRegsTargets.reduce((sum, target) => {
      const numRegs = target.querySelectorAll(`.child${id}`).length;
      const courseCost = this.bestCourses(numRegs, courses);
      // If child is Kindy and has less than 5 registrations, apply the 184 yen
      // increase to half of them so price will only decrease when finalised
      const connectCost =
        member && numRegs < 5 && level === "Kindy"
          ? this.calcConnectCost(numRegs)
          : 0;

      return sum + courseCost + connectCost;
    }, 0);

    return cost;
  }

  // Calculates cost from spot use when less than 5 courses
  spotUse(numRegs, courses) {
    return courses[1] * numRegs;
  }

  // True if child is a member
  isMember(child) {
    const membership = child.querySelector(".membership").innerHTML;

    if (membership === "Member") {
      return true;
    } else {
      return false;
    }
  }

  // Find the largest course that fits the number of registrations
  nearestFive(num) {
    return Math.floor(num / 5) * 5;
  }
}
