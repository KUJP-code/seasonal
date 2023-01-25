import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = ['target', 'template']
  static values = {
    wrapperSelector: {
      type: String,
      default: '.child_fields_wrapper'
    }
  }

  add (e) {
    e.preventDefault()

    const content = this.templateTarget.innerHTML.replace(/CHILD/g, new Date().getTime().toString())
    this.targetTarget.insertAdjacentHTML('beforebegin', content)
  }

  remove (e) {
    e.preventDefault()

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