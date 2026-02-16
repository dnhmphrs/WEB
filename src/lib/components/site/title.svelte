<script>
  import { onMount } from 'svelte';
  import { screenType } from '$lib/store/store'; // Assuming screenType is correctly set up to identify mobile (1) and desktop (>1)

  let fonts = ['martina-plantijn', 'nb-television-3d', 'nb-architekt', 'nb-television'];
  let text = 'AUFBAU';
  let lastFontChange = Date.now();
  let lastHighlightChange = Date.now();
  let currentFont = 0;
  $: fontChangeInterval = $screenType === 1 ? 80 : 100; // Interval for changing font
  const highlightInterval = 400; // Interval for highlighting text

  onMount(() => {
    const h1Element = document.querySelector('section h1');

    // Desktop functionality
    const handleMouseMove = () => {
      // Change font
      if (Date.now() - lastFontChange > fontChangeInterval) {
        lastFontChange = Date.now();
        currentFont = (currentFont + 1) % fonts.length;
        h1Element.style.fontFamily = fonts[currentFont];
      }

      // Highlight text
      if (Date.now() - lastHighlightChange > highlightInterval) {
        lastHighlightChange = Date.now();
        randomHighlight(h1Element);
      }
    };

    // Continuous effect on mobile
    const continuousEffect = () => {
      // Change font
      if (Date.now() - lastFontChange > fontChangeInterval) {
        lastFontChange = Date.now();
        currentFont = (currentFont + 1) % fonts.length;
        h1Element.style.fontFamily = fonts[currentFont];
      }

      // Highlight text
      if (Date.now() - lastHighlightChange > highlightInterval) {
        lastHighlightChange = Date.now();
        randomHighlight(h1Element);
      }
    };

    // Check screen type and apply respective functionality
    screenType.subscribe(value => {
      if (value === 1) { // Mobile
        setInterval(continuousEffect, Math.min(fontChangeInterval, highlightInterval));
      } else { // Desktop
        window.addEventListener('mousemove', handleMouseMove);
      }
    });

    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
    };
  });

  function randomHighlight(h1Element) {
    let randomStart = Math.floor(Math.random() * text.length);
    let randomLength = Math.floor(Math.random() * (text.length - randomStart));

    let highlightedText = '';
    for (let i = 0; i < text.length; i++) {
      if (i >= randomStart && i < randomStart + randomLength) {
        highlightedText += `<span class="highlight"  style="font-size: 20vw;background:var(--background);color:var(--primary);padding:10px 0;">${text[i]}</span>`;
      } else {
        highlightedText += text[i];
      }
    }

    h1Element.innerHTML = highlightedText;
  }
</script>


<section>
	<h1>AUFBAU</h1>
</section>

<style>
	section {
		padding: 0 0;
		height: 100%;
		width: 100%;
		overflow: hidden;
		display: flex;
		flex-flow: column nowrap;
		justify-content: center;

		align-items: center;
		text-align: center;

		overflow: none;
		user-select: none;
	}

	section h1 {
		font-size: 20vw;
		color: var(--background);
	}

	@media (max-width: 568px) {
    section {
      opacity: 0;
    }
  }
</style>
