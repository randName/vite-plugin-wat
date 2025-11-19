import { defineConfig } from 'vite'
import wat from './watPlugin.js'

export default defineConfig({
	plugins: [
		wat({
			tail_call: true,
			exceptions: true,
		}),
	],
})
