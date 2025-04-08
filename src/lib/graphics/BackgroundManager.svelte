<script>
	import { onMount, onDestroy } from 'svelte';
	import { page } from '$app/stores';
	
	// Import dynamically to avoid loading unused components
	let ThreeBG;
	let HomeBG;
	let activeComponent = null;
	let isLoading = true;
	let currentPath = '';
	
	// Setup for cleanup - this will hold either the component instance or its cleanup function
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
	
	// Load the appropriate background based on the current route
	$: if ($page.url.pathname !== currentPath) {
		currentPath = $page.url.pathname;
		loadBackgroundComponent(currentPath);
	}
	
	async function loadBackgroundComponent(pathname) {
		isLoading = true;
		
		// Run cleanup for current component if it exists
		executeCleanup();
		
		// Reset active component and cleanup reference
		activeComponent = null;
		cleanupRef = null;
		
		try {
			// Home page
			if (pathname === '/') {
				if (!HomeBG) {
					const homeModule = await import('./HomeBG.svelte');
					HomeBG = homeModule.default;
				}
				activeComponent = HomeBG;
			} 
			// About page or any other page (404, etc.)
			else if (pathname === '/about' || pathname.includes('/about/') || !pathname.match(/^\/[a-zA-Z0-9\-_]+\/?$/)) {
				if (!ThreeBG) {
					const threeModule = await import('./AboutBG.svelte');
					ThreeBG = threeModule.default;
				}
				activeComponent = ThreeBG;
			}
			// Other specific routes can be added here
			else {
				// Default to home background for other routes
				if (!HomeBG) {
					const homeModule = await import('./HomeBG.svelte');
					HomeBG = homeModule.default;
				}
				activeComponent = HomeBG;
			}
		} catch (e) {
			console.error('Error loading background:', e);
			// Fallback to home background on error
			if (!HomeBG) {
				try {
					const homeModule = await import('./HomeBG.svelte');
					HomeBG = homeModule.default;
					activeComponent = HomeBG;
				} catch (fallbackError) {
					console.error('Fatal error loading fallback background:', fallbackError);
				}
			} else {
				activeComponent = HomeBG;
			}
		}
		
		isLoading = false;
	}
	
	onDestroy(() => {
		executeCleanup();
	});
</script>

{#if isLoading}
	<div class="loading">loading.</div>
{:else if activeComponent}
	<svelte:component this={activeComponent} bind:this={cleanupRef} />
{/if}

<style>
	.loading {
		position: absolute;
		font-style: italic;
		font-family: serif;
		top: 50%;
		left: 50%;
		transform: translate(-50%, -50%);
		padding: 10px;
		font-size: 12px;
		z-index: -1;
	}
</style> 