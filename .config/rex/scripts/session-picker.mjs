#!/usr/bin/env node
// Pick Rex sessions and toggle the last two selected through this helper.
import { spawnSync } from "node:child_process";
import { existsSync, readFileSync, readSync, realpathSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { parseArgs } from "node:util";
import {
  commandPath,
  isObject,
  rex as callRex,
  saveJson,
  withJsonLock,
} from "./rex-runtime.mjs";

const rex = (...args) => callRex(args);

function readHistory(path) {
  if (!existsSync(path)) return {};
  let state;
  try {
    state = JSON.parse(readFileSync(path, "utf8"));
  } catch (error) {
    if (error instanceof SyntaxError)
      throw new Error(`Invalid session history: ${path}`);
    throw error;
  }
  const validEntry = (entry) =>
    isObject(entry) &&
    Object.keys(entry).length === 2 &&
    typeof entry.current === "string" &&
    entry.current.length > 0 &&
    typeof entry.previous === "string" &&
    entry.previous.length > 0;
  if (
    !isObject(state) ||
    !Object.values(state).every(
      (clients) =>
        isObject(clients) && Object.values(clients).every(validEntry),
    )
  ) {
    throw new Error(`Invalid session history: ${path}`);
  }
  return state;
}

export function switchSession(client, current, target) {
  const path = join(
    process.env.XDG_CONFIG_HOME || join(homedir(), ".config"),
    "rex/state/session-history.json",
  );
  return withJsonLock(path, target === undefined ? 0 : 20, () => {
    const apps = rex("client", "ls", "--json").clients || [];
    if (
      !apps.some(
        (app) =>
          app.client_id === client &&
          app.info?.kind === "app" &&
          app.connection_state === "connected",
      )
    ) {
      throw new Error(
        "Choose a connected Rex app with --client CLIENT_ID (rex client ls)",
      );
    }
    const status = rex("api", "call", "server.status", "{}");
    const scope = status.host_id || status.instance_id;
    const state = readHistory(path);
    const available = new Set(
      (rex("ls", "--json").sessions || []).map((session) => session.session_id),
    );
    if (!available.has(current))
      throw new Error("The source session no longer exists; reopen the picker");
    const entry = state[scope]?.shared;
    if (target === undefined) {
      if (entry) {
        // The invoking session is authoritative after an untracked native switch.
        target = entry.current === current ? entry.previous : entry.current;
      } else {
        // Old client IDs change on reconnect. Recover only when live legacy
        // pairs containing this session agree; JSON order is not recency.
        const candidates = new Set();
        for (const legacy of Object.values(state[scope] || {})) {
          const other = legacy.current === current
            ? legacy.previous
            : legacy.previous === current ? legacy.current : undefined;
          if (other !== current && available.has(other)) candidates.add(other);
        }
        if (candidates.size > 1)
          throw new Error(
            "Legacy session history is ambiguous; choose a session with the session or project picker",
          );
        [target] = candidates;
      }
      if (target === undefined)
        throw new Error(
          "No previous session yet; first switch with the session or project picker",
        );
    }
    if (!available.has(target))
      throw new Error(
        "The previous or selected session was closed; choose another session with the picker",
      );
    if (target === current) return;
    rex("-C", client, "do", "session.select", `session_id=${target}`);
    state[scope] ??= {};
    state[scope].shared = { current: target, previous: current };
    try {
      saveJson(path, state);
    } catch (error) {
      throw new Error(
        `Session switched, but history could not be saved: ${error.message}`,
      );
    }
  });
}

function pick(sessions) {
  if (sessions.length === 0) throw new Error("No Rex sessions available");
  const records = new Map(
    sessions.map(({ session_id: id, label }) => {
      const safeLabel = label.replace(/[\p{C}\p{Zl}\p{Zp}]/gu, " ");
      return [`${id}\t${safeLabel}  [${id}]`, id];
    }),
  );
  const env = Object.fromEntries(
    Object.entries(process.env).filter(([key]) => !key.startsWith("FZF_")),
  );
  const result = spawnSync(
    commandPath("fzf"),
    [
      "--read0",
      "--print0",
      "--no-multi",
      "--layout=reverse",
      "--delimiter=\t",
      "--with-nth=2..",
      "--prompt=Session> ",
      "--border",
      "--header=Enter: switch session | Esc: cancel",
    ],
    {
      env,
      encoding: "utf8",
      input: `${[...records.keys()].join("\0")}\0`,
      stdio: ["pipe", "pipe", "inherit"],
      maxBuffer: 8 * 1024 * 1024,
    },
  );
  if (result.error) throw result.error;
  if (
    result.status === 1 ||
    result.status === 130 ||
    result.signal === "SIGINT"
  )
    return null;
  if (result.status !== 0)
    throw new Error(`fzf failed with exit status ${result.status}`);
  const selected = result.stdout.replace(/\0$/, "");
  if (!records.has(selected))
    throw new Error("fzf returned an unexpected selection");
  return records.get(selected);
}

function main() {
  let pickerTab = false;
  try {
    const { values, positionals } = parseArgs({
      allowPositionals: true,
      options: {
        client: { type: "string" },
        current: { type: "string" },
        session: { type: "string" },
        "picker-tab": { type: "boolean" },
        help: { type: "boolean", short: "h" },
      },
    });
    pickerTab = values["picker-tab"] || false;
    if (values.help) {
      console.log(
        "Usage: session-picker.sh {pick,toggle,select} --client CLIENT --current SESSION [--session TARGET] [--picker-tab]",
      );
      return 0;
    }
    const [command] = positionals;
    if (
      positionals.length !== 1 ||
      !["pick", "toggle", "select"].includes(command)
    )
      throw new Error("Choose pick, toggle, or select");
    if (!values.client || !values.current)
      throw new Error("--client and --current are required");
    if (command === "select" && !values.session)
      throw new Error("select requires --session");
    if (command !== "select" && values.session !== undefined)
      throw new Error("--session is only valid with select");
    let target = values.session;
    if (command === "pick") {
      target = pick(rex("ls", "--json").sessions || []);
      if (target === null) return 0;
    }
    switchSession(values.client, values.current, target);
    return 0;
  } catch (error) {
    console.error(`rex-session-picker: ${error.message}`);
    if (pickerTab) {
      process.stdout.write("Press Enter to close the picker… ");
      try {
        readSync(0, Buffer.alloc(1), 0, 1, null);
      } catch {
        /* The picker may already have closed. */
      }
    }
    return 1;
  }
}

if (
  process.argv[1] &&
  realpathSync(process.argv[1]) === fileURLToPath(import.meta.url)
) {
  process.exitCode = main();
}
