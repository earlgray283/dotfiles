export type PermissionMode =
  | "default"
  | "plan"
  | "acceptEdits"
  | "dontAsk"
  | "bypassPermissions";

export interface HookInputBase {
  session_id: string;
  transcript_path: string;
  cwd?: string;
  permission_mode: PermissionMode;
  hook_event_name: string;
}

// Stop / SubagentStop
export interface StopInput extends HookInputBase {
  hook_event_name: "Stop" | "SubagentStop";
  stop_hook_active: boolean;
}

// Notification
export type NotificationType =
  | "permission_prompt"
  | "idle_prompt"
  | "auth_success"
  | "elicitation_dialog";

export interface NotificationInput extends HookInputBase {
  hook_event_name: "Notification";
  message: string;
  notification_type: NotificationType;
}

// PermissionRequest
export interface PermissionRequestInput extends HookInputBase {
  hook_event_name: "PermissionRequest";
  tool_name: string;
  tool_input: Record<string, unknown>;
  tool_use_id: string;
}

// Hook output (JSON to stdout)
export interface HookOutput {
  continue?: boolean;
  stopReason?: string;
  suppressOutput?: boolean;
  systemMessage?: string;
}
