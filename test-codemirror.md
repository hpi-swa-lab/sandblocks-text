# Test CodeMirror 6

This is a simple test to verify CodeMirror 6 loads correctly.

<script>
import { h, render } from "./dist/external/preact.mjs";
import { useSignal } from "./dist/external/preact-signals.mjs";
import { javascript } from "./dist/external/codemirror6/codemirror.bundle.js";
import { setConfig, CodeMirrorWithVitrail, baseCMExtensions } from "./dist/sandblocks.js";

// Set base URL for module resolution
setConfig({ baseURL: "./" });

function SimpleEditor() {
  const value = useSignal(`function hello() {
  console.log("Hello from CodeMirror 6!");
  return 42;
}`);

  return h("div", { style: "border: 1px solid #ccc; padding: 10px;" },
    h("h3", {}, "CodeMirror 6 Editor Test"),
    h(CodeMirrorWithVitrail, {
      value: value,
      fetchAugmentations: () => [],
      cmExtensions: [...baseCMExtensions, javascript()],
    })
  );
}

// Create a container, render into it, and it becomes the last statement
const container = document.createElement("div");
render(h(SimpleEditor), container);
container;
</script>
