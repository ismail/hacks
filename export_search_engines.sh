#!/bin/sh

DESTINATION=${1:-"$HOME/keywords.sql"}
TEMP_SQL_SCRIPT=$(mktemp)

echo "Exporting Chrome keywords to $DESTINATION..."
cd "$HOME/Library/Application Support/Google/Chrome/Default"
echo ".output '$DESTINATION'" > "$TEMP_SQL_SCRIPT"
echo ".dump keywords" >> "$TEMP_SQL_SCRIPT"
sqlite3 -init "$TEMP_SQL_SCRIPT" "Web Data" .exit
rm "$TEMP_SQL_SCRIPT"