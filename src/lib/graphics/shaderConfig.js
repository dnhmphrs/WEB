import * as THREE from 'three';

// Import all shader fragments
import vertexShader from './shaders/vertexShader-three.glsl';

import fragmentShader_aufbau from './shaders/about/fragmentShader-aufbau.glsl';
import fragmentShader_niels from './shaders/about/fragmentShader-niels.glsl';
import fragmentShader_raum from './shaders/about/fragmentShader-raum.glsl';
import fragmentShader_closed_loop from './shaders/about/fragmentShader-closed-loop.glsl';
import fragmentShader_new from './shaders/about/fragmentShader-new.glsl';
import fragmentShader_garret from './shaders/about/fragmentShader-garrett.glsl';

import fragmentShader_terminal from './shaders/home/fragmentShader-terminal.glsl';

// Define color palettes for different pages
export const colorPalettes = {
  // Vibrant colors for about page (now also default)
  about: {
    color1: new THREE.Color(0xff6b6b), // Playful Red
    color2: new THREE.Color(0xffd93d), // Playful Yellow
    color3: new THREE.Color(0x6bcbef), // Playful Light Blue
    color4: new THREE.Color(0x32a852), // Playful Green
    color5: new THREE.Color(0x995d81), // Playful Mauve
    color6: new THREE.Color(0xed6663), // Playful Coral
    color7: new THREE.Color(0x4b89dc), // Playful Blue
    color8: new THREE.Color(0xf0a07c), // Playful Peach
  },
  
  // Terminal/punchcard colors for home page
  home: {
    color1: new THREE.Color(0xfafafa), // Terminal Green
    color2: new THREE.Color(0xf0f0f0), // Bright Terminal Highlight
  }
};

// Common vertex shader for all pages
export const commonVertexShader = vertexShader;

// Define shader sets for different pages
export const shaderSets = {
  // About page - uses all current shaders
  'about': {
    shaders: {
      aufbau: fragmentShader_aufbau,
      niels: fragmentShader_niels,
      raum: fragmentShader_raum,
      closed_loop: fragmentShader_closed_loop,
      new: fragmentShader_new,
      garrett: fragmentShader_garret,
    },
    colors: colorPalettes.about,
    harmonic: {
      ratios: [1, 2, 3/2, 4/3, 5/3, 5/4, 6/5, 8/5, 10/6],
      baseInterval: 2000
    }
  },
  
  // Home page - uses single terminal shader
  'home': {
    shaders: {
      terminal: fragmentShader_terminal,
    },
    colors: colorPalettes.home,
    harmonic: {
      ratios: [1, 2, 3/2, 4/3],
      baseInterval: 3000
    }
  }
};

// Function to get the shader set based on the current page path
export function getShaderSetForPage(pagePath) {
  if (pagePath === '/' || pagePath === '') {
    return shaderSets.home;
  } else {
    // Use 'about' as the default for all other pages
    return shaderSets.about;
  }
} 