import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

export default class extends Controller {
  static targets = [ "email", "feedback" ]

  submit(event) {
    event.preventDefault()
    const emailEl = this.emailTarget
    const feedbackEl = this.feedbackTarget
    feedbackEl.innerHTML = ""

    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (!emailPattern.test(emailEl.value)) {
      console.error('Invalid email address')
      feedbackEl.innerHTML = "Invalid email address"
      return false
    }

    var formData = {
        email: emailEl.value
    };

    fetch('https://api.someparty.ca/some_party_subscribe', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
    })

    .then(response => response.text())
    .then(data => console.log('Subscribe Success:', data))
    .catch(error => console.error('Subscribe Error:', error))
  }
}
