/// <reference types="../wat.d.ts" />
import init from './main.wat'
const instance = await init({})
console.log(instance.exports)

document.querySelector('#app').innerHTML = `<pre>
     add(2, 3) = ${instance.exports.add(2, 3)}
divmod(152, 9) = ${instance.exports.divmod(152, 9)}
 factorial(10) = ${instance.exports.factorial(10)}
fibbonacci(10) = ${instance.exports.fibbonacci(10)}
</pre>`

console.log(Array.from({ length: 100 }, (_, i) => instance.exports.isPrime(i) ? i : 0).filter((n) => !!n))

try {
	instance.exports.exception()
} catch (err) {
	console.log('exception:', err, err.getArg(instance.exports.errtag, 0))
}
