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
    h(Browser, {
      files: [
        {
          name: "index.html",
          content: `class MyClass {
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
}

class OtherClass {
  constructor() {
    this.numberField = 10;
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
    h('h2', {}, 'Editing Scenarios'),
    'Below, we show program snippets that demonstrate the capabilities of the editing API. The snippets are evaluated and the result of the last expression is shown below the snippet.',

    h('h3', {}, 'Replace Atom inserts Parentheses to comply with Precedence'),
    h(LiveEvalEditor, { initialText: `const stmt = languageFor("javascript").parseOffscreen('a + 4').children[0]
const identifierA = stmt.children[0].children[0]
identifierA.replaceWith('2 + 3')

stmt.sourceString // we expect: (2 + 3) * 4` }),

    h('h3', {}, 'Wrapping Expressions'),
    h(LiveEvalEditor, { initialText: `const stmt = languageFor("javascript").parseOffscreen('3 + 4').children[0]
const op = stmt.children[0]
op.wrapWith('[', ']')

stmt.sourceString // we expect: [3 + 4]` }),

    h('h3', {}, 'Insert Adds Delimiters'),
    h(LiveEvalEditor, { initialText: `const stmt = languageFor("javascript").parseOffscreen('[2, 4, 5]').children[0]
const array = stmt.children[0]
array.insert('3', 'expression', 1)

stmt.sourceString // we expect: [2, 3,4, 5] (use of a code formatter for JavaScript would add a whitespace)` }),

    h('h3', {}, 'Delete Cleans Up Delimiters'),
    h(LiveEvalEditor, { initialText: `const stmt = languageFor("javascript").parseOffscreen('[2, 5, 3]').children[0]
const array = stmt.children[0]
const number = array.childBlocks[1]
number.removeFull()

stmt.sourceString // we expect: [2, 3]` }),
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

  return h("div", {style: 'border: 1px solid gray; padding: 0.5rem'},
    h(CodeMirrorWithVitrail, {
      value: text,
      fetchAugmentations: () => jsAugmentations,
      cmExtensions: [...baseCMExtensions, javascript()],
    }),
    h("div", {}, "Eval: " + result.value),
  );
}

render(h(Demo), document.body);
