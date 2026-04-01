#!/usr/bin/env python3
"""Git sync listener — слушает UDP порт и делает git pull при сигнале."""
import socket
import subprocess
import logging
import sys

PORT = 9876
REPO_DIR = "/etc/nixos"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s git-sync: %(message)s",
)
log = logging.getLogger("git-sync")


def git_pull():
    log.info("Received git-pull signal, pulling changes...")
    try:
        result = subprocess.run(
            ["git", "pull", "--rebase", "--autostash"],
            cwd=REPO_DIR,
            capture_output=True,
            text=True,
            timeout=60,
        )
        if result.returncode == 0:
            log.info("Pull successful")
        else:
            log.warning("Pull failed: %s", result.stderr.strip())
    except subprocess.TimeoutExpired:
        log.error("Pull timed out")
    except Exception as e:
        log.error("Pull error: %s", e)


def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(("0.0.0.0", PORT))
    log.info("Listening on UDP port %d", PORT)

    while True:
        try:
            data, addr = sock.recvfrom(1024)
            msg = data.decode().strip()
            if msg == "git-pull":
                log.info("Signal from %s", addr)
                git_pull()
        except KeyboardInterrupt:
            break
        except Exception as e:
            log.error("Error: %s", e)


if __name__ == "__main__":
    main()
