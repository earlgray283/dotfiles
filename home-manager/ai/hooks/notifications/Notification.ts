#!/usr/bin/env bun
import type { NotificationInput } from "../types";

const input: NotificationInput = await Bun.file("/dev/stdin").json();

const subtitle = input.cwd ? input.cwd.split("/").at(-1) : "";

// Escape AppleScript string delimiters
const escaped = input.message.replace(/\\/g, "\\\\").replace(/"/g, '\\"');

const proc = Bun.spawn([
  "osascript",
  "-e",
  `display notification "${escaped}" with title "Claude Code" subtitle "${subtitle}"`,
]);
await proc.exited;
