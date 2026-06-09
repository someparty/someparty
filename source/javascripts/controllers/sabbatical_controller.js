import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

export default class extends Controller {
  async connect() {
    const content = this.element.innerHTML
    Swal.fire({ title: "Gone Fishin'", html: content, icon: false })
  }
}
