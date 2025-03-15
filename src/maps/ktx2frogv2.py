#!/usr/bin/env python3
"""Convert a KTX .bot waypoint file into a Frogbot v2 file
(TODO: also do conversion in other direction).
2025-03, Alexander Thomas aka DrLex.

Released under GPL license."""

import argparse
import re
import sys

KTX_PATHF_TO_V2 = {
    "r": 512,  # rocket jump
    "j": 1024,  # jump ledge?
    "v": 0,  # not sure what this is, something with platforms, no equivalent in v2 Frog?
}

KTX_MARKF_TO_V2 = {
    "f": 1,  # unreachable???
}


def print_neat_lines(text: str, item_count: int, max_items: int) -> int:
    """Print line, increment item_count, and add newline if item_count exceeds max_items.
    Returns new item_count."""
    print(text, end="")
    item_count += 1
    if item_count >= max_items:
        print("")
        item_count = 0
    return item_count


def transform_ktx_files(args: argparse.Namespace) -> None:
    """Transforms KTX waypoint source files listed in args.list_file
    into Frogbot v2 QuakeC format."""
    for bot_file in args.files:
        # Although files should normally be pure ASCII, use a bogus encoding
        # that allows pretty much any byte value
        with open(bot_file, 'r+', encoding='iso8859_15') as qc_file:
            code_lines = qc_file.readlines()
            section = 0
            item_count = 0
            print("void() map_MAPNAMEHERE =\n{")
            for (i, line) in enumerate(code_lines):
                if section == 0:
                    if mat := re.match(r"^CreateMarker (-?\d+) (-?\d+) (-?\d+)", line):
                        item_count = print_neat_lines(
                            f"N({mat.group(1)},{mat.group(2)},{mat.group(3)});", item_count, 4
                        )
                        continue
                    if item_count:
                        print("")
                    print("LSQ();")
                    section = 1
                    item_count = 0
                if mat := re.match(r"^SetZone (\d+) (\d+)", line):
                    item_count = print_neat_lines(
                        f"Z{mat.group(2)}(m{mat.group(1)});", item_count, 8
                    )
                elif mat := re.match(r"^SetGoal (\d+) (\d+)", line):
                    item_count = print_neat_lines(
                        f"G{mat.group(2)}(m{mat.group(1)});", item_count, 8
                    )
                elif mat := re.match(r"^SetMarkerPath (\d+) (\d+) (\d+)", line):
                    item_count = print_neat_lines(
                        f"m{mat.group(1)}.P{mat.group(2)}=m{mat.group(3)};", item_count, 8
                    )
                elif mat := re.match(r"^SetMarkerPathFlags (\d+) (\d+) (.+)", line):
                    path_mode = KTX_PATHF_TO_V2.get(mat.group(3), 0)
                    if not path_mode:
                        print(f"Skipping path mode flag {mat.group(3)};", file=sys.stderr)
                        continue
                    item_count = print_neat_lines(
                        f"m{mat.group(1)}.D{mat.group(2)}={path_mode};", item_count, 8
                    )
                elif mat := re.match(r"^SetMarkerFlag (\d+) (.+)", line):
                    mark_mode = KTX_MARKF_TO_V2.get(mat.group(2), 0)
                    if not mark_mode:
                        print(f"Skipping marker mode flag {mat.group(2)};", file=sys.stderr)
                        continue
                    item_count = print_neat_lines(
                        f"m{mat.group(1)}.T={mark_mode};", item_count, 8
                    )
                elif args.verbose:
                    print(f"Skipping line {i}: {line};", file=sys.stderr)
            if item_count:
                print("")
            print("};")


def main():
    """Script entry point"""
    parser = argparse.ArgumentParser(
        description=("Converts KTX .bot waypoint files into Frogbot v2 QuakeC source files. "
        "In the future, the reverse conversion may also be offered."))
    parser.add_argument('-v', '--verbose', action='store_true',
                        help="verbose output.")
    parser.add_argument('files', type=str, nargs="+",
                        help="Input files to be converted")
    args = parser.parse_args()

    if args.verbose:
        print("Verbose output enabled", file=sys.stderr)

    transform_ktx_files(args)

if __name__ == '__main__':
    main()
