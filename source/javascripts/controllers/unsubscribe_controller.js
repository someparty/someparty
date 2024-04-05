import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
import { spinner } from '../spinner.js';

export default class extends Controller {
  async connect() {
    const inputTarget = this.inputTarget
    const params = new URLSearchParams(window.location.search)
    const email = params.get('email')
    const uuid = params.get('uuid')

    if(!email || !uuid) {
      return
    }

    // Swal is loaded with defer so wait
    this.checkSwalLoaded = setInterval(async () => {
      if (window.Swal) {
        clearInterval(this.checkSwalLoaded);
        await this.promptUnsubscribe(email, uuid)
      }
    }, 100);
  }

  async promptUnsubscribe(email, uuid) {
    var formData = {
      email: email,
      uuid: uuid
   }

    const result = await Swal.fire({
      title: "Confirm Unsubscribe",
      text: `Please confirm that you'd like unsubscribe ${email} from the newsletter.`,
      showDenyButton: true,
      showCancelButton: false,
      confirmButtonText: "Yes, Unsubscribe Me",
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

      try {
        const response = await fetch('https://api.someparty.ca/some_party_unsubscribe', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(formData),
        })

        const data = await response.text()
        await Swal.fire("Unsubscribe Request Submitted", data, "success")
      } catch (error) {
        await Swal.fire("Unsubscribe Error", error, "error")
      }
    } else if (result.isDenied) {
      Swal.fire("Unsubscribe cancelled", "You're still subscribed to Some Party.", "info")
    }

  }
}
