import { defineConfig } from 'vite'
import wabtInit from 'wabt'

/** @returns {Promise<import('vite').Plugin>} */
async function wat() {
	const watFileRegex = /\.wat$/
	const wabtModule = await wabtInit()
	const importHelper = `import initWasm from "\0vite/wasm-helper.js"`

	return {
		name: 'wat-loader',
		transform: {
			filter: { id: watFileRegex },
			handler(code, id) {
				if (!watFileRegex.test(id)) return null
				try {
					const parsed = wabtModule.parseWat(id, code)
					parsed.validate()
					const bin = parsed.toBinary({ write_debug_names: true })
					const b64 = btoa(String.fromCodePoint.apply(undefined, bin.buffer))
					const data = JSON.stringify(`data:application/wasm;base64,${b64}`)
					return {
						code: `${importHelper};export default opt=>initWasm(opt,${data})`,
					}
				} catch (err) {
					return {
						code: `export default ()=>{throw new Error(${JSON.stringify(err.message)})}`,
					}
				}
			},
		},
	}
}

export default defineConfig({
	plugins: [
		//
		await wat(),
	],
})
