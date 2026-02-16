<script>
	import { onMount } from 'svelte';
	import { screenType, selectedProject } from '$lib/store/store';
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
	let isProjectActive = false;

	// Subscribe to selectedProject changes
	$: isProjectActive = $selectedProject !== null;

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

		scene = new THREE.Scene();
		scene.background = new THREE.Color(0x232323);

		// setupShaderMaterials();
		assignShadersRandomly();

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
		window.addEventListener('mousemove', onDocumentMouseMove);
		window.addEventListener('mouseup', onDocumentMouseUp);
		window.addEventListener('keydown', onSpacebar);
		window.addEventListener('click', onSpacebar);
		window.addEventListener('touchstart', onSpacebar);
		// window.addEventListener('navigate', onNavigate);
	}

	function assignShadersRandomly() {
		// remove all shaders if they exist
		scene.children.forEach(child => {
			if (child.material instanceof THREE.ShaderMaterial) {
				scene.remove(child);
			}
		});


    // Define the grid size and positions
		const no_rows = 20;
    const gridSize = { rows: no_rows, cols: no_rows }; // Example grid size
    const gridPositions = [];

    // Populate grid positions
    for (let row = 0; row < gridSize.rows; row++) {
        for (let col = 0; col < gridSize.cols; col++) {
					gridPositions.push({ x: col * 60 - no_rows * 30 + 30, y: row * 60 - no_rows * 30 + 30 });
        }
    }

    // Randomly assign shaders to grid positions
    gridPositions.forEach(position => {
        const shaderName = Object.keys(shaders)[Math.floor(Math.random() * Object.keys(shaders).length)];
        const shaderMaterial = new THREE.ShaderMaterial({
            vertexShader: vertexShader,
            fragmentShader: shaders[shaderName],
            uniforms: {
                ...uniformsBase,
								// random colours from colours dict
                color1: { value: colors[Object.keys(colors)[Math.floor(Math.random() * Object.keys(colors).length)]] },
								color2: { value: colors[Object.keys(colors)[Math.floor(Math.random() * Object.keys(colors).length)]] },
								color3: { value: colors[Object.keys(colors)[Math.floor(Math.random() * Object.keys(colors).length)]] },
								color4: { value: colors[Object.keys(colors)[Math.floor(Math.random() * Object.keys(colors).length)]] },
            }
        });

        // Create and position the plane
				const plane_size = 110;
        const plane = new THREE.Mesh(new THREE.PlaneGeometry(plane_size, plane_size), shaderMaterial);
        plane.position.set(position.x, position.y, 0);
        scene.add(plane);
    });
}


	function onWindowResize() {
		let width = window.innerWidth;
		let height = window.innerHeight;

		camera.aspect = width / height;
		camera.updateProjectionMatrix();

		renderer.setSize(width, height);
	}

	function onDocumentMouseDown(event) {
		if (isProjectActive) return;
    isDragging = true;
    previousMousePosition.x = event.clientX;
    previousMousePosition.y = event.clientY;
}

	function onDocumentMouseMove(event) {
		if (isProjectActive) return;
		
		var clientX = event.clientX;
		var clientY = event.clientY;

		mouse.x = (clientX / window.innerWidth) * 2 - 1;
		mouse.y = -(clientY / window.innerHeight) * 2 + 1;

		if (true) { // if (isDragging) {
        const deltaX = event.clientX - previousMousePosition.x;
        const deltaY = event.clientY - previousMousePosition.y;

        // Update camera or scene position
        camera.position.x += deltaX * 0.15; camera.position.y += deltaY * 0.15;

        previousMousePosition.x = event.clientX;
        previousMousePosition.y = event.clientY;
    }
	}

	function onDocumentMouseUp() {
    isDragging = false;
	}

	function onSpacebar(event) {
		if (isProjectActive) return;
		// Only trigger on spacebar for keydown events
		if (event.type === 'keydown' && event.code !== 'Space') return;
		assignShadersRandomly();
	}


	function animate() {
		requestAnimationFrame(animate);
		render();
	}

	function render() {
		updateShaderUniforms();
		renderer.render(scene, camera);
	}

	function cleanup() {
		window.removeEventListener('resize', onWindowResize);
		window.removeEventListener('navigate', onNavigate);
		window.removeEventListener('mousemove', onDocumentMouseMove);
		window.removeEventListener('mousedown', onDocumentMouseDown);
		window.removeEventListener('mouseup', onDocumentMouseUp);
		window.removeEventListener('keydown', onSpacebar);
		window.removeEventListener('click', onSpacebar);
		window.removeEventListener('touchstart', onSpacebar);

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