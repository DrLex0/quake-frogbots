#!/usr/bin/env python3
"""Generate the maplist and/or QuakeC code for v2 FrogBot.
Also acts as a conversion tool for old waypoint files.
2024-12/2025-05, Alexander Thomas aka DrLex.

Released under GPL license."""

import argparse
import glob
import os
import re
import sys
from typing import Tuple

GENERATE_QC = "map_load_gen.qc"

# SprintMaps() formatting
COLUMNS = 3
COL_WIDTH = 10

# For QuakeC-friendly function names
SAFE_MAP_STRINGS = {
    '+': 'PLUS',
    '-': 'DASH',
}


def mapname_from_path(path: str) -> str:
    """Returns lowercase "mapname" if path ends with a file name like 'map_mApNaMe.qc',
    otherwise returns empty string."""
    base = os.path.basename(path).lower()
    if mat := re.match(r"map_(.*)\.qc$", base):
        return mat.group(1)
    return ""


def add_maps(maps: list[str], aliases: dict[str, list[str]], glob_pattern: str) -> None:
    """Appends map paths to the list, found according to the glob pattern.
    Aliases will be extended with entries for the map name if the QC file
    contains a line '// ALIASES alias1 alias2' etc."""
    for map_file in sorted(glob.glob(glob_pattern)):
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
        map_name = mapname_from_path(map_file)
        if not map_name:
            print(f"WARNING: skipping '{map_file}' because invalid file name (should not happen!)",
                  file=sys.stderr)
            continue
        if [True for path in maps if mapname_from_path(path) == map_name]:
            print(f"WARNING: skipping '{map_file}' because duplicate map name", file=sys.stderr)
            continue

        maps.append(map_file)
        with open(map_file, encoding="iso8859_15") as map_data:
            for line in map_data.readlines():
                if mat := re.match(r"//\s*ALIASES (.*)\s*$", line):
                    ali = re.split(r"\s+", mat.group(1))
                    if ali:
                        aliases[map_name] = ali
                    break


def generate_listfile(args: argparse.Namespace) -> None:
    """Writes a map sources list file named args.list_file and an aliases file
    named args.alias_file."""
    maps: list[str] = []
    aliases: dict[str, list[str]] = {}
    add_maps(maps, aliases, "map_*.qc")
    for folder in args.folder or []:
        add_maps(maps, aliases, os.path.join(folder, "map_*.qc"))
    with open(args.list_file, "w", encoding="ascii") as list_file:
        print("\n".join(maps), file=list_file)
    with open(args.alias_file, "w", encoding="ascii") as alias_file:
        entries = [f"{mapname} {' '.join(ali)}" for mapname, ali in aliases.items()]
        print("\n".join(entries), file=alias_file)
    if args.verbose:
        print(f"Written '{args.list_file}' with {len(maps)} entries")
        print(f"Written '{args.alias_file}' with {len(aliases)} entries")


def load_map_aliases(path: str, map_names: list[str]) -> dict[str, list[str]]:
    """Loads map aliases from file, extends @map_names with any matching aliases,
    and returns the dict with the aliases."""
    result = {}
    with open(path, encoding="ascii") as alias_data:
        for line in alias_data.readlines():
            parts = line.strip().split()
            if not parts:
                continue
            map_name, *aliases = parts
            for alias in aliases:
                if alias in map_names:
                    print(f"WARNING: ignoring aliased '{alias}' because already in map names",
                        file=sys.stderr)
            aliases = [alias for alias in aliases if alias not in map_names]
            if not aliases or map_name not in map_names:
                continue
            result[map_name] = aliases
            map_names.extend(aliases)
    return result


def quakecify_mapname(mapname: str) -> str:
    """Inefficient but effective transformation of map name to QuakeC-safe function name string"""
    return ''.join(SAFE_MAP_STRINGS.get(char, char) for char in mapname)


def generate_qc_source(args: argparse.Namespace) -> None:
    """Generates a QC source file ../{GENERATE_QC} for maps listed in args.list_file
    and aliases in args.alias_file."""
    with open(args.list_file, encoding="ascii") as list_file:
        map_files = [line.strip() for line in list_file.readlines() if line.strip()]
    map_names = [mapname_from_path(map_file) for map_file in map_files]
    aliases = load_map_aliases(args.alias_file, map_names)
    reverse_aliases = {
        rev_ali: mapname
        for mapname, alis in aliases.items()
        for rev_ali in alis
    }
    if args.verbose:
        print(f"Read {len(map_files)} entries from '{args.list_file}'")
        print(f"Read {len(aliases)} entries from '{args.alias_file}'")

    with open(os.path.join("..", GENERATE_QC), "w", encoding="ascii") as qc_file:
        print('// This file has been generated with generate_maplist.py\n', file=qc_file)

        for map_file in map_files:
            print(f'#include "maps/{map_file}"', file=qc_file)
        print("", file=qc_file)

        print("void() SprintMaps =\n{", file=qc_file)
        map_names_sorted = sorted(map_names)
        for i in range(0, len(map_names_sorted), COLUMNS):
            row = map_names_sorted[i:i+COLUMNS]
            row_text = " ".join(f"{m_name:>{COL_WIDTH}}" for m_name in row)
            # Fudge it if map names are long
            while (len(row_text) > COLUMNS * (COL_WIDTH + 1) - 1) and "  " in row_text:
                shrink_me = row_text.rsplit("  ", 1)
                row_text = " ".join(shrink_me)
            print(f'\tsprint_fb(self, 2, " {row_text}\\n");', file=qc_file)
        print("};\n", file=qc_file)

        print("float() LoadWaypoints =\n{", file=qc_file)
        for map_name in map_names:
            actual_map = quakecify_mapname(reverse_aliases.get(map_name, map_name))
            print(
                f"""\tif (mapname == "{map_name}")
\t{{
\t\tmap_{actual_map}();
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
            print(f"Written '{qc_file.name}' with {len(map_files) + len(reverse_aliases)} entries")


def wipe_obsolete_descriptions(line: str) -> Tuple[bool, str]:
    """Removes path description numbers below 256, because those may occur in
    older waypoint files where they meant something else than their new values.
    Returns tuple (changed, new_line)"""
    chunks = line.split(";")
    new_chunks = []
    changed = False
    for chunk in chunks:
        parts = re.match(r"\s*(m\d+)\.D(\d)=(\d+)\s*", chunk)
        if not parts:
            new_chunks.append(chunk)
            continue
        old_bits = int(parts.group(3))
        # Clear all bits below 256. In theory we could preserve value 2 which used to
        # represent WATERJUMP_, and the new FOCUS_PATH may be useful in the same situation,
        # but in practice I have found no waypoint files using this value.
        new_bits = old_bits & ~0xFF
        if old_bits == new_bits:
            new_chunks.append(chunk)
        else:
            changed = True
            if new_bits:
                new_chunks.append(f"{parts.group(1)}.D{parts.group(2)}={new_bits}")
    return (changed, ";".join(new_chunks))


def transform_qc_files(args: argparse.Namespace) -> None:
    """Transforms waypoint source files listed in args.list_file, replacing the old N('x y z')
    invocations with new N(x,y,z) format."""
    with open(args.list_file, encoding="ascii") as list_file:
        map_files = [line.strip() for line in list_file.readlines()]
    for map_file in map_files:
        # Although files should normally be pure ASCII, use a bogus encoding
        # that allows pretty much any byte value
        with open(map_file, 'r+', encoding='iso8859_15') as qc_file:
            code_lines = qc_file.readlines()
            old_format = False
            changed = False
            desc_changed = False
            for (i, line) in enumerate(code_lines):
                new_line = re.sub(r"N\('(\S+) +(\S+) +(\S+)'\)", r"N(\1,\2,\3)", line)
                if new_line != line:
                    old_format = True
                elif old_format:
                    d_change, new_line = wipe_obsolete_descriptions(line)
                    desc_changed = desc_changed or d_change
                if new_line != line:
                    changed = True
                    code_lines[i] = new_line
            if changed:
                qc_file.seek(0)
                qc_file.write("".join(code_lines))
                qc_file.truncate()
            if args.verbose:
                print(f"File {map_file} " +
                      ("has been transformed!" if changed else "does not need transforming"))
            if desc_changed:
                print(f"WARNING: obsolete path descriptions have been removed from {map_file}",
                      file=sys.stderr)


def main():
    """Script entry point"""
    parser = argparse.ArgumentParser(description=(
        "Sets up source files for building Quake FrogBot with waypoint files for a set of maps. "
        "The map QuakeC files must be in the working directory, and be named 'map_mapname.qc'. "
        "Inside the QC file, there must be a definition for void() map_mapname.qc, and "
        "mapname must be lowercase.")
    )
    parser.add_argument('-v', '--verbose', action='store_true',
        help="verbose output.")
    parser.add_argument('-l', '--make_list', action='store_true',
        help="generate a maplist.txt file with all waypoint source files in this directory. "
             "You can edit this file afterwards to select only the desired maps. "
             "Any existing file will be overwritten.")
    parser.add_argument('-g', '--generate', action='store_true',
        help=f"generate the '{GENERATE_QC}' file one directory level up. "
             "If there is a 'maplist.txt' file, this will be used; otherwise "
             "a new one will be generated as if -l was used.")
    parser.add_argument('-t', '--transform', action='store_true',
        help="convert map sources from old N('vector') to new N(x,y,z) format. "
             "Same remark about map list file as with -g.")
    parser.add_argument('-f','--list_file', type=str, default='maplist.txt',
        help="use a custom file name instead of 'maplist.txt'.")
    parser.add_argument('-a','--alias_file', type=str, default='mapaliases.txt',
        help="use a custom aliases file name instead of 'mapaliases.txt'. "
             "If the QC file for 'mapname' contains a line '// ALIASES ali1 ali2', then "
             "the aliases file will contain a line 'mapname ali1 ali2'.")
    parser.add_argument('-d','--folder', type=str, nargs="+",
        help="also include maps in these subdirectories.")
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
