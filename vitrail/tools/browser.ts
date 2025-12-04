import { useMemo, useRef } from "../../external/preact-hooks.mjs";
import { useSignal, useSignalEffect } from "../../external/preact-signals.mjs";
import { h } from "../../external/preact.mjs";
import { List } from "./list.js";
import { appendCss, clamp, last, takeWhile } from "../../utils.js";
import { outline } from "./outline.ts";
import { removeCommonIndent } from "./whitespace.ts";
import {
  SelectionInteraction,
  useValidateKeepNodes,
  useValidator,
  useVitrailProps,
  VitrailPane,
} from "../vitrail.ts";
import {
  baseCMExtensions,
  CodeMirrorWithVitrail,
  PaneFacet,
} from "../codemirror6.ts";
import {
  javascript,
  lineNumbers,
} from "../../external/codemirror6/codemirror.bundle.js";
import { SBLanguage, SBNode } from "../../core/model.js";
import { languageFor } from "../../core/languages.js";

appendCss(`
.browser-editor {
  display: flex;
  height: 200px;
  flex: 1 1 0;
  width: 100%;
}
.browser-editor > .cm-editor {
  width: 100%;
}

.pane-full-width > .cm-editor {
  width: 100%;
  height: 100%;
}`);

const emptyList = [];

export function Browser({ files, initialSelection }) {
  const fileContent = useSignal("");
  const selectedFile = useSignal(
    initialSelection
      ? files.find((it) => it.path === initialSelection.path)
      : files[0],
  );
  const topLevelEntries = useSignal([]);
  const selectedTopLevel = useSignal(null);
  const selectedMember = useSignal(null);
  const vitrail = useSignal(null);

  const selectedIndex = useRef(0);

  const getModel = () => vitrail.value.defaultModel;
  const getRoot = () => vitrail.value.getModels().get(getModel());
  const getOutline = () => outline(getRoot());

  let selectedNodes = selectedMember.value ?? selectedTopLevel.value;
  // TODO same for selectedMember
  if (selectedNodes && !selectedNodes[0].connected) {
    selectedTopLevel.value = topLevelEntries.value
      ? topLevelEntries.value[
          clamp(selectedIndex.value, 0, topLevelEntries.value.length - 1)
        ]?.nodes
      : null;
    selectedNodes = selectedTopLevel.value;
  }

  const selectedTopLevelItem = topLevelEntries.value?.find(
    (e) => e.nodes[0] === selectedTopLevel.value?.[0],
  );
  const selectedMemberItem = selectedTopLevelItem?.members?.find(
    (e) => e.nodes[0] === selectedMember.value?.[0],
  );
  selectedIndex.value = topLevelEntries.value.indexOf(selectedTopLevelItem);

  const removeIndentAug = useMemo(
    () => removeCommonIndent(selectedNodes ?? []),
    selectedNodes ?? [],
  );
  const singleDeclarationAug = useMemo(
    () => singleDeclaration(languageFor("javascript")),
    [],
  );

  useSignalEffect(() => {
    fileContent.value = selectedFile.value?.content ?? "";
  });
  useValidator(
    vitrail.value && getModel(),
    (_root, _diff, _changes) => !selectedNodes || !!selectedNodes[0].connected,
    [...(selectedNodes ?? [])],
    vitrail,
  );

  return h(
    "div",
    { style: { display: "flex", flexDirection: "column", flex: "1 1 0" } },
    h(
      "div",
      { style: { display: "flex" } },
      h(List, {
        style: { flex: 1, maxWidth: "250px" },
        items: files,
        iconFunc: (it) => "symbol-file",
        selected: selectedFile.value,
        setSelected: (s) => (selectedFile.value = s),
        labelFunc: (it) => it.path,
        height: 200,
        selectionContext: { path: selectedFile.value?.path },
      }),
      h(
        "div",
        {
          style: {
            flex: 1,
            maxWidth: "250px",
            display: "flex",
            flexDirection: "column",
          },
        },
        h(List, {
          style: { flex: 1 },
          items: topLevelEntries.value,
          selected: selectedTopLevelItem,
          setSelected: (s) => {
            selectedTopLevel.value = s.nodes;
            selectedMember.value = null;
          },
          labelFunc: (it) => it.name,
          height: 200,
          selectionContext: {
            path: selectedFile.value?.path,
            topLevel: selectedTopLevelItem?.name,
          },
        }),
        h(
          "button",
          {
            onClick: () => {
              const node = getRoot().insert(
                "__VI_PLACEHOLDER_statement;",
                "statement",
                0,
              );
              selectedTopLevel.value = getOutline().find(({ nodes }) =>
                nodes.includes(node),
              ).nodes;
            },
          },
          "Add",
        ),
      ),
      h(
        "div",
        {
          style: {
            flex: 1,
            maxWidth: "250px",
            display: "flex",
            flexDirection: "column",
          },
        },
        h(List, {
          style: { flex: 1, maxWidth: "250px" },
          items: selectedTopLevelItem?.members ?? emptyList,
          selected: selectedMemberItem,
          setSelected: (s) => (selectedMember.value = s.nodes),
          labelFunc: (it) => it.name,
          height: 200,
          selectionContext: {
            path: selectedFile.value?.path,
            topLevel: selectedTopLevelItem?.name,
            member: selectedMemberItem?.name,
          },
        }),
        h(
          "button",
          {
            onClick: () => {
              const node = getRoot().insert(
                "__VI_PLACEHOLDER_statement;",
                "statement",
                0,
              );
              selectedTopLevel.value = getOutline().find(({ nodes }) =>
                nodes.includes(node),
              ).nodes;
            },
          },
          "Add",
        ),
      ),
      h("div", {
        style: { height: "1.5rem" },
      }),
    ),
    selectedFile.value &&
      h(CodeMirrorWithVitrail, {
        value: fileContent,
        className: "browser-editor",
        key: selectedFile.value.path,
        onLoad: (v) => {
          vitrail.value = v;
          topLevelEntries.value = getOutline();
          selectedTopLevel.value =
            topLevelEntries.value.find(
              (entry) => entry.name === initialSelection?.topLevel,
            )?.nodes ?? topLevelEntries.value[0]?.nodes;
          selectedMember.value = selectedTopLevel.value?.members?.find(
            (entry) => entry.name === initialSelection?.member,
          )?.nodes;
        },
        onChange: () => (topLevelEntries.value = getOutline()),
        cmExtensions: [javascript(), baseCMExtensions],
        fetchAugmentations: () => [removeIndentAug, singleDeclarationAug],
        props: { nodes: selectedNodes },
        style: { width: "100%" },
      }),
  );
}

function FullDeclarationPane({ nodes, ...props }: { nodes: SBNode[] }) {
  useValidateKeepNodes(nodes, nodes[0].language);

  // make sure no changes in our cell would destroy the next node
  const nextNode = last(nodes).nextSiblingNode;
  useValidateKeepNodes(nextNode ? [nextNode] : [], nodes[0].language);

  const list = nodes[0].isRoot
    ? nodes
    : [
        ...takeWhile(
          nodes[0].parent!.children.slice(0, nodes[0].siblingIndex).reverse(),
          (c) => c.isWhitespace() || c.type === "comment",
        ),
        ...nodes,
        ...takeWhile(
          last(nodes).parent!.children.slice(last(nodes).siblingIndex + 1),
          (c) => c.isWhitespace() || c.type === "comment",
        ),
      ];

  return h(VitrailPane, {
    ...props,
    // prevent making the trailing newline editable
    rangeOffsets: last(list).sourceString.endsWith("\n") ? [0, 1] : [0, 0],
    nodes: list,
    className: "pane-full-width",
    hostOptions: {
      cmExtensions: [
        lineNumbers({
          formatNumber: (line, state) =>
            (
              (state.facet(PaneFacet as any) as any).startLineNumber +
              line -
              1
            ).toString(),
        }),
      ],
    },
  });
}

const singleDeclaration = (model: SBLanguage) => ({
  name: "singleDeclaration",
  type: "replace" as const,
  matcherDepth: 1,
  model,
  selectionInteraction: SelectionInteraction.Skip,
  match: (node) => (node.isRoot ? {} : null),
  view: ({ nodes: topLevel }) => {
    const nodes = useVitrailProps().nodes ?? topLevel;
    return h(FullDeclarationPane, { nodes });
  },
});
