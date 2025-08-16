<script>
	import { onMount, onDestroy } from 'svelte';
	// import { page } from '$lib/store/store';
	import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js';
	import * as THREE from 'three';

	let container, animationFrameId;
	let scene, camera, renderer, clock;
	let cameraGroup, mainGroup, macGroup, plantGroup;

	onDestroy(() => {
		cancelAnimationFrame(animationFrameId);
		window.removeEventListener('resize', handleWindowResize);
	});

	function initializeScene() {
		scene = new THREE.Scene();
		mainGroup = new THREE.Group();

		// Set up camera and camera group
		camera = new THREE.PerspectiveCamera(20, window.innerWidth / window.innerHeight, 0.01, 200);
		camera.position.y = 1.5;
		camera.position.z = 115; // Move camera in front of the objects

		cameraGroup = new THREE.Group();
		cameraGroup.add(camera);
		// cameraGroup.position.z = 300;
		scene.add(cameraGroup);
		
		// Add mainGroup to the scene
		scene.add(mainGroup);

		// Set up renderer
		renderer = new THREE.WebGLRenderer({ antialias: true, alpha: false });
		renderer.setClearColor(0x000000, 0);
		renderer.setSize(window.innerWidth, window.innerHeight);

		// Set up clock for smooth animations
		clock = new THREE.Clock();

		// Add basic lights
		const light = new THREE.HemisphereLight(0xf0f0f0, 0xb0b0b0, 1.4);
		light.position.set(0, 10, 125); // Position light near the camera to illuminate objects
		scene.add(light);

		// Add fog to the scene
		// const color = 0xd0d0d0;
		// const density = 0.005;
		// scene.fog = new THREE.FogExp2(color, density);

		// Append renderer to DOM
		container.appendChild(renderer.domElement);

		// Handle window resize
		window.addEventListener('resize', handleWindowResize);

		// setupCubeGrid(); // Add cube grid setup
		setupMac();
		setupPlant();

		// Start rendering
		renderScene();
	}

	function handleWindowResize() {
		camera.aspect = window.innerWidth / window.innerHeight;
		camera.updateProjectionMatrix();
		renderer.setSize(window.innerWidth, window.innerHeight);
	}


	function setupMac() {
		macGroup = new THREE.Group();
		const gltfLoader = new GLTFLoader();

		// Create desktop surface (cuboid)
		const desktopGeometry = new THREE.BoxGeometry(100, 3, 75);
		const desktopMaterial = new THREE.MeshToonMaterial({ 
			color: 0xffffff, // White base color
		});
		const desktop = new THREE.Mesh(desktopGeometry, desktopMaterial);
		desktop.position.set(0, -7.5, 62.5); // Position below the Mac
		macGroup.add(desktop);

		gltfLoader.load('/mac.glb', (glb) => {
			const mac = glb.scene.children[0];
			// mac.rotation.x += Math.PI;
			mac.position.set(0, -5.0, 62.5); // Position it centrally in the group
			mac.scale.set(0.2, 0.2, 0.2); // Uniform scaling to ensure visibility

			// mac.traverse(function (child) {
			// 	if (child.material) {
			// 		child.material = new THREE.MeshToonMaterial({
			// 			color: 0xf0f0f0
			// 		});
			// 	}
			// });

			macGroup.add(mac);
			// macGroup.position.set(0, 0, 50); // Position the Mac group in front of the camera
			mainGroup.add(macGroup); // Add macGroup to mainGroup
		});
	}

	function setupPlant() {
		// Create first plant (left side)
		const plantGroup1 = new THREE.Group();
		const gltfLoader1 = new GLTFLoader();

		gltfLoader1.load('/plant.glb', (glb) => {
			const plant1 = glb.scene.children[0];
			plant1.position.set(-11.5, -6.0, 55); // Left side of the desk
			plant1.scale.set(0.75, 0.75, 0.75);

			// plant1.traverse(function (child) {
			// 	if (child.material) {
			// 		child.material = new THREE.MeshToonMaterial({
			// 			color: 0xf0f0f0
			// 		});
			// 	}
			// });

			plantGroup1.add(plant1);
			mainGroup.add(plantGroup1);
		});

		// Create second plant (right side)
		const plantGroup2 = new THREE.Group();
		const gltfLoader2 = new GLTFLoader();

		gltfLoader2.load('/plant.glb', (glb) => {
			const plant2 = glb.scene.children[0];
			plant2.position.set(10.5, -6.0, 55); // Right side of the desk
			plant2.scale.set(0.75, 0.75, 0.75);

			// plant2.traverse(function (child) {
			// 	if (child.material) {
			// 		child.material = new THREE.MeshToonMaterial({
			// 			color: 0xf0f0f0
			// 		});
			// 	}
			// });

			plantGroup2.add(plant2);
			mainGroup.add(plantGroup2);
		});

		// Store both plant groups for visibility control
		plantGroup = [plantGroup1, plantGroup2];
	}

	function renderScene(time) {
		const elapsedTime = clock.getElapsedTime();
		updateScene(elapsedTime);

		renderer.render(scene, camera);
		animationFrameId = requestAnimationFrame(renderScene);

		// Update active tween
		// Object.values(tweens).forEach((tween) => tween.update(time));
	}

	function updateScene(elapsedTime) {

	}

	// Define scene configurations
	// const sceneConfigs = {
	// 	1: setupScene1,
	// 	2: setupScene2,
	// 	3: setupScene3,
	// 	4: setupScene4,
	// };

	// React to page changes
	// $: {
	// 	if (sceneConfigs[$page]) {
	// 		sceneConfigs[$page]();
	// 	}
	// }

	// Initialize scene on mount
	onMount(() => {
		initializeScene();
	});
</script>

<div bind:this={container} class:geometry={true} />

<style>
	.geometry {
		position: absolute;
		top: 0;
		left: 0;
		z-index: -10;
		overflow: hidden;

		width: 100vw;
		height: 100vh;
		height: calc(var(--vh, 1vh) * 100);

		/* opacity: 0;
		animation: fadein 3s 1s ease;
		animation-fill-mode: forwards; */
	}
</style>
