import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { target: String };

  scrollTo() {
    const targetId = this.targetValue;
    const targetElement = document.getElementById(targetId);

    if (targetElement) {
      targetElement.scrollIntoView({
        behavior: "smooth",
        block: "start",
      });
    }
  }
}
