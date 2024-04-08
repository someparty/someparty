import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
import { spinner } from '../spinner.js';

export default class extends Controller {
  static targets = [ "email", "input", "spinner" ]

  async connect() {
    const params = new URLSearchParams(window.location.search)
    const email = params.get('email')
    const inputEl = this.inputTarget

    if(!email) {
      return
    }

    // The manual form is not needed since we pulled the email from the URL
    inputEl.style.display = 'none'

    // Swal is loaded with defer so wait
    this.checkSwalLoaded = setInterval(async () => {
      if (window.Swal) {
        clearInterval(this.checkSwalLoaded);
        await this.promptEntry(email)
      }
    }, 100);
  }

  async promptEntry(email) {
    const confirm = this.element.dataset.confirm

    const result = await Swal.fire({
      title: "Confirm Entry",
      text: confirm,
      showDenyButton: true,
      showCancelButton: false,
      confirmButtonText: "Yes, Enter Me",
      denyButtonText: `Nevermind`,
      icon: 'question'
    })

    if (result.isConfirmed) {
      Swal.fire({
        title: "Please wait",
        html: spinner,
        showCloseButton: false,
        showCancelButton: false,
        showConfirmButton: false,
        allowOutsideClick: false
      })

      await this.confirmEntry(email)
    } else if (result.isDenied) {
      Swal.fire("Contest entry cancelled", "You haven't entered the draw.", "info")
    }
  }

  async submit(event) {
    event.preventDefault()
    const emailEl = this.emailTarget
    const inputEl = this.inputTarget

    // Trim whitespace from the email
    emailEl.value = emailEl.value.trim()

    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (!emailPattern.test(emailEl.value)) {
      console.error('Invalid email address')
      Swal.fire("Invalid email address", "Please check that the email address you entered is valid", "error")
      return false
    }

    inputEl.style.display = 'none'
    await this.confirmEntry(emailEl.value)
  }

  async confirmEntry(email) {
    const spinnerEl = this.spinnerTarget
    const contest = this.element.dataset.contest

    if(!email || !contest) {
      return
    }

    var formData = {
      email: email,
      contest: contest
    }

    spinnerEl.innerHTML = spinner

    try {
      const response = await fetch('https://api.someparty.ca/some_party_enter_contest', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      })

      const data = await response.text()
      spinnerEl.innerHTML = ''
      inputEl.style.display = ''
      await Swal.fire("Entry Submitted", data, "success")
    } catch (error) {
      spinnerEl.innerHTML = ''
      inputEl.style.display = ''
      await Swal.fire("Contest Entry Error", error, "error")
    }
  }
}
