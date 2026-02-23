import { useEffect, useMemo, useState } from "../../external/preact-hooks.mjs";
import {
  debugIt,
  match,
  nodesWithWhitespace,
  query,
} from "../../core/query.js";
import { randomId, objectToString } from "../../utils.js";
import { h, html } from "../../view/widgets.js";
import {
  VitrailPane,
  useTagNode,
  useValidateKeepReplacement,
} from "../vitrail.ts";
import { SBNode } from "../../core/model.js";
import { languageFor } from "../../core/languages.js";
import { removeCommonIndent } from "./whitespace.ts";

export const watch = (model) => ({
  type: "replace" as const,
  model,
  match: match((capture) => [
    query(`["sbWatch", $expression][1]`),
    (it) => it.expression,
    capture("expression"),
    nodesWithWhitespace,
    capture("expressions"),
  ]),
  matcherDepth: 15,
  view: ({ replacement, expressions, expression }) => {
    const [count, setCount] = useState(0);
    const [lastValue, setLastValue] = useState("");

    useRuntimeValues(expression, (value) => {
      setCount((c) => c + 1);
      setLastValue(objectToString(value));
    });
    useValidateKeepReplacement(replacement);
    const augs = useMemo(() => [removeCommonIndent(expressions)], expressions);

    return html`<div
      style=${{
        padding: "0.25rem",
        background: "#333",
        display: "inline-block",
        borderRadius: "4px",
        margin: "0 0.15rem",
      }}
    >
      <${VitrailPane}
        nodes=${expressions}
        fetchAugmentations=${() => augs}
        style=${{
          padding: "0.1rem",
          background: "#fff",
          display: "inline-block",
        }}
      />
      <div style=${{ color: "#fff", display: "flex", marginTop: "0.25rem" }}>
        ${lastValue}
      </div>
    </div>`;
  },
});

const USE_LOCAL_JS = true;
export const invisibleWatchRewrite = (model) => ({
  name: "invisible-watch",
  type: "rewrite" as const,
  model,
  match: (node) => (node.hasTag("viWatch") ? { node } : null),
  view: ({ node }) => {
    const port = 7921;

    for (const id of node.getAllTagDataFor("viWatch")) {
      if (
        node.language === languageFor("javascript") ||
        node.language === languageFor("typescript")
      ) {
        if (USE_LOCAL_JS) {
          const prefix = `["viWatch",((e) => (window.sbWatch(e, ${id})))(`;
          const suffix = `),][1]`;
          node.wrapWith(prefix, suffix);
        } else {
          const url = `${window.location.origin}/sb-watch`;
          const headers = `headers: {"Content-Type": "application/json"}`;
          const opts = `{method: "POST", body: JSON.stringify({id: ${id}, e}), ${headers},}`;
          const prefix = `["viWatch",((e) => (fetch("${url}", ${opts}), e))(`;
          const suffix = `),][1]`;

          if (node.parent.type === "formal_parameter") {
            node.parent.parent
              .firstOfType("statement_block")
              .insert(0, "statement", `${prefix}${node.text}${suffix}`);
          } else {
            node.wrapWith(prefix, suffix);
          }
        }
      } else if (node.language === languageFor("python")) {
        node.wrapWith(
          `(lambda e: ((lambda s: (
          s.connect(("localhost", ${port})),
          s.send(__import__("json").dumps({"id":${id},"e":e},default=str).encode()),
          s.close())
        )(__import__("socket").socket()), e))(`,
          ")[1]",
        );
      }
    }
  },
});

export function useRuntimeValues(
  node: SBNode | SBNode[] | undefined,
  onValue: (value: any) => void,
) {
  if (Array.isArray(node)) {
    const nonWhiteSpace = node.filter((n) => !n.isWhitespace());
    if (nonWhiteSpace.length !== 1) throw new Error("need a single node");
    node = nonWhiteSpace[0];
  }

  const id = useMemo(() => randomId(), []);

  useTagNode(node, "viWatch", id);
  useEffect(() => {
    (window as any).sbWatch.registry.set(id, onValue);
    return () => (window as any).sbWatch.registry.delete(id);
  }, [id, onValue]);
}

(window as any).sbWatch = function (value, id) {
  (window as any).sbWatch.registry.get(id)?.(value);
  return value;
};
(window as any).sbWatch.registry = new Map();
