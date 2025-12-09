/// <reference types="../wat.d.ts" />
import init from './math.wat'

const mainMemory = new WebAssembly.Memory({ initial: 1 })
const mat4Memory = new WebAssembly.Memory({ initial: 1 })

const instance = await init({
	Math,
	memory: {
		main: mainMemory,
		mat4: mat4Memory
	},
	console: { log: (...a) => console.log(a)}
})

console.log(instance.exports)

const mem = new Float32Array(mainMemory.buffer)

mem.set([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1])
mem.set([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16], 16)

instance.exports.mat4mul(0, 16 * 4, 32 * 4)

document.querySelector('#app').innerHTML = `<pre>
${Array.from({ length: 5 }, (_, i) => mem.slice(i * 16, i * 16 + 16).join(' ')).join('\n')}
</pre>`
