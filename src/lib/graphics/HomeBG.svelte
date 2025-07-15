<script>
	import { onMount, onDestroy } from 'svelte';
	import * as THREE from 'three';
	import { CSS3DRenderer, CSS3DObject } from 'three/examples/jsm/renderers/CSS3DRenderer.js';
	import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
	import { selectedSites } from '$lib/store/iframeCubeStore'; // Import the store

	// Import shaders
	import vertexShader from './shaders/vertexShader-three.glsl';
	import fragmentShader from './shaders/about/fragmentShader-aufbau.glsl';

	let container;
	let scene, camera, controls;
	let webglRenderer, cssRenderer; // Use both renderers
	let orthoScene, orthoCamera; // For fixed 2D background
	let cubeGroup;
	let iframeElements = [];
	let animationFrameId;
	let unsubscribeStore; // To hold the unsubscribe function for the store

	// Shader variables
	let shaderPlane, shaderMaterial;
	const clock = new THREE.Clock();
	const mouse = new THREE.Vector2(); // For shader uniform

	// Export the cleanup function for the component manager
	export function cleanup() {
		if (animationFrameId) {
			cancelAnimationFrame(animationFrameId);
			animationFrameId = null;
		}
		if (controls) {
			controls.dispose();
			controls = null;
		}
		if (shaderPlane) {
			if (shaderPlane.geometry) shaderPlane.geometry.dispose();
			if (shaderPlane.material) shaderPlane.material.dispose();
			if (scene && scene.children.includes(shaderPlane)) scene.remove(shaderPlane);
			shaderPlane = null;
			shaderMaterial = null;
		}
		// Cleanup WebGL Renderer
		if (webglRenderer) {
			if (container && container.contains(webglRenderer.domElement)) {
				container.removeChild(webglRenderer.domElement);
			}
			webglRenderer.dispose();
			webglRenderer = null;
		}
		// Cleanup CSS3D Renderer
		if (cssRenderer) {
			if (container && container.contains(cssRenderer.domElement)) {
				container.removeChild(cssRenderer.domElement);
			}
			// cssRenderer doesn't have dispose()
			cssRenderer = null;
		}
		if (unsubscribeStore) {
			unsubscribeStore(); // Unsubscribe from the Svelte store
			unsubscribeStore = null;
		}
		window.removeEventListener('resize', handleResize);
		window.removeEventListener('mousemove', handleMouseMove); // Remove mouse listener
		
		// Clear scene objects if necessary (CSS3DObjects are DOM elements managed elsewhere)
		scene = null;
		camera = null;
		cubeGroup = null;
		iframeElements = [];
		// Cleanup ortho scene/camera
		orthoScene = null;
		orthoCamera = null;
	}

	function handleResize() {
		if (!camera || !webglRenderer || !cssRenderer) return;
		
		const width = window.innerWidth;
		const height = window.innerHeight;

		camera.aspect = width / height;
		camera.updateProjectionMatrix();

		// Resize both renderers
		webglRenderer.setSize(width, height);
		cssRenderer.setSize(width, height);

		// Update ortho camera
		if (orthoCamera) {
			orthoCamera.left = -width / 2;
			orthoCamera.right = width / 2;
			orthoCamera.top = height / 2;
			orthoCamera.bottom = -height / 2;
			orthoCamera.updateProjectionMatrix();
		}
	}

	// Handle mouse move for shader uniform
	function handleMouseMove(event) {
		mouse.x = (event.clientX / window.innerWidth) * 2 - 1;
		mouse.y = -(event.clientY / window.innerHeight) * 2 + 1;
	}

	onMount(() => {
		// Scene setup
		scene = new THREE.Scene();
		camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
		camera.position.z = 700; // Move camera back to see the cube

		// Ortho scene for fixed background
		orthoScene = new THREE.Scene();
		orthoCamera = new THREE.OrthographicCamera(
			window.innerWidth / -2,
			window.innerWidth / 2,
			window.innerHeight / 2,
			window.innerHeight / -2,
			1,
			10
		);
		orthoCamera.position.z = 5; // Position doesn't affect orthographic rendering size

		// --- Shader Background Setup ---
		const shaderColors = {
			color1: new THREE.Color(0xff6b6b), // Playful Red (from AboutBG)
			color2: new THREE.Color(0xffd93d), // Playful Yellow (from AboutBG)
			color3: new THREE.Color(0x6bcbef)  // Playful Light Blue (from AboutBG)
		};

		shaderMaterial = new THREE.ShaderMaterial({
			vertexShader: vertexShader,
			fragmentShader: fragmentShader,
			uniforms: {
				time: { value: 0 },
				mouse: { value: new THREE.Vector2(0.0, 0.0) }, // Match shader expectation
				color1: { value: shaderColors.color1 },
				color2: { value: shaderColors.color2 },
				color3: { value: shaderColors.color3 }
			}
		});

		// Create plane geometry (size will be set in handleResize)
		const geometry = new THREE.PlaneGeometry(2, 2); // Simple 2x2 quad for ortho
		shaderPlane = new THREE.Mesh(geometry, shaderMaterial);
		// shaderPlane.position.z = 0; // Position doesn't matter much in ortho
		orthoScene.add(shaderPlane); // Add to ortho scene
		// --- End Shader Background Setup ---

		// --- WebGL Renderer Setup (for shader background) ---
		webglRenderer = new THREE.WebGLRenderer({ antialias: true });
		webglRenderer.setPixelRatio(window.devicePixelRatio);
		webglRenderer.setSize(window.innerWidth, window.innerHeight);
		webglRenderer.autoClear = false; // IMPORTANT: Allow multiple renders per frame
		webglRenderer.domElement.style.position = 'absolute';
		webglRenderer.domElement.style.top = '0';
		webglRenderer.domElement.style.left = '0';
		webglRenderer.domElement.style.zIndex = '-2'; // Behind CSS renderer
		webglRenderer.domElement.style.pointerEvents = 'none'; // Non-interactive
		container.appendChild(webglRenderer.domElement);
		// --- End WebGL Renderer Setup ---

		// --- CSS3D Renderer Setup (for iframe cube) ---
		cssRenderer = new CSS3DRenderer();
		cssRenderer.setSize(window.innerWidth, window.innerHeight);
		cssRenderer.domElement.style.position = 'absolute';
		cssRenderer.domElement.style.top = '0';
		cssRenderer.domElement.style.left = '0';
		cssRenderer.domElement.style.zIndex = '-1'; // Behind main content, in front of WebGL
		// pointer-events are handled by parent (.background-wrapper)
		container.appendChild(cssRenderer.domElement);
		// --- End CSS3D Renderer Setup ---

		// Controls setup - Target the container which covers the CSS renderer area
		controls = new OrbitControls(camera, container);
		controls.enableZoom = true;
		controls.enablePan = false;

		// Cube setup
		cubeGroup = new THREE.Group();
		scene.add(cubeGroup);
		const cubeSize = 500; // Size of the cube faces
		const halfCubeSize = cubeSize / 2;

		const positions = [
			{ pos: [0, 0, halfCubeSize], rot: [0, 0, 0] }, // Front
			{ pos: [0, 0, -halfCubeSize], rot: [0, Math.PI, 0] }, // Back
			{ pos: [-halfCubeSize, 0, 0], rot: [0, -Math.PI / 2, 0] }, // Left
			{ pos: [halfCubeSize, 0, 0], rot: [0, Math.PI / 2, 0] } // Right
		];

		iframeElements = []; // Reset iframe elements array
		unsubscribeStore = selectedSites.subscribe(urls => {
			urls.forEach((url, index) => {
				let iframe;
				let object;

				if (index >= positions.length) return; // Prevent errors if store has > 4 sites

				if (iframeElements[index]) {
					// Update existing iframe src if it exists
					iframe = iframeElements[index].element; // Access the iframe via the CSS3DObject element property
					iframe.src = url;
				} else {
					// Create new iframe and CSS3DObject
					iframe = document.createElement('iframe');
					iframe.style.width = `${cubeSize}px`;
					iframe.style.height = `${cubeSize}px`;
					iframe.style.border = 'none';
					iframe.style.backgroundColor = 'rgba(0,0,0,0.1)';
					iframe.src = url;

					object = new CSS3DObject(iframe);
					object.position.fromArray(positions[index].pos);
					object.rotation.fromArray(positions[index].rot);
					cubeGroup.add(object);
					iframeElements[index] = object; // Store the CSS3DObject
				}
			});
			// Remove extra iframes if the URL list shrinks (more robust)
			for (let i = urls.length; i < iframeElements.length; i++) {
				if (iframeElements[i]) {
					cubeGroup.remove(iframeElements[i]);
					iframeElements[i] = null; // Clear the slot
				}
			}
			iframeElements.length = urls.length; // Adjust array length
		});

		// Animation loop
		function animate() {
			animationFrameId = requestAnimationFrame(animate);

			const elapsedTime = clock.getElapsedTime();

			// Update shader uniforms
			if (shaderMaterial) {
				shaderMaterial.uniforms.time.value = elapsedTime;
				// Lerp mouse uniform for smoother effect
				shaderMaterial.uniforms.mouse.value.lerp(mouse.clone().multiplyScalar(0.5), 0.1); // Adjust multiplier/lerp factor as needed
			}

			controls.update();

			// Render both scenes
			webglRenderer.clear(); // Clear everything
			webglRenderer.render(orthoScene, orthoCamera); // Render 2D background first
			webglRenderer.clearDepth(); // Clear depth buffer for 3D scene
			webglRenderer.render(scene, camera); // Render 3D scene over it
			cssRenderer.render(scene, camera);
		}
		animate();

		// Initial resize and setup listeners
		window.addEventListener('resize', handleResize);
		handleResize();
		window.addEventListener('mousemove', handleMouseMove);

		return cleanup; // Svelte will call this on component destruction
	});

	onDestroy(() => {
		cleanup(); // Ensure cleanup runs if component is destroyed externally
	});
</script>

<div bind:this={container} class="home-background">
</div>

<style>
    .home-background {
        width: 100%;
        height: 100%;
        /* Ensure it doesn't block events if something is behind it, although unlikely here */
        /* pointer-events: none; */ /* REMOVED to allow canvas events */
        /* Let parent handle positioning */
    }
</style>