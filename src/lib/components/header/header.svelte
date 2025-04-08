<script>
	import { page } from '$app/stores';
	import { screenType } from '$lib/store/store';
</script>

<header>

	<!-- {#if $screenType==3}
	<h1 style="padding-right:10px;">PRESS SPACEBAR</h1>
	{/if} -->
	
	{#if $page.url.pathname == '/'}
	<a href='/about'><h1 style="padding-left:10px;">ABOUT // CONTACT</h1></a>
	{:else }
	<a href='/'><h1 style="padding-left:10px;min-width: 200px;">HOME<span style="font-size: 20px; margin-left: 100px;">↝</span></h1></a>
	{/if}

</header>

<style>
	header {
		user-select: none;
		color: var(--primary);
		display: flex;
		justify-content: flex-end;
	}

	h1 {
		font-size: 20px;
		padding: 2px;
		color:var(--primary);
		background: var(--background);
		
	}

	a:hover {
		text-underline-offset: 4px;
	}
</style>
