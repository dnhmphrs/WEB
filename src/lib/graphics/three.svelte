<script>
	import { onMount } from 'svelte';
	import { screenType } from '$lib/store/store';
	import { page } from '$app/stores';
	// import { afterNavigate } from '$app/navigation';

	import * as THREE from 'three';

	import vertexShader from './shaders/vertexShader-three.glsl';
	import fragmentShader_aufbau from './shaders/fragmentShader-aufbau.glsl';
	import fragmentShader_niels from './shaders/fragmentShader-niels.glsl';
	import fragmentShader_raum from './shaders/fragmentShader-raum.glsl';
	import fragmentShader_closed_loop from './shaders/fragmentShader-closed-loop.glsl';
	import fragmentShader_new from './shaders/fragmentShader-new.glsl';
	import fragmentShader_garret from './shaders/fragmentShader-garrett.glsl';

	let isDragging = false;
	let previousMousePosition = { x: 0, y: 0 };
	
	// For better mouse influence tracking
	let targetCameraPosition = { x: 0, y: 0 };
	let viewCenter = { x: 0, y: 0 };

	const uniformsBase = {
		time: { value: 0 },
		mouse: { value: [0.0,0.0] }
	};

	const colors = {
   color1: new THREE.Color(0xff6b6b), // Playful Red
   color2: new THREE.Color(0xffd93d), // Playful Yellow
   color3: new THREE.Color(0x6bcbef), // Playful Light Blue
   color4: new THREE.Color(0x32a852), // Playful Green
   color5: new THREE.Color(0x995d81), // Playful Mauve
   color6: new THREE.Color(0xed6663), // Playful Coral
   color7: new THREE.Color(0x4b89dc), // Playful Blue
   color8: new THREE.Color(0xf0a07c), // Playful Peach
}

	const shaders = {
    aufbau: fragmentShader_aufbau,
    niels: fragmentShader_niels,
    raum: fragmentShader_raum,
    closed_loop: fragmentShader_closed_loop,
		new: fragmentShader_new,
		garrett: fragmentShader_garret,
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
	
	// Harmonic timing for tile changes
	const HARMONIC_RATIOS = [1, 2, 3/2, 4/3, 5/3, 5/4, 6/5, 8/5, 10/6]; // Harmonic ratios
	const BASE_CHANGE_INTERVAL = 2000; // Base interval in milliseconds
	
	// Track tile change timers
	const tileTimers = new Map();
	
	// Mouse movement detection for changes
	let isMouseMoving = false;
	let mouseMovementTimeout;
	const MOUSE_IDLE_THRESHOLD = 300; // ms without movement to consider mouse stopped

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

	function createTile(x, y) {
		const tileKey = `${x},${y}`;
		
		// If tile already exists, don't create it again
		if (tileCache.has(tileKey)) {
			return tileCache.get(tileKey);
		}
		
		const shaderName = Object.keys(shaders)[Math.floor(Math.random() * Object.keys(shaders).length)];
		const shaderMaterial = new THREE.ShaderMaterial({
			vertexShader: vertexShader,
			fragmentShader: shaders[shaderName],
			uniforms: {
				...uniformsBase,
				color1: { value: colors[Object.keys(colors)[Math.floor(Math.random() * Object.keys(colors).length)]] },
				color2: { value: colors[Object.keys(colors)[Math.floor(Math.random() * Object.keys(colors).length)]] },
				color3: { value: colors[Object.keys(colors)[Math.floor(Math.random() * Object.keys(colors).length)]] },
				color4: { value: colors[Object.keys(colors)[Math.floor(Math.random() * Object.keys(colors).length)]] },
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
		
		// Get a new random shader
		const shaderName = Object.keys(shaders)[Math.floor(Math.random() * Object.keys(shaders).length)];
		
		// Dispose of the old material
		if (tile.material) {
			tile.material.dispose();
		}
		
		// Create a new material with the new shader
		const newMaterial = new THREE.ShaderMaterial({
			vertexShader: vertexShader,
			fragmentShader: shaders[shaderName],
			uniforms: {
				...uniformsBase,
				time: { value: clock.getElapsedTime() },
				mouse: { value: [mouse.x, mouse.y] },
				color1: { value: colors[Object.keys(colors)[Math.floor(Math.random() * Object.keys(colors).length)]] },
				color2: { value: colors[Object.keys(colors)[Math.floor(Math.random() * Object.keys(colors).length)]] },
				color3: { value: colors[Object.keys(colors)[Math.floor(Math.random() * Object.keys(colors).length)]] },
				color4: { value: colors[Object.keys(colors)[Math.floor(Math.random() * Object.keys(colors).length)]] },
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
