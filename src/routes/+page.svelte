<script>
	// import { screenType } from '$lib/store/store'; // Keep if needed, commented out for now
	// import Title from '$lib/components/site/title.svelte';
	import { selectedSites, availableSites, updateSite } from '$lib/store/iframeCubeStore';

	const faceLabels = ['Front', 'Back', 'Left', 'Right'];

	function handleChange(event, index) {
		const newUrl = event.target.value;
		updateSite(index, newUrl);
	}
</script>

<!-- <Title /> -->

<div class="controls-container">
	{#each $selectedSites as selectedUrl, index}
		<div class="control-group">
			<label for={`face-${index}`}>{faceLabels[index]}:</label>
			<select id={`face-${index}`} value={selectedUrl} on:change={(e) => handleChange(e, index)}>
				{#each availableSites as site}
					<option value={site.url}>{site.name}</option>
				{/each}
			</select>
		</div>
	{/each}
</div>

<style>
	.controls-container {
		position: absolute;
		top: var(--margin, 20px); /* Use margin variable from global styles */
		left: var(--margin, 20px);
		background-color: var(--background-50, rgba(35, 35, 35, 0.5)); /* Use background with transparency */
		padding: 10px 15px;
		border: var(--border, 1px solid #232323); /* Use border from global, fallback */
		z-index: 10; 
		font-family: var(--font-body, sans-serif); /* Use body font */
		color: var(--primary, #d0d0d0);
		max-width: 250px;
	}

	.control-group {
		display: flex;
		align-items: center;
		margin-bottom: 8px;
	}
	.control-group:last-child {
		margin-bottom: 0;
	}

	.control-group label {
		font-family: var(--font-header, serif); /* Use header font for labels */
		min-width: 45px;
		margin-right: 10px;
		font-size: 14px; /* Slightly larger */
		color: var(--primary);
	}

	.control-group select {
		padding: 4px 6px;
		flex-grow: 1;
		background-color: var(--background, #232323);
		color: var(--primary, #d0d0d0);
		border: 1px solid var(--primary-50, rgba(208, 208, 208, 0.5));
		font-family: var(--font-body, sans-serif);
		font-size: 12px;
		outline: none;
	}
	
	/* Styling for options */
	.control-group select option {
		background-color: var(--background, #232323);
		color: var(--primary, #d0d0d0);
	}
</style>