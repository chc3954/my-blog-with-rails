import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["toggle"];

  connect() {
    this.applyTheme();
  }

  toggle() {
    localStorage.getItem("theme") === "dark"
      ? localStorage.setItem("theme", "light")
      : localStorage.setItem("theme", "dark");

    this.applyTheme();
  }

  applyTheme() {
    const isDarkSet = localStorage.getItem("theme") === "dark";
    const isDarkPreferred =
      !("theme" in localStorage) && window.matchMedia("(prefers-color-scheme: dark)").matches;

    isDarkSet || isDarkPreferred
      ? document.documentElement.classList.add("dark")
      : document.documentElement.classList.remove("dark");
  }
}
