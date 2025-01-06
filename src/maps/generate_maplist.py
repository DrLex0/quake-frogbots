#!/usr/bin/env python3
"""Generate the maplist and/or QuakeC code for FrogBot.
2024-12, Alexander Thomas aka DrLex.

Released under GPL license."""

import glob
import os
import re
import sys
import argparse


GENERATE_QC = "map_load_gen.qc"

# SprintMaps() formatting
COLUMNS = 3
COL_WIDTH = 10


def generate_listfile(args: argparse.Namespace):
    """Writes a map sources list file named args.list_file."""
    maps: list[str] = []
    for map_file in sorted(glob.glob("map_*.qc")):
        bad = []
        if any(ord(char) > 127 for char in map_file):
            bad.append("non-ASCII characters")
        if " " in map_file:
            bad.append("spaces")
        if '"' in map_file:
            bad.append("quotes")
        if map_file.lower() == "map_.qc":
            bad.append("no actual name")
        if bad:
            print(f"WARNING: skipping '{map_file}' because it contains: {', '.join(bad)}",
                  file=sys.stderr)
            continue
        maps.append(map_file)

    with open(args.list_file, "w", encoding="ascii") as list_file:
        print("\n".join(maps), file=list_file)
    if args.verbose:
        print(f"Written '{args.list_file}' with {len(maps)} entries")


def generate_qc_source(args: argparse.Namespace):
    """Generates a QC source file ../{GENERATE_QC} for maps listed in args.list_file."""
    with open(args.list_file, encoding="ascii") as list_file:
        map_files = [line.strip() for line in list_file.readlines()]
    map_names = [map_file[4:][:-3].lower() for map_file in map_files]
    if args.verbose:
        print(f"Read {len(map_files)} entries from '{args.list_file}'")

    with open(os.path.join("..", GENERATE_QC), "w", encoding="ascii") as qc_file:
        print('// This file has been generated with generate_maplist.py\n', file=qc_file)

        for map_file in map_files:
            print(f'#include "maps/{map_file}"', file=qc_file)
        print("", file=qc_file)

        print("void() SprintMaps =\n{", file=qc_file)
        for i in range(0, len(map_names), COLUMNS):
            row = map_names[i:i+COLUMNS]
            row_text = " ".join(f"{m_name:>{COL_WIDTH}}" for m_name in row)
            # Fudge it if map names are long
            while (len(row_text) > COLUMNS * (COL_WIDTH + 1) - 1) and "  " in row_text:
                shrink_me = row_text.rsplit("  ", 1)
                row_text = " ".join(shrink_me)
            print(f'\tsprint_fb(self, 2, " {row_text}\\n");', file=qc_file)
        print("};\n", file=qc_file)

        print("float() LoadWaypoints =\n{", file=qc_file)
        for map_name in map_names:
            print(
                f"""\tif (mapname == "{map_name}")
\t{{
\t\tmap_{map_name}();
\t\treturn TRUE;
\t}}""", file=qc_file)
        print("\treturn FALSE;\n};\n", file=qc_file)

        print("string(string mname) MapHasWaypoints =\n{", file=qc_file)
        for map_name in map_names:
            print(
                f"""\tif (mname == "{map_name}")
\t\treturn "{map_name}";""", file=qc_file)
        print('\treturn "";\n};', file=qc_file)

        if args.verbose:
            print(f"Written '{qc_file.name}' with {len(map_files)} entries")


def transform_qc_files(args: argparse.Namespace):
    """Transforms waypoint source files listed in args.list_file, replacing the old N('x y z')
    invocations with new N(x,y,z) format."""
    with open(args.list_file, encoding="ascii") as list_file:
        map_files = [line.strip() for line in list_file.readlines()]
    for map_file in map_files:
        # Although files should normally be pure ASCII, use a bogus encoding
        # that allows pretty much any byte value
        with open(map_file, 'r+', encoding='iso8859_15') as qc_file:
            code_lines = qc_file.readlines()
            changed = False
            for i in range(0, len(code_lines)):
                new_line = re.sub(r"N\('(\S+) +(\S+) +(\S+)'\)", r"N(\1,\2,\3)", code_lines[i])
                if new_line != code_lines[i]:
                    changed = True
                    code_lines[i] = new_line
            if changed:
                qc_file.seek(0)
                qc_file.write("".join(code_lines))
                qc_file.truncate()
            if args.verbose:
                print(f"File {map_file} " +
                      ("has been transformed" if changed else "does not need transforming"))


def main():
    """Script entry point"""
    parser = argparse.ArgumentParser(
        description=("Sets up source files for building Quake FrogBot with waypoint files for a set of maps. "
        "The map QuakeC files must be in the working directory, and be named 'map_mapname.qc'. "
        "Inside the QC file, there must be a definition for void() map_mapname.qc, and mapname must be lowercase."))
    parser.add_argument('-v', '--verbose', action='store_true',
                        help="verbose output.")
    parser.add_argument('-l', '--make_list', action='store_true',
                        help="generate a maplist.txt file with all waypoint source files in this directory. You can edit this file afterwards to select only the desired maps. Any existing file will be overwritten.")
    parser.add_argument('-g', '--generate', action='store_true',
                        help=f"generate the '{GENERATE_QC}' file one directory level up. If there is a 'maplist.txt' file, this will be used; otherwise a new one will be generated as if -l was used.")
    parser.add_argument('-t', '--transform', action='store_true',
                        help="convert map sources from old N('vector') to new N(x,y,z) format. Same remark about map list file as with -g.")
    parser.add_argument('-f','--list_file', type=str, default='maplist.txt',
                        help="use a custom file name instead of 'maplist.txt'.")
    args = parser.parse_args()

    if args.verbose:
        print("Verbose output enabled")

    dome_something = False
    if args.make_list or ((args.generate or args.transform)
                          and not os.path.exists(args.list_file)):
        if args.verbose:
            print(("Overwriting" if os.path.exists(args.list_file) else "Creating new") +
                  f" list file {args.list_file}")
        generate_listfile(args)
        dome_something = True

    if args.transform:
        transform_qc_files(args)
        dome_something = True

    if args.generate:
        generate_qc_source(args)
        dome_something = True

    if not dome_something:
        print("Run the script with -lg to generate files. Use --help for more info.")


if __name__ == '__main__':
    main()
