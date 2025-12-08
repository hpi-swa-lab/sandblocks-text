# Getting Started

1. Open `index.html` in a browser (tested on Firefox 145.0.1 and Chrome 142.0.7444.175). Interact with the nested editor widgets. (This is the CodeMirror v6 implementation.)
2. Lively TODO (This is the lively4 implementation.)
3. Squeak TODO (This is the Squeak/Smalltalk implementation.)

# Overview of Claims and Step-by-Step Instructions

As the step-by-step instructions for all but one claim are very short, we merged the instructions with the overview of claims.

## Claim: Section 4.1 --- Structure Tracking
- temporary syntax errors leave tools intact
- cut-pasting text with embedded tools recovers tools

To reproduce:
1. Open `index.html` (see Getting Started).
2. In the watch example at the top, select from outside the watch to the multiplication sign (`3 +| WATCH *| 4`).
3. Invoke the Web Browser's cut shortcut (Ctrl/Cmd+x or right-click). The Watch should remain in the text buffer and a notice should appear that there are pending changes.
4. Navigate to the start of the file (before the 3).
5. Invoke the Web Browser's paste (Ctrl+Cmd v or right-click). The watch should move to the start and the pending changes notice should disappear.

## Claim: Section 4.2 --- Nested Editors
- selection is kept intact when a tool appears
- indentation can be removed
- leading and trailing whitespace handling

TODO

## Claim: Section 4.3 --- Structured Access
- 4.3.1 dynamic information
- 4.3.3 editing atoms, siblings, parent-child structures

TODO

## Claim: Section 5 --- Platform Support
- Codemirror
- lively4
- Squeak/Smalltalk

To reproduce:
1. Follow the instructions for Getting Started, which allows to open all three implementations.

## Claim: Section 6 --- Case Studies
- Section 6.1: Placeholder
- Section 6.2: Composing Languages
- Section 6.3: Browser
- Section 6.4: Livelits

1. Follow step 1 of Getting Started. The website includes the four case studies described in Section 6.

TODO specific steps to use?




TODOs
* replacing w/ parens
* insert algo: Should there be multiple repeating structures in the same definition, which tends to be rare, the user can specify a function that selects the desired one given all options, for example, based on the type of node that is repeated.
* whitespace detect: To mitigate this issue, we employ a default heuristic to always pull in whitespace to the right of a fragment's expression but only pull in whitespace to the left of a fragment's expression if it is not indentation and if it is more than one space character.
