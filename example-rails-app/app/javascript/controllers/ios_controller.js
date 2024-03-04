import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  miSnap() {
    window.webkit?.messageHandlers?.nativeApp?.postMessage({
      name: "MiSnap"
    })
  }
}
