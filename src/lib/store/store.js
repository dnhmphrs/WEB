import { writable } from 'svelte/store';

export const userType = writable(null);
export const screenType = writable(null);
export const isIframe = writable(true);

export const DARK_PAGES = ['/ml-network'];
export const darkMode = writable(false);

export const lobbySelected = writable(false);
export const mouseOnLink = writable(false);

export const mousePosition = writable({ x: 0, y: 0, z: 0 });
export const screenSize = writable({ width: 0, height: 0 });

// Projects data
export const projects = [
    {
		id: 'daniel',
		name: 'DANIEL',
		year: 2026,
		description: 'Personal Webpage',
		url: 'https://danielniels.co.uk/',
		displayIframe: true
	},
	{
		id: 'garrett',
		name: 'GARRETT',
		year: 2024,
		description: 'Portfolio landing Page',
		url: 'https://garrettmusar.work/',
		displayIframe: true
	},
	// {
	// 	id: 'glide-globe',
	// 	name: 'GLIDE-GLOBE',
	// 	year: 2024,
	// 	description: '3d Globe Component',
	// 	url: 'https://www.glideapps.com/experts-program',
	// 	displayIframe: false
	// },
	{
		id: 'quasicrystal',
		name: 'Quasicrystal',
		year: 2024,
		description: 'Digital Art',
		url: 'https://quasicrystal.aufbau.io/',
		displayIframe: true
	},
	{
		id: 'birds',
		name: 'BIRDS',
		year: 2025,
		description: 'Digital art / Flocking sim',
		url: 'https://birds.aufbau.io/',
		displayIframe: true
	},
];

// Currently selected project
export const selectedProject = writable(null);

// Whether to use monochrome palette (for home page)
export const useMonochrome = writable(false);