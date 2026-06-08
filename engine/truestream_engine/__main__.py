import sys
import json
from pathlib import Path

from truestream_engine.paths import set_paths
from truestream_engine.bootstrap import bootstrap
from truestream_engine.formats import get_formats


def cmd_bootstrap():
    result = bootstrap()
    print(json.dumps(result, indent=2, default=str))


def cmd_formats(url: str):
    result = get_formats(url)
    print(json.dumps(result, indent=2, default=str))


def cmd_help():
    print("Usage: python -m truestream_engine <command> [args]")
    print()
    print("Commands:")
    print("  bootstrap            Check engine health")
    print("  formats <url>        List available formats for URL")
    print("  help                 Show this help")


def main():
    if len(sys.argv) < 2:
        cmd_help()
        return

    command = sys.argv[1]

    if command == "bootstrap":
        cmd_bootstrap()
    elif command == "formats" and len(sys.argv) >= 3:
        cmd_formats(sys.argv[2])
    else:
        cmd_help()


if __name__ == "__main__":
    main()
