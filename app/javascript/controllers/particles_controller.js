import { Controller } from "@hotwired/stimulus";
import * as THREE from "three";

export default class extends Controller {
  connect() {
    this.initThree();
    this.animate();
  }

  disconnect() {
    if (this.renderer) {
      this.element.removeChild(this.renderer.domElement);
    }
  }

  initThree() {
    const width = this.element.clientWidth;
    const height = this.element.clientHeight;

    // Scene
    this.scene = new THREE.Scene();

    // Camera
    this.camera = new THREE.PerspectiveCamera(75, width / height, 0.1, 1000);
    this.camera.position.z = 10;

    // Renderer
    this.renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true });
    this.renderer.setSize(width, height);
    this.element.appendChild(this.renderer.domElement);

    // Particles
    const geometry = new THREE.BufferGeometry();
    const particlesCount = 100;
    const posArray = new Float32Array(particlesCount * 3);
    const colorArray = new Float32Array(particlesCount * 3);

    for (let i = 0; i < particlesCount; i++) {
      // Random positions centered around 0
      posArray[i * 3] = (Math.random() - 0.5) * 15;
      posArray[i * 3 + 1] = (Math.random() - 0.5) * 15;
      posArray[i * 3 + 2] = (Math.random() - 0.5) * 15;

      // Random Colors
      const color = new THREE.Color();
      color.setHSL(Math.random(), 0.7, 0.5); // Random hue, high saturation
      colorArray[i * 3] = color.r;
      colorArray[i * 3 + 1] = color.g;
      colorArray[i * 3 + 2] = color.b;
    }

    geometry.setAttribute("position", new THREE.BufferAttribute(posArray, 3));
    geometry.setAttribute("color", new THREE.BufferAttribute(colorArray, 3));

    // Circular Texture
    const sprite = this.getCircleTexture();

    // Material
    const material = new THREE.PointsMaterial({
      size: 0.2,
      map: sprite,
      transparent: true,
      alphaTest: 0.5,
      opacity: 0.8,
      vertexColors: true,
    });

    this.particlesMesh = new THREE.Points(geometry, material);
    this.scene.add(this.particlesMesh);

    // Lights
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
    this.scene.add(ambientLight);

    const pointLight = new THREE.PointLight(0xffffff, 1);
    pointLight.position.set(10, 10, 10);
    this.scene.add(pointLight);

    // Handle Resize
    window.addEventListener("resize", this.onWindowResize.bind(this));
  }

  getCircleTexture() {
    const canvas = document.createElement("canvas");
    canvas.width = 32;
    canvas.height = 32;
    const context = canvas.getContext("2d");
    const center = 16;
    const radius = 16;

    context.beginPath();
    context.arc(center, center, radius, 0, 2 * Math.PI);
    context.fillStyle = "white";
    context.fill();

    const texture = new THREE.CanvasTexture(canvas);
    return texture;
  }

  onWindowResize() {
    if (!this.camera || !this.renderer) return;
    const width = this.element.clientWidth;
    const height = this.element.clientHeight;
    this.camera.aspect = width / height;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(width, height);
  }

  animate() {
    requestAnimationFrame(this.animate.bind(this));

    if (this.particlesMesh) {
      this.particlesMesh.rotation.y += 0.002;
      this.particlesMesh.rotation.x += 0.001;
    }

    this.renderer.render(this.scene, this.camera);
  }
}
