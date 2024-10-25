import { assertEq, describe, run, test } from "../test.ts";
import { languageFor } from "./languages.js";

await languageFor("javascript").ready();

describe("model edit", () => {
  test("insert in array", () => {
    const t = languageFor("javascript").parseOffscreen("[1, 3]");
    t.firstOfType("array")!.insert("2", "expression", 1);
    assertEq(t.sourceString, "[1, 2,3]");
  });

  test("insert statement", () => {
    const t = languageFor("javascript").parseOffscreen("1;\n3;");
    t.insert("2", "statement", 1);
    assertEq(t.sourceString, "1;\n2 3;");
  });

  test("test replace simple", () => {
    const t = languageFor("javascript").parseOffscreen("1");
    t.firstOfType("number")!.replaceWith("2");
    assertEq(t.sourceString, "2");
  });

  test.view("test replace with parentheses", () => {
    const t = languageFor("javascript").parseOffscreen("1*3");
    t.firstOfType("number")!.replaceWith("1+2");
    assertEq(t.sourceString, "(1+2)*3");
  });
});

run();
