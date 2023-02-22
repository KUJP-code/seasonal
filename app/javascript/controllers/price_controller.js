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
    const courseCost = (this.childTargets.every(this.isMember) ? this.sameMembership(true) : (this.childTargets.every(this.notMember) ? this.sameMembership(false) : this.mixedMembership()));

    const optionCost = this.optCostTargets.filter(cost => cost.classList.contains('registered')).reduce(
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

    if (numRegs >= 5) {
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

  // True if child is a member
  isMember(child) {
    const id = parseInt(child.children[0].innerHTML)
    const membership = document.getElementById(`child${id}membership`).innerHTML

    if (membership === 'Member') {
      return true
    } else {
      return false
    }
  }

  // Calculates course costs if a mixture of registered and unregistered kids
  mixedMembership() {
    const memberIds = this.childTargets.filter(child => this.isMember(child)).map(
      (child) => parseInt(child.children[0].innerHTML)
    )
    
    const memberRegs = memberIds.reduce(
      (sum, id) => sum + this.slotRegsTarget.querySelectorAll(`.child${id}`).length,
      0
    )
    
    const nonMemberIds = this.childTargets.filter(child => this.notMember(child)).map(
      (child) => parseInt(child.children[0].innerHTML)
    )
    
    const nonMemberRegs = nonMemberIds.reduce(
      (sum, id) => sum + this.slotRegsTarget.querySelectorAll(`.child${id}`).length,
      0
    )
    
    const combinedCost = this.bestCourses(memberRegs, this.memberPrice) + this.bestCourses(nonMemberRegs, this.nonMemberPrice)
    return combinedCost
  }

  // Find the largest course that fits the number of registrations
  nearestFive(num) {
    return Math.floor(num / 5) * 5
  }

  // True if child is not member
  notMember(child) {
    const id = parseInt(child.children[0].innerHTML)
    const membership = document.getElementById(`child${id}membership`).innerHTML

    if (membership === 'Member') {
      return false
    } else {
      return true
    }
  }

  // Calculates course costs if kids are both members/not
  sameMembership(member) {
    const courses = (member) ? this.memberPrice : this.nonMemberPrice

    const ids = this.childTargets.map(
      (child) => parseInt(child.children[0].innerHTML)
    )
    const numRegs = ids.reduce(
      (sum, id) => sum + this.slotRegsTarget.querySelectorAll(`.child${id}`).length,
      0
    )

    return this.bestCourses(numRegs, courses)
  }

  // Calculates cost from spot use when less than 5 courses
  spotUse(numRegs, courses) {
    return courses[1] * numRegs
  }
}