import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = [
    'child',
    'slotRegs',
    'optRegs',
    'optCost',
    'finalCost']

  static values = {
    memberPrice: Object,
    nonMemberPrice: Object
  }

  // Base function called when fields added to English form
  calculate() {
    const courseCost = this.childTargets.reduce(
      (sum, child) => sum + this.childCost(child),
      0
    )

    const optionCost = this.optCostTargets.reduce(
      (sum, option) => sum + parseInt(option.innerHTML),
      0
    )

    const finalCost = optionCost + courseCost
    this.finalCostTarget.innerHTML = `Total Cost: ${finalCost}円`
  }

  // Finds the cheapest price for the given number of regs
  bestCourses(numRegs, courses) {
    if (numRegs >= 35) {
      return courses[30] + this.bestCourses(numRegs - 30, courses)
    }

    if (numRegs > 5) {
      const bestCourse = this.nearestFive(numRegs)
      const cost = courses[bestCourse]
      return cost + this.bestCourses(numRegs - bestCourse, courses)
    }

    return this.spotUse(numRegs, courses)
  }

  // Get the course objects on connect so you don't have to parse before each calculation
  connect() {
    this.memberPrice = this.memberPriceValue
    this.nonMemberPrice = this.nonMemberPriceValue
  }

  // Calculates course cost per child
  childCost(child) {
    const id = parseInt(child.children[0].innerHTML)
    const membership = document.getElementById(`child${id}membership`).innerHTML
    const numRegs = this.slotRegsTarget.querySelectorAll(`.child${id}`).length
    const course = (membership === 'Member') ? this.memberPrice : this.nonMemberPrice

    return this.bestCourses(numRegs, course)
  }

  // Find the largest course that fits the number of registrations
  nearestFive(num) {
    return Math.floor(num / 5) * 5
  }

  // Calculates cost from spot use when less than 5 courses
  spotUse(numRegs, courses) {
    return courses[1] * numRegs
  }
}