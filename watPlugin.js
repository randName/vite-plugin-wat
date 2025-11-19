import path from 'node:path'
import wabtInit from 'wabt'

/**
 * @param {string} b64
 * @param {WebAssembly.Imports} [importObject]
 * @param {import('./wat').CompileOptions} [compileOptions]
 */
const watHelper = async (b64, importObject, compileOptions) => {
	const arr = Uint8Array.from(globalThis.atob(b64), (x) => x.codePointAt(0))
	const mod = await WebAssembly.instantiate(arr, importObject, compileOptions)
	return mod.instance
}

/**
 * @param {import('./wat').WasmFeatures} [features]
 * @returns {import('vite').Plugin}
 */
export const wat = (features) => {
	/** @type {import('vite').ResolvedConfig} */
	let config

	const watHelperId = '\0virtual:wat-helper.js'
	const watHelperCode = watHelper.toString()
	const watHelperRegex = /^\0virtual\:wat-helper\.js$/
	const watFileRegex = /\.wat$/
	const wabtPromise = wabtInit()

	/**
	 * @param {string} fn
	 * @param {string | Uint8Array} src
	 */
	const compile = async (fn, src) => {
		const parsed = (await wabtPromise).parseWat(fn, src, features)
		parsed.validate()
		const bin = parsed.toBinary({ write_debug_names: true })
		return bin.buffer
	}

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
			}
		},
		transform: {
			filter: { id: watFileRegex },
			async handler(code, id) {
				if (!watFileRegex.test(id)) return null
				try {
					const buf = await compile(path.basename(id), code)
					const b64 = JSON.stringify(btoa(String.fromCodePoint.apply(undefined, buf)))
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
