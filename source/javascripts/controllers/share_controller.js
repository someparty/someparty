import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

export default class extends Controller {
  static targets = [ "container" ]

  connect() {
    const containerEl = this.containerTarget
    const canonicalLink = document.getElementById('canonical')
    let link = `${document.location.origin}${document.location.pathname}`

    if(canonicalLink) {
      link = canonicalLink.href
    }

    const anchor = this.element.previousElementSibling.id
    if(anchor) {
      let anchorLink = `${link}#${anchor}`

      var shareLink = document.createElement('a')
      var linkText = document.createTextNode("Link here")
      shareLink.appendChild(linkText)
      shareLink.title = "Link directly to this section of the newsletter"
      shareLink.href = anchorLink

      containerEl.innerHTML = " - "
      containerEl.appendChild(shareLink)
    }
  }
}
