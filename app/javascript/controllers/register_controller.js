import { Controller } from "@hotwired/stimulus"

// Toggles registration buttons from registered to unregistered when clicked
export default class extends Controller {

  static targets = ['button']

  toggle (e) {
    e.preventDefault()

    const content = this.buttonTarget.innerHTML
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
  }
}