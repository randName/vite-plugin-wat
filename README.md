# Vite plugin for WAT (WebAssembly Text) files

## Usage

no package, just copy `watPlugin.js` and install [`jco`](https://github.com/bytecodealliance/jco) (e.g. `npm i -D @bytecodealliance/jco`)

```js
// vite.config.js
import { defineConfig } from 'vite'
import wat from './watPlugin.js'

export default defineConfig({
  plugins: [wat()],
})

```

```js
// main.js
import init from './foo.wat'
const instance = await init()
instance.exports.add(1, 2) // 3
```

```wat
;; foo.wat
(module
  (func (export "foo") (param i32 i32) (result i32)
    (i32.add (local.get 0) (local.get 1))
  )
)
```

## Useful resources

- [WASM intro](https://rsms.me/wasm-intro)
- [Understanding WAT](https://developer.mozilla.org/en-US/docs/WebAssembly/Guides/Understanding_the_text_format)
- [WASM by hand](https://github.com/rhmoller/wasm-by-hand)
- [`wasm-tools`](https://github.com/bytecodealliance/wasm-tools)
- [`wasm-tools parse` demo](https://bytecodealliance.github.io/wasm-tools/parse)
- [WebAssembly Binary Toolkit](https://github.com/WebAssembly/wabt)
