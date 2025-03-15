#!/usr/bin/env python3
"""Convert KTX .bot waypoint files into Frogbot v2 files
(TODO: also do conversion in other direction).
2025-03, Alexander Thomas aka DrLex.

Released under GPL license."""

import argparse
import os
import re
import sys
from typing import TextIO


KTX_PATHF_TO_V2 = {
    "r": 512,  # rocket jump
    "j": 1024,  # jump ledge?
    "v": 0,  # not sure what this is, something with platforms, no equivalent in v2 Frog?
}

KTX_MARKF_TO_V2 = {
    "f": 1,  # unreachable???
}


def print_neat_lines(text: str, o_stream: TextIO, item_count: int, max_items: int) -> int:
    """Print line, increment item_count, and add newline if item_count exceeds max_items.
    Returns new item_count."""
    print(text, end="", file=o_stream)
    item_count += 1
    if item_count >= max_items:
        print("", file=o_stream)
        item_count = 0
    return item_count


def ktx_to_frog2(
    args: argparse.Namespace,
    map_name: str,
    in_stream: TextIO,
    out_stream: TextIO
) -> None:
    """Transforms a KTX waypoint source file stream into Frogbot v2 QuakeC format."""
    code_lines = in_stream.readlines()
    section = 0
    item_count = 0
    print(f"void() map_{map_name} =\n{{", file=out_stream)
    for (i, line) in enumerate(code_lines):
        if section == 0:
            if mat := re.match(r"^CreateMarker (-?\d+) (-?\d+) (-?\d+)", line):
                item_count = print_neat_lines(
                    f"N({mat.group(1)},{mat.group(2)},{mat.group(3)});",
                    out_stream, item_count, 4
                )
                continue
            if item_count:
                print("", file=out_stream)
            print("LSQ();", file=out_stream)
            section = 1
            item_count = 0
        if mat := re.match(r"^SetZone (\d+) (\d+)", line):
            item_count = print_neat_lines(
                f"Z{mat.group(2)}(m{mat.group(1)});",
                out_stream, item_count, 8
            )
        elif mat := re.match(r"^SetGoal (\d+) (\d+)", line):
            item_count = print_neat_lines(
                f"G{mat.group(2)}(m{mat.group(1)});",
                out_stream, item_count, 8
            )
        elif mat := re.match(r"^SetMarkerPath (\d+) (\d+) (\d+)", line):
            item_count = print_neat_lines(
                f"m{mat.group(1)}.P{mat.group(2)}=m{mat.group(3)};",
                out_stream, item_count, 8
            )
        elif mat := re.match(r"^SetMarkerPathFlags (\d+) (\d+) (.+)", line):
            path_mode = KTX_PATHF_TO_V2.get(mat.group(3), 0)
            if not path_mode:
                print(f"Skipping path mode flag {mat.group(3)};", file=sys.stderr)
                continue
            item_count = print_neat_lines(
                f"m{mat.group(1)}.D{mat.group(2)}={path_mode};",
                out_stream, item_count, 8
            )
        elif mat := re.match(r"^SetMarkerFlag (\d+) (.+)", line):
            mark_mode = KTX_MARKF_TO_V2.get(mat.group(2), 0)
            if not mark_mode:
                print(f"Skipping marker mode flag {mat.group(2)};", file=sys.stderr)
                continue
            item_count = print_neat_lines(
                f"m{mat.group(1)}.T={mark_mode};",
                out_stream, item_count, 8
            )
        elif args.verbose:
            print(f"Skipping line {i}: {line};", file=sys.stderr)
    if item_count:
        print("", file=out_stream)
    print("};", file=out_stream)


def transform_ktx_files(args: argparse.Namespace) -> None:
    """Transforms KTX waypoint source files listed in args.list_file
    into Frogbot v2 QuakeC format."""
    for bot_file in args.files:
        map_name = re.sub(r"(\..+)?$", "", os.path.basename(bot_file))
        out_file = f"map_{map_name}.qc"
        if os.path.exists(out_file):
            if not args.force:
                print(
                    f"Skipping {bot_file} because output file {out_file} exists, "
                    "use --force to overwrite",
                    file=sys.stderr
                )
                continue
            if args.verbose:
                print(f"Overwriting existing {out_file}")

        # Although files should normally be pure ASCII, use a bogus encoding
        # that allows pretty much any byte value
        with open(bot_file, 'r+', encoding='iso8859_15') as ktx_file:
            with open(out_file, 'w', encoding='iso8859_15') as qc_file:
                ktx_to_frog2(args, map_name, ktx_file, qc_file)


def main():
    """Script entry point"""
    parser = argparse.ArgumentParser(
        description=("Converts KTX .bot waypoint files into Frogbot v2 QuakeC source files. "
        "In the future, the reverse conversion may also be offered. "
        "Output files are written to working directory."))
    parser.add_argument('-v', '--verbose', action='store_true',
                        help="verbose output")
    parser.add_argument('-f', '--force', action='store_true',
                        help="overwrite existing output files")
    parser.add_argument('files', type=str, nargs="+",
                        help="Input files to be converted")
    args = parser.parse_args()

    if args.verbose:
        print("Verbose output enabled", file=sys.stderr)

    transform_ktx_files(args)

if __name__ == '__main__':
    main()
