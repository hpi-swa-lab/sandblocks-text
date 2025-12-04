// Library entry point - exports all modules needed by main.js
export { CodeMirrorWithVitrail, baseCMExtensions } from "./vitrail/codemirror6.ts";
export { invisibleWatchRewrite, watch } from "./vitrail/tools/watch.ts";
export { languageFor } from "./core/languages.js";
export { placeholder } from "./vitrail/tools/placeholder.ts";
export { sql } from "./vitrail/tools/sql.ts";
export { color, slider } from "./vitrail/tools/livelits.ts";
export { safeEval } from "./utils.js";
export { Browser } from "./vitrail/tools/browser.ts";
export { setConfig } from "./core/config.js";
