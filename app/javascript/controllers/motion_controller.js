import { Controller } from "@hotwired/stimulus";
import { animate, inView } from "motion";

export default class extends Controller {
  static values = {
    initial: Object,
    animate: Object,
    transition: Object,
    delay: Number,
    inView: Boolean,
  };

  connect() {
    const options = {
      duration: this.transitionValue?.duration || 0.8,
      delay: (this.transitionValue?.delay || 0) + (this.delayValue || 0),
      easing: "ease-out",
    };

    const initialStyles = this.initialValue || { opacity: 0, y: 50 };
    const targetStyles = this.animateValue || { opacity: 1, y: 0 };

    // Set initial state
    Object.assign(this.element.style, this.mapStylesToCss(initialStyles));

    if (this.inViewValue) {
      inView(this.element, () => {
        animate(this.element, targetStyles, options);
      });
    } else {
      animate(this.element, targetStyles, options);
    }
  }

  // Simple mapping for common framer-motion like props to CSS
  mapStylesToCss(styles) {
    const mapping = {};
    if (styles.opacity !== undefined) mapping.opacity = styles.opacity;
    if (styles.y !== undefined) mapping.transform = `translateY(${styles.y}px)`;
    if (styles.x !== undefined) mapping.transform = `translateX(${styles.x}px)`;
    if (styles.scale !== undefined) mapping.transform = `scale(${styles.scale})`;
    return mapping;
  }
}
