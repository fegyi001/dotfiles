// Shared runtime for the Rex session and project pickers (macOS, Node.js 20+).
import { spawnSync } from "node:child_process";
import { randomUUID } from "node:crypto";
import {
  accessSync,
  closeSync,
  constants,
  existsSync,
  fsyncSync,
  mkdirSync,
  openSync,
  renameSync,
  statSync,
  unlinkSync,
  writeFileSync,
} from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";

export const isObject = (value) =>
  value !== null && typeof value === "object" && !Array.isArray(value);

export function commandPath(name) {
  const home = homedir();
  const directories = (process.env.PATH || "").split(":");
  if (name === "rex") {
    directories.push(
      join(
        home,
        "Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS",
      ),
    );
  }
  directories.push(
    join(home, ".local/bin"),
    "/opt/homebrew/bin",
    "/usr/local/bin",
  );
  if (name === "rex")
    directories.push(
      "/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS",
    );
  for (const directory of directories) {
    const candidate = join(directory, name);
    try {
      accessSync(candidate, constants.X_OK);
      if (statSync(candidate).isFile()) return candidate;
    } catch {
      /* Try the next installed location. */
    }
  }
  throw new Error(
    `Could not find ${name}; install it or add its directory to Rex's PATH`,
  );
}

export function rex(args, timeout = 10_000) {
  const env = { ...process.env };
  delete env.REX_SERVER; // Both pickers operate on this machine's server.
  const result = spawnSync(commandPath("rex"), args, {
    env,
    encoding: "utf8",
    timeout,
    maxBuffer: 8 * 1024 * 1024,
  });
  if (result.error) {
    if (result.error.code === "ETIMEDOUT")
      throw new Error(
        "Rex timed out; inspect sessions before retrying creation or switching",
      );
    throw result.error;
  }
  if (result.status !== 0)
    throw new Error(
      result.stderr.trim() || `Rex exited with status ${result.status}`,
    );
  try {
    return result.stdout.trim() ? JSON.parse(result.stdout) : null;
  } catch {
    throw new Error(
      "Rex returned invalid JSON; inspect sessions before retrying creation or switching",
    );
  }
}

export function saveJson(path, state, prefix = ".session-history-") {
  const temporary = join(dirname(path), `${prefix}${randomUUID()}`);
  let fd;
  try {
    fd = openSync(temporary, "wx", 0o600);
    writeFileSync(fd, `${JSON.stringify(state, null, 2)}\n`);
    fsyncSync(fd);
    closeSync(fd);
    fd = undefined;
    renameSync(temporary, path);
  } finally {
    if (fd !== undefined) closeSync(fd);
    if (existsSync(temporary)) unlinkSync(temporary);
  }
}

export function withJsonLock(path, waitSeconds, operation) {
  mkdirSync(dirname(path), { recursive: true, mode: 0o700 });
  const fd = openSync(path.replace(/\.json$/, ".lock"), "a", 0o600);
  try {
    // macOS lockf locks an inherited descriptor. The parent keeps the same open-file
    // description alive, so the kernel lock lasts until closeSync(fd), even after lockf exits.
    const result = spawnSync(
      "/usr/bin/lockf",
      ["-s", "-t", String(waitSeconds), "3"],
      {
        stdio: ["ignore", "pipe", "pipe", fd],
        encoding: "utf8",
        timeout: (waitSeconds + 2) * 1000,
      },
    );
    if (result.error) throw result.error;
    if (result.status === 75)
      throw new Error(
        "A session switch is already in progress; wait before trying again",
      );
    if (result.status !== 0)
      throw new Error(
        result.stderr.trim() || "Could not lock Rex session state",
      );
    return operation();
  } finally {
    closeSync(fd);
  }
}
