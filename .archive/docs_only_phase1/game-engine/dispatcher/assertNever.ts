export function assertNever(x: never, msg?: string): never {
  throw new Error(msg ?? `Unhandled value in exhaustive switch: ${String(x)}`);
}

export default assertNever;
