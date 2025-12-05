# Hello CodeMirror!

<script>
  import { languageFor } from "./core/languages.js";  
  import {
    all,
    metaexec,
    optional,
    spawnArray,
    replace,
  } from "./core/query.js";

  import {
    VitrailPaneWithWhitespace,
    useValidateKeepReplacement,
  } from "./vitrail/vitrail.ts";

  import {setConfig} from "./core/config.js"

  import { h } from "./external/preact.mjs";

  var baseDir = lively.query(this, "lively-container").getDir()
  // setConfig({baseURL: baseDir + '../'})
  setConfig({baseURL: baseDir + '/'})

  lively.notify("basedir: " + baseDir)
  import {addVitrailToLivelyEditor} from './vitrail/lively.js';
</script>

<script>
try {
  
  let source = `var a = 3 + 4;`

  const editor = await (<lively-code-mirror style="width:800px; height: 500px; display: block"></lively-code-mirror>)

  editor.value = source

  const query = (query, extract) => (it) => it.query(query, extract);

  await addVitrailToLivelyEditor(editor, []) 

  
var pane = <div style="border:1px solid ">{editor}</div>

} catch(e) {
  debugger
}

pane
</script>
