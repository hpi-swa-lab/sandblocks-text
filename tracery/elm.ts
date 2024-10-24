import { minimize } from "../core/diff.js";
import { languageFor } from "../core/languages.js";
import { useSignal } from "../external/preact-signals.mjs";
import { h } from "../external/preact.mjs";
import { useValidator } from "../vitrail/vitrail.ts";

export const elm = {
  name: "elm",
  type: "insert" as const,
  model: languageFor("elm"),
  match: (it) => (it.isRoot ? {} : null),
  view: () => {
    const lastChange = useSignal(null);
    useValidator(
      languageFor("elm"),
      (_root, diff, _changes) => {
        console.log(minimize(diff));
        return false;
      },
      [],
    );

    return h("div", {
      style: {
        display: "flow",
        flowDirection: "column",
        boxShadow: "0 4px 8px 0 rgba(0,0,0,0.2)",
        padding: "1rem",
      },
    });
  },
};
