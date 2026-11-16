#!/usr/bin/env python3
"""Pick Rex sessions and toggle the last two selected through this helper."""

from __future__ import annotations

import argparse
import fcntl
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


def command_path(name: str) -> str:
    found = shutil.which(name)
    if found:
        return found
    # App-launched actions do not inherit the login shell's PATH.
    directories = [Path.home() / ".local/bin", Path("/opt/homebrew/bin"), Path("/usr/local/bin")]
    if name == "rex":
        directories.insert(0, Path.home() / (
            "Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/"
            "Rex Server.app/Contents/MacOS"
        ))
        directories.append(Path("/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS"))
    for directory in directories:
        candidate = directory / name
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return str(candidate)
    raise RuntimeError(f"Could not find {name}; install it or add its directory to Rex's PATH")


def rex(*args):
    # Like rex-project-picker, manage sessions on this machine's server.
    env = dict(os.environ)
    env.pop("REX_SERVER", None)
    try:
        result = subprocess.run([command_path("rex"), *args], stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                text=True, timeout=10, env=env)
    except subprocess.TimeoutExpired as error:
        raise RuntimeError("Rex timed out; inspect the app before retrying the switch") from error
    if result.returncode:
        raise RuntimeError(result.stderr.strip() or f"Rex exited with status {result.returncode}")
    try:
        return json.loads(result.stdout) if result.stdout.strip() else None
    except ValueError as error:
        raise RuntimeError("Rex returned invalid JSON") from error


def history_path() -> Path:
    config = Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")
    return config / "rex/session-history.json"


def read_history(path: Path) -> dict:
    try:
        state = json.loads(path.read_text()) if path.exists() else {}
    except ValueError as error:
        raise ValueError(f"Invalid session history: {path}") from error
    valid = isinstance(state, dict)
    if valid:
        for clients in state.values():
            if not isinstance(clients, dict):
                valid = False
                break
            for entry in clients.values():
                if (not isinstance(entry, dict) or set(entry) != {"current", "previous"}
                        or any(not isinstance(value, str) or not value for value in entry.values())):
                    valid = False
                    break
    if not valid:
        raise ValueError(f"Invalid session history: {path}")
    return state


def save_history(path: Path, state: dict):
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, prefix=".session-history-", delete=False) as handle:
            temporary = Path(handle.name)
            json.dump(state, handle, indent=2)
            handle.write("\n")
            handle.flush()
            os.fsync(handle.fileno())
        temporary.replace(path)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


def switch(client: str, current: str, target: str | None = None, *, state_path: Path | None = None) -> str:
    path = state_path if state_path is not None else history_path()
    path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    # Keep a separate lock inode: save_history replaces the JSON file atomically.
    with path.with_suffix(".lock").open("a") as lock:
        # A queued toggle would carry stale action context. Reject it instead of silently replaying it.
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | (fcntl.LOCK_NB if target is None else 0))
        except BlockingIOError as error:
            raise RuntimeError("A session switch is already in progress; wait before toggling again") from error
        apps = rex("client", "ls", "--json").get("clients") or []
        if not any(app.get("client_id") == client and app.get("info", {}).get("kind") == "app"
                   and app.get("connection_state") == "connected" for app in apps):
            raise RuntimeError("Choose a connected Rex app with --client CLIENT_ID (rex client ls)")
        status = rex("api", "call", "server.status", "{}")
        scope = status.get("host_id") or status["instance_id"]
        state = read_history(path)
        entry = state.get(scope, {}).get(client)
        if target is None:
            if not entry:
                raise RuntimeError("No previous session yet; first switch with the session or project picker")
            # A native sidebar click may have changed the invoking session since the last tracked switch.
            target = entry["previous"] if entry["current"] == current else entry["current"]
        sessions = rex("ls", "--json").get("sessions") or []
        available = {session["session_id"] for session in sessions}
        if current not in available:
            raise RuntimeError("The source session no longer exists; reopen the picker")
        if target not in available:
            raise RuntimeError("The previous or selected session was closed; choose another session with the picker")
        if target == current:
            return target
        rex("-C", client, "do", "session.select", f"session_id={target}")
        state.setdefault(scope, {})[client] = {"current": target, "previous": current}
        try:
            save_history(path, state)
        except OSError as error:
            raise RuntimeError(f"Session switched, but history could not be saved: {error}") from error
    return target


def pick(sessions: list[dict]) -> str | None:
    if not sessions:
        raise RuntimeError("No Rex sessions available")
    records = {}
    for session in sessions:
        # Labels are display-only: control characters cannot alter fzf records or terminal output.
        label = "".join(char if char.isprintable() else " " for char in session["label"])
        sid = session["session_id"]
        records[f"{sid}\t{label}  [{sid}]"] = sid
    env = {key: value for key, value in os.environ.items() if not key.startswith("FZF_")}
    result = subprocess.run(
        [command_path("fzf"), "--read0", "--print0", "--no-multi", "--layout=reverse", "--delimiter=\t", "--with-nth=2..",
         "--prompt=Session> ", "--border", "--header=Enter: switch session | Esc: cancel"],
        input=("\0".join(records) + "\0").encode("utf-8"), stdout=subprocess.PIPE, env=env,
    )
    if result.returncode in (1, 130):
        return None
    if result.returncode:
        raise RuntimeError(f"fzf failed with exit status {result.returncode}")
    selected = result.stdout.removesuffix(b"\0").decode("utf-8")
    if selected not in records:
        raise RuntimeError("fzf returned an unexpected selection")
    return records[selected]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("pick", "toggle", "select"))
    parser.add_argument("--client", required=True, help="full ID of the Rex app to switch")
    parser.add_argument("--current", required=True, help="full ID of the invoking session")
    parser.add_argument("--session", help="full target session ID for select")
    parser.add_argument("--picker-tab", action="store_true", help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.command == "select" and not args.session:
        parser.error("select requires --session")
    if args.command != "select" and args.session:
        parser.error("--session is only valid with select")
    try:
        target = args.session
        if args.command == "pick":
            target = pick(rex("ls", "--json").get("sessions") or [])
            if target is None:
                return 0
        switch(args.client, args.current, target)
        return 0
    except (OSError, ValueError, RuntimeError) as error:
        print(f"rex-session-picker: {error}", file=sys.stderr)
        if args.picker_tab:
            try:
                input("Press Enter to close the picker… ")
            except (EOFError, KeyboardInterrupt):
                pass
        return 1
    except KeyboardInterrupt:
        return 0


if __name__ == "__main__":
    sys.exit(main())
