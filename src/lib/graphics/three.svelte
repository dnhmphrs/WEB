<script>
	import { onMount } from 'svelte';
	import { screenType } from '$lib/store/store';
	import { page } from '$app/stores';
	import { browser } from '$app/environment';
	// import { afterNavigate } from '$app/navigation';

	import * as THREE from 'three';

	// Import the shader configuration
	import { getShaderSetForPage, commonVertexShader } from './shaderConfig';

	// Accept current path as a prop
	export let currentPath = '';

	let isDragging = false;
	let previousMousePosition = { x: 0, y: 0 };
	
	// For better mouse influence tracking
	let targetCameraPosition = { x: 0, y: 0 };
	let viewCenter = { x: 0, y: 0 };

	const uniformsBase = {
		time: { value: 0 },
		mouse: { value: [0.0,0.0] }
	};

	let container;

	let camera, scene, renderer;

	let width = window.innerWidth;
	let height = window.innerHeight;

	let mouse = new THREE.Vector2();
	const clock = new THREE.Clock();
	
	// Grid configuration
	const TILE_SIZE = 60;
	const PLANE_SIZE = 110;
	const VISIBLE_RANGE = 25; // Number of tiles visible in each direction from center
	const tileCache = new Map(); // Cache for tracking existing tiles
	
	// Current shader set based on page
	let currentShaders;
	let currentColors;
	let HARMONIC_RATIOS;
	let BASE_CHANGE_INTERVAL;
	
	// Track tile change timers
	const tileTimers = new Map();
	
	// Mouse movement detection for changes
	let isMouseMoving = false;
	let mouseMovementTimeout;
	const MOUSE_IDLE_THRESHOLD = 300; // ms without movement to consider mouse stopped

	// Initialize with the appropriate shader set for the current page
	$: updateShaderSet(currentPath || $page.url.pathname);

	function updateShaderSet(pathname) {
		if (browser) {
			const shaderSet = getShaderSetForPage(pathname);
			currentShaders = shaderSet.shaders;
			currentColors = shaderSet.colors;
			HARMONIC_RATIOS = shaderSet.harmonic.ratios;
			BASE_CHANGE_INTERVAL = shaderSet.harmonic.baseInterval;
			
			// If the scene is already initialized, regenerate all tiles with new shaders
			if (scene) {
				regenerateTiles();
			}
		}
	}

	function regenerateTiles() {
		// Clear all existing tiles
		for (const [tileKey, tile] of tileCache.entries()) {
			// Clear timer
			if (tileTimers.has(tileKey)) {
				clearTimeout(tileTimers.get(tileKey));
				tileTimers.delete(tileKey);
			}
			
			scene.remove(tile);
			if (tile.material) {
				tile.material.dispose();
			}
			if (tile.geometry) {
				tile.geometry.dispose();
			}
			tileCache.delete(tileKey);
		}
		
		// Recreate visible tiles with new shaders
		updateVisibleTiles();
	}

	init();
	animate();

	function updateShaderUniforms() {
		const elapsedTime = clock.getElapsedTime();

		scene.children.forEach(child => {
			if (child.material instanceof THREE.ShaderMaterial) {
				child.material.uniforms.time.value = elapsedTime;
				child.material.uniforms.mouse.value.x = mouse.x;
				child.material.uniforms.mouse.value.y = mouse.y;
			}
		});
	}

	function init() {
		camera = new THREE.PerspectiveCamera(20, width / height, 1, 2000);
		camera.position.z = 400;
		
		// Initialize target and view center with starting camera position
		targetCameraPosition.x = camera.position.x;
		targetCameraPosition.y = camera.position.y;
		viewCenter.x = camera.position.x;
		viewCenter.y = camera.position.y;

		scene = new THREE.Scene();
		scene.background = new THREE.Color(0x232323);

		// Initialize shader set
		updateShaderSet(currentPath || $page.url.pathname);
		
		updateVisibleTiles();

		renderer = new THREE.WebGLRenderer({ antialias: false });
		renderer.setPixelRatio(window.devicePixelRatio);
		renderer.setSize(width, height);

		onMount(() => {
			container.appendChild(renderer.domElement);
			return cleanup;
		});

		window.addEventListener('mousemove', onDocumentMouseMove);
		window.addEventListener('resize', onWindowResize);
		window.addEventListener('mousedown', onDocumentMouseDown);
		window.addEventListener('mouseup', onDocumentMouseUp);
	}

	function getRandomColor() {
		const colorKeys = Object.keys(currentColors);
		return currentColors[colorKeys[Math.floor(Math.random() * colorKeys.length)]];
	}

	function createTile(x, y) {
		const tileKey = `${x},${y}`;
		
		// If tile already exists, don't create it again
		if (tileCache.has(tileKey)) {
			return tileCache.get(tileKey);
		}
		
		// Get random shader from current shader set
		const shaderKeys = Object.keys(currentShaders);
		const shaderName = shaderKeys[Math.floor(Math.random() * shaderKeys.length)];
		const selectedShader = currentShaders[shaderName];
		
		const shaderMaterial = new THREE.ShaderMaterial({
			vertexShader: commonVertexShader,
			fragmentShader: selectedShader,
			uniforms: {
				...uniformsBase,
				color1: { value: getRandomColor() },
				color2: { value: getRandomColor() },
				color3: { value: getRandomColor() },
				color4: { value: getRandomColor() },
			}
		});

		const plane = new THREE.Mesh(new THREE.PlaneGeometry(PLANE_SIZE, PLANE_SIZE), shaderMaterial);
		plane.position.set(x * TILE_SIZE, y * TILE_SIZE, 0);
		plane.userData = { tileKey };
		scene.add(plane);
		
		// Store in cache
		tileCache.set(tileKey, plane);
		
		// Set up randomized harmonic change interval for this tile
		setupTileChangeTimer(tileKey);
		
		return plane;
	}
	
	function setupTileChangeTimer(tileKey) {
		// Clear any existing timer for this tile
		if (tileTimers.has(tileKey)) {
			clearTimeout(tileTimers.get(tileKey));
		}
		
		// Choose a random harmonic ratio
		const ratio = HARMONIC_RATIOS[Math.floor(Math.random() * HARMONIC_RATIOS.length)];
		const interval = BASE_CHANGE_INTERVAL * ratio;
		
		// Set a timer to change this tile, but only if mouse is moving when the timer triggers
		const timerId = setTimeout(() => {
			if (tileCache.has(tileKey)) {
				// Only change tile if mouse is moving
				if (isMouseMoving) {
					changeTileShader(tileKey);
				}
				// Set up the next change regardless
				setupTileChangeTimer(tileKey);
			}
		}, interval);
		
		tileTimers.set(tileKey, timerId);
	}
	
	function changeTileShader(tileKey) {
		const tile = tileCache.get(tileKey);
		if (!tile) return;
		
		// Get a new random shader from current shader set
		const shaderKeys = Object.keys(currentShaders);
		const shaderName = shaderKeys[Math.floor(Math.random() * shaderKeys.length)];
		const selectedShader = currentShaders[shaderName];
		
		// Dispose of the old material
		if (tile.material) {
			tile.material.dispose();
		}
		
		// Create a new material with the new shader
		const newMaterial = new THREE.ShaderMaterial({
			vertexShader: commonVertexShader,
			fragmentShader: selectedShader,
			uniforms: {
				...uniformsBase,
				time: { value: clock.getElapsedTime() },
				mouse: { value: [mouse.x, mouse.y] },
				color1: { value: getRandomColor() },
				color2: { value: getRandomColor() },
				color3: { value: getRandomColor() },
				color4: { value: getRandomColor() },
			}
		});
		
		// Apply the new material
		tile.material = newMaterial;
	}
	
	function updateVisibleTiles() {
		// Calculate visible range based on camera position
		const centerX = Math.round(camera.position.x / TILE_SIZE);
		const centerY = Math.round(camera.position.y / TILE_SIZE);
		
		// Track which tiles we've updated this cycle
		const updatedTiles = new Set();
		
		// Create visible tiles
		for (let x = centerX - VISIBLE_RANGE; x <= centerX + VISIBLE_RANGE; x++) {
			for (let y = centerY - VISIBLE_RANGE; y <= centerY + VISIBLE_RANGE; y++) {
				const tileKey = `${x},${y}`;
				createTile(x, y);
				updatedTiles.add(tileKey);
			}
		}
		
		// Remove tiles that are now out of view
		for (const [tileKey, tile] of tileCache.entries()) {
			if (!updatedTiles.has(tileKey)) {
				scene.remove(tile);
				if (tile.material) {
					tile.material.dispose();
				}
				if (tile.geometry) {
					tile.geometry.dispose();
				}
				
				// Clear the change timer for this tile
				if (tileTimers.has(tileKey)) {
					clearTimeout(tileTimers.get(tileKey));
					tileTimers.delete(tileKey);
				}
				
				tileCache.delete(tileKey);
			}
		}
	}

	function onWindowResize() {
		width = window.innerWidth;
		height = window.innerHeight;

		camera.aspect = width / height;
		camera.updateProjectionMatrix();

		renderer.setSize(width, height);
	}

	function onDocumentMouseDown(event) {
		isDragging = true;
		previousMousePosition.x = event.clientX;
		previousMousePosition.y = event.clientY;
	}

	function onDocumentMouseMove(event) {
		var clientX = event.clientX;
		var clientY = event.clientY;

		mouse.x = (clientX / window.innerWidth) * 2 - 1;
		mouse.y = -(clientY / window.innerHeight) * 2 + 1;
		
		// Set mouse as moving and reset the timeout
		isMouseMoving = true;
		clearTimeout(mouseMovementTimeout);
		
		// Set a timeout to mark mouse as stopped after threshold
		mouseMovementTimeout = setTimeout(() => {
			isMouseMoving = false;
		}, MOUSE_IDLE_THRESHOLD);

		if (isDragging) {
			const deltaX = event.clientX - previousMousePosition.x;
			const deltaY = event.clientY - previousMousePosition.y;

			// Update camera position for drag movement
			camera.position.x -= deltaX * 0.5;
			camera.position.y += deltaY * 0.5;
			
			// Update target position with camera position during drag
			targetCameraPosition.x = camera.position.x;
			targetCameraPosition.y = camera.position.y;
			
			previousMousePosition.x = event.clientX;
			previousMousePosition.y = event.clientY;
			
			// Update tiles when camera moves
			updateVisibleTiles();
		}
	}

	function onDocumentMouseUp() {
		isDragging = false;
		
		// Update the view center to the current camera position when dragging stops
		viewCenter.x = camera.position.x;
		viewCenter.y = camera.position.y;
	}

	function animate() {
		requestAnimationFrame(animate);
		render();
	}

	function render() {
		updateShaderUniforms();
		
		// Add enhanced mouse influence when not dragging
		if (!isDragging) {
			// Calculate mouse influence relative to the current view center
			// Enhanced cursor effect with larger multiplier (0.25 instead of 0.1)
			const mouseInfluenceX = mouse.x * 0.25;
			const mouseInfluenceY = mouse.y * 0.25;
			
			// Calculate a gentle return force toward view center, not based on camera position
			const returnForceX = (viewCenter.x - camera.position.x) * 0.005;
			const returnForceY = (viewCenter.y - camera.position.y) * 0.005;
			
			// Apply combined influences
			camera.position.x += mouseInfluenceX + returnForceX;
			camera.position.y += mouseInfluenceY + returnForceY;
			
			// Update target position with smooth movement
			targetCameraPosition.x = camera.position.x;
			targetCameraPosition.y = camera.position.y;
			
			updateVisibleTiles();
		}
		
		renderer.render(scene, camera);
	}

	function cleanup() {
		window.removeEventListener('resize', onWindowResize);
		window.removeEventListener('mousemove', onDocumentMouseMove);
		window.removeEventListener('mousedown', onDocumentMouseDown);
		window.removeEventListener('mouseup', onDocumentMouseUp);
		
		// Clear mouse movement timeout
		clearTimeout(mouseMovementTimeout);

		// Clear all timers
		for (const timerId of tileTimers.values()) {
			clearTimeout(timerId);
		}
		tileTimers.clear();

		// Cleanup all tiles
		for (const [tileKey, tile] of tileCache.entries()) {
			if (tile.material) {
				tile.material.dispose();
			}
			if (tile.geometry) {
				tile.geometry.dispose();
			}
		}
		tileCache.clear();

		//cleanup webgl
		renderer.dispose();
		scene.dispose();
	}
</script>

<div bind:this={container} class:geometry={true} />

<style>
	.geometry {
		position: absolute;
		top: 0;
		left:0;
		width: 100%;
		height: 100%;
		display: block; /* Removes potential extra space below the canvas */
		padding: 0;
		margin: 0;
		border: none;
		z-index: -1;
	}
</style>
