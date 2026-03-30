#!/usr/bin/env python3
"""
Deploy and start the stats server for the OpenClaw iOS dashboard.
- Checks if stats_server.py exists in the workspace
- Installs missing Python deps
- Starts the server
- Registers watchdog cron via openclaw CLI
"""
import json
import os
import subprocess
import sys
import time

STATS_SCRIPTS_DIR = os.path.join(
    os.path.expanduser("~/.openclaw/workspace/orchestrator/scripts/dashboard")
)
STATS_SERVER_SCRIPT = os.path.join(STATS_SCRIPTS_DIR, "stats_server.py")
ENSURE_SCRIPT = os.path.join(STATS_SCRIPTS_DIR, "ensure_stats_server.sh")


def run(cmd, timeout=30, env=None):
    e = os.environ.copy()
    if env:
        e.update(env)
    r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=timeout, env=e)
    return r.returncode, r.stdout.strip(), r.stderr.strip()


def is_running():
    code, out, _ = run("pgrep -f stats_server.py")
    return code == 0


def get_gateway_token():
    code, out, _ = run("openclaw config get gateway.auth.token 2>/dev/null")
    if code == 0 and out and out != "null":
        return out.strip('"')
    # Fallback from config file
    config_path = os.path.expanduser("~/.openclaw/openclaw.json")
    if os.path.exists(config_path):
        try:
            import re
            with open(config_path) as f:
                content = f.read()
            m = re.search(r'"token"\s*:\s*"([^"]+)"', content)
            if m:
                return m.group(1)
        except Exception:
            pass
    return None


def start_server(token):
    if not os.path.exists(STATS_SERVER_SCRIPT):
        print(json.dumps({"ok": False, "error": f"stats_server.py not found at {STATS_SERVER_SCRIPT}"}))
        sys.exit(1)

    if os.path.exists(ENSURE_SCRIPT):
        os.chmod(ENSURE_SCRIPT, 0o755)
        code, out, err = run(
            f"bash {ENSURE_SCRIPT}",
            env={"OPENCLAW_GATEWAY_TOKEN": token or ""}
        )
        success = code == 0
    else:
        # Fallback: start directly
        cmd = (
            f"OPENCLAW_GATEWAY_TOKEN='{token}' "
            f"nohup python3 {STATS_SERVER_SCRIPT} >> /tmp/stats_server.log 2>&1 &"
        )
        code, out, err = run(cmd)
        time.sleep(1)
        success = is_running()

    return success


def register_watchdog_cron(token):
    """Register a 24h watchdog cron that restarts the stats server if down."""
    # Check if watchdog already exists
    code, out, _ = run("openclaw cron list --json 2>/dev/null")
    if code == 0 and out:
        try:
            crons = json.loads(out)
            for c in (crons.get("results") or crons if isinstance(crons, list) else []):
                msg = (c.get("payload") or {}).get("message", "")
                if "stats" in msg.lower() and "watchdog" in msg.lower():
                    return {"already_exists": True, "id": c.get("id")}
        except Exception:
            pass
    # Don't register here — agent will do it via cron tool
    return {"registered": False, "note": "Agent should register watchdog cron via cron tool"}


def main():
    if is_running():
        print(json.dumps({
            "ok": True,
            "already_running": True,
            "message": "Stats server is already running"
        }))
        return

    token = get_gateway_token()
    if not token:
        print(json.dumps({
            "ok": False,
            "error": "Could not determine gateway token. Set OPENCLAW_GATEWAY_TOKEN env var or configure gateway.auth.token"
        }))
        sys.exit(1)

    success = start_server(token)
    watchdog = register_watchdog_cron(token)

    result = {
        "ok": success,
        "started": success,
        "already_running": False,
        "watchdog": watchdog,
        "message": "Stats server started successfully" if success else "Failed to start stats server — check /tmp/stats_server.log"
    }
    print(json.dumps(result, indent=2))
    if not success:
        sys.exit(1)


if __name__ == "__main__":
    main()
