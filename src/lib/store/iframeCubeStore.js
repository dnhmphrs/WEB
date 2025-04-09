import { writable } from 'svelte/store';

// List of available demo websites
export const availableSites = [
    { name: 'SvelteKit', url: 'https://kit.svelte.dev/docs/introduction' },
    { name: 'Three.js', url: 'https://threejs.org/docs/#manual/en/introduction/Creating-a-scene' },
    { name: 'Example.com', url: 'http://example.com/' },
    { name: 'Wikipedia', url: 'https://en.wikipedia.org/wiki/Main_Page' },
    { name: 'Google', url: 'https://www.google.com/webhp?igu=1' }, // igu=1 bypasses some framing restrictions
    { name: 'DuckDuckGo', url: 'https://duckduckgo.com' } 
];

// Store for the 4 currently selected sites for the cube faces (Front, Back, Left, Right)
// Initialize with the first 4 available sites
export const selectedSites = writable(availableSites.slice(0, 4).map(site => site.url));

// Helper function to update a site at a specific index
export function updateSite(index, url) {
    selectedSites.update(currentSites => {
        const newSites = [...currentSites];
        if (index >= 0 && index < 4) {
            newSites[index] = url;
        }
        return newSites;
    });
} 