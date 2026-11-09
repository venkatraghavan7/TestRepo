// A tiny module so the factory has something to build on and a test to keep green.
export function greet(name) {
  if (typeof name !== "string" || name.trim() === "") {
    throw new TypeError("name must be a non-empty string");
  }
  return `Hello, ${name.trim()}!`;
}
