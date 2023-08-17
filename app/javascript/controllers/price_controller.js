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
        slot.includes("暗闇で光るスライム/フルーツスムージー") ||
        slot.includes("イングリッシュスポーツイベント") ||
        slot.includes("スペシャルクッキングイベント") ||
        slot.includes("3校対決！Englishスポーツ大会") ||
        slot.includes("スクール対抗スポーツ大会") ||
        slot.includes("遠足＠しながわ水族館") ||
        slot.includes("具だくさんスライム＆光るタピオカパーティー☆彡") ||
        slot.includes("親子で参加可能♪浴衣OK♡うちわ作り体験＆KidsUP夏祭り") ||
        slot.includes("宝探し&amp;夏祭り") ||
        slot.includes("KidsUP大夏祭り/時計作り") ||
        slot.includes("夏祭り@蒲田")
    ).length;
    this.specialCountTarget.innerHTML = `スペシャルデー: ${specialCount.toString()}つ`;
    // Get cost of all of them to add to the final price
    let specialCost = specialCount * 1500;
    // Handle + 1100 fees
    if (
      regList.includes("夏祭り@南町田グランベリーパーク (午後)") ||
      regList.includes("夏祭り@二俣川 (午前)") ||
      regList.includes("Kids UP縁日 (午後)") ||
      regList.includes("大人気アクティビティアンコールイベント (午前)")
    ) {
      specialCost += 1100;
      this.specialCountTarget.appendChild(document.createElement("br"));
      this.specialCountTarget.innerHTML += "スペシャルデー：1つ";
    }
    // Handle + 2000 fees
    if (regList.includes("カワスイ 川崎水族館 遠足 (午前)")) {
      specialCost += 2000;
      this.specialCountTarget.appendChild(document.createElement("br"));
      this.specialCountTarget.innerHTML += "スペシャルデー：1つ";
    }
    // Handle + 3000 fees
    if (regList.includes("スペシャル遠足@品川アクアパーク (午後)")) {
      specialCost += 3000;
      this.specialCountTarget.appendChild(document.createElement("br"));
      this.specialCountTarget.innerHTML += "スペシャルデー：1つ";
    }
    // Handle 4500 fixed cost
    if (
      regList.includes(
        "親子参加型！サイエンスアイスクリームを作ろう♪ (午後)"
      ) ||
      regList.includes("親子参加型！サイエンスアイスクリームを作ろう♪ (午前)")
    ) {
      if (this.isMember(this.childTarget)) {
        specialCost += 80;
      } else {
        specialCost -= 1430;
      }
      this.specialCountTarget.appendChild(document.createElement("br"));
      this.specialCountTarget.innerHTML += "スペシャルデー：1つ";
    }
    // Handle 6 000 fixed cost
    if (
      regList.includes("遠足＠うんこミュージアム (午前)") ||
      regList.includes("キッズアップハンター (午前)")
    ) {
      if (this.isMember(this.childTarget)) {
        specialCost += 1580;
      } else {
        specialCost -= 930;
      }
      this.specialCountTarget.appendChild(document.createElement("br"));
      this.specialCountTarget.innerHTML += "スペシャルデー：1つ";
    }
    // Rinkai morn and aft can both be registered, so handle separately
    if (regList.includes("サマーモンスター (午後)")) {
      if (this.isMember(this.childTarget)) {
        specialCost += 1580;
      } else {
        specialCost -= 930;
      }
      this.specialCountTarget.appendChild(document.createElement("br"));
      if (regList.includes("キッズアップハンター (午前)")) {
        this.specialCountTarget.innerHTML += "スペシャルデー：2つ";
      } else {
        this.specialCountTarget.innerHTML += "スペシャルデー：1つ";
      }
    }
    // Handle 7 000 fixed cost
    if (regList.includes("遠足＠アクアパーク品川 (午後)")) {
      specialCost += this.isMember(this.childTarget) ? 2580 : 70;
      this.specialCountTarget.appendChild(document.createElement("br"));
      this.specialCountTarget.innerHTML += "スペシャルデー：1つ";
    }
    // Decrement snack cost for all the PM with no snack charge
    if (
      regList.includes(
        "親子で参加可能♪浴衣OK♡うちわ作り体験＆KidsUP夏祭り (午後)"
      ) ||
      regList.includes("スペシャルクッキングイベント (午後)") ||
      regList.includes("サマーモンスター (午後)") ||
      regList.includes("Kids UP縁日 (午後)") ||
      regList.includes("スペシャル遠足@品川アクアパーク (午後)") ||
      regList.includes("遠足＠アクアパーク品川 (午後)") ||
      regList.includes("宝探し&amp;夏祭り (午後)") ||
      regList.includes("夏祭り@蒲田 (午後)") ||
      regList.includes("親子参加型！サイエンスアイスクリームを作ろう♪ (午後)")
    ) {
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
