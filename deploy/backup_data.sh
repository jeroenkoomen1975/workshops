#!/usr/bin/env bash
# Back-up van de map .data naar ~/backups. De laatste 30 back-ups blijven bewaard.
# Als geplande taak (tabblad "Tasks"):  bash /home/GEBRUIKERSNAAM/workshops/deploy/backup_data.sh
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/backups"
KEEP=30

mkdir -p "$BACKUP_DIR"
if [ ! -d "$PROJECT_DIR/.data" ]; then
  echo "Geen map .data gevonden; niets om te back-uppen."
  exit 0
fi

FILE="$BACKUP_DIR/workshops-data-$(date +%Y-%m-%d_%H%M).tgz"
tar czf "$FILE" -C "$PROJECT_DIR" .data
echo "Back-up gemaakt: $FILE"

ls -1t "$BACKUP_DIR"/workshops-data-*.tgz | tail -n +$((KEEP + 1)) | xargs -r rm --
