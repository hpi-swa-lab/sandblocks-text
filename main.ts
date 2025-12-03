import { h, render } from "./external/preact.mjs";
import {
  CodeMirrorWithVitrail,
  baseCMExtensions,
} from "./vitrail/codemirror6.ts";
import { useSignal } from "./external/preact-signals.mjs";
import {
  drawSelection,
  lineNumbers,
  keymap,
  javascript,
  cpp,
  python,
  sql as cmSql,
  markdown,
} from "./external/codemirror6/codemirror.bundle.js";
import { invisibleWatchRewrite, watch } from "./vitrail/tools/watch.ts";
import { languageFor } from "./core/languages.js";

const jsAugmentations = [
  invisibleWatchRewrite(languageFor("javascript")),
  watch(languageFor("javascript")),
];

function Demo() {
  const value = useSignal('a + ["sbWatch", 2 + 2][1]');

  return h(CodeMirrorWithVitrail, {
    value,
    fetchAugmentations: () => jsAugmentations,
    cmExtensions: [...baseCMExtensions, javascript()],
  });
}

render(h(Demo), document.body);
