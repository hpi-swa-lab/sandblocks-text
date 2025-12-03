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
import { invisibleWatchRewrite } from "./vitrail/tools/watch.ts";
import { languageFor } from "./core/languages.js";

function Demo() {
  const value = useSignal("hello");

  return h(CodeMirrorWithVitrail, {
    value,
    fetchAugmentations: () => [
      invisibleWatchRewrite(languageFor("javascript")),
    ],
    cmExtensions: [
      ...baseCMExtensions,
      javascript(),
      // , drawSelection()
    ],
  });
}

render(h(Demo), document.body);
