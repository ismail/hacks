#!/bin/bash
#
SOURCE=${1:-"$HOME/keywords.sql"}
TEMP_SQL_SCRIPT=$(mktemp)

echo
echo "Importing Chrome keywords from $SOURCE..."
cd "$HOME/Library/Application Support/Google/Chrome/Default"
echo "DROP TABLE IF EXISTS keywords;" > "$TEMP_SQL_SCRIPT"
echo ".read '$SOURCE'" >> "$TEMP_SQL_SCRIPT"
sqlite3 -init "$TEMP_SQL_SCRIPT" "Web Data" .exit
rm "$TEMP_SQL_SCRIPT"