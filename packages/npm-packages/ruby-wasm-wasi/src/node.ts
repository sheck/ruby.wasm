import { WASI } from "wasi";
import { RubyVM } from "./index.js";

export const DefaultRubyVM = async (
  rubyModule: WebAssembly.Module,
  options: { env?: Record<string, string> | undefined } = {},
) => {
  const wasi = new WASI({ env: options.env });
  const vm = new RubyVM();
  const imports = {
    wasi_snapshot_preview1: wasi.wasiImport,
  };

  vm.addToImports(imports);

  const instance = await WebAssembly.instantiate(rubyModule, imports);

  await vm.setInstance(instance);

  wasi.initialize(instance);
  vm.initialize();

  return {
    vm,
    wasi,
    instance,
  };
};
