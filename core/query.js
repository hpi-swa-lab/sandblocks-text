import { last, takeWhile } from "../utils.js";

export function match(makeScript) {
  return (it) => {
    return metaexec(it, makeScript);
  };
}

export function metaexec(obj, makeScript) {
  return _metaexec(obj, makeScript)?.captures;
}

export function _metaexec(obj, makeScript) {
  let captures = {};
  let selectedInput = {};
  let selectedOutput = {};
  const capture = function (captureName) {
    return (it) => {
      captures[captureName] = it;
      return it;
    };
  };
  capture.get = (name) => captures[name];
  const script = makeScript(
    capture,
    function () {
      return (it) => {
        selectedInput = it;
      };
    },
    function () {
      return (it) => (selectedOutput = it);
    },
  );
  const res = execScript(obj, ...script);
  return res
    ? {
        captures: captures,
        selectedInput: selectedInput,
        selectedOutput: selectedOutput,
      }
    : null;
}

function isAbortReason(next) {
  if (typeof next === "number") return false;
  if (!next) return true;
  if (_isEmptyObject(next)) return true;
  // does not make sense with array processing
  // if (Array.isArray(next) && next.length < 1) return true;
  return false;
}

export function replace(capture) {
  return (it) => {
    capture("nodes")(Array.isArray(it) ? it : [it]);
    return it;
  };
}

function execScript(arg, ...script) {
  if (!arg) return null;
  let current = arg;

  for (const predicate of script) {
    try {
      let next = predicate(current);
      if (isAbortReason(next)) {
        return null;
      }
      if (next !== true) current = next;
    } catch (e) {
      console.error(e);
      return null;
    }
  }

  return current;
}

function _isEmptyObject(obj) {
  return Object.keys(obj).length === 0 && obj.constructor === Object;
}

export function spawnArray(pipeline, filter = true) {
  return (it) => {
    let matches = null;
    if (Array.isArray(pipeline)) {
      matches = it.map((node) => execScript(node, ...pipeline));
    } else {
      matches = it.map((node) => pipeline(node));
    }

    if (filter) {
      return matches.filter((node) => node != null);
    } else {
      return matches.every((it) => !isAbortReason(it)) ? matches : null;
    }
  };
}

export function allMatch(pipeline) {
  return (it) => {
    return Array.isArray(pipeline)
      ? it.every((node) => execScript(node, ...pipeline))
      : it.every((node) => pipeline(node));
  };
}

export function languageSpecific(language, ...pipeline) {
  return (it) => {
    const language_list = Array.isArray(language) ? language : [language];
    const mod_pipeline = [
      (it) => language_list.includes(it.language),
      ...pipeline,
    ];
    return execScript(it, ...mod_pipeline);
  };
}

export function selected(selectedInput, selectedOutput, ...pipeline) {
  return (it) => {
    selectedInput(it);
    const output = execScript(it, ...pipeline);
    selectedOutput(output);
    return output;
  };
}

//execute abitray code, without effecting the the next step in the pipeline
export function also(pipeline) {
  return (it) => {
    const og_it = it;
    execScript(it, ...pipeline);
    return og_it;
  };
}

export function first(...pipelines) {
  return (it) => {
    for (const pipeline of pipelines) {
      const res = execScript(it, ...pipeline);
      if (res) {
        return res;
      }
    }
    return null;
  };
}

export const optional = (pipeline) => first(pipeline, [() => true]);

export const debugIt = (it) => {
  console.log(it);
  return it;
};

export function all(...pipelines) {
  return (it) => {
    for (const pipeline of pipelines) {
      const res = execScript(it, ...pipeline);
      if (isAbortReason(res)) return null;
    }
    // signal that we completed, but return no sensible value
    return true;
  };
}

export function getField(name) {
  return (it) => findFieldRec(it, name);
}

function findFieldRec(obj, name) {
  const match = obj.childBlocks.find(
    (childBlock) =>
      childBlock.type == "pair" && childBlock.atField("key").text == name,
  );
  return match
    ? match
    : obj.childBlocks.map((childBlock) => findFieldRec(childBlock, name))[0];
}

export function captureAll(capture) {
  return (it) => {
    for (const key in it) capture(key)(it[key]);
    return it;
  };
}

export function extract(key) {
  return (it) => it[key];
}
export function query(query, extract) {
  return (it) => it.query(query, extract);
}
export function queryDeep(query, extract) {
  return (it) => it.findQuery(query, extract);
}
export function type(typeName) {
  return (it) => it.type === typeName;
}

export function log(prefix = "") {
  return (it) => {
    if (prefix != "") console.log(prefix);
    console.log(it);
    return it;
  };
}

export function getObjectField(obj, fieldName) {
  const res = obj.childBlocks.filter(
    (it) => it.childBlocks[0].text == fieldName,
  )[0].childBlocks[1];
  return res ? res : "";
}

export function nodesWithWhitespace(nodes, ignoreLeft = false) {
  if (!Array.isArray(nodes)) nodes = [nodes];
  return nodes.length === 0
    ? []
    : [
        ...(ignoreLeft
          ? []
          : takeWhile(
              nodes[0].parent.children
                .slice(0, nodes[0].siblingIndex)
                .reverse(),
              (c) => c.isWhitespace(),
            )),
        ...nodes,
        ...takeWhile(
          last(nodes).parent.children.slice(last(nodes).siblingIndex + 1),
          (c) => c.isWhitespace(),
        ),
      ];
}
