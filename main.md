<script>

// Import from dist/external to match the bundle's imports
import { h, render } from "./dist/external/preact.mjs";
import { useSignal, useSignalEffect } from "./dist/external/preact-signals.mjs";
import {
  lineNumbers,
  javascript,
  cpp,
  python,
  sql as cmSql,
  markdown,
} from "./dist/external/codemirror6/codemirror.bundle.js";

// Import from built library bundle
import {
  setConfig,
  CodeMirrorWithVitrail,
  baseCMExtensions,
  invisibleWatchRewrite,
  watch,
  languageFor,
  placeholder,
  sql,
  color,
  slider,
  safeEval,
  Browser,
} from "./dist/sandblocks.js";

// Create pane element first
var pane = document.createElement('div');

// Set base URL
setConfig({
  baseURL: "http://localhost:9005/sandblocks-text-artifact/"
});


function Demo() {
  // Create augmentations inside the component
  const jsAugmentations = [
    invisibleWatchRewrite(languageFor("javascript")),
    watch(languageFor("javascript")),
    placeholder(languageFor("javascript")),
    sql(languageFor("javascript")),
    slider(languageFor("javascript")),
    color(languageFor("javascript")),
  ];
  const placeholderValue = useSignal(`function __VI_PLACEHOLDER_functionName() {
  __VI_PLACEHOLDER_body
}`);
  console.log("placeholderValue initial:", placeholderValue.value);

  const composingValue = useSignal(
    "db.execute(sql`SELECT \\`name\\` FROM \\`users\\``);",
  );

  const watchValue = useSignal('3 + ["sbWatch", 2 + 2][1]');
  const watchEditor = useSignal(null);
  useSignalEffect(() => {
    // TODO not rewritten yet on startup
    watchValue.value; // subscribe to changes
    safeEval(watchEditor.value?.rewrittenSourceString);
  });

  const livelitValue = useSignal(`let baseline = ["slider", 0, 110, 1, 30][4];
let color = ["color", baseline + 140, 3, ["slider", 0, 255, 1, 25][4]];`);
  const livelitEditor = useSignal(null);
  useSignalEffect(() => {
    // TODO not rewritten yet on startup
    livelitValue.value; // subscribe to changes
    safeEval(livelitEditor.value?.rewrittenSourceString);
  });

  return [
    h("h2", {}, "Watch"),
    h(CodeMirrorWithVitrail, {
      value: watchValue,
      onLoad: (v) => (watchEditor.value = v),
      fetchAugmentations: () => jsAugmentations,
      cmExtensions: [...baseCMExtensions, javascript()],
    }),

    h("h2", {}, "Placeholder"),
    h(CodeMirrorWithVitrail, {
      value: placeholderValue,
      fetchAugmentations: () => jsAugmentations,
      cmExtensions: [...baseCMExtensions, javascript()],
    }),

    h("h2", {}, "Composing Languages"),
    h(CodeMirrorWithVitrail, {
      value: composingValue,
      fetchAugmentations: () => jsAugmentations,
      cmExtensions: [...baseCMExtensions, javascript()],
    }),

    h("h2", {}, "Browser"),
    h("p", {}, "TODO: press add button, indent marker missing at start"),
    h(Browser, {
      files: [
        {
          name: "index.html",
          content: `class MyCls {
  numberField

  constructor() {
    this.numberField = 10;
  }

  someMethod() {
    console.log("someMethod called");
  }

  otherMethod() {
    console.log("otherMethod called");
  }
}`,
          path: "sample.js",
        },
      ],
    }),

    h("h2", {}, "Livelits"),
    h(CodeMirrorWithVitrail, {
      value: livelitValue,
      onLoad: (v) => (livelitEditor.value = v),
      fetchAugmentations: () => jsAugmentations,
      cmExtensions: [...baseCMExtensions, javascript()],
    }),
  ];
}

render(h(Demo), pane);

// Copy sandblocks CSS into pane for shadow DOM compatibility
document.querySelectorAll('style[data-sandblocks-css]').forEach(style => {
  pane.appendChild(style.cloneNode(true));
});

// Copy CodeMirror 6 dynamically generated styles (they contain .ͼ classes)
// We need to wait a bit for CodeMirror to inject its styles
setTimeout(() => {
  document.head.querySelectorAll('style').forEach(style => {
    if (style.textContent.includes('.ͼ')) {
      pane.appendChild(style.cloneNode(true));
    }
  });
}, 100);

pane
</script>