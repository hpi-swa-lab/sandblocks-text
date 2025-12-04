import { h } from "../../external/preact.mjs";
import { debugIt, match, query } from "../../core/query.js";
import { bindPlainString } from "../../core/bindings.ts";
import { baseCMExtensions, CodeMirrorWithVitrail } from "../codemirror6.ts";
import { sql as cmSql } from "../../external/codemirror6/codemirror.bundle.js";

export const sql = (model) => ({
  type: "replace" as const,
  matcherDepth: 3,
  model,
  match: match((capture) => [
    query("sql`$_string`"),
    (x) => x.string,
    bindPlainString,
    capture("string"),
    capture("nodes"),
  ]),
  view: ({ string: { text, onLocalChange } }) => {
    const source = {
      get value() {
        return text;
      },
      set value(_) {},
    };

    return h(CodeMirrorWithVitrail, {
      onchange: (e) =>
        e.detail.changes.forEach((c) => onLocalChange?.(c, true)),
      fetchAugmentations: () => [],
      value: source,
      cmExtensions: [cmSql(), ...baseCMExtensions],
      style: { display: "inline-block" },
      className: "no-padding",
    });
  },
});
