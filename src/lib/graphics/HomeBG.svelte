<script>
	import { onMount, onDestroy } from 'svelte';

	// Simple placeholder background for now
	let container;
	let canvas;
	let resizeHandler;
	let mounted = false;

	// Export the cleanup function for the component manager
	export function cleanup() {
		if (resizeHandler) {
			window.removeEventListener('resize', resizeHandler);
			resizeHandler = null;
		}
		
		if (canvas && container && container.contains(canvas)) {
			container.removeChild(canvas);
			canvas = null;
		}
		
		mounted = false;
	}

	onMount(() => {
		mounted = true;
		// Here you would implement your home page specific background
		// This is a placeholder that you can replace with your actual home experience
		canvas = document.createElement('canvas');
		container.appendChild(canvas);
		
		// Simple canvas gradient background as placeholder
		const ctx = canvas.getContext('2d');
		
		resizeHandler = () => {
			if (!mounted || !canvas) return;
			
			canvas.width = window.innerWidth;
			canvas.height = window.innerHeight;
			
			// Create gradient
			const gradient = ctx.createLinearGradient(0, 0, canvas.width, canvas.height);
			gradient.addColorStop(0, '#1a2a6c');
			gradient.addColorStop(0.5, '#b21f1f');
			gradient.addColorStop(1, '#fdbb2d');
			
			ctx.fillStyle = gradient;
			ctx.fillRect(0, 0, canvas.width, canvas.height);
		};
		
		resizeHandler();
		window.addEventListener('resize', resizeHandler);
		
		return cleanup;
	});
	
	onDestroy(() => {
		cleanup();
	});
</script>

<div bind:this={container} class="home-background"></div>

<style>
	.home-background {
		position: absolute;
		top: 0;
		left: 0;
		width: 100%;
		height: 100%;
		z-index: -1;
	}
</style> 