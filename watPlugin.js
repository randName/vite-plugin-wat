import { parse } from '@bytecodealliance/jco'

/**
 * @param {string} b64
 * @param {WebAssembly.Imports} [importObject]
 * @param {WebAssembly.WebAssemblyCompileOptions} [compileOptions]
 */
const watHelper = async (b64, importObject, compileOptions) => {
	const arr =
		'fromBase64' in Uint8Array
			? Uint8Array.fromBase64(b64)
			: Uint8Array.from(globalThis.atob(b64), (x) => x.codePointAt(0))
	const mod = await WebAssembly.instantiate(arr, importObject, compileOptions)
	return mod.instance
}

/**
 * @returns {import('vite').Plugin}
 */
export const wat = () => {
	/** @type {import('vite').ResolvedConfig} */
	let config

	const watHelperId = '\0virtual:wat-helper.js'
	const watHelperCode = watHelper.toString()
	const watHelperRegex = /^\0virtual\:wat-helper\.js$/
	const watFileRegex = /\.wat$/

	return {
		name: 'wat-loader',
		configResolved(resolvedConfig) {
			config = resolvedConfig
		},
		resolveId: {
			filter: { id: watHelperRegex },
			handler(id) {
				return id
			},
		},
		load: {
			filter: { id: [watHelperRegex] },
			handler(id) {
				if (id === watHelperId) return `export default ${watHelperCode}`
			},
		},
		transform: {
			filter: { id: watFileRegex },
			async handler(code, id) {
				if (!watFileRegex.test(id)) return null
				try {
					const buf = await parse(code)
					const b64 = JSON.stringify(toBase64(buf))
					return {
						code: `import _i from "${watHelperId}";export default (o,c)=>_i(${b64},o,c)`,
					}
				} catch (error) {
					this.environment.logger.error(error.message, {
						error,
						clear: true,
						timestamp: true,
					})
					return `export default ()=>{throw new Error(${JSON.stringify(error.message)})}`
				}
			},
		},
	}
}

export default wat

/**
 * polyfill for `Uint8Array.prototype.toBase64`
 * @param {Uint8Array} arr
 */
function toBase64(arr) {
	let binary = ''
	for (let i = 0; i < arr.length; i += 0x8000) {
		binary += String.fromCodePoint(...arr.subarray(i, i + 0x8000))
	}
	return globalThis.btoa(binary)
}
