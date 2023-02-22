import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = [
    'slotTemplate',
    'slotTarget',
    'optTemplate',
    'optTarget'
  ]

  add (child, cost, id, type) {
    const wrapper = document.getElementById(id.concat(child))

    if (wrapper) {
      // For existing registrations
      const destroy = wrapper.querySelector("input[name*='_destroy']")
      destroy.value = '0'
      wrapper.classList.add(`child${child}`)
      if (type === 'Option') {
        const cost = wrapper.querySelector('.opt_cost.hidden')
        console.log(cost)
        cost.classList.add('registered')
        console.log(cost)
      }
    } else {
      // For newly created registrations
      if (type === 'TimeSlot') {
        const content = this.slotTemplateTarget.innerHTML.replace(/REG_INDEX/g, new Date().getTime().toString()).replace(/NEW_ID/g, id.concat(child)).replace(/NEW_CLASS/, `child${child}`).replace(/NEW_CHILD_ID/g, child).replace(/NEW_REGISTERABLE_ID/g, id)
        this.slotTargetTarget.insertAdjacentHTML('beforebegin', content)
      } else {
        const content = this.optTemplateTarget.innerHTML.replace(/REG_INDEX/g, new Date().getTime().toString()).replace(/NEW_ID/g, id.concat(child)).replace(/NEW_CLASS/, `child${child}`).replace(/NEW_CHILD_ID/g, child).replace(/NEW_REGISTERABLE_ID/g, id).replace(/NEW_COST/g, cost)
        this.optTargetTarget.insertAdjacentHTML('beforebegin', content)
      }
    }

    this.dispatch('add')
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
      this.remove(child, id, type)
    }
  }

  remove (child, id, type) {

    const wrapper = document.getElementById(id.concat(child))

    if (wrapper.dataset.newRecord === 'true') {
      // For newly created registrations
      wrapper.remove()
    } else {
      // For existing registrations
      const destroy = wrapper.querySelector("input[name*='_destroy']")
      destroy.value = '1'
      wrapper.classList.remove(`child${child}`)
      if (type === 'Option') {
        const cost = wrapper.querySelector('.opt_cost.hidden')
        cost.classList.remove('registered')
        console.log(cost)
      }
    }

    this.dispatch('remove')
  }
}