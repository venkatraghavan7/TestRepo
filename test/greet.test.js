import { test } from "node:test";
import assert from "node:assert/strict";
import { greet } from "../src/greet.js";

test("greets a person by name", () => {
  assert.equal(greet("Ada"), "Hello, Ada!");
});

test("trims spaces around the name", () => {
  assert.equal(greet("  Ada  "), "Hello, Ada!");
});

test("rejects an empty name", () => {
  assert.throws(() => greet("   "), TypeError);
});

test("rejects a name that is not a string", () => {
  assert.throws(() => greet(42), TypeError);
});
