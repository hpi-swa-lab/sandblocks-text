import { h, render } from "./external/preact.mjs";
import {
  CodeMirrorWithVitrail,
  baseCMExtensions,
} from "./vitrail/codemirror6.ts";
import { useSignal, useSignalEffect } from "./external/preact-signals.mjs";
import {
  lineNumbers,
  javascript,
  cpp,
  python,
  sql as cmSql,
  markdown,
} from "./external/codemirror6/codemirror.bundle.js";
import { invisibleWatchRewrite, watch } from "./vitrail/tools/watch.ts";
import { languageFor } from "./core/languages.js";
import { placeholder } from "./vitrail/tools/placeholder.ts";
import { sql } from "./vitrail/tools/sql.ts";
import { color, slider } from "./vitrail/tools/livelits.ts";
import { safeEval } from "./utils.js";
import { Browser } from "./vitrail/tools/browser.ts";

const jsAugmentations = [
  invisibleWatchRewrite(languageFor("javascript")),
  watch(languageFor("javascript")),
  placeholder(languageFor("javascript")),
  sql(languageFor("javascript")),
  slider(languageFor("javascript")),
  color(languageFor("javascript")),
];

// expose for eval()
window.languageFor = languageFor;
await languageFor("python").ready();
await languageFor("javascript").ready();

function Demo() {
  const placeholderValue = useSignal(`function __VI_PLACEHOLDER_functionName() {
  __VI_PLACEHOLDER_body
}`);

  const composingValue = useSignal(
    "db.execute(sql`SELECT \\`name\\` FROM \\`users\\``);",
  );

  const watchValue = useSignal('3 + ["sbWatch", 2 + 2][1] * 4');
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

    h(EditingScenarios),
  ];
}

function EditingScenarios() {
  return [
    h('h3', {}, 'Replace with precedence'),
    h(LiveEvalEditor, { initialText: `const program = languageFor("python").parseOffscreen('a * 4')
const identifierA = program.children[0].children[0]
identifierA.replaceWith('2 + 3')
program.sourceString` }),
  ]
}

function LiveEvalEditor({ initialText }) {
  const text = useSignal(initialText);
  const result = useSignal("");
  useSignalEffect(() => {
    try {
      result.value = eval(text.value).toString();
    } catch (error) {
      result.value = error.toString();
    }
  });

  return [
    h(CodeMirrorWithVitrail, {
      value: text,
      fetchAugmentations: () => jsAugmentations,
      cmExtensions: [...baseCMExtensions, javascript()],
    }),
    h("div", {}, "Result: " + result.value),
  ];
}

render(h(Demo), document.body);
