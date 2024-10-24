const tests: (() => Promise<void>)[] = [];
const configStack: { before?: (() => void)[]; after?: (() => void)[] }[] = [{}];
let viewTest;
export async function run() {
  if (viewTest) viewTest();
  else for (const test of tests) await test();
}
export function test(name: string, cb: () => void | Promise<void>) {
  const config = [...configStack];
  tests.push(async () => {
    try {
      for (const c of config) for (const b of c.before ?? []) b();
      await cb();
    } finally {
      for (const c of config) for (const b of c.after ?? []) b();
    }
  });
}
test.skip = () => {};
test.view = (name: string, cb: () => void | Promise<void>) => {
  if (viewTest) throw new Error("multiple tests designated for viewing");
  const config = [...configStack];
  viewTest = async () => {
    for (const c of config) for (const b of c.before ?? []) b();
    await cb();
    // skip cleanup, as it would close the view
  };
};
export function describe(name: string, cb: () => void) {
  configStack.push({});
  cb();
  configStack.pop();
}
describe.skip = () => {};
export function beforeEach(cb: () => void | Promise<void>) {
  (configStack[configStack.length - 1].before ??= []).push(cb);
}
export function afterEach(cb: () => void | Promise<void>) {
  (configStack[configStack.length - 1].after ??= []).push(cb);
}
export function assertTrue(a: boolean) {
  if (!a) throw new Error(`expected ${a} to be true`);
}
export function assertEq<T>(a: T, b: T, contains = false) {
  if (a === b) return true;
  if (Array.isArray(a) && Array.isArray(b)) {
    if (a.length !== b.length) throw new Error(`expected ${a} to equal ${b}`);
    for (let i = 0; i < a.length; i++) assertEq(a[i], b[i], contains);
    return;
  }
  if (typeof a === "object" && typeof b === "object" && a && b) {
    if (!contains) for (const k in a) assertEq(a[k], b[k], contains);
    for (const k in b) assertEq(a[k], b[k], contains);
    return;
  }
  if (a !== b) throw new Error(`expected ${a} to equal ${b}`);
}
export function assertContains<T>(a: T, b: T) {
  return assertEq(a, b, true);
}
export function tick() {
  return new Promise((resolve) => setTimeout(resolve, 0));
}
export function eventDispatched(object: EventTarget, name: string) {
  return new Promise((resolve) => {
    const handler = (e) => {
      object.removeEventListener(name, handler);
      resolve(e);
    };
    object.addEventListener(name, handler);
  });
}
