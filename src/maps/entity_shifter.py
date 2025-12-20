#!/usr/bin/env python3
"""Script to update waypoint files when their map BSP file has been modified by
adding or removing entities since the waypoints were made. This requires the indices
of the markers to be shifted up/down.

Restrictions on input files, deviating from this will cause a mess:
- lines with comments and lines with marker commands must be strictly separated
- each line with marker commands must end in ";"
- any occurrence of 'm' followed by an integer represents a marker and will also be shifted

Alexander Thomas aka DrLex. Created 2025-03, last change 2025-12.
Released under GPL license."""

import argparse
import os
import re
import sys
from typing import IO


def shift_cmd(cmd: str, shift_from: int, offset: int, del_from: int, del_to: int) -> str:
    """Transforms a code statement according to shift parameters.
    The cmd argument must not include the trailing ';'.
    Returns empty string if the whole statement applies to a deleted marker."""
    # Z1(m1); G2(m2); etc
    if mat := re.match(r"([ZG]\d+)\(m(\d+)\)", cmd):
        idx = int(mat.group(2))
        if del_from <= idx <= del_to:
            return ""
        if idx < shift_from:
            return cmd
        return f"{mat.group(1)}(m{idx + offset})"
    # m1.P0=m2; etc
    if mat := re.match(r"m(\d+)\.(\S+)=m(\d+)", cmd):
        idx1 = int(mat.group(1))
        idx2 = int(mat.group(3))
        if (del_from <= idx1 <= del_to) or (del_from <= idx2 <= del_to):
            return ""
        if idx1 >= shift_from:
            idx1 += offset
        if idx2 >= shift_from:
            idx2 += offset
        return f"m{idx1}.{mat.group(2)}=m{idx2}"
    # m1.D0=4; m2.T=8; m1.something=whatever;
    if mat := re.match(r"m(\d+)\.(\S+)=(\S+)", cmd):
        idx = int(mat.group(1))
        if del_from <= idx <= del_to:
            return ""
        if idx < shift_from:
            return cmd
        return f"m{idx + offset}.{mat.group(2)}={mat.group(3)}"
    # dm6_door=m42; etc
    if mat := re.match(r"(\S+)=m(\d+)", cmd):
        idx = int(mat.group(2))
        if del_from <= idx <= del_to:
            return ""
        if idx < shift_from:
            return cmd
        return f"{mat.group(1)}=m{idx + offset}"
    return cmd


def shift_freeform(chunk: str, shift_from: int, offset: int) -> str:
    """Transforms a non-code line, assuming any patterns "mNUM" refer to markers."""
    def shifter(match):
        num = int(match.group(1))
        if num >= shift_from:
            return f"m{num + offset}"
        return match.group(0)
    return re.sub(r"m(\d+)", shifter, chunk)


def shift_file(args: argparse.Namespace, out_file: IO[str]) -> None:
    """Transforms the QuakeC file stream from args.infile, printing output to out_file."""
    shift_from: int = args.from_idx
    offset: int = args.offset
    delete_from: int = args.from_idx + offset if offset < 0 else 0
    delete_to: int = args.from_idx - 1 if offset < 0 else 0
    if args.verbose:
        print(f"Shifting {'up' if offset > 0 else 'down'} by {abs(offset)} from m{shift_from}, "
              f"in other words m{shift_from} becomes m{shift_from + offset}",
              file=sys.stderr)
        if delete_from:
            if delete_from == delete_to:
                print(f"Deleting m{delete_from}", file=sys.stderr)
            else:
                print(f"Deleting m{delete_from} to m{delete_to}", file=sys.stderr)

    lines = args.infile.readlines()
    in_comment = False
    cmds_removed = 0
    for line in lines:
        sline = line.rstrip("\n")
        if mat := re.match(r"\s*/\*", sline):
            in_comment = True
        if in_comment or re.match(r"\s*//", sline):
            # Drop lines from MarkerInfo
            if mat:= re.match(r"m(\d+) \S+ -?\d+ -?\d+ -?\d+", sline):
                if delete_from <= int(mat.group(1)) <= delete_to:
                    continue
            print(shift_freeform(sline, shift_from, offset), file=out_file)
            if re.match(r".*\*/\s*$", sline):
                in_comment = False
            continue
        if re.match(r".*\*/\s*$", sline):
            print(shift_freeform(sline, shift_from, offset), file=out_file)
            in_comment = False
            continue
        if re.match(r"^\s*$", sline):
            print(line.strip("\n"), file=out_file)
            continue

        sline = sline.strip()
        if sline.startswith("void() map_"):  # Do not mess up map names
            print(sline, file=out_file)
            continue
        if not sline.endswith(";"):
            print(shift_freeform(sline, shift_from, offset), file=out_file)
            continue

        cmds = sline.split(";")[:-1]  # drop final empty element
        new_cmds = []
        for cmd in cmds:
            cmd = cmd.strip()
            if not cmd:
                continue
            new_cmd = shift_cmd(cmd, shift_from, offset, delete_from, delete_to)
            if new_cmd:
                new_cmds.append(new_cmd)
            else:
                cmds_removed += 1
        if new_cmds:
            print(";".join(new_cmds) + ";", file=out_file)
    if cmds_removed and args.verbose:
        print(f"Removed {cmds_removed} commands related to removed marker(s)", file=sys.stderr)


def main():
    """Script entry point"""
    parser = argparse.ArgumentParser(description=(
        "Offset marker indices in a Frogbot v2 waypoint file, for when items have been added "
        "or deleted in a BSP after waypoints were created. Use a positive offset when items "
        "were added, negative when deleted. When offset is negative, removed markers and paths "
        "will also be deleted from the waypoints. Load and re-dump modified data in the tool to "
        "clean up. (NO NOT use this to delete custom markers, use the waypoint tool for that.)"))
    parser.add_argument('-v', '--verbose', action='store_true',
                        help="verbose output")
    parser.add_argument('-o', '--offset', type=int, default=1,
                        help="offset to apply to marker indexes starting at from_idx, in other "
                        "words the number of entities that have been added or deleted at that "
                        "point. A negative value will delete existing markers and paths that "
                        "overlap with the shifted values. Default 1.")
    # Cannot use FileType('w') here, or the input file would be destroyed if same as output
    parser.add_argument('-f', '--outfile', type=str, default="",
                        help="output file path. Default is to print output on stdout.")
    parser.add_argument('from_idx', type=int,
                        help="The lowest index to start incrementing/decrementing, should be "
                        "the index after the one of the added or deleted item. When added, "
                        "typically this should be the former index of the first custom marker. "
                        "When item mN has been deleted, this should be N+1. When item mN+1 has "
                        "also been deleted, this should be N+2, and so on.")
    # Although files should normally be pure ASCII, use a bogus encoding that allows
    # pretty much any byte value. (This will cause mojibake when printing to stdout,
    # so the -f option is recommended.)
    parser.add_argument('infile', type=argparse.FileType('r', encoding='iso8859_15'),
                        help="Input file to be converted")
    args = parser.parse_args()

    if os.path.abspath(args.infile.name) == os.path.abspath(args.outfile):
        print("ERROR: input and output file cannot be the same!", file=sys.stderr)
        sys.exit(2)
    out_file: IO[str] = (
        open(args.outfile, 'w', encoding='iso8859_15')  # pylint: disable=consider-using-with
        if args.outfile
        else sys.stdout
    )

    if args.verbose:
        print("Verbose output enabled", file=sys.stderr)
    if args.from_idx + args.offset < 1:
        print("ERROR: new marker indices cannot become 0 or negative", file=sys.stderr)
        sys.exit(2)

    shift_file(args, out_file)


if __name__ == '__main__':
    main()
