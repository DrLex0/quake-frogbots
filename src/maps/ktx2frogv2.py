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
    "6": 256,  # dm6 door
    "r": 512,  # rocket jump
    "j": 1024,  # jump ledge
    "w": 2,  # waterjump: treat as focused path
    "v": 0,  # vertical platform, platform handling in v2 frogbot is automatic
    "a": 0,  # curljump hint, not sure what it's for
}

KTX_MARKF_TO_V2 = {
    "u": 1,  # unreachable
    "6": -6,  # is dm6_door
    "f": 0,  # fire on match start, is hard-coded logic in v2 frogbot
    "b": 0,  # blocked on STATE_TOP, TODO I might still implement this
    "t": 0,  # door touchable, not sure what it's for
    "e": 0,  # escape route, not sure what it's for
    "n": 64,  # untouchable
}

V2_PATHF_TO_KTX = {
    1: "",  # just GO
    2: "",  # focused
    4: "",  # exclusive door (pseudo)
    128: "",  # precise jump
    256: "6",  # dm6 door
    512: "r",  # rocket jump
    1024: "j",  # jump ledge
}

V2_MARKF_TO_KTX = {
    1: "u",  # unreachable
    2: "",  # slime island
    4: "",  # exclusive
    8: "",  # want biosuit
    16: "",  # narrow
    32: "",  # wait lift
    64: "n",  # untouchable
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
            path_mode = 0
            for flag in list(mat.group(3)):
                mode: int = KTX_PATHF_TO_V2.get(flag, 0)
                if not mode:
                    print(f"Skipping path mode flag {flag};", file=sys.stderr)
                path_mode += mode
            if not path_mode:
                continue
            item_count = print_neat_lines(
                f"m{mat.group(1)}.D{mat.group(2)}={path_mode};",
                out_stream, item_count, 8
            )
        elif mat := re.match(r"^SetMarkerFlag (\d+) (.+)", line):
            mark_mode = 0
            for flag in list(mat.group(2)):
                mode: int = KTX_MARKF_TO_V2.get(flag, 0)
                if not mode:
                    print(f"Skipping marker mode flag {flag};", file=sys.stderr)
                elif mode == -6:
                    item_count = print_neat_lines(
                        f"dm6_door=m{mat.group(1)};",
                        out_stream, item_count, 8
                    )
                    mode = 0
                mark_mode += mode
            if not mark_mode:
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


def frog2_to_ktx(
    args: argparse.Namespace,
    in_stream: TextIO,
    out_stream: TextIO
) -> None:
    """Transforms a Frogbot v2 QuakeC waypoint source file stream into KTX format."""
    print("UNIMPLEMENTED!")


def transform_ktx_files(args: argparse.Namespace) -> None:
    """Transforms KTX waypoint source files (.bot extension) listed
    in args.list_file into Frogbot v2 QuakeC format (.qc extension)."""
    for bot_file in args.files:
        if not re.search(r"\.bot$", bot_file, flags=re.IGNORECASE):
            continue
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

        if args.verbose:
            print(f"Converting {bot_file} to {out_file}")
        # Although files should normally be pure ASCII, use a bogus encoding
        # that allows pretty much any byte value
        with open(bot_file, 'r+', encoding='iso8859_15') as ktx_file:
            with open(out_file, 'w', encoding='iso8859_15') as fv2_file:
                ktx_to_frog2(args, map_name, ktx_file, fv2_file)


def transform_qc_files(args: argparse.Namespace) -> None:
    """Transforms Frogbot v2 QuakeC waypoint source files (.qc extension)
    listed in args.list_file into KTX format (.bot extension)."""
    for qc_file in args.files:
        if not re.search(r"\.qc$", qc_file, flags=re.IGNORECASE):
            continue
        map_name = re.sub(r"(\..+)?$", "", os.path.basename(qc_file))
        map_name = re.sub(r"^map_", "", map_name, flags=re.IGNORECASE)
        out_file = f"{map_name}.bot"
        if os.path.exists(out_file):
            if not args.force:
                print(
                    f"Skipping {qc_file} because output file {out_file} exists, "
                    "use --force to overwrite",
                    file=sys.stderr
                )
                continue
            if args.verbose:
                print(f"Overwriting existing {out_file}")

        if args.verbose:
            print(f"Converting {qc_file} to {out_file}")
        # Although files should normally be pure ASCII, use a bogus encoding
        # that allows pretty much any byte value
        with open(qc_file, 'r+', encoding='iso8859_15') as fv2_file:
            with open(out_file, 'w', encoding='iso8859_15') as ktx_file:
                frog2_to_ktx(args, fv2_file, ktx_file)


def check_files(args: argparse.Namespace) -> None:
    """Reports files in args.list_file that have an extension other than .qc or .bot"""
    for some_file in args.files:
        if not re.search(r"\.(bot|qc)$", some_file, flags=re.IGNORECASE):
            print(
                f"Skipping unknown file {some_file}; only .bot or .qc files allowed",
                file=sys.stderr
            )


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

    check_files(args)
    transform_ktx_files(args)
    transform_qc_files(args)


if __name__ == '__main__':
    main()
