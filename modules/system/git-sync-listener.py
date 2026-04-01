#!/usr/bin/env python3
"""Git sync listener — слушает UDP порт и делает git pull при сигнале."""
import socket
import subprocess
import logging
import os
import sys

PORT = 9876
REPO_DIR = "/etc/nixos"
PID_FILE = "/run/git-sync-listener.pid"

logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s git-sync: %(message)s",
    handlers=[
        logging.StreamHandler(sys.stdout),
    ],
)
log = logging.getLogger("git-sync")


def check_prerequisites():
    """Проверяем что git и репозиторий доступны."""
    if not os.path.isdir(os.path.join(REPO_DIR, ".git")):
        log.error("Git repo not found at %s", REPO_DIR)
        return False
    log.info("Prerequisites OK: repo=%s", REPO_DIR)
    return True


def git_pull():
    """Выполняет git pull с полным логированием."""
    log.info("=== Starting git pull ===")
    try:
        result = subprocess.run(
            ["git", "pull", "--rebase", "--autostash"],
            cwd=REPO_DIR,
            capture_output=True,
            text=True,
            timeout=120,
            env={**os.environ, "GIT_TERMINAL_PROMPT": "0"},
        )
        log.info("stdout: %s", result.stdout.strip())
        if result.returncode == 0:
            log.info("Pull successful")
        else:
            log.warning("Pull failed (rc=%d): %s", result.returncode, result.stderr.strip())
    except subprocess.TimeoutExpired:
        log.error("Pull timed out after 120s")
    except Exception as e:
        log.error("Pull error: %s", e)
    log.info("=== Done ===")


def main():
    log.info("Starting git-sync listener")
    log.info("PID: %d", os.getpid())

    if not check_prerequisites():
        log.error("Prerequisites check failed, exiting")
        sys.exit(1)

    # Write PID file
    try:
        with open(PID_FILE, "w") as f:
            f.write(str(os.getpid()))
    except Exception as e:
        log.warning("Cannot write PID file: %s", e)

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.bind(("0.0.0.0", PORT))
    log.info("Listening on UDP 0.0.0.0:%d", PORT)

    while True:
        try:
            data, addr = sock.recvfrom(1024)
            raw = data.hex()
            msg = data.decode("utf-8", errors="replace").strip()
            log.info("Received from %s: raw=%s msg='%s'", addr, raw, msg)

            if msg == "git-pull":
                log.info("Matched 'git-pull' command")
                git_pull()
            else:
                log.info("Unknown command, ignoring")
        except KeyboardInterrupt:
            log.info("Interrupted, exiting")
            break
        except Exception as e:
            log.error("Loop error: %s", e, exc_info=True)

    # Cleanup
    try:
        os.unlink(PID_FILE)
    except OSError:
        pass


if __name__ == "__main__":
    main()
