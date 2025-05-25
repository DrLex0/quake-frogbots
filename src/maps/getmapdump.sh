#!/bin/bash
# Crude script to extract the QC code from a quake log file after dumping it from the waypoint tool.
# This assumes the log file ends with the dump, with nothing coming after it.
# TODO: rewrite this in Python to make it more portable (less efficient, but nobody cares)

function getmapdump
{
	# Print condump file starting from last matching line.
	# Substitute + and - characters in the function name with PLUS, DASH respectively.
	awk '/void\(\) map_.* =/ {found=NR} END {if (found) for (i=found; i<=NR; i++) print lines[i]} {lines[NR]=$0}' condump.txt | sed '/^$/d' | perl -pe '
if (/^void\(\) map_([^ =]+)( =.*)$/) {
    $group = $1;
    $group =~ s/\+/PLUS/g;
    $group =~ s/-/DASH/g;
    $_ = "void() map_${group}$2\n";
}'
}

if [ -z "$1" ]; then
	getmapdump
elif [ ! -f "$1" ]; then
	if [ ! -d "$(dirname $PWD)" ]; then
		echo "ERROR: argument must point to an existing file or a new file in an existing directory" 1>&2
		exit 2
	fi
	echo "Creating new file '$1'" 1>&2
	getmapdump > "$1"
else
	sed '/^void() map_/,$d' "$1" > /tmp/tmpmapdumpfump && getmapdump >> /tmp/tmpmapdumpfump && mv /tmp/tmpmapdumpfump "$1"
fi
