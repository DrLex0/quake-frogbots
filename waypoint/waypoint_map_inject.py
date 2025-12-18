#!/usr/bin/env python3
"""
Inject Frogbot waypoint annotations into a Quake .map or .ent file,
to allow compiling the map with built-in Frogbot support, or to play with
Frogbots in a BSP map without editing it if the engine supports .ent files.
2025-01 to 2025-12, Alexander Thomas aka DrLex.

Released under GPL license.
"""

from __future__ import annotations

import argparse
import re
import sys

# In case there is ever a need for a breaking change in the format
FRB_EMB_WP_VERSION = 1

# All the entities that invoke AddToQue in their spawn function. Not all of them become markers,
# Likely because 'Frog' considered using them at some point but never did. The v2 Frogbot has added
# a few classnames to the ones that become markers.
# For some, like func_train, it depends on their configuration whether they become markers or not.
# Luckily we don't need to care about marker-ness here, we only need to ensure we count in the
# same way as the FrogBot QuakeC code.
# For those things that (may) become a marker, this also specifies default FrB_ID name prefixes.
MARKERABLE: dict[str, str | None] = {
    "func_button": "butn",
    "trigger_changelevel": None,
    "info_player_deathmatch": "dm",
    "func_door": "door",
    "func_door_secret": "sdor",
    "item_health": "heal",
    "item_armor1": "armo",
    "item_armor2": "army",
    "item_armorInv": "armr",
    "weapon_supershotgun": "SS",
    "weapon_nailgun": "NG",
    "weapon_supernailgun": "SG",
    "weapon_grenadelauncher": "GL",
    "weapon_rocketlauncher": "RL",
    "weapon_lightning": "LG",
    "item_shells": "shel",
    "item_spikes": "nail",
    "item_rockets": "rock",
    "item_cells": "cell",
    "item_weapon": None,
    "item_artifact_invulnerability": "invu",
    "item_artifact_envirosuit": "envi",
    "item_artifact_invisibility": "invi",
    "item_artifact_super_damage": "quad",
    "func_plat": "plat",
    "func_train": "trai",
    "trigger_multiple": "mulT",
    "trigger_once": None,
    "trigger_secret": None,
    "trigger_counter": None,
    "info_teleport_destination": "telD",
    "trigger_teleport": "telT",
    "trigger_setskill": None,
    "trigger_onlyregistered": None,
    "trigger_hurt": None,
    "trigger_push": "pusT",
}

ERR_2LEVELS = "Invalid map file: cannot have more than 2 levels of {} brackets"
ERR_NO_WORLD = (
    "WARNING: no worldspawn entity found; global waypoint properties cannot be stored, "
    "check the input map/ent file."
)

# Spawnflag bit that indicates entity does not spawn in deathmatch mode
NOT_IN_DEATHMATCH = 2048


def is_deathmatch_entity(entity: Entity) -> bool:
    """Check if entity spawns in deathmatch mode (spawnflags bit 2048 not set)."""
    spawnflags_str = entity.properties.get("spawnflags", "0")
    try:
        spawnflags = int(spawnflags_str)
    except ValueError:
        return True  # If we can't parse, assume it spawns
    return (spawnflags & NOT_IN_DEATHMATCH) == 0


class Entity:
    """Represents a single entity in a Quake `.map` file."""

    def __init__(
        self,
        properties: dict[str, str] | None = None,
        comments: list[str] | None = None,
        body: list[str] | None = None,
    ) -> None:
        self.properties = properties or {}
        self.comments = comments or []
        self.body = body or []

    @classmethod
    def from_lines(
        cls, lines: list[str], comments: list[str] | None = None
    ) -> "Entity":
        """Create an Entity instance from lines of text with optional preceding comments."""
        properties = {}
        comments = comments or []
        body = []
        in_body = False
        for line in lines:
            sline = line.strip()
            if sline.startswith("{"):
                if in_body:
                    raise RuntimeError(ERR_2LEVELS)
                in_body = True
                body.append(line)
            elif sline.endswith("}"):
                if in_body:
                    in_body = False
                    body.append(line)
                else:
                    raise RuntimeError("Error: spurious closing bracket }")
            else:
                match = re.match(r'^"([^"]+)"\s+"([^"]+)"$', sline)
                if match:  # entity field
                    key, value = match.groups()
                    properties[key] = value
                else:
                    body.append(line)
        return cls(properties, comments, body)

    def to_lines(self) -> list[str]:
        """Convert the entity's data to lines of text."""
        lines = self.comments + ["{\n"]
        lines += [f'"{key}" "{value}"\n' for key, value in self.properties.items()]
        lines += self.body
        lines.append("}\n")
        return lines

    def __str__(self):
        """String representation of the entity."""
        return "".join(self.to_lines())


class QMapParser:
    """Rudimentary parser for Quake .map files, with just the stuff we need."""

    def __init__(self, filepath: str) -> None:
        self.filepath = filepath
        self.entities: list[Entity] = []
        self.load_map()

    def load_map(self) -> None:
        """Parse the .map file into entities and preceding comments."""
        # File should not contain non-ASCII, but use bogus encoding just in
        # case someone thought to be funny and include funky characters.
        with open(self.filepath, "r", encoding="iso8859_15") as file:
            lines = file.readlines()

        current_comments = []
        current_entity_lines = []
        in_entity = False
        in_entity_body = False
        for line in lines:
            sline = line.strip()
            if sline.startswith("//"):
                # To keep things simple, comment lines mixed in with entity fields will
                # become lumped together below the fields, before any body content.
                if not in_entity:
                    current_comments.append(line)
                else:
                    current_entity_lines.append(line)
            elif sline.startswith("{"):
                if not in_entity:  # Start of an entity
                    current_entity_lines = []
                    in_entity = True
                else:
                    if in_entity_body:
                        raise RuntimeError(ERR_2LEVELS)
                    in_entity_body = True
                    current_entity_lines.append(line)
            elif sline.endswith("}"):
                if in_entity_body:
                    current_entity_lines.append(line)
                    in_entity_body = False
                else:  # End of an entity
                    entity = Entity.from_lines(current_entity_lines, current_comments)
                    self.entities.append(entity)
                    current_comments = []
                    current_entity_lines = []
                    in_entity = False
            elif in_entity:
                current_entity_lines.append(line)
            else:  # Outside of any entity
                current_comments.append(line)

    def add_entity(self, entity: Entity) -> None:
        """Add a new entity to the map."""
        self.entities.append(entity)

    def remove_entity(self, index: int) -> None:
        """Remove an entity by its index."""
        if 0 <= index < len(self.entities):
            self.entities.pop(index)

    def modify_entity(self, index: int, new_entity: Entity) -> None:
        """Replace an entity with new content."""
        if 0 <= index < len(self.entities):
            self.entities[index] = new_entity

    def save_map(self, output_filepath: str = "") -> None:
        """Write the entities back to a .map file, or the same file if not specified."""
        if not output_filepath:
            output_filepath = self.filepath
        with open(output_filepath, "w", encoding="iso8859_15") as file:
            for entity in self.entities:
                file.write(str(entity))


class Marker:
    """Represents a Frogbot marker."""

    def __init__(
        self,
        index: int,
        zone: int = 0,
        goal: int = 0,
        classname: str = "",
        pos: str = "",
        paths: list[int] | None = None,
        descriptions: list[int] | None = None,
        r_values: list[int] | None = None,
        field_t: int = 0,
        view_ofs_z: int = -10000,
        d_door_open: int = 0,
    ) -> None:
        self.index = index
        self.zone = zone
        self.goal = goal
        self.classname = classname
        self.pos = pos
        self.paths = paths or []
        self.descriptions = descriptions or []
        self.r_values = r_values or []
        self.field_t = field_t
        self.view_ofs_z = view_ofs_z
        self.d_door_open = d_door_open

    def __str__(self) -> str:
        output = f"m{self.index}:"
        if self.zone:
            output += f" Z{self.zone}"
        if self.goal:
            output += f" G{self.goal}"
        if self.pos:
            output += f" [{self.pos}]"
        if self.classname:
            output += f" {self.classname}"
        if self.field_t:
            output += f" T={self.field_t}"
        if self.view_ofs_z > -10000:
            output += f" oZ={self.view_ofs_z}"
        if self.d_door_open:
            output += f" dD={self.d_door_open}"
        if self.paths:
            output += f" P={self.paths}"
        if self.descriptions:
            output += f" D={self.descriptions}"
        if self.r_values:
            output += f" R={self.r_values}"
        return output


class WaypParser:
    """Parser for waypoint data as dumped from the waypoint v2 tool."""

    def __init__(self, filepath: str = "") -> None:
        self.filepath = filepath
        self.markers: dict[int, Marker] = {}
        self.n_cache: list[str] = []
        self.first_custom_index: int = 0
        # Global map properties
        self.dm6_door: int = 0
        self.door_open_dist: int = 0
        self.door_targetz: int = 0
        self.desire_adj_g1: float = 0.0
        self.desire_adj_g2: float = 0.0
        self.intermission: tuple[float, ...] | None = None  # (X, Y, Z, P, W, R)
        if filepath:
            self.load_wp()

    def __str__(self) -> str:
        output = ""
        if self.dm6_door:
            output += f" dm6_door={self.dm6_door}"
        if self.door_open_dist:
            output += f" door_open_dist={self.door_open_dist}"
        if self.door_targetz:
            output += f" door_targetZ={self.door_targetz}"
        if self.desire_adj_g1:
            output += f" desire_adj_G1={self.desire_adj_g1}"
        if self.desire_adj_g2:
            output += f" desire_adj_G2={self.desire_adj_g2}"
        if self.intermission:
            output += f" intermission={self.intermission}"
        return output

    def set_marker(
        self,
        m_index: int,
        zone: int = 0,
        goal: int = 0,
        classname: str = "",
        pos: str = "",
        paths: list[int] | None = None,
        descriptions: list[int] | None = None,
        r_values: list[int] | None = None,
        field_t: int = 0,
        view_ofs_z: int = -10000,
        d_door_open: int = 0,
    ) -> None:
        """Add or update Marker with given index and properties."""
        if m_index not in self.markers:
            self.markers[m_index] = Marker(
                m_index,
                zone=zone,
                goal=goal,
                classname=classname,
                pos=pos,
                paths=paths,
                descriptions=descriptions,
                r_values=r_values,
                field_t=field_t,
                view_ofs_z=view_ofs_z,
                d_door_open=d_door_open,
            )
        else:
            marker = self.markers[m_index]
            if zone:
                marker.zone = zone
            if goal:
                marker.goal = goal
            if classname:
                marker.classname = classname
            if pos:
                marker.pos = pos
            if field_t:
                marker.field_t = field_t
            if view_ofs_z > -10000:
                marker.view_ofs_z = view_ofs_z
            if d_door_open:
                marker.d_door_open = d_door_open
            # Merge array properties
            if paths:
                if marker.paths:
                    marker.paths = [
                        new if new != 0 else old
                        for old, new in zip(marker.paths, paths)
                    ]
                else:
                    marker.paths = paths
            if descriptions:
                if marker.descriptions:
                    marker.descriptions = [
                        new if new != 0 else old
                        for old, new in zip(marker.descriptions, descriptions)
                    ]
                else:
                    marker.descriptions = descriptions
            if r_values:
                if marker.r_values:
                    marker.r_values = [
                        new if new != 0 else old
                        for old, new in zip(marker.r_values, r_values)
                    ]
                else:
                    marker.r_values = r_values

    def parse_statement(self, statem: str) -> None:
        """Parse a waycode-related QuakeC statement and update the affected data.
        @statem must have no surrounding whitespace or trailing ;."""
        if not statem or statem == "LSQ()":
            return
        if walrus := re.match(r"N\((-?\d+),(-?\d+),(-?\d+)\)", statem):
            # Cache these values and attach them to the appropriate markers
            # once we know the full list of indices.
            self.n_cache.append(
                f"{walrus.group(1)} {walrus.group(2)} {walrus.group(3)}"
            )
        elif walrus := re.match(r"Z(\d+)\(m(\d+)\)", statem):
            m_index = int(walrus.group(2))
            m_zone = int(walrus.group(1))
            self.set_marker(m_index, zone=m_zone)
        elif walrus := re.match(r"G(\d+)\(m(\d+)\)", statem):
            m_index = int(walrus.group(2))
            m_goal = int(walrus.group(1))
            self.set_marker(m_index, goal=m_goal)
        elif walrus := re.match(r"m(\d+)\.view_ofs_z=(-?\d+)", statem):
            m_index = int(walrus.group(1))
            m_zoff = int(walrus.group(2))
            self.set_marker(m_index, view_ofs_z=m_zoff)
        elif walrus := re.match(r"m(\d+)\.T=(\d+)", statem):
            m_index = int(walrus.group(1))
            m_t = int(walrus.group(2))
            self.set_marker(m_index, field_t=m_t)
        elif walrus := re.match(r"m(\d+)\.d_door_open=(\d+)", statem):
            m_index = int(walrus.group(1))
            m_dd = int(walrus.group(2))
            self.set_marker(m_index, d_door_open=m_dd)
        elif walrus := re.match(r"m(\d+)\.P([0-7])=m(\d+)", statem):
            m_index = int(walrus.group(1))
            m_pnum = int(walrus.group(2))
            m_pdest = int(walrus.group(3))
            p_array = [m_pdest if i == m_pnum else 0 for i in range(8)]
            self.set_marker(m_index, paths=p_array)
        elif walrus := re.match(r"m(\d+)\.D([0-7])=(\d+)", statem):
            m_index = int(walrus.group(1))
            m_dnum = int(walrus.group(2))
            m_dval = int(walrus.group(3))
            d_array = [m_dval if i == m_dnum else 0 for i in range(8)]
            self.set_marker(m_index, descriptions=d_array)
        elif walrus := re.match(r"m(\d+)\.R([0-7])=(\d+)", statem):
            m_index = int(walrus.group(1))
            m_rnum = int(walrus.group(2))
            m_rval = int(walrus.group(3))
            r_array = [m_rval if i == m_rnum else 0 for i in range(8)]
            self.set_marker(m_index, r_values=r_array)
        elif walrus := re.match(r"dm6_door=m(\d+)", statem):
            self.dm6_door = int(walrus.group(1))
        elif walrus := re.match(r"door_open_dist=(\d+)", statem):
            self.door_open_dist = int(walrus.group(1))
        elif walrus := re.match(r"door_targetZ=(\d+)", statem):
            self.door_targetz = int(walrus.group(1))
        elif walrus := re.match(r"desire_adj_G1=([\d.]+)", statem):
            self.desire_adj_g1 = float(walrus.group(1))
        elif walrus := re.match(r"desire_adj_G2=([\d.]+)", statem):
            self.desire_adj_g2 = float(walrus.group(1))
        elif walrus := re.match(
            r"AddIntermission\(([\d.-]+),([\d.-]+),([\d.-]+),"
            r"([\d.-]+),([\d.-]+),([\d.-]+)\)",
            statem,
        ):
            self.intermission = (
                float(walrus.group(1)),
                float(walrus.group(2)),
                float(walrus.group(3)),
                float(walrus.group(4)),
                float(walrus.group(5)),
                float(walrus.group(6)),
            )

    def load_wp(self) -> None:
        """Parse the waypoint QC file into marker data."""
        with open(self.filepath, "r", encoding="iso8859_15") as file:
            lines = file.readlines()
        parse_part = 0
        in_comment = False
        for line in lines:
            sline = line.strip()
            # Decent effort to strip comments. If someone does stupid things
            # by mixing both types of comments in strange ways, too bad.
            if in_comment and "*/" in sline:  # end of comment block
                sline = sline.split("*/", 1)[1]
                in_comment = False
            sline = sline.split("//", 1)[0]  # strip inline comment
            sline = re.sub(r"/\*.*?\*/", "", sline)  # strip complete comment blocks
            if "/*" in sline:  # start of comment block
                sline = sline.split("/*", 1)[0]
                in_comment = True

            if parse_part < 1:
                if sline.startswith("{"):
                    parse_part = 1
                    sline = sline.lstrip("{")
                else:
                    continue
            if parse_part == 1:
                if "};" in sline:
                    sline = sline.split("};", 1)[0]
                    parse_part = 2
                statements = sline.split(";")
                for statement in statements:
                    self.parse_statement(statement.strip())
            if parse_part == 2:
                if "/* MarkerInfo" in line:
                    parse_part = 3
            elif parse_part == 3:
                if "*/" in line:
                    break
                marker_info = re.match(r"m(\d+) (\S+) (-?\d+ -?\d+ -?\d+)", sline)
                if not marker_info:
                    continue
                m_idx = int(marker_info.group(1))
                self.set_marker(
                    m_idx,
                    classname=marker_info.group(2),
                    pos=marker_info.group(3),
                )
                # Track the first custom marker index
                if marker_info.group(2) == "marker" and self.first_custom_index == 0:
                    self.first_custom_index = m_idx


def strip_frb_fields(entity: Entity, keep_id: bool = True) -> None:
    """Remove all FrB_ fields from an entity, optionally keeping FrB_ID."""
    keys_to_remove = [
        k
        for k in entity.properties
        if k.startswith("FrB_") and (not keep_id or k != "FrB_ID")
    ]
    for key in keys_to_remove:
        del entity.properties[key]


def scrub_waypoints(parsed_map: QMapParser, verbose: bool = False) -> None:
    """Remove all waypoint annotations from the map."""
    # Remove testplayerstart entities with FrB_ID (custom markers)
    original_count = len(parsed_map.entities)
    parsed_map.entities = [
        ent
        for ent in parsed_map.entities
        if not (
            ent.properties.get("classname") == "testplayerstart"
            and "FrB_ID" in ent.properties
        )
    ]
    removed_count = original_count - len(parsed_map.entities)
    if verbose and removed_count:
        print(f"Removed {removed_count} custom marker entities")

    # Strip all FrB_ fields from all entities (including FrB_ID)
    for ent in parsed_map.entities:
        strip_frb_fields(ent, keep_id=False)

    # Remove FrogBotWP field from worldspawn
    for ent in parsed_map.entities:
        if ent.properties.get("classname") == "worldspawn":
            ent.properties.pop("FrogBotWP", None)
            break


def generate_unique_id(prefix: str, ids_seen: dict[str, str]) -> str:
    """Generate a unique FrB_ID with the given prefix."""
    counter = 1
    frb_id = f"{prefix}{counter}"
    while frb_id in ids_seen:
        counter += 1
        frb_id = f"{prefix}{counter}"
    return frb_id


def inject_waypoints(
    parsed_map: QMapParser,
    parsed_wp: WaypParser,
    verbose: bool = False,
) -> None:
    """Inject waypoint data from parsed_wp into parsed_map entities."""
    # Step 1: Remove existing testplayerstart entities with FrB_ID (custom markers)
    parsed_map.entities = [
        ent
        for ent in parsed_map.entities
        if not (
            ent.properties.get("classname") == "testplayerstart"
            and "FrB_ID" in ent.properties
        )
    ]

    # Step 2: Strip existing FrB_ fields (except ID) from all entities
    for ent in parsed_map.entities:
        strip_frb_fields(ent, keep_id=True)

    # Step 3: Build marker index -> entity mapping and collect existing IDs
    ids_seen: dict[str, str] = {}
    marker_index_to_entity: dict[int, Entity] = {}
    marker_index_to_id: dict[int, str] = {}

    # First pass: collect existing FrB_IDs
    m_index = 0
    for ent in parsed_map.entities:
        classname = ent.properties.get("classname")
        if classname not in MARKERABLE:
            continue
        # Skip entities that don't spawn in deathmatch mode
        if not is_deathmatch_entity(ent):
            continue
        m_index += 1
        frb_id = ent.properties.get("FrB_ID")
        if frb_id:
            if frb_id in ids_seen:
                print(
                    f"WARNING: duplicate FrB_ID='{frb_id}' on m{m_index}, {classname} "
                    f"(first seen on {ids_seen[frb_id]})",
                    file=sys.stderr,
                )
            else:
                ids_seen[frb_id] = classname or ""
                marker_index_to_id[m_index] = frb_id
        marker_index_to_entity[m_index] = ent

    # Second pass: assign new IDs where missing
    m_index = 0
    for ent in parsed_map.entities:
        classname = ent.properties.get("classname")
        if classname not in MARKERABLE:
            continue
        # Skip entities that don't spawn in deathmatch mode
        if not is_deathmatch_entity(ent):
            continue
        m_index += 1
        if m_index in marker_index_to_id:
            continue  # Already has an ID
        prefix = MARKERABLE[classname]
        if not prefix:
            continue  # This entity type doesn't get markers
        frb_id = generate_unique_id(prefix, ids_seen)
        ent.properties["FrB_ID"] = frb_id
        ids_seen[frb_id] = classname or ""
        marker_index_to_id[m_index] = frb_id
        if verbose:
            print(f"Assigned FrB_ID='{frb_id}' to m{m_index} ({classname})")

    # Step 4: Create testplayerstart entities for custom markers
    first_custom = parsed_wp.first_custom_index
    if first_custom > 0:
        for i, pos in enumerate(parsed_wp.n_cache):
            custom_idx = first_custom + i
            frb_id = generate_unique_id("mark", ids_seen)
            ids_seen[frb_id] = "testplayerstart"
            marker_index_to_id[custom_idx] = frb_id

            new_ent = Entity(
                properties={
                    "classname": "testplayerstart",
                    "origin": pos,
                    "FrB_ID": frb_id,
                },
                comments=["// Frogbot custom marker\n"],
            )
            parsed_map.add_entity(new_ent)
            marker_index_to_entity[custom_idx] = new_ent
            if verbose:
                print(
                    f"Created custom marker m{custom_idx} at {pos} with FrB_ID='{frb_id}'"
                )

    # Step 5: Apply marker properties to entities
    for m_idx, marker in parsed_wp.markers.items():
        if m_idx not in marker_index_to_entity:
            print(f"WARNING: marker m{m_idx} not found in entity list", file=sys.stderr)
            continue
        ent = marker_index_to_entity[m_idx]

        # Zone -> FrB_Z (note: Zn in QC becomes FrB_Z, Gn becomes FrB_g per instructions)
        if marker.zone:
            ent.properties["FrB_Z"] = str(marker.zone)
        # Goal -> FrB_g
        if marker.goal:
            ent.properties["FrB_g"] = str(marker.goal)
        # T -> FrB_T
        if marker.field_t:
            ent.properties["FrB_T"] = str(marker.field_t)
        # view_ofs_z -> FrB_oZ
        if marker.view_ofs_z > -10000:
            ent.properties["FrB_oZ"] = str(marker.view_ofs_z)
        # d_door_open -> FrB_dD
        if marker.d_door_open:
            ent.properties["FrB_dD"] = str(marker.d_door_open)

        # Paths: P0-P7 -> FrB_P0-FrB_P7 (values are FrB_IDs of destinations)
        for p_num, dest_idx in enumerate(marker.paths):
            if dest_idx == 0:
                continue
            if dest_idx not in marker_index_to_id:
                print(
                    f"WARNING: m{m_idx}.P{p_num} references unknown marker m{dest_idx}",
                    file=sys.stderr,
                )
                continue
            ent.properties[f"FrB_P{p_num}"] = marker_index_to_id[dest_idx]

        # Descriptions: D0-D7 -> FrB_D0-FrB_D7
        for d_num, d_val in enumerate(marker.descriptions):
            if d_val == 0:
                continue
            ent.properties[f"FrB_D{d_num}"] = str(d_val)

        # R values: R0-R7 -> FrB_R0-FrB_R7
        for r_num, r_val in enumerate(marker.r_values):
            if r_val == 0:
                continue
            ent.properties[f"FrB_R{r_num}"] = str(r_val)

    # Step 6: Add global properties to worldspawn
    worldspawn = None
    for ent in parsed_map.entities:
        if ent.properties.get("classname") == "worldspawn":
            worldspawn = ent
            break

    if worldspawn:
        worldspawn.properties["FrogBotWP"] = str(FRB_EMB_WP_VERSION)
        if parsed_wp.desire_adj_g1:
            worldspawn.properties["FrB_adj_G1"] = str(parsed_wp.desire_adj_g1)
        if parsed_wp.desire_adj_g2:
            worldspawn.properties["FrB_adj_G2"] = str(parsed_wp.desire_adj_g2)
        if parsed_wp.intermission:
            x, y, z, p, w, r = parsed_wp.intermission
            worldspawn.properties["FrB_iX"] = str(x)
            worldspawn.properties["FrB_iY"] = str(y)
            worldspawn.properties["FrB_iZ"] = str(z)
            worldspawn.properties["FrB_iP"] = str(p)
            worldspawn.properties["FrB_iW"] = str(w)
            worldspawn.properties["FrB_iR"] = str(r)
    else:
        print(ERR_NO_WORLD, file=sys.stderr)


def main() -> None:
    """Script entry point."""
    parser = argparse.ArgumentParser(
        description=(
            "Injects Frogbot waypoint annotations into a .map or .ent file. "
            "This allows to build the map with Frogbot support built-in, or play "
            "with Frogbots in a BSP map without editing it, if the engine supports "
            "overriding entities through .ent files."
        )
    )
    parser.add_argument("-v", "--verbose", action="store_true", help="verbose output")
    parser.add_argument(
        "-w",
        "--waypoints",
        type=str,
        help="the file containing the waypoint code as produced by the waypoint tool",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=str,
        help="output file path (default: overwrite input file)",
    )
    parser.add_argument(
        "-s",
        "--scrub",
        action="store_true",
        help="remove all waypoint annotations from the file instead of injecting",
    )
    parser.add_argument(
        "mapfile",
        type=str,
        help="the .map or .ent file in which to inject waypoint annotations",
    )
    args = parser.parse_args()

    # Parse the map/ent file
    parsed_map = QMapParser(args.mapfile)
    if args.verbose:
        print(f"Loaded {len(parsed_map.entities)} entities from {args.mapfile}")

    if args.scrub:
        # Scrub mode: remove all waypoint annotations
        if args.waypoints:
            print(
                "WARNING: waypoint file argument is ignored in scrub mode",
                file=sys.stderr,
            )
        scrub_waypoints(parsed_map, verbose=args.verbose)
    else:
        # Inject mode: waypoint file is optional (assigns FrB_IDs only if not provided)
        parsed_wp = WaypParser(args.waypoints or "")
        if args.waypoints and args.verbose:
            print(f"Loaded {len(parsed_wp.markers)} markers from waypoint file")
            print(f"First custom marker index: {parsed_wp.first_custom_index}")
            print(f"Custom marker positions: {len(parsed_wp.n_cache)}")

        # Validate waypoint data
        for m_idx, marker in parsed_wp.markers.items():
            if marker.zone == 0 and marker.classname != "marker":
                print(
                    f"WARNING: m{m_idx} ({marker.classname}) has no zone assigned",
                    file=sys.stderr,
                )

        # Inject waypoints
        inject_waypoints(parsed_map, parsed_wp, verbose=args.verbose)

    # Save result
    output_path = args.output or args.mapfile
    parsed_map.save_map(output_path)
    print(f"Saved result to {output_path}")


if __name__ == "__main__":
    main()
