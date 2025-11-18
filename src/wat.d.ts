declare module '*.wat' {
	function init(importObject?: WebAssembly.Imports): Promise<WebAssembly.Instance>
	export default init
}