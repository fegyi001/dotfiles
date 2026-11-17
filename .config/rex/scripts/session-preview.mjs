#!/usr/bin/env node
// Read-only, short-lived fzf snapshot worker. Never attaches to or selects a session.
import { execFile } from "node:child_process";
import { setTimeout as delay } from "node:timers/promises";
import { stripVTControlCharacters } from "node:util";
import { commandPath, isObject } from "./rex-runtime.mjs";

const TAIL_BYTES = 32 * 1024;
const controller = new AbortController();
const { signal } = controller;
let cancelled = false;
const cancel = () => {
  cancelled = true;
  controller.abort();
};
process.once("SIGTERM", cancel);
process.once("SIGINT", cancel);
const deadline = setTimeout(() => controller.abort(), 2000);

async function snapshot(session) {
  if (
    !/^session:[A-Za-z0-9:-]+$/.test(session || "") ||
    process.argv.length !== 3
  )
    throw new Error("Invalid session ID");
  await delay(75, undefined, { signal });
  const executable = commandPath("rex");
  const env = { ...process.env };
  delete env.REX_SERVER;

  const call = (args) =>
    new Promise((resolve, reject) => {
      if (signal.aborted) return reject(new Error("Preview cancelled"));
      let escalation;
      const stop = () => {
        child.kill("SIGTERM");
        escalation = setTimeout(() => child.kill("SIGKILL"), 100);
      };
      const child = execFile(
        executable,
        args,
        {
          env,
          encoding: "utf8",
          maxBuffer: 256 * 1024,
        },
        (error, stdout) => {
          clearTimeout(escalation);
          signal.removeEventListener("abort", stop);
          if (error || signal.aborted)
            return reject(new Error("Rex preview request failed"));
          try {
            resolve(JSON.parse(stdout));
          } catch {
            reject(new Error("Invalid Rex preview response"));
          }
        },
      );
      signal.addEventListener("abort", stop, { once: true });
      if (signal.aborted) stop();
    });

  const view = await call([
    "api",
    "call",
    "session.view",
    JSON.stringify({ session_id: session }),
  ]);
  if (!isObject(view) || !Array.isArray(view.windows))
    throw new Error("No session view");
  const window = view.windows.find(
    (entry) => entry.window_id === view.active_window_id,
  );
  const block = window?.layers
    ?.flatMap((layer) => layer.blocks || [])
    .find((entry) => entry.block_id === window.focused_block_id);
  if (
    block?.creator_name !== "com.superlogical.terminal" ||
    !/^block:[A-Za-z0-9:-]+$/.test(block.block_id || "")
  )
    throw new Error("No focused terminal");
  const terminal = (method, args) =>
    call([
      "block",
      "call",
      "-s",
      session,
      "-b",
      block.block_id,
      method,
      JSON.stringify(args),
    ]);
  const modes = await terminal("modes", {});
  if (!isObject(modes) || typeof modes.screen !== "string")
    throw new Error("No terminal screen mode");
  const alternate = modes.screen === "alternate";
  const formatted = await terminal("format", {
    format: "text",
    trim: true,
    max_bytes: 4096,
  });
  if (!isObject(formatted) || typeof formatted.content !== "string")
    throw new Error("No terminal text");
  let text = formatted.content;
  let truncated = false;
  if (formatted.id !== undefined) {
    if (
      !Number.isSafeInteger(formatted.id) ||
      formatted.id < 0 ||
      !Number.isSafeInteger(formatted.total) ||
      formatted.total <= 0
    )
      throw new Error("Invalid snapshot metadata");
    const offset = alternate ? 0 : Math.max(0, formatted.total - TAIL_BYTES);
    // Alternate screens need the head, not shell scrollback's tail. max_bytes
    // counts encoded bytes; the head budget also bounds its source bytes.
    // Neither budget bounds Rex's internal formatting cost.
    const tail = await terminal("blob_read", {
      id: formatted.id,
      offset,
      max_bytes: alternate ? TAIL_BYTES : TAIL_BYTES * 6,
    });
    if (
      !isObject(tail) ||
      tail.id !== formatted.id ||
      tail.total !== formatted.total ||
      typeof tail.eof !== "boolean" ||
      (!alternate && !tail.eof) ||
      typeof tail.data !== "string"
    )
      throw new Error("Incomplete snapshot");
    text = tail.data;
    if (Buffer.byteLength(text) > TAIL_BYTES + 3)
      throw new Error("Snapshot too large");
    if (alternate && !tail.eof) {
      truncated = true;
      // blob_read preserves UTF-8 but may stop mid-line. Keep only complete
      // leading lines so editor code is never shown with a chopped line.
      text = text.slice(0, Math.max(0, text.lastIndexOf("\n") + 1));
    } else if (offset > 0) {
      // The byte offset can split a UTF-8 character or a line. Never display
      // the leading fragment; remaining complete lines retain valid Unicode.
      const newline = text.indexOf("\n");
      if (newline < 0) throw new Error("No complete snapshot lines");
      text = text.slice(newline + 1);
    }
  } else if (formatted.eof === false || Buffer.byteLength(text) > TAIL_BYTES) {
    throw new Error("Unbounded snapshot");
  }
  const requestedRows = Number(process.env.FZF_PREVIEW_LINES);
  const rows =
    Number.isSafeInteger(requestedRows) && requestedRows > 0
      ? Math.min(200, requestedRows)
      : 24;
  const safe = stripVTControlCharacters(text)
    .replace(/\r\n?/g, "\n")
    .replace(/[\u0000-\u0008\u000b-\u001f\u007f-\u009f]/g, "")
    .replace(/\n+$/, "");
  if (alternate) {
    const lines = safe ? safe.split("\n") : [];
    if (truncated || lines.length > 200)
      return [...lines.slice(0, 199), "[Preview truncated]"].join("\n");
    return safe || "(Terminal is empty)";
  }
  return safe.split("\n").slice(-rows).join("\n") || "(Terminal is empty)";
}

try {
  const text = await snapshot(process.argv[2]);
  if (!cancelled) process.stdout.write(`${text}\n`);
} catch {
  if (!cancelled)
    process.stdout.write(
      "Preview unavailable (no readable terminal or request timed out).\n",
    );
} finally {
  clearTimeout(deadline);
  process.removeListener("SIGTERM", cancel);
  process.removeListener("SIGINT", cancel);
}
