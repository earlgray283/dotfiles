#!/usr/bin/env bun
import type { PermissionRequestInput } from "../types";

const input: PermissionRequestInput = await Bun.file("/dev/stdin").json();

const subtitle = input.cwd ? input.cwd.split("/").at(-1) : "";

const message = `権限リクエスト: ${input.tool_name}`;
const escaped = message.replace(/\\/g, "\\\\").replace(/"/g, '\\"');

const proc = Bun.spawn([
  "osascript",
  "-e",
  `display notification "${escaped}" with title "Claude Code" subtitle "${subtitle}"`,
]);
await proc.exited;
