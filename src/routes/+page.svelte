<script>
	import { onMount, onDestroy } from 'svelte';
	import { screenType, projects, selectedProject, useMonochrome } from '$lib/store/store';
	import Title from '$lib/components/site/title.svelte';

	let menuOpen = false;

	onMount(() => {
		useMonochrome.set(true);
	});

	onDestroy(() => {
		useMonochrome.set(false);
		selectedProject.set(null);
	});

	function selectProject(project) {
		selectedProject.set(project);
		menuOpen = false;
	}

	function closeProject() {
		selectedProject.set(null);
	}

	function toggleMenu() {
		menuOpen = !menuOpen;
	}
</script>

<!-- Header -->
<header>
	<button class="logo" on:click={closeProject}>AUF<span class="smol">B</span>AU</button>
	
	{#if $screenType === 1}
		<!-- Mobile: hamburger -->
		<button class="menu-toggle" on:click={toggleMenu}>
			{menuOpen ? '✕' : '☰'}
		</button>
	{:else}
		<!-- Desktop: inline project links -->
		<nav>
			{#each projects as project}
				<button 
					class="project-link"
					class:active={$selectedProject?.id === project.id}
					on:click={() => selectProject(project)}
				>
					{project.name}
				</button>
			{/each}
		</nav>
	{/if}
</header>

<!-- Mobile full-page menu -->
{#if $screenType === 1 && menuOpen}
	<div class="mobile-menu">
		<button class="close-menu" on:click={() => menuOpen = false}>✕</button>
		<nav>
			{#each projects as project}
				<button 
					class="mobile-link"
					on:click={() => selectProject(project)}
				>
					{project.name}
				</button>
			{/each}
		</nav>
	</div>
{/if}

<!-- Main content -->
<main>
	{#if $selectedProject}
		<div class="iframe-container">
			<div class="iframe-header">
				<a href="{$selectedProject.url}" class="project-title" target="_blank">{$selectedProject.name} : {$selectedProject.description} </a>
				<button class="close-btn" on:click={closeProject}>✕</button>
			</div>
			<iframe 
				src={$selectedProject.url} 
				title={$selectedProject.name}
				frameborder="0"
				allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
				allowfullscreen
			></iframe>
		</div>
	{:else}
		<!-- Home: Title + About -->
		<Title />
		
		<div class="about-wrapper">
			<div class="fill">
				<h1 style="padding:10px;">D<span class="smol">A</span>NIEL HUMPHRIES</h1>
				<p style="text-align:center;">Freelancer, open to Creative and{#if $screenType !=1}<br>{/if} technical Work with small clients.</p>
				<br>
				<p>graphics + 3d web</p>
				<p>low latency rust systems</p>
				<p>neuroscience, ML, mathematics</p>
				<br>
				<div class="links">
					<p>[</p>
					<a href="/daniel_humphries_cv.pdf">ME</a>
					<p>//</p>
					<a href="mailto: dan@aufbau.io">Email</a>
					<p>]</p>
				</div>
				<h1><span style="font-size: 32px; width: 100%;">🍉</span></h1>
			</div>
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
		color: var(--primary);
		background: none;
		border: none;
		cursor: pointer;
		padding: 0;
		letter-spacing: 0.1em;
	}

	.logo:hover {
		opacity: 0.7;
	}

	/* Desktop nav */
	header nav {
		display: flex;
		gap: 5px;
	}

	.project-link {
		background: none;
		border: none;
		color: var(--primary);
		font-size: 12px;
		letter-spacing: 0.1em;
		cursor: pointer;
		padding: 8px 12px;
	}

	.project-link:hover {
		opacity: 0.7;
	}

	.project-link.active {
		font-weight: 600;
		text-decoration: underline;
		text-underline-offset: 4px;
	}

	/* Mobile hamburger */
	.menu-toggle {
		background: none;
		border: none;
		color: var(--primary);
		font-size: 18px;
		cursor: pointer;
		padding: 5px;
	}

	/* Mobile full-page menu */
	.mobile-menu {
		position: fixed;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
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
		background: none;
		border: none;
		color: var(--primary);
		font-size: 24px;
		cursor: pointer;
	}

	.mobile-menu nav {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 20px;
	}

	.mobile-link {
		background: none;
		border: none;
		color: var(--background);
		font-size: 14px;
		letter-spacing: 0.15em;
		cursor: pointer;
		padding: 10px 20px;
		text-decoration: underline;
		text-underline-offset: 6px;
	}

	.mobile-link:hover {
		opacity: 0.7;
	}

	/* Main content */
	main {
		position: relative;
		width: 100%;
		height: 100%;
		padding-top: 40px;
		display: flex;
		flex-direction: column;
	}

	/* About wrapper */
	.about-wrapper {
		position: absolute;
		top: 50%;
		left: 50%;
		transform: translate(-50%, -50%);
		z-index: 10;
	}

	.fill {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		backdrop-filter: blur(10px);
		border: solid 1px var(--primary);
		padding: 10px 20px;
		min-width: 400px;
	}

	.smol {
		font-family: martina-plantijn;
		font-style: italic;
	}

	.links {
		display: flex;
		flex-direction: row;
		justify-content: center;
		align-items: center;
		gap: 10px;
	}

	.fill h1 {
		font-size: 20px;
		margin: 10px 2px 2px 2px;
		color: var(--primary);
		padding-bottom: 5px;
	}

	.fill a {
		padding: 0 10px;
	}

	.fill a:hover {
		text-underline-offset: 4px;
	}

	/* Iframe container */
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
		border-bottom: 1px solid var(--primary);
	}

	.project-title {
		font-size: 12px;
		letter-spacing: 0.15em;
		color: var(--background);
	}

	.close-btn {
		background: none;
		border: none;
		color: var(--background);
		cursor: pointer;
		font-size: 14px;
		padding: 5px;
	}

	.close-btn:hover {
		opacity: 0.7;
	}

	iframe {
		flex: 1;
		width: 100%;
		height: 100%;
		background: #f0f0f0;
	}

	/* Mobile styles */
	@media (max-width: 768px) {
		header {
			padding: 0 15px;
		}

		.iframe-container {
			margin: 10px;
		}

		.about-wrapper {
			top: 55%;
		}

		.fill {
			min-width: 90vw;
			max-width: 90vw;
		}
	}
</style>