declare module '*.wat' {
	function init(
		importObject?: WebAssembly.Imports,
		compileOptions?: WebAssembly.WebAssemblyCompileOptions,
	): Promise<WebAssembly.Instance>
	export default init
}
