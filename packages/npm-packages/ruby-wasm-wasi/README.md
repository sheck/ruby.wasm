# @ruby/wasm-wasi

[![npm version](https://badge.fury.io/js/@ruby%2Fwasm-wasi.svg)](https://www.npmjs.com/package/@ruby/wasm-wasi)

This package provides core APIs for Ruby on WebAssembly targeting WASI-compatible environments. WebAssembly binaries are distributed in version-specific packages.

See [Cheat Sheet](https://github.com/ruby/ruby.wasm/blob/main/docs/cheat_sheet.md) for how to use this package.

## Ruby Version Support

| Version | Package                                            |
| ------- | -------------------------------------------------- |
| `head`  | [`@ruby/head-wasm-wasi`](./../ruby-head-wasm-wasi) |
| `3.2`   | [`@ruby/3.2-wasm-wasi`](./../ruby-3.2-wasm-wasi)   |

## API

<!-- Generated by documentation.js. Update this documentation by updating the source code. -->

### RubyVM

A Ruby VM instance

#### Examples

```javascript
const wasi = new WASI();
const vm = new RubyVM();
const imports = {
  wasi_snapshot_preview1: wasi.wasiImport,
};

vm.addToImports(imports);

const instance = await WebAssembly.instantiate(rubyModule, imports);
await vm.setInstance(instance);
wasi.initialize(instance);
vm.initialize();
```

#### initialize

Initialize the Ruby VM with the given command line arguments

##### Parameters

- `args` The command line arguments to pass to Ruby. Must be
  an array of strings starting with the Ruby program name. (optional, default `["ruby.wasm","--disable-gems","-EUTF-8","-e_=0"]`)

#### setInstance

Set a given instance to interact JavaScript and Ruby's
WebAssembly instance. This method must be called before calling
Ruby API.

##### Parameters

- `instance` The WebAssembly instance to interact with. Must
  be instantiated from a Ruby built with JS extension, and built
  with Reactor ABI instead of command line.

#### addToImports

Add intrinsic import entries, which is necessary to interact JavaScript
and Ruby's WebAssembly instance.

##### Parameters

- `imports` The import object to add to the WebAssembly instance

#### printVersion

Print the Ruby version to stdout

#### eval

Runs a string of Ruby code from JavaScript

##### Parameters

- `code` The Ruby code to run

##### Examples

```javascript
vm.eval("puts 'hello world'");
const result = vm.eval("1 + 2");
console.log(result.toString()); // 3
```

Returns **any** the result of the last expression

#### evalAsync

Runs a string of Ruby code with top-level `JS::Object#await`
Returns a promise that resolves when execution completes.

##### Parameters

- `code` The Ruby code to run

##### Examples

```javascript
const text = await vm.evalAsync(`
  require 'js'
  response = JS.global.fetch('https://example.com').await
  response.text.await
`);
console.log(text.toString()); // <html>...</html>
```

Returns **any** a promise that resolves to the result of the last expression

#### wrap

Wrap a JavaScript value into a Ruby JS::Object

##### Parameters

- `value` The value to convert to RbValue

##### Examples

```javascript
const hash = vm.eval(`Hash.new`);
hash.call("store", vm.eval(`"key1"`), vm.wrap(new Object()));
```

Returns **any** the RbValue object representing the given JS value

### RbValue

A RbValue is an object that represents a value in Ruby

#### call

Call a given method with given arguments

##### Parameters

- `callee` name of the Ruby method to call
- `args` **...any** arguments to pass to the method. Must be an array of RbValue

##### Examples

```javascript
const ary = vm.eval("[1, 2, 3]");
ary.call("push", 4);
console.log(ary.call("sample").toString());
```

#### toPrimitive

- **See**: <https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/Symbol/toPrimitive>

##### Parameters

- `hint` Preferred type of the result primitive value. `"number"`, `"string"`, or `"default"`.

#### toString

Returns a string representation of the value by calling `to_s`

#### toJS

Returns a JavaScript object representation of the value
by calling `to_js`.

Returns null if the value is not convertible to a JavaScript object.

### RbError

**Extends Error**

Error class thrown by Ruby execution

### RbFatalError

**Extends RbError**

Error class thrown by Ruby execution when it is not possible to recover.
This is usually caused when Ruby VM is in an inconsistent state.
