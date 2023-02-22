import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = [
    'slotTemplate',
    'slotTarget',
    'optTemplate',
    'optTarget'
  ]

  add (child, cost, id, type) {

    if (type === 'TimeSlot') {
      const content = this.slotTemplateTarget.innerHTML.replace(/REG_INDEX/g, new Date().getTime().toString()).replace(/###/g, id.concat(child)).replace(/NEW_CHILD_ID/g, child).replace(/NEW_REGISTERABLE_ID/g, id)
      this.slotTargetTarget.insertAdjacentHTML('beforebegin', content)
    } else {
      const content = this.optTemplateTarget.innerHTML.replace(/REG_INDEX/g, new Date().getTime().toString()).replace(/###/g, id.concat(child)).replace(/NEW_CHILD_ID/g, child).replace(/NEW_REGISTERABLE_ID/g, id).replace(/NEW_COST/g, cost)
      this.optTargetTarget.insertAdjacentHTML('beforebegin', content)
    }
  }

  change (e) {
    const child = e.detail.child
    const content = e.detail.content
    const cost = e.detail.cost
    const id = e.detail.id
    const type = e.detail.type

    if (content === 'Register' || content === '✖') {
      this.add(child, cost, id, type)
    } else {
      this.remove(child, id)
    }
  }

  remove (child, id) {

    const wrapper = document.getElementById(id.concat(child))

    if (wrapper.dataset.newRecord === 'true') {
      wrapper.remove()
    } else {
      // TODO: need to add this field, and probably also enable destroy on invoice controller
      const input = wrapper.querySelector("input[name*='_destroy']")
      input.value = '1'
    }
  }
}