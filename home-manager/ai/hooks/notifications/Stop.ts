#!/usr/bin/env bun
import type { StopInput } from "../types";

const input: StopInput = await Bun.file("/dev/stdin").json();

// Prevent infinite loop: skip if already inside a stop hook
if (input.stop_hook_active) {
  process.exit(0);
}

const subtitle = input.cwd ? input.cwd.split("/").at(-1) : "";

const proc = Bun.spawn([
  "osascript",
  "-e",
  `display notification "応答が完了しました" with title "Claude Code" subtitle "${subtitle}"`,
]);
await proc.exited;
