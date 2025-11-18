/// <reference types="./wat.d.ts" />
import init from './main.wat'
const memory = new WebAssembly.Memory({ initial: 1 })
const decoder = new TextDecoder()
const instance = await init({
	env: {
		memory,
		/**
		 * @param {number} p
		 * @param {number} s
		 */
		log: (p, s) => {
			console.log(decoder.decode(memory.buffer.slice(p, p + s)))
		},
	}
})

console.log(instance.exports.factorial(5))
console.log(instance.exports.divmod(152))
