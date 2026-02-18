#!/usr/bin/env python3
"""
Extract and format Frogbot waypoint data dump from a console log file.
2026-01/02, Alexander Thomas aka DrLex.

Released under GPL license.
"""

from __future__ import annotations

import argparse
import re
import sys

# Grouping constants: how many of each command type per line
MAX_NUM_N = 4  # N()
MAX_NUM_ZG = 8  # Z() and G()
MAX_NUM_M = 4  # custom marker properties view_ofs_z, d_door_open, rj_angles
MAX_NUM_T = 8  # marker type .T
MAX_NUM_P = 6  # path definitions
MAX_NUM_DR = 6  # path descriptors and airstrafe override

# Map name character transformations; any character that conflicts
# with QuakeC syntax must be encoded
MAPNAME_TRANSFORMS: dict[str, str] = {
    "-": "DASH",
    "+": "PLUS",
}


def transform_mapname(mapname: str) -> str:
    """Apply character transformations to the map name."""
    result = mapname
    for char, replacement in MAPNAME_TRANSFORMS.items():
        result = result.replace(char, replacement)
    return result


def group_items(items: list[str], count: int) -> list[str]:
    """Group items into lines with at most 'count' items each."""
    lines = []
    for i in range(0, len(items), count):
        lines.append("".join(items[i : i + count]))
    return lines


def parse_waypoint_dump(content: str) -> tuple[str, str, str] | None:
    """
    Find the last occurrence of a waypoint dump in the content.
    Returns (map_declaration_line, code_block, comment_block) or None if not found.
    """
    # Find all occurrences of waypoint dumps;
    # assume format as dumped from waypoint tool;
    # use non-greedy match for the code block, ending at };
    pattern = r"void\(\)\s+map_(\S+) =[^{]*\{(.*?)\};\s*(/\*.*?\*/)?"
    matches = list(re.finditer(pattern, content, re.DOTALL))

    if not matches:
        return None
    match = matches[-1]
    mapname = match.group(1)
    code_block = match.group(2)
    comment_block = match.group(3) or ""
    transformed_name = transform_mapname(mapname)
    map_decl = f"void() map_{transformed_name} ="

    return map_decl, code_block, comment_block


def parse_code_block(code_block: str) -> dict[str, list[str]]:
    """
    Parse the code block and categorize statements.
    Returns a dict with categorized statements.
    """
    categories: dict[str, list[str]] = {
        "comments": [],
        "c_marker_start": [],
        "N": [],
        "LSQ": [],
        "Z": [],
        "G": [],
        "marker_props": [],  # view_ofs_z, d_door_open, rj_angles
        "T": [],
        "P": [],
        "DR": [],  # D and R combined
        "globals": [],  # desire_adj_G*, force_raspawn, AddIntermission
    }

    # Regex patterns for different statement types
    patterns = {
        "comment": re.compile(r"^//.*$"),
        "c_marker_start": re.compile(r"^custom_marker_start=\s*(\d+);?$"),
        "N": re.compile(r"^N\(-?\d+,-?\d+,-?\d+\);?$"),
        "LSQ": re.compile(r"^LSQ\(\);?$"),
        "Z": re.compile(r"^Z\d+\(m\d+\);?$"),
        "G": re.compile(r"^G\d+\(m\d+\);?$"),
        "view_ofs_z": re.compile(r"^m\d+\.view_ofs_z=-?\d+;?$"),
        "d_door_open": re.compile(r"^m\d+\.d_door_open=\d+;?$"),
        "rj_angles": re.compile(r"^m\d+\.rj_angles='-?\d+\s+-?\d+\s+-?\d+';?$"),
        "T": re.compile(r"^m\d+\.T=\d+;?$"),
        "P": re.compile(r"^m\d+\.P\d+=m\d+;?$"),
        "D": re.compile(r"^m\d+\.D\d+=\d+;?$"),
        "R": re.compile(r"^m\d+\.R\d+=-?\d+;?$"),
        "desire_adj": re.compile(r"^desire_adj_G\d+=\s*([\d.]+);?$"),
        "force_raspawn": re.compile(r"^force_raspawn=\s*([\d.]+);?$"),
        "AddIntermission": re.compile(
            r"^AddIntermission\(-?\d+,-?\d+,-?\d+,-?\d+,-?\d+,-?\d+\);?$"
        ),
    }

    # Process lines and individual statements
    for line in code_block.split("\n"):
        line = line.strip()
        if not line:
            continue

        # Check for comment lines first
        if patterns["comment"].match(line):
            categories["comments"].append(line)
            continue

        # Split line into individual statements (separated by ;)
        # Allow lines that do not end with ; although this will likely end in failure
        statements = re.split(r";(?=\S)", line)
        for stmt_raw in statements:
            stmt_raw = stmt_raw.strip().rstrip(";")
            if not stmt_raw:
                continue
            stmt = stmt_raw + ";"

            matched = False
            if patterns["N"].match(stmt):
                categories["N"].append(stmt)
                matched = True
            elif patterns["LSQ"].match(stmt):
                categories["LSQ"].append(stmt)
                matched = True
            elif patterns["Z"].match(stmt):
                categories["Z"].append(stmt)
                matched = True
            elif patterns["G"].match(stmt):
                categories["G"].append(stmt)
                matched = True
            elif patterns["view_ofs_z"].match(stmt):
                categories["marker_props"].append(stmt)
                matched = True
            elif patterns["d_door_open"].match(stmt):
                categories["marker_props"].append(stmt)
                matched = True
            elif patterns["rj_angles"].match(stmt):
                categories["marker_props"].append(stmt)
                matched = True
            elif patterns["T"].match(stmt):
                categories["T"].append(stmt)
                matched = True
            elif patterns["P"].match(stmt):
                categories["P"].append(stmt)
                matched = True
            elif patterns["D"].match(stmt):
                categories["DR"].append(stmt)
                matched = True
            elif patterns["R"].match(stmt):
                categories["DR"].append(stmt)
                matched = True
            elif patterns["desire_adj"].match(stmt):
                # Remove leading whitespace from value
                clean_stmt = re.sub(r"=\s+", "=", stmt)
                categories["globals"].append(clean_stmt)
                matched = True
            elif patterns["force_raspawn"].match(stmt):
                clean_stmt = re.sub(r"=\s+", "=", stmt)
                categories["globals"].append(clean_stmt)
                matched = True
            elif patterns["AddIntermission"].match(stmt):
                categories["globals"].append(stmt)
                matched = True
            elif patterns["c_marker_start"].match(stmt):
                clean_stmt = re.sub(r"=\s+", "=", stmt)
                categories["c_marker_start"] = [clean_stmt]
                matched = True

            if not matched and stmt_raw:
                print(
                    f"WARNING: Ignoring unrecognized statement: {stmt_raw}", file=sys.stderr
                )

    return categories


def format_output(
    map_decl: str, categories: dict[str, list[str]], comment_block: str
) -> str:
    """Format the parsed data into the output format."""
    lines: list[str] = []

    # Map declaration
    lines.append(map_decl)
    lines.append("{")

    # Comments
    for comment in categories["comments"]:
        lines.append(comment)

    # Custom marker index for sanity check
    for marker_start in categories["c_marker_start"]:
        lines.append(marker_start)

    # N() instructions
    if categories["N"]:
        lines.extend(group_items(categories["N"], MAX_NUM_N))

    # LSQ()
    if categories["LSQ"]:
        lines.append("".join(categories["LSQ"]))

    # Z instructions
    if categories["Z"]:
        lines.extend(group_items(categories["Z"], MAX_NUM_ZG))

    # G instructions
    if categories["G"]:
        lines.extend(group_items(categories["G"], MAX_NUM_ZG))

    # Marker properties (view_ofs_z, d_door_open, rj_angles)
    if categories["marker_props"]:
        lines.extend(group_items(categories["marker_props"], MAX_NUM_M))

    # T instructions
    if categories["T"]:
        lines.extend(group_items(categories["T"], MAX_NUM_T))

    # P instructions
    if categories["P"]:
        lines.extend(group_items(categories["P"], MAX_NUM_P))

    # D and R instructions
    if categories["DR"]:
        lines.extend(group_items(categories["DR"], MAX_NUM_DR))

    # Global properties (desire_adj_G*, force_raspawn, AddIntermission)
    for global_stmt in categories["globals"]:
        lines.append(global_stmt)

    lines.append("};")

    # Add comment block if present
    if comment_block:
        lines.append(comment_block)

    return "\n".join(lines) + "\n"


def check_existing_file(filepath: str, new_map_func: str) -> tuple[list[str], bool]:
    """
    Check if file exists and if it does, has the same map function name.
    Returns (preceding_lines, is_valid).
    """
    try:
        with open(filepath, "r", encoding="iso8859_15") as f:
            content = f.read()
    except FileNotFoundError:
        return [], True

    lines = content.split("\n")
    preceding_lines: list[str] = []

    # Find the void() map_... line
    map_decl_pattern = re.compile(r"^void\(\)\s+(map_\S+)\s*=")
    found_decl = False
    existing_func = ""

    for line in lines:
        if found := map_decl_pattern.match(line.strip()):
            found_decl = True
            existing_func = found.group(1)
            break
        preceding_lines.append(line)

    if not found_decl:
        # No existing waypoint data, treat as valid
        return preceding_lines, True

    return preceding_lines, (new_map_func == existing_func)


def main() -> None:
    """Script entry point."""
    parser = argparse.ArgumentParser(
        description=(
            "Extract and format waypoint data dump from a Quake console log file. "
            "Finds the last occurrence of a waypoint dump and cleans it up to have "
            "a standard format. Output can be written to an existing file, this will "
            "preserve any comments preceding the 'void' declaration."
        )
    )
    parser.add_argument(
        "logfile",
        type=str,
        nargs="?",
        default="condump.txt",
        help="the console log file (default: condump.txt) containing the waypoint dump",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=str,
        help="output file path (default: print to stdout)",
    )
    parser.add_argument(
        "-f",
        "--force",
        action="store_true",
        help="force overwrite even if map name in existing file differs",
    )
    args = parser.parse_args()

    # Read input file, use bogus encoding that will not break on custom Quake bytes
    try:
        with open(args.logfile, "r", encoding="iso8859_15") as f:
            content = f.read()
    except FileNotFoundError:
        print(
            f"ERROR: Input file not found: {args.logfile}. Pass the log file as first argument.",
            file=sys.stderr
        )
        sys.exit(1)
    except IOError as e:
        print(f"ERROR: Could not read input file {args.logfile}: {e}", file=sys.stderr)
        sys.exit(1)

    result = parse_waypoint_dump(content)
    if result is None:
        print(f"ERROR: No waypoint dump found in input file {args.logfile}", file=sys.stderr)
        sys.exit(1)

    map_decl, code_block, comment_block = result
    categories = parse_code_block(code_block)
    formatted = format_output(map_decl, categories, comment_block)

    if args.output:
        new_map_func = map_decl.split(" ")[1]
        # Check existing file: avoid accidentally nuking the wrong file
        preceding_lines, is_valid = check_existing_file(args.output, new_map_func)

        if not is_valid and not args.force:
            print(
                f"ERROR: Map function in existing file differs from '{new_map_func}'. "
                "Use --force to overwrite.",
                file=sys.stderr,
            )
            sys.exit(1)

        # Write output with preserved preceding lines
        try:
            with open(args.output, "w", encoding="iso8859_15") as f:
                if preceding_lines:
                    prefix = "\n".join(preceding_lines)
                    if not prefix.endswith("\n"):
                        prefix += "\n"
                    f.write(prefix)
                f.write(formatted)
            print(f"Saved result to {args.output}")
        except IOError as e:
            print(f"ERROR: Could not write output file: {e}", file=sys.stderr)
            sys.exit(1)
    else:
        print(formatted, end="")


if __name__ == "__main__":
    main()
