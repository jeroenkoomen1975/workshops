#!/usr/bin/env bash
# Nieuwe versie uit GitHub binnenhalen en de website herladen.
#   cd ~/workshops && bash deploy/update.sh
# De mappen .data en .venv en het bestand .env blijven onaangeroerd.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

echo "==> Eerst een back-up van de gegevens"
bash deploy/backup_data.sh

echo "==> Nieuwe code ophalen"
git pull --ff-only

echo "==> Pakketten bijwerken"
.venv/bin/pip install -r requirements.txt

echo "==> Controle: kan de app geladen worden?"
.venv/bin/python -c "import pythonanywhere_wsgi"

echo "==> Website herladen"
shopt -s nullglob
WSGI_FILES=(/var/www/*_wsgi.py)
if [ ${#WSGI_FILES[@]} -eq 0 ]; then
  echo "    Geen WSGI-bestand gevonden; klik zelf op 'Reload' op het tabblad Web."
else
  for f in "${WSGI_FILES[@]}"; do
    touch "$f"
    echo "    Herladen: $f"
  done
fi
echo "Klaar."
