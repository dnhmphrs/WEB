<script>
	import { onMount, onDestroy } from 'svelte';
	import * as THREE from 'three';
	import { CSS3DRenderer, CSS3DObject } from 'three/examples/jsm/renderers/CSS3DRenderer.js';
	import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
	import { selectedSites } from '$lib/store/iframeCubeStore'; // Import the store

	let container;
	// let controlsContainer; // REMOVE - No longer needed
	let scene, camera, renderer, controls;
	let cubeGroup;
	let iframeElements = [];
	let animationFrameId;
	let unsubscribeStore; // To hold the unsubscribe function for the store

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
		if (renderer && container && container.contains(renderer.domElement)) {
			container.removeChild(renderer.domElement);
			renderer = null;
		}
		if (unsubscribeStore) {
			unsubscribeStore(); // Unsubscribe from the Svelte store
			unsubscribeStore = null;
		}
		window.removeEventListener('resize', handleResize);
		
		// Clear scene objects if necessary (CSS3DObjects are DOM elements managed elsewhere)
		scene = null;
		camera = null;
		cubeGroup = null;
		iframeElements = [];
	}

	function handleResize() {
		if (!camera || !renderer) return;
		
		camera.aspect = window.innerWidth / window.innerHeight;
		camera.updateProjectionMatrix();
		renderer.setSize(window.innerWidth, window.innerHeight);
	}

	onMount(() => {
		// Scene setup
		scene = new THREE.Scene();
		camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
		camera.position.z = 700; // Move camera back to see the cube

		// Renderer setup (CSS3D)
		renderer = new CSS3DRenderer();
		renderer.setSize(window.innerWidth, window.innerHeight);
		renderer.domElement.style.position = 'absolute';
		renderer.domElement.style.top = '0';
		renderer.domElement.style.zIndex = '-1'; // Set z-index to ensure it's behind UI elements
		renderer.domElement.style.pointerEvents = 'none'; // Explicitly set pointer-events in JS
		container.appendChild(renderer.domElement);

		// Controls setup - Attach to document.body instead of a specific div
		controls = new OrbitControls(camera, document.body); // Attach to body
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

				if (iframeElements[index]) {
					// Update existing iframe src if it exists
					iframe = iframeElements[index];
					iframe.src = url;
				} else {
					// Create new iframe and CSS3DObject
					iframe = document.createElement('iframe');
					iframe.style.width = `${cubeSize}px`;
					iframe.style.height = `${cubeSize}px`;
					iframe.style.border = 'none'; // Changed '0px' to 'none'
					iframe.style.backgroundColor = 'rgba(0,0,0,0.1)'; // Slight background while loading
					iframe.src = url;
					iframeElements[index] = iframe; // Store the iframe element

					object = new CSS3DObject(iframe);
					object.position.fromArray(positions[index].pos);
					object.rotation.fromArray(positions[index].rot);
					cubeGroup.add(object);
				}
			});
			// Ensure exactly 4 iframes are present (remove extras if logic changes)
			// This simple setup assumes the store always provides 4 URLs
		});

		// Animation loop
		function animate() {
			animationFrameId = requestAnimationFrame(animate);
			controls.update(); // Re-enable
			renderer.render(scene, camera);
		}
		animate();

		// Handle resize
		window.addEventListener('resize', handleResize);
		handleResize(); // Initial size setup

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
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        overflow: hidden; /* Prevent scrollbars */
    }
</style>