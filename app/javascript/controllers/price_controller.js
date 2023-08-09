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
    "specialCount",
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
    let snackCount = regList.filter((slot) => slot.includes("午後")).length;
    // Count the days in the list of special days
    const specialCount = regList.filter(
      (slot) =>
        slot.includes("水鉄砲合＆スイカ割り") ||
        slot.includes("巨大なお城のクラフト") ||
        slot.includes("フルーツサンド作り") ||
        slot.includes("BBQ風やきそば/コーラの噴射実験") ||
        slot.includes("暗闇で光るスライム/フルーツスムージー")
    ).length;
    this.specialCountTarget.innerHTML = `スペシャルデー: ${specialCount.toString()}つ`;
    // Get cost of all of them to add to the final price
    let specialCost = specialCount * 1500;
    // Add Minami Machida/Futa's dumb special price if it exists
    if (
      regList.includes("夏祭り@南町田グランベリーパーク (午後)") ||
      regList.includes("夏祭り@二俣川 (午前)")
    ) {
      specialCost += 1100;
      this.specialCountTarget.appendChild(document.createElement("br"));
      this.specialCountTarget.innerHTML += "夏祭りスペシャルデー：1つ";
    }
    // Handle Ojima aquarium trip
    if (regList.includes("スペシャル遠足@品川アクアパーク (午後)")) {
      specialCost += 3000;
      this.specialCountTarget.appendChild(document.createElement("br"));
      this.specialCountTarget.innerHTML +=
        "スペシャル遠足@品川アクアパーク：1つ";
      snackCount--;
    }
    // Handle the two shit events (and rinkai morning)
    if (
      regList.includes("遠足＠うんこミュージアム (午前)") ||
      regList.includes("キッズアップハンター (午前)")
    ) {
      // The cost needs to be 6 000 no matter what, so adjust for int/ext
      if (this.isMember(this.childTarget)) {
        specialCost += 1580;
      } else {
        specialCost -= 930;
      }
      this.specialCountTarget.appendChild(document.createElement("br"));
      this.specialCountTarget.innerHTML += "遠足＠うんこミュージアム：1つ";
    }
    // Handle the Kitashinagawa/Oi aquarium trip (and rinkai afternoon)
    if (
      regList.includes("遠足＠アクアパーク品川 (午後)") ||
      regList.includes("サマーモンスター (午後)")
    ) {
      // The cost needs to be 7 000 no matter what, so adjust for int/ext
      specialCost += this.isMember(this.childTarget) ? 2580 : 70;
      this.specialCountTarget.appendChild(document.createElement("br"));
      this.specialCountTarget.innerHTML += "遠足＠アクアパーク品川：1つ";
      snackCount--;
    }
    // Get the cost of all those snacks to add to the final price
    const snackCost = snackCount * 165;
    this.snackCountTarget.innerHTML = `午後コースおやつ代：${snackCount.toString()}つ`;
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
