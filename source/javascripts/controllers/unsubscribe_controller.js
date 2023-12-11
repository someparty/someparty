import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

export default class extends Controller {
  static targets = [ "email", "uuid", "pending", "feedback" ]

  connect() {
    const params = new URLSearchParams(window.location.search);
    const email = params.get('email');
    const uuid = params.get('uuid');

    this.emailTarget.value = email;
    this.uuidTarget.value = uuid;

    if(email && uuid) {
      this.pendingTarget.innerHTML = `Please confirm that you'd like unsubscribe ${email} from the newsletter?`
    }
  }

  submit(event) {
    event.preventDefault()
    const emailEl = this.emailTarget
    const uuidEl = this.emailTarget
    const feedbackEl = this.feedbackTarget
    feedbackEl.innerHTML = ""

    var formData = {
        email: emailEl.value,
        uuid: uuidEl.value
    };

    fetch('https://api.someparty.ca/some_party_unsubscribe', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
    })

    .then(response => response.text())
    .then(data => console.log('Unsubscribe Success:', data))
    .catch(error => console.error('Unsubscribe Error:', error))
  }
}
