<script>
    import { screenType } from '$lib/store/store';
    // import Title from '$lib/components/site/title.svelte';
</script>

<!-- <Title /> -->

<body>
  <p>hi</p>
</body>

<style>
  body {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);

    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    height: 100vh;
    color: var(--primary);

  }
</style>