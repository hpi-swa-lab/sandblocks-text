# Getting Started

1. Run `docker image load < hybridse.tar`, then `docker run -p 8080:9005 lively4-artifact`
2. Open [http://localhost:8080/lively4-core/start.html?load=http://localhost:8080/sandblocks-text-artifact/lively-demo.md]() in a browser, which should open a file browser-like interface on the left with an editor on the right (tested on Chrome 142.0.7444.175).

[http://localhost:8080/sandblocks-text-artifact/squeak-demo/squeak.html]()
[http://localhost:8080/sandblocks-text-artifact/dist-demo/index.html]()

# Overview of Claims

Since the steps to reproduce our claims are short, we merged the step-by-step instructions with the list of claims for a better overview.

## Claim: Section 4.1 --- Structure Tracking
- temporary syntax errors leave tools intact
- cut-pasting text with embedded tools recovers tools

To reproduce:
1. Open `index.html` (see Getting Started).
2. In the watch example at the top, select from outside the watch to the multiplication sign (`3 +| WATCH *| 4`).
3. Invoke the Web Browser's cut shortcut (Ctrl/Cmd+x or right-click). The Watch should remain in the text buffer and a notice should appear that there are pending changes.
4. Navigate to the start of the file (before the 3).
5. Invoke the Web Browser's paste (Ctrl+Cmd v or right-click). The watch should move to the start and the pending changes notice should disappear.
6. Insert syntax errors near the watch (e.g., add a `2` just before the watch element) and observe the pending changes notice appearing until the expression is valid again (e.g., add a `+` after the just-inserted `2`).

## Claim: Section 4.2 --- Nested Editors
- leading and trailing whitespace handling trims more than one whitespace
- indentation can be removed

To reproduce leading/trailing whitespace handling:
1. Open `index.html` (see Getting Started).
2. In the "Watch" example, add a space to the right of the `2 + 2` expression, inside the watch, and continue typing `+ 3`.

To reproduce indentation removal:
1. Open `index.html` (see Getting Started).
2. In the "Browser" example, select the "constructor" method. Its base indentation has been replaced with a tab-icon.

## Claim: Section 4.3 --- Structured Access
- 4.3.1 support for accessing dynamic information
- 4.3.3 support for inserting, replacing, and deleting program structures

1. Follow step 1 of Getting Started. The website includes the "Watch" case study, which makes use of dynamic information, and three editing scenarios.
2. Watch: try changing the expression to observe the change in the user interface to reflect the changed expression's result.
3. Editing Scenarios: inspect the three editing scenarios, shown here as code snippets that use the API that we provide to users of the framework. The scenarios are editable and are re-evaluated on change.

## Claim: Section 5 --- Platform Support
- Codemirror v6 implementation
- lively4 implementation
- Squeak/Smalltalk implementation

To reproduce:
1. Follow the instructions for Getting Started, which allows to open all three implementations.

## Claim: Section 6 --- Case Studies
- Section 6.1: Placeholder
- Section 6.2: Composing Languages
- Section 6.3: Browser
- Section 6.4: Livelits

1. Follow step 1 of Getting Started. The website includes the four case studies described in Section 6.
TODO specific steps to use?

