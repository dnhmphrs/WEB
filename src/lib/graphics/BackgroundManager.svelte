<script>
	import { onMount, onDestroy } from 'svelte';
	import { browser } from '$app/environment';
	import AboutBG from './AboutBG.svelte';
	
	let activeComponent = AboutBG;
	let cleanupRef = null;
	
	// Function to safely execute cleanup
	function executeCleanup() {
		if (!cleanupRef) return;
		
		try {
			// If cleanupRef is a function, call it directly
			if (typeof cleanupRef === 'function') {
				cleanupRef();
			} 
			// If it has a cleanup method, call that
			else if (cleanupRef && typeof cleanupRef.cleanup === 'function') {
				cleanupRef.cleanup();
			}
		} catch (e) {
			console.warn('Cleanup error:', e);
		}
	}
	
	onDestroy(() => {
		executeCleanup();
	});
</script>

{#if browser}
	<div class="background-wrapper">
		<svelte:component this={activeComponent} bind:this={cleanupRef} />
	</div>
{/if}

<style>
	.background-wrapper {
		position: absolute;
		top: 0;
		left: 0;
		width: 100%;
		height: 100%;
		z-index: -1;
		pointer-events: auto; /* Allow events to pass through to the canvas */
	}
</style> 