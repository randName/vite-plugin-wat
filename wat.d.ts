export type CompileOptions = {
	builtins?: string[]
	importedStringConstants?: string
}

declare module '*.wat' {
	function init(
		importObject?: WebAssembly.Imports,
		compileOptions?: CompileOptions
	): Promise<WebAssembly.Instance>
	export default init
}
