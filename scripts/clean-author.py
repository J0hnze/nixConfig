#!/usr/bin/env python3

import argparse
import os
import re
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime


@dataclass(frozen=True)
class Args:
    email: str
    date: str
    time: str
    name: str | None
    timezone: str
    force: bool


def run(cmd: list[str], *, check: bool = True, capture: bool = False) -> subprocess.CompletedProcess:
    return subprocess.run(
        cmd,
        check=check,
        text=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
    )


def require_git_repo() -> None:
    try:
        run(["git", "rev-parse", "--is-inside-work-tree"], capture=True)
    except subprocess.CalledProcessError:
        print("error: not inside a git work tree", file=sys.stderr)
        sys.exit(2)


def require_clean_worktree(force: bool) -> None:
    status = run(["git", "status", "--porcelain=v1"], capture=True).stdout.strip()
    if status and not force:
        print("error: working tree is not clean.", file=sys.stderr)
        print("       commit/stash changes, or re-run with --force", file=sys.stderr)
        sys.exit(2)


def validate_email(email: str) -> None:
    if not re.fullmatch(r"[^@\s]+@[^@\s]+\.[^@\s]+", email):
        print(f"error: invalid email: {email!r}", file=sys.stderr)
        sys.exit(2)


def parse_ddmmyyyy(date_str: str) -> tuple[int, int, int]:
    m = re.fullmatch(r"(\d{2})/(\d{2})/(\d{4})", date_str)
    if not m:
        print("error: --date must be DD/MM/YYYY (e.g. 01/01/2026)", file=sys.stderr)
        sys.exit(2)
    day, month, year = map(int, m.groups())
    return year, month, day


def parse_hhmm(time_str: str) -> tuple[int, int]:
    m = re.fullmatch(r"(\d{2}):(\d{2})", time_str)
    if not m:
        print("error: --time must be HH:MM (24h) (e.g. 20:00)", file=sys.stderr)
        sys.exit(2)
    hour, minute = map(int, m.groups())
    if hour > 23 or minute > 59:
        print("error: invalid --time value", file=sys.stderr)
        sys.exit(2)
    return hour, minute


def format_git_datetime(date_str: str, time_str: str, timezone: str) -> str:
    year, month, day = parse_ddmmyyyy(date_str)
    hour, minute = parse_hhmm(time_str)
    dt = datetime(year, month, day, hour, minute, 0)

    try:
        from zoneinfo import ZoneInfo  # py3.9+

        dt = dt.replace(tzinfo=ZoneInfo(timezone))
        return dt.strftime("%Y-%m-%dT%H:%M:%S%z")
    except Exception:
        return dt.strftime("%Y-%m-%dT%H:%M:%S")


def default_name_from_email(email: str) -> str:
    return email.split("@", 1)[0]


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Rewrite git history to set author/committer email (and optionally name) and force all commit dates."
    )
    parser.add_argument("--email", required=True, help="New author/committer email (applied to all commits).")
    parser.add_argument("--date", required=True, help="DD/MM/YYYY (applied to all commits).")
    parser.add_argument("--time", required=True, help="HH:MM 24h (applied to all commits).")
    parser.add_argument("--name", help="New author/committer name (defaults to local part of email).")
    parser.add_argument(
        "--timezone",
        default=os.environ.get("TZ", "UTC"),
        help="IANA timezone name (e.g. Europe/London). Defaults to $TZ or UTC.",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Allow running with a dirty work tree (not recommended).",
    )
    ns = parser.parse_args()

    args = Args(
        email=ns.email,
        date=ns.date,
        time=ns.time,
        name=ns.name,
        timezone=ns.timezone,
        force=ns.force,
    )

    validate_email(args.email)
    require_git_repo()
    require_clean_worktree(args.force)

    name = args.name or default_name_from_email(args.email)
    git_dt = format_git_datetime(args.date, args.time, args.timezone)

    print("This will rewrite history for ALL refs (branches + tags).")
    print(f"- name:  {name}")
    print(f"- email: {args.email}")
    print(f"- date:  {git_dt} (timezone={args.timezone})")
    print("")
    print("WARNING: This rewrites commit SHAs. You will need to force-push and collaborators must re-clone.")
    print("")
    response = input("Type 'rewrite' to continue: ").strip()
    if response != "rewrite":
        print("aborted.")
        return 1

    env_filter = f"""
GIT_AUTHOR_NAME={name!r}
GIT_AUTHOR_EMAIL={args.email!r}
GIT_COMMITTER_NAME={name!r}
GIT_COMMITTER_EMAIL={args.email!r}
GIT_AUTHOR_DATE={git_dt!r}
GIT_COMMITTER_DATE={git_dt!r}
export GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL GIT_AUTHOR_DATE GIT_COMMITTER_DATE
""".strip().replace("\n", "; ")

    run(
        [
            "git",
            "filter-branch",
            "-f",
            "--env-filter",
            env_filter,
            "--tag-name-filter",
            "cat",
            "--",
            "--all",
        ],
        check=True,
    )

    print("")
    print("Done. Suggested follow-ups:")
    print("- Remove backup refs: `rm -rf .git/refs/original/`")
    print("- Expire reflogs: `git reflog expire --expire=now --all`")
    print("- GC: `git gc --prune=now --aggressive`")
    print("- Force push: `git push --force --tags origin <branch>`")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

