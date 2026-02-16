<script>
	import './styles.css';

	import { browser } from '$app/environment';
	import { page } from '$app/stores';
	import { webVitals } from '$lib/vitals';

	import { onMount } from 'svelte';
	import { screenType, isIframe, screenSize } from '$lib/store/store';
	import { getDeviceType, getScreenSize } from '$lib/functions/utils';

	import Footer from '$lib/components/footer/footer.svelte';

	export let data;
	let Geometry;

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

	onMount(async () => {
		// webgl
		const module = await import('$lib/graphics/three.svelte');
		Geometry = module.default;

		handleScreen();
		window.addEventListener('resize', () => handleScreen());

		// releasr opacity block once geometry is loaded
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

{#if Geometry}
    <svelte:component this={Geometry} />
{:else}
    <div class="loading">loading.</div>
{/if}

<main>
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
	}

	footer {
		position: absolute;
		bottom: 0;
		width: 100%;
	}

	body {
		display: flex;
		flex-direction: column;
		overflow: hidden;
		/* padding: calc(1 * var(--margin)); */
		width: 100%;
		height: 100%;
		background: none;
	}

	.loading {
		position: absolute;
		font-style: italic;
		font-family: serif;
		top: 50%;
		left: 50%;
		transform: translate(-50%, -50%);
		padding: 10px;
		font-size: 12px;
	}
</style>
