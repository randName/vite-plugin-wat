import wabt from 'wabt'

export type CompileOptions = {
	builtins?: string[]
	importedStringConstants?: string
}

export type WasmFeatures = NonNullable<
	Parameters<Awaited<ReturnType<typeof wabt>>['parseWat']>[2]
>

declare module '*.wat' {
	function init(
		importObject?: WebAssembly.Imports,
		compileOptions?: CompileOptions
	): Promise<WebAssembly.Instance>
	export default init
}
