<script>
	import './styles.css';

	import { browser } from '$app/environment';
	import { page } from '$app/stores';
	import { webVitals } from '$lib/vitals';

	import { onMount } from 'svelte';
	import { screenType, isIframe, screenSize } from '$lib/store/store';
	import { getDeviceType, getScreenSize } from '$lib/functions/utils';

	import Header from '$lib/components/header/header.svelte';
	import Footer from '$lib/components/footer/footer.svelte';
	import BackgroundManager from '$lib/graphics/BackgroundManager.svelte';

	export let data;

	$: if (browser && data?.analyticsId) {
		webVitals({
			path: $page.url.pathname,
			params: $page.params,
			analyticsId: data.analyticsId
		});
	}

	function handleScreen() {
		// screen size
		screenSize.set(getScreenSize());

		// device type
		screenType.set(getDeviceType());
		isIframe.set(window.location !== window.parent.location);
	}

	onMount(() => {
		handleScreen();
		window.addEventListener('resize', () => handleScreen());

		// Release opacity block once mounted
		document.querySelector('main').style.opacity = 1;

		return () => {
			window.removeEventListener('resize', () => handleScreen());
		};
	});
</script>

<svelte:head>
	<title>MAKE WEB FUN AGAIN</title>
	<meta
		name="description"
		content="Der logische Aufbau der Web."
	/>
	<meta
		name="keywords"
		content="AUFBAU, Creative, Freelance, Freelancer, Web, Websites, Apps, Shaders, Graphics, WebGL, WebGPU, Rust, Developer, Engineer, Engineering, Development, London, Dan Humphries, Daniel Humphries, UCL, Neuroscience, Mathematics, Machine Learning, ML"
	/>
	<meta name="author" content="AUFBAU" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0" />
</svelte:head>

<!-- Background manager will load the appropriate background based on the route -->
<BackgroundManager />

<main>
	<header>
		<Header />
	</header>

	<body>
		<slot />
	</body>

	{#if $screenType==3}
	<footer>
		<Footer />
	</footer>
	{/if}
	
</main>

<style>
	main {
		display: flex;
		flex-direction: column;
		height: 100dvh;
		max-height: 100vh;
		background: none;
		opacity: 0;
		overflow: hidden;
		position: relative;
		pointer-events: none;
		z-index: 1;
	}

	header {
		position: absolute;
		top: 0;
		width: 100%;
		z-index: 1;
		pointer-events: auto;
	}

	footer {
		position: absolute;
		bottom: 0;
		width: 100%;
		pointer-events: auto;
	}

	body {
		display: flex;
		flex-direction: column;
		overflow: hidden;
		/* padding: calc(1 * var(--margin)); */
		width: 100%;
		height: 100%;
		background: none;
		pointer-events: none;
	}
</style>
