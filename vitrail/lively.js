import { Vitrail, replacementRange } from "./vitrail.ts";

import { Pane} from "./pane.ts"

export async function addVitrailToLivelyEditor(
  livelyCodeMirror,
  augmentations,
) {
  // Ensure editor is initialized before proceeding
  if (!livelyCodeMirror.editor) {
    await livelyCodeMirror.editView("");
  }

  function paneFromLively(livelyCodeMirror, vitrail, fetchAugmentations) {
    const cm = livelyCodeMirror.editor;
    if (!cm) {
      // Editor not ready yet, try to initialize
      if (livelyCodeMirror.editView) {
        livelyCodeMirror.editView("");
      }
    }

    const markers = new Map();

    // Function to get cm safely (for shards that might not be ready)
    const getCm = () => livelyCodeMirror.editor;

    // Use the CodeMirror wrapper element as the view for proper DOM containment
    // This ensures replacements inserted via markText are properly contained
    const view = cm ? cm.getWrapperElement() : livelyCodeMirror;

    const pane = new Pane({
      vitrail,
      view: view,
      host: livelyCodeMirror,
      fetchAugmentations,
      getLocalSelectionIndices: () => {
        const cm = getCm();
        if (!cm) return [0, 0];
        return [
          cm.indexFromPos(cm.getCursor("from")),
          cm.indexFromPos(cm.getCursor("to")),
        ];
      },
      syncReplacements: () => {
        const cm = getCm();
        if (!cm) return;
        for (const replacement of pane.replacements) {
          const range = replacementRange(replacement, vitrail);
          if (markers.has(replacement)) {
            const marker = markers.get(replacement);
            const pos = marker.find();
            if (
              pos &&
              range[0] - pane.startIndex === cm.indexFromPos(pos.from) &&
              range[1] - pane.startIndex === cm.indexFromPos(pos.to)
            ) {
              continue;
            }
            marker.clear();
          }
          const marker = cm.doc.markText(
            cm.posFromIndex(range[0] - pane.startIndex),
            cm.posFromIndex(range[1] - pane.startIndex),
            { replacedWith: replacement.view },
          );
          markers.set(replacement, marker);
        }

        for (const [replacement, marker] of [...markers.entries()]) {
          if (!pane.replacements.includes(replacement)) {
            marker.clear();
            markers.delete(replacement);
          }
        }
      },
      focusRange: (head, anchor) => {
        const cm = getCm();
        if (!cm) return;
        console.log("focusRange");
        window.timeStart = performance.now();
        queueMicrotask(() => cm.focus());
        cm.setSelection(cm.posFromIndex(anchor), cm.posFromIndex(head));
      },
      applyLocalChanges: function (changes) {
        const cm = getCm();
        if (!cm) return;
        for (const change of changes) {
          let from = cm.posFromIndex(change.from);
          let to = cm.posFromIndex(change.to);
          cm.replaceRange(change.insert, from, to);
        }
        this.syncReplacements();
      },
      getText: () => {
        const cm = getCm();
        return cm ? cm.getValue() : "";
      },
      setText: (text) => {
        const cm = getCm();
        if (cm) cm.setValue(text);
      },
      hasFocus: () => {
        const cm = getCm();
        return cm ? cm.hasFocus() : false;
      },
    });

    // Setup CodeMirror event handlers
    const setupCodeMirrorHandlers = () => {
      const cm = getCm();
      if (!cm) {
        // If editor not ready, retry in a bit (for shard panes)
        setTimeout(setupCodeMirrorHandlers, 10);
        return;
      }

      cm.on("keydown", (cm, e) => {
      if (e.key === "ArrowLeft") {
        if (pane.moveCursor(false)) {
          e.preventDefault();
          e.stopPropagation();
        }
      }
      if (e.key === "ArrowRight") {
        if (pane.moveCursor(true)) {
          e.preventDefault();
          e.stopPropagation();
        }
      }
      if (e.key === "Backspace") {
        if (pane.handleDeleteAtBoundary(false)) {
          lively.warn("NO BACKSPACE");
          e.preventDefault();
        }
      }
      if (e.key === "Delete") {
        if (pane.handleDeleteAtBoundary(true)) e.preventDefault();
      }
    });

    let changeRange = null;
    let isUndoRedo = false;

    cm.on("beforeChange", (cm, e) => {
      if (e.origin === "setValue" || !e.origin) return;

      // Track if this is an undo/redo operation
      isUndoRedo = e.origin === "undo" || e.origin === "redo";

      // to resolve the correct indices, we need to calculate the index before
      // the change is applied. However, Vitrail expects the change to have been
      // applied when we inform it of a change. So we need both listeners.
      changeRange = [cm.indexFromPos(e.from), cm.indexFromPos(e.to)];
    });

    cm.on("change", (_cm, e) => {
      if (e.origin === "setValue" || !e.origin) return;

      const [from, to] = changeRange;
      const insert = e.text.join("\n");
      const removed = e.removed.join("\n");

      const change = {
        from: from + pane.startIndex,
        to: to + pane.startIndex,
        insert,
        sourcePane: pane,
        inverse: {
          from: from + pane.startIndex,
          to: from + pane.startIndex + insert.length,
          insert: removed,
        },
        // Pass the undo/redo flag to Vitrail (it may use this in the future)
        isUndoRedo,
      };

      v.applyChanges([change]);

      // Reset the flag
      isUndoRedo = false;
    });
    };

    // Setup handlers (will retry if editor not ready yet)
    setupCodeMirrorHandlers();

    return pane;
  }

  const v = new Vitrail({
    createPane: (fetchAugmentations) => {
      const editor = document.createElement("lively-code-mirror");
      editor.classList.add("shard");
      editor.style = "display:inline-block; border: 1px solid gray";
      return paneFromLively(editor, v, fetchAugmentations);
    },
    showValidationPending: (pending) => {
      console.log("Validation Pending:", pending);
    },
  });

  await v.connectHost(paneFromLively(livelyCodeMirror, v, () => augmentations));
  return v;
}

function onEnterDOM(element, cb) {
  const observer = new MutationObserver(() => {
    cb();
    observer.disconnect();
  });
  observer.observe(element, { childList: true, subtree: true });
}
