<script>
	import { onMount, onDestroy } from 'svelte';
	import { screenType, projects, selectedProject } from '$lib/store/store';
	import Title from '$lib/components/site/title.svelte';

	let menuOpen = false;
	let iframeLoading = false;

	onDestroy(() => selectedProject.set(null));

	function selectProject(project) {
		if ($selectedProject?.id === project.id) return;
		iframeLoading = true;
		selectedProject.set(project);
		menuOpen = false;
	}

	function closeProject() {
		selectedProject.set(null);
	}
</script>

<header>
	<button class="logo" on:click={closeProject}>AUF<span class="alt">B</span>AU</button>
	
	{#if $screenType === 1}
		<button class="menu-toggle" on:click={() => menuOpen = !menuOpen}>
			{menuOpen ? '✕' : '☰'}
		</button>
	{:else}
		<nav>
			{#each projects as project}
				<button 
					class:active={$selectedProject?.id === project.id}
					on:click={() => selectProject(project)}
				>{project.name}</button>
			{/each}
		</nav>
	{/if}
</header>

{#if $screenType === 1 && menuOpen}
	<div class="mobile-menu">
		<button class="close-menu" on:click={() => menuOpen = false}>✕</button>
		<nav>
			{#each projects as project}
				<button on:click={() => selectProject(project)}>{project.name}</button>
			{/each}
		</nav>
	</div>
{/if}

<main>
	{#if $selectedProject}
		<div class="iframe-container">
			<div class="iframe-header">
				<a href={$selectedProject.url} target="_blank">{$selectedProject.name} : {$selectedProject.description}</a>
				<button on:click={closeProject}>✕</button>
			</div>
			{#if $selectedProject.displayIframe}
				<div class="iframe-wrap">
					{#if iframeLoading}
						<div class="loading"><p>...</p></div>
					{/if}
					<iframe 
						src={$selectedProject.url} 
						title={$selectedProject.name}
						on:load={() => iframeLoading = false}
					></iframe>
				</div>
			{:else}
				<div class="blocked">
					<p>iframe blocked by site</p>
					<a href={$selectedProject.url} target="_blank">{$selectedProject.url}</a>
				</div>
			{/if}
		</div>
	{:else}
		<Title />
		<div class="about">
			<h1>D<span class="alt">A</span>NIEL HUMPHRIES</h1>
			<p>Freelancer, open to Creative and{#if $screenType !== 1}<br>{/if} technical Work with small clients.</p>
			<br>
			<p>graphics + 3d web</p>
			<p>low latency rust systems</p>
			<p>neuroscience, ML, mathematics</p>
			<br>
			<div class="links">
				<span>[</span>
				<a href="/daniel_humphries_cv.pdf">ME</a>
				<span>//</span>
				<a href="mailto:dan@aufbau.io">Email</a>
				<span>]</span>
			</div>
			<span class="emoji">🍉</span>
		</div>
	{/if}
</main>

<style>
	/* Header */
	header {
		position: fixed;
		top: 0;
		left: 0;
		right: 0;
		height: 40px;
		backdrop-filter: blur(10px);
		border-bottom: 1px solid var(--primary);
		display: flex;
		align-items: center;
		justify-content: space-between;
		padding: 0 20px;
		z-index: 100;
	}

	.logo {
		font-family: var(--font-header);
		font-size: 16px;
	}

	header nav {
		display: flex;
		gap: 5px;
	}

	header nav button {
		font-size: 12px;
		padding: 8px 12px;
	}

	header nav button.active {
		font-weight: 600;
		text-decoration: underline;
		text-underline-offset: 4px;
	}

	.menu-toggle { font-size: 18px; }

	/* Mobile menu */
	.mobile-menu {
		position: fixed;
		inset: 0;
		backdrop-filter: blur(10px);
		z-index: 200;
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		gap: 10px;
	}

	.close-menu {
		position: absolute;
		top: 15px;
		right: 20px;
		font-size: 24px;
	}

	.mobile-menu nav {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 20px;
	}

	.mobile-menu nav button {
		font-size: 14px;
		padding: 10px 20px;
		text-decoration: underline;
		text-underline-offset: 6px;
	}

	/* Main */
	main {
		position: relative;
		width: 100%;
		height: 100%;
		padding-top: 40px;
		display: flex;
		flex-direction: column;
	}

	/* About */
	.about {
		position: absolute;
		top: 50%;
		left: 50%;
		transform: translate(-50%, -50%);
		z-index: 10;
		display: flex;
		flex-direction: column;
		align-items: center;
		backdrop-filter: blur(10px);
		border: 1px solid var(--primary);
		padding: 10px 20px;
		min-width: 400px;
		text-align: center;
	}

	.about h1 {
		font-size: 20px;
		padding: 10px;
	}

	.alt {
		font-family: martina-plantijn;
		font-style: italic;
	}

	.links {
		display: flex;
		align-items: center;
		gap: 10px;
	}

	.links a { padding: 0 10px; }
	.emoji { font-size: 32px; margin-top: 10px; }

	/* Iframe */
	.iframe-container {
		flex: 1;
		display: flex;
		flex-direction: column;
		margin: 10px;
		border: 1px solid var(--primary);
		backdrop-filter: blur(10px);
		z-index: 1;
	}

	.iframe-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 5px 15px;
	}

	.iframe-header a { font-size: 12px; }

	.iframe-wrap {
		flex: 1;
		position: relative;
		display: flex;
	}

	.iframe-wrap iframe {
		flex: 1;
		width: 100%;
		height: 100%;
		border: none;
		background: var(--background);
	}

	.loading, .blocked {
		position: absolute;
		inset: 0;
		background: var(--background);
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		gap: 15px;
	}

	.blocked {
		background: none;
		backdrop-filter: blur(10px);
	}

	.loading p, .blocked p {
		font-size: 10px;
		opacity: 0.7;
	}

	.blocked a {
		text-decoration: underline;
		text-underline-offset: 4px;
	}

	/* Shared button styles */
	button {
		background: none;
		border: none;
		color: var(--primary);
		cursor: pointer;
		letter-spacing: 0.1em;
	}

	button:hover, a:hover { opacity: 0.7; }

	/* Mobile */
	@media (max-width: 568px) {
		header { padding: 0 15px; }
		.about {
			min-width: 90vw;
			max-width: 90vw;
			backdrop-filter: none;
		}
	}
</style>