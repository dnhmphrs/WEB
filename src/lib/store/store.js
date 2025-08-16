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

export const page = writable("dummy"); // for geometry