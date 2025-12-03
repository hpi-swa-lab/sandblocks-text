import { h, render } from "../external/preact.mjs";
import { appendCss } from "../utils.js";
import {
  CodeMirrorWithVitrail,
  baseCMExtensions,
} from "../vitrail/codemirror6.ts";
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
} from "../codemirror6/external/codemirror.bundle.js";

function Demo() {
  const value = useSignal("");

  return h(CodeMirrorWithVitrail, {
    value,
    fetchAugmentations: () => [],
    cmExtensions: [
      ...cmExtensions,
      ...baseCMExtensions,
      // , drawSelection()
    ],
  });
}

render(Demo(), document.body);
