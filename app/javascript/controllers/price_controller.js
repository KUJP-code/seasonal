import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "adjChange",
    "child",
    "eventCost",
    "finalCost",
    "optRegs",
    "optCost",
    "optCount",
    "slotRegs",
    "snackCount",
  ];

  static values = {
    memberPrice: Object,
    nonMemberPrice: Object,
    otherCost: Number,
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

    // Count the number of options registered for
    const optCount = this.optRegsTargets.reduce(
      (sum, target) => sum + target.querySelectorAll(".registered").length,
      0
    );
    this.optCountTarget.innerHTML = `オプション：${optCount.toString()}つ`;

    // Get a list of all registered.slots
    const regList = [...document.getElementById("reg_slots").children].reduce(
      (list, child) => {
        return list.concat(child.innerHTML);
      },
      []
    );
    // Count the 午後 ones, as these must be charged for a snack
    const snackCount = regList.filter((slot) => slot.includes("午後")).length;
    this.snackCountTarget.innerHTML = `午後コースおやつ代：${snackCount.toString()}つ`;
    // Get the cost of all those snacks to add to the final price
    const snackCost = snackCount * 165;
    // Count the days in the list of special days
    const specialCount = regList.filter(
      (slot) =>
        slot.includes("Banana Party") ||
        slot.includes("Design a Kite") ||
        slot.includes("水鉄砲合") ||
        slot.includes("巨大なお城のクラフト")
    ).length;
    const specialCost = specialCount * 1500;

    const finalCost =
      optionCost + courseCost + adjustmentChange + snackCost + specialCost;
    this.finalCostTarget.innerHTML = `合計（税込）: ${finalCost}円`;
    this.eventCostTarget.innerHTML = `サマースクール 2023の合計: ${(
      this.otherCostValue + finalCost
    )
      .toString()
      .replace(/\B(?=(\d{3})+(?!\d))/g, ",")}円`;
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
    return Math.ceil(numRegs / 2) * 200;
  }

  // Calculates course costs if kids are both members/not
  calcCourseCost(member) {
    const courses = member ? this.memberPrice : this.nonMemberPrice;
    const id = parseInt(this.childTarget.children[0].innerHTML);
    const level = this.childTarget.querySelector(".level").innerHTML;

    const cost = this.slotRegsTargets.reduce((sum, target) => {
      const numRegs = target.querySelectorAll(`.child${id}`).length;
      const courseCost = this.bestCourses(numRegs, courses);
      // If child is Kindy and has less than 5 registrations, apply the 200 yen
      // increase to half of them so price will only decrease when finalised
      const connectCost =
        member && numRegs < 5 && numRegs > 1 && level === "Kindy"
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

    return membership === "Yes" ? true : false;
  }

  // Find the largest course that fits the number of registrations
  nearestFive(num) {
    return Math.floor(num / 5) * 5;
  }
}
