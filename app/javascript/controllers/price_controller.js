import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = [
    'child',
    'slotRegs',
    'optRegs',
    'optCost',
    'adjChange',
    'summary',
    'finalCost']

  static values = {
    memberPrice: Object,
    nonMemberPrice: Object
  }

  // Base function called when fields added to form
  calculate() {
    this.summaryTarget.innerHTML = ''

    const courseCost = (this.childTargets.every(this.isMember) ? this.sameMembership(true) : (this.childTargets.every(this.notMember) ? this.sameMembership(false) : this.mixedMembership()));

    const optionCost = this.optCostTargets.filter(cost => cost.classList.contains('registered')).reduce(
      (sum, option) => sum + parseInt(option.innerHTML),
      0
    )

    this.summaryTarget.innerHTML += `<p>Option cost is ${optionCost} for ${this.optCostTargets.length} options</p>`

    const adjustmentChange = (this.hasAdjChangeTarget) ? this.adjChangeTargets.reduce(
      (sum, change) => sum + parseInt(change.innerHTML),
      0
    ) : 0

    console.log(adjustmentChange)

    const finalCost = optionCost + courseCost + adjustmentChange
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

    const memberCost = this.bestCourses(memberRegs, this.memberPrice)
    const nonMemberCost = this.bestCourses(nonMemberRegs, this.nonMemberPrice)
    const combinedCost =  memberCost + nonMemberCost

    this.summaryTarget.innerHTML += `<p>Cost for member registrations is ${memberCost} for ${memberRegs} registrations</p>`
    this.summaryTarget.innerHTML += `<p>Cost for non-member registrations is ${nonMemberCost} for ${nonMemberRegs} registrations</p>`
    this.summaryTarget.innerHTML += `<p>Total registration cost is ${combinedCost} for ${memberRegs + nonMemberRegs} registrations</p>`

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

    const courseCost = this.bestCourses(numRegs, courses)
    this.summaryTarget.innerHTML += `Course cost is ${courseCost} for ${numRegs} registrations\n`
    return courseCost
  }

  // Calculates cost from spot use when less than 5 courses
  spotUse(numRegs, courses) {
    return courses[1] * numRegs
  }
}