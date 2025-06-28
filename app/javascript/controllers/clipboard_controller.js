import { Controller } from "@hotwired/stimulus"
// Using clipboard API to add a copy-to-clipboard button on index.html.erb

// Connects to data-controller="clipboard"
export default class extends Controller {

  static targets = ["content", "button"]

  connect() {
    console.log("Clipboard controller connected")
  }

  copy() {
    const text = this.contentTarget.innerText
    navigator.clipboard.writeText(text)
      .then(() => {
        alert(text + " copied to clipboard");
      })
      .catch((error) => {
        console.error('Failed to copy text to clipboard:', error);
      });
  }
}
