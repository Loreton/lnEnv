#!/usr/bin/env python3
# ========================================
# updated by ...: Loreto Notarantonio
# Date .........: 11-05-2026 15.42.25
# ========================================
#### chatGPT
from __future__ import annotations

import sys; sys.dont_write_bytecode = True


import argparse
import difflib
import os
import shutil
import socket
import subprocess
import sys
from datetime import datetime
from pathlib import Path


VERSION = "V2026-05-11"


# =========================================================
# COLORS
# =========================================================
class C:
    RESET = "\033[0m"

    RED = "\033[91m"
    GREEN = "\033[92m"
    YELLOW = "\033[93m"
    CYAN = "\033[96m"
    PURPLE = "\033[95m"
    GRAY = "\033[90m"


# auto disable colors if not tty
if not sys.stdout.isatty():
    for attr in dir(C):
        if not attr.startswith("_"):
            setattr(C, attr, "")


# =========================================================
#
# =========================================================
class CrontabUpdater:

    def __init__(self, execute: bool = False):

        self.execute = execute
        self.dry_run = "" if execute else "--dry-run"

        self.now = datetime.now().strftime("%Y%m%d_%H%M")
        self.hostname = socket.gethostname().split(".")[0].lower()

        self.host_config_dir = os.environ.get("ln_HOST_CONFIG_DIR")

        if not self.host_config_dir:
            self.error("environment variable ln_HOST_CONFIG_DIR not set")

        self.source_crontab_file = (
            Path(self.host_config_dir)
            / "crontab"
            / "crontab.conf"
        )

        self.backup_file = (Path("/tmp/crontab") / f"crontab_{self.now}.conf" )

        self.crontab_bin = shutil.which("crontab")

        if not self.crontab_bin:
            self.error("crontab command not found")

    # =====================================================
    #
    # =====================================================
    @staticmethod
    def error(msg: str, rcode: int = 1):
        print(f"{C.RED}ERROR: {msg}{C.RESET}")
        sys.exit(rcode)

    # =====================================================
    #
    # =====================================================
    def ensure_paths(self):
        if not self.source_crontab_file.exists():
            self.error(f"file not found: {self.source_crontab_file}")

        self.backup_file.parent.mkdir(parents=True, exist_ok=True, )

    # =====================================================
    #
    # =====================================================
    def run(
        self,
        descr: str,
        cmd: list[str],
        stdout_file=None,
    ):

        print()
        print(f"{C.GRAY}------[{self.hostname}]------------------------")
        print(f"{C.CYAN}{descr}{C.RESET}")

        cmd_str = " ".join(cmd)

        print(
            f"{C.PURPLE}[{self.dry_run}] "
            f"{C.CYAN}{cmd_str}{C.RESET}"
        )

        if not self.execute:
            print(f"{C.YELLOW}rcode:   0")
            print(f"ret_val: {self.dry_run}{C.RESET}")
            return ""

        try:

            if stdout_file:
                with open(stdout_file, "w") as fd:

                    result = subprocess.run(
                        cmd,
                        stdout=fd,
                        stderr=subprocess.PIPE,
                        text=True,
                        check=True,
                    )
                    ret_val = ""

            else:

                result = subprocess.run(
                    cmd,
                    capture_output=True,
                    text=True,
                    check=True,
                )

                ret_val = result.stdout.strip()

            print(f"{C.YELLOW}rcode:   0")
            print(f"ret_val: {ret_val}{C.RESET}")

            return ret_val

        except subprocess.CalledProcessError as exc:

            print(f"{C.RED}rcode: {exc.returncode}{C.RESET}")

            if exc.stderr:
                print(exc.stderr)

            sys.exit(exc.returncode)

    # =====================================================
    #
    # =====================================================
    def save_current_crontab(self):

        self.run(
            descr="save current crontab",
            cmd=[self.crontab_bin, "-l"],
            stdout_file=self.backup_file,
        )

    # =====================================================
    #
    # =====================================================
    def display_diff(self) -> bool:

        print()
        print(
            f"{C.CYAN}"
            "----------- diff result -------------------------"
        )

        current = self.backup_file.read_text().splitlines()
        new = self.source_crontab_file.read_text().splitlines()

        diff = list(
            difflib.unified_diff(
                current,
                new,
                fromfile=str(self.backup_file),
                tofile=str(self.source_crontab_file),
                lineterm="",
            )
        )

        if diff:
            for line in diff:
                print(line)

            print(f"{C.YELLOW}rcode: 1{C.RESET}")
            return True

        print(f"{C.GREEN}No differences found{C.RESET}")
        print(f"{C.YELLOW}rcode: 0{C.RESET}")

        return False

    # =====================================================
    #
    # =====================================================
    def load_new_crontab(self):

        self.run(
            descr="load new crontab",
            cmd=[
                self.crontab_bin,
                str(self.source_crontab_file),
            ],
        )

    # =====================================================
    #
    # =====================================================
    def main(self):

        self.ensure_paths()

        self.save_current_crontab()

        diff_found = self.display_diff()

        if diff_found:
            self.load_new_crontab()
        else:
            print()
            print(
                f"{C.GREEN}"
                "Crontab unchanged"
                f"{C.RESET}"
            )


# =========================================================
#
# =========================================================
def parse_args():

    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--go",
        action="store_true",
        help="execute commands",
    )

    parser.add_argument(
        "--version",
        action="version",
        version=VERSION,
    )

    return parser.parse_args()


# =========================================================
#
# =========================================================
def main():

    args = parse_args()

    updater = CrontabUpdater(
        execute=args.go,
    )

    updater.main()


# =========================================================
#
# =========================================================
if __name__ == "__main__":
    main()