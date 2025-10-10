import { test } from "test";
import { a } from "test2";
import { b } from "test3";

class MyCls2 {
  constructor() {
    console.log("a");
  }

  invoke(arg) {
    return arg * 3;
  }

  copy(arg) {
    return new MyCls()
  }
}

let a = 5;

class MyCls {
  constructor() {
    console.log("a");
  }

  invoke(arg) {
    return arg * 3;
  }

  copy(arg) {
    return new MyCls()
  }
}

export { MyCls };
