import { Controller } from "@hotwired/stimulus"

// Toggles registration buttons from registered to unregistered when clicked
export default class extends Controller {

  static targets = ['button', 'name']
  static values = {
    id: Number,
    type: String,
    child: Number,
    cost: Number
}

  toggle (e) {
    e.preventDefault()

    const content = this.buttonTarget.innerHTML
    const id = this.idValue
    const type = this.typeValue
    const child = this.childValue
    const cost = this.costValue

    console.log(content)

    switch (content) {
        case 'Register':
            this.buttonTarget.classList.add('registered')
            this.buttonTarget.innerHTML = 'Unregister'
            break;
        case 'Unregister':
            this.buttonTarget.classList.remove('registered')
            this.buttonTarget.innerHTML = 'Register'
            break;
        case '✖':
            this.buttonTarget.classList.add('registered')
            this.buttonTarget.innerHTML = '✓'
            break;
        case '✓':
            this.buttonTarget.classList.remove('registered')
            this.buttonTarget.innerHTML = '✖'
            break;
        default:
            break;
    }

    this.dispatch('toggle', { detail: { id: id, type: type, child: child, cost: cost } })
  }
}