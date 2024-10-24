import { assertEq, describe, run, test } from "../test.ts";
import { Transaction, TrueDiff } from "./diff.js";
import { SBBlock, SBText } from "./model.js";

describe("diff", () => {
  test("deleting element from mid of list does not cause an update", () => {
    const a = SBBlock.test("list", [
      SBBlock.test("item", [SBText.test("a")]),
      SBBlock.test("item", [SBText.test("b")]),
      SBBlock.test("item", [SBText.test("c")]),
    ]);
    const b = SBBlock.test("list", [
      SBBlock.test("item", [SBText.test("a")]),
      SBBlock.test("item", [SBText.test("c")]),
    ]);

    const diff = new TrueDiff();
    const { root, diff: buffer } = diff.detectEdits(a, b);
    buffer.apply(new Transaction());
    console.log(root.print());
    assertEq(root.children[0].children[0].text, "a");
    assertEq(root.children[1].children[0].text, "c");
    assertEq(buffer.posBuf.length, 0);
    // assert(root.children[0].type === "a");
    // assert(root.children[1].type === "c");
    // assert(root.children[2].type === "d");
  });
});

run();
