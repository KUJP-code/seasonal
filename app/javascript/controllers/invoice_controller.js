import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = ['slotRegs', 'optRegs', 'optCost', 'template', 'target']
  static values = {
  }

  add (e) {

    const id = e.detail.id
    const type = e.detail.type
    const child = e.detail.child
    const cost = e.detail.cost

    console.log(id)
    console.log(type)
    console.log(child)
    console.log(cost)

    // TODO: put the real condition in once you have the value
    if (false) {
        this.optCostTarget.innerHTML = 'cost'
    }
    // TODO: substitute the real values once you get them
    const content = this.templateTarget.innerHTML.replace(/REG/g, new Date().getTime().toString()).replace(/child_id/g, 'passed child id').replace(/reg_id/g, 'passed reg id').replace(/reg_type/g, 'passed reg type')
    this.targetTarget.insertAdjacentHTML('beforebegin', content)
  }

  remove (e) {

    const wrapper = e.target.closest(this.wrapperSelectorValue)

    if (wrapper.dataset.newRecord === 'true') {
      wrapper.remove()
    } else {
      wrapper.style.display = 'none'

      const input = wrapper.querySelector("input[name*='_destroy']")
      input.value = '1'
    }
  }
}