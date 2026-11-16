#!/usr/bin/env node
// Find local project directories and open their Rex sessions.
import { spawnSync } from "node:child_process";
import { createHash } from "node:crypto";
import { existsSync, readFileSync, readdirSync, readSync, realpathSync, statSync } from "node:fs";
import { homedir } from "node:os";
import { basename, isAbsolute, join, resolve } from "node:path";
import { parseArgs } from "node:util";
import { commandPath, isObject, rex as callRex, saveJson, withJsonLock } from "./rex-runtime.mjs";
import { switchSession } from "./session-picker.mjs";

const rex = (...args) => callRex(args, 30_000);
const expandHome = (path) => path === "~" ? homedir() : path.startsWith("~/") ? join(homedir(), path.slice(2)) : path;

function canonicalPath(path) {
  try { return realpathSync(path); } catch (error) {
    if (error.code === "ENOENT") return resolve(path);
    throw error;
  }
}

function isDirectory(path) {
  try { return statSync(path).isDirectory(); } catch (error) {
    if (error.code === "ENOENT" || error.code === "ENOTDIR") return false;
    throw error;
  }
}

function loadConfig(path) {
  const config = JSON.parse(readFileSync(path, "utf8"));
  if (!isObject(config) || !Array.isArray(config.roots) || config.roots.length === 0) {
    throw new Error("projects.json must contain a nonempty roots list");
  }
  const exclude = Object.hasOwn(config, "exclude") ? config.exclude : ["node_modules", "vendor", "__pycache__"];
  if (!Array.isArray(exclude) || exclude.some((name) => typeof name !== "string" || !name)) {
    throw new Error("exclude must be a list of directory names");
  }
  const roots = [];
  for (const root of config.roots) {
    if (!isObject(root) || typeof root.path !== "string" || !root.path) throw new Error("each root needs a nonempty path");
    if (!Number.isInteger(root.depth) || root.depth < 1) throw new Error("each root needs a positive integer depth");
    const expanded = expandHome(root.path);
    if (!isAbsolute(expanded)) throw new Error("root paths must be absolute or start with ~/");
    try { roots.push({ path: canonicalPath(expanded), depth: root.depth }); } catch (error) {
      console.error(`Warning: skipping unusable root ${JSON.stringify(expanded)}: ${error.message}`);
    }
  }
  return { roots, exclude };
}

function discover(config) {
  const found = new Set();
  const excluded = new Set(config.exclude);
  for (const root of config.roots) {
    if (!isDirectory(root.path)) {
      console.error(`Warning: skipping missing root ${JSON.stringify(root.path)}`);
      continue;
    }
    const pending = [[root.path, 0]];
    while (pending.length) {
      const [directory, depth] = pending.pop();
      try {
        for (const entry of readdirSync(directory, { withFileTypes: true })) {
          // Dirent.isDirectory() does not follow symlinks, preventing cycles.
          if (entry.name.startsWith(".") || excluded.has(entry.name) || !entry.isDirectory()) continue;
          const path = canonicalPath(join(directory, entry.name));
          found.add(path);
          if (depth + 1 < root.depth) pending.push([path, depth + 1]);
        }
      } catch (error) {
        console.error(`Warning: cannot read ${JSON.stringify(directory)}: ${error.message}`);
      }
    }
  }
  return [...found].sort();
}

function pick(paths) {
  const env = Object.fromEntries(Object.entries(process.env).filter(([key]) => !key.startsWith("FZF_")));
  const result = spawnSync(commandPath("fzf"), [
    "--read0", "--print0", "--no-multi", "--layout=reverse",
    "--prompt=Project> ", "--border", "--header=Enter: open workspace | Esc: cancel",
  ], {
    env, encoding: "utf8", input: `${paths.join("\0")}\0`, stdio: ["pipe", "pipe", "inherit"],
    maxBuffer: 8 * 1024 * 1024,
  });
  if (result.error) throw result.error;
  if (result.status === 1 || result.status === 130 || result.signal === "SIGINT") return null;
  if (result.status !== 0) throw new Error(`fzf failed with exit status ${result.status}`);
  if (!result.stdout) return null;
  const selected = result.stdout.replace(/\0$/, "");
  if (!paths.includes(selected)) throw new Error("fzf returned an unexpected selection");
  return selected;
}

function resolveClient(client) {
  const requested = client || process.env.REX_CLIENT;
  const apps = (rex("client", "ls", "--json").clients || [])
    .filter((app) => app.info?.kind === "app" && app.connection_state === "connected");
  const matches = requested ? apps.filter((app) => app.client_id === requested) : apps;
  if (matches.length !== 1) throw new Error("Choose exactly one connected Rex app with --client CLIENT_ID (rex client ls)");
  return matches[0].client_id;
}

function readRegistry(path) {
  if (!existsSync(path)) return {};
  let state;
  try { state = JSON.parse(readFileSync(path, "utf8")); } catch (error) {
    if (error instanceof SyntaxError) throw new Error(`Invalid project-session registry: ${path}`);
    throw error;
  }
  if (!isObject(state) || !Object.values(state).every((mapping) => isObject(mapping)
    && Object.values(mapping).every((sid) => typeof sid === "string" && sid.length > 0))) {
    throw new Error(`Invalid project-session registry: ${path}`);
  }
  return state;
}

function matchingSessions(path, sessions, host, pickerBlock) {
  const matches = [];
  for (const session of sessions) {
    const sid = session.session_id;
    const view = rex("session", "inspect", sid, "--json");
    let matched = false;
    for (const window of view.windows || []) {
      for (const layer of window.layers || []) {
        for (const block of layer.blocks || []) {
          if (block.block_id === pickerBlock || block.creator_name !== "com.superlogical.terminal"
            || !host || block.host_id !== host) continue;
          const process = rex("block", "call", "-s", sid, "-b", block.block_id, "process");
          const cwd = process.foreground?.cwd || (process.ancestors || []).find((ancestor) => ancestor.cwd)?.cwd;
          if (cwd && canonicalPath(cwd) === path) matched = true;
        }
      }
    }
    if (matched) matches.push(sid);
  }
  return matches;
}

function projectLabel(path, sessions) {
  let base = [...basename(path)].map((char) => char === " " || !/[\p{C}\p{Z}]/u.test(char) ? char : " ").join("").trim() || "project";
  if (base.startsWith("-")) base = `project-${base}`;
  let truncated = "";
  for (const char of base) {
    if (Buffer.byteLength(truncated + char, "utf8") > 100) break;
    truncated += char;
  }
  base = truncated;
  const occupied = new Set(sessions.map((session) => session.label));
  if (!occupied.has(base)) return base;
  const suffix = createHash("sha256").update(path).digest("hex").slice(0, 8);
  let label = `${base}-${suffix}`;
  let number = 2;
  while (occupied.has(label)) label = `${base}-${suffix}-${number++}`;
  return label;
}

function openProject(path, client, pickerBlock) {
  const current = process.env.REX_SESSION;
  if (!current) throw new Error("Open the project picker from an existing Rex session (REX_SESSION is not set)");
  const directory = canonicalPath(expandHome(path));
  if (!isDirectory(directory)) throw new Error(`Project directory no longer exists: ${JSON.stringify(directory)}`);
  client = resolveClient(client);
  const status = rex("api", "call", "server.status", "{}");
  const endpoint = (status.listeners || []).find((listener) => listener.primary)?.endpoint ?? status.instance_id;
  const scope = `${status.host_id || ""}|${endpoint}`;
  const stateFile = join(process.env.XDG_STATE_HOME || join(homedir(), ".local/state"), "rex/project-sessions.json");
  const sid = withJsonLock(stateFile, 20, () => {
    const state = readRegistry(stateFile);
    const mapping = state[scope] ??= {};
    const sessions = rex("ls", "--json").sessions || [];
    let target = mapping[directory];
    if (!sessions.some((session) => session.session_id === target)) {
      const matches = matchingSessions(directory, sessions, status.host_id || "", pickerBlock);
      if (matches.length > 1) throw new Error("Multiple Rex sessions have terminals in this directory; select one manually");
      if (matches.length === 1) {
        [target] = matches;
      } else {
        if (!isDirectory(directory)) throw new Error(`Project directory no longer exists: ${JSON.stringify(directory)}`);
        target = rex("new", projectLabel(directory, sessions), "-c", directory, "--window", "Terminal", "--json")?.session_id;
        if (typeof target !== "string" || !target) {
          throw new Error("Rex did not return a session ID; inspect sessions before retrying creation");
        }
      }
      mapping[directory] = target;
      saveJson(stateFile, state, ".project-sessions-");
    }
    return target;
  });
  // Keep the project association even if Remote Control refuses the switch.
  switchSession(client, current, sid);
}

function main() {
  let pickerTab = false;
  try {
    const { values, positionals } = parseArgs({
      allowPositionals: true,
      options: {
        config: { type: "string" }, client: { type: "string" },
        "picker-tab": { type: "boolean" }, help: { type: "boolean", short: "h" },
      },
    });
    pickerTab = values["picker-tab"] || false;
    if (values.help) {
      console.log("Usage: rex-project-picker [DIRECTORY] [--config FILE] [--client CLIENT] [--picker-tab]");
      return 0;
    }
    if (positionals.length > 1) throw new Error("Expected at most one project directory");
    let [path] = positionals;
    if (path === undefined) {
      const config = values.config || join(process.env.XDG_CONFIG_HOME || join(homedir(), ".config"), "rex/projects.json");
      const paths = discover(loadConfig(config));
      if (paths.length === 0) throw new Error("No project directories found. Check your Rex projects.json roots.");
      path = pick(paths);
    }
    if (path !== null) openProject(path, values.client, pickerTab ? process.env.REX_BLOCK : undefined);
    return 0;
  } catch (error) {
    console.error(`rex-project-picker: ${error.message}`);
    if (pickerTab) {
      process.stdout.write("Press Enter to close the picker… ");
      try { readSync(0, Buffer.alloc(1), 0, 1, null); } catch { /* The picker may already have closed. */ }
    }
    return 1;
  }
}

process.exitCode = main();
