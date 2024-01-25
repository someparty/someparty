import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
import { spinner } from '../spinner.js'

export default class extends Controller {
  static targets = [ "email", "input", "spinner" ]

  submit(event) {
    event.preventDefault()
    const emailEl = this.emailTarget
    const inputEl = this.inputTarget
    const spinnerEl = this.spinnerTarget
    spinnerEl.innerHTML = ""

    // Trim whitespace from the email
    emailEl.value = emailEl.value.trim()

    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (!emailPattern.test(emailEl.value)) {
      console.error('Invalid email address')
      Swal.fire("Invalid email address", "Please check that the email address you entered is valid", "error")
      return false
    }

    var formData = {
        email: emailEl.value
    }

    spinnerEl.innerHTML = spinner
    inputEl.style.display = 'none'

    fetch('https://api.someparty.ca/some_party_resend', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),

    })

    .then(response => response.text())
    .then(data => {
        spinnerEl.innerHTML = ''
        inputEl.style.display = ''
        Swal.fire("Unsubscribe Link Sent", "If you're a current subscriber, an email has been sent with your custom unsubscribe link.", "success")
      }
    )
    .catch(error => {
      console.error('Subscribe Error:', error)
      spinnerEl.innerHTML = ''
      inputEl.style.display = ''
      Swal.fire("Error requesting the link", "There was a problem confirming your subscription. Please try again.", "error")
    })
  }
}
