#!/usr/bin/env bash
# Eenmalige installatie op PythonAnywhere. Uitvoeren in een Bash console:
#   cd ~/workshops && bash deploy/pythonanywhere_setup.sh
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

if [ ! -f app.py ]; then
  echo "FOUT: app.py niet gevonden in $PROJECT_DIR. Staat de code van de app in de repository?"
  exit 1
fi
if [ ! -f requirements.txt ]; then
  echo "FOUT: requirements.txt ontbreekt. Voeg die toe (bijvoorbeeld met de regel: flask)."
  exit 1
fi

# Kies de nieuwste beschikbare Python-versie
PYTHON=""
for v in python3.13 python3.12 python3.11 python3.10; do
  if command -v "$v" >/dev/null 2>&1; then PYTHON="$v"; break; fi
done
if [ -z "$PYTHON" ]; then PYTHON=python3; fi
PY_VERSION="$("$PYTHON" -c 'import sys; print(f"{sys.version_info[0]}.{sys.version_info[1]}")')"

echo "==> Virtuele omgeving maken met $PYTHON"
if [ ! -d .venv ]; then
  "$PYTHON" -m venv .venv
fi
.venv/bin/pip install --upgrade pip >/dev/null
.venv/bin/pip install -r requirements.txt

echo "==> Map voor gegevens"
mkdir -p .data "$HOME/backups"

echo "==> Instellingen (.env)"
if [ ! -f .env ]; then
  SECRET="$(.venv/bin/python -c 'import secrets; print(secrets.token_hex(32))')"
  cat > .env <<EOF
# Geheime instellingen. Dit bestand staat NIET in GitHub.
SECRET_KEY=$SECRET
EOF
  chmod 600 .env
  echo "    .env aangemaakt met een nieuwe geheime sleutel."
else
  echo "    .env bestaat al, niet gewijzigd."
fi

echo "==> Controle: kan de app geladen worden?"
.venv/bin/python -c "import pythonanywhere_wsgi; print('    OK:', pythonanywhere_wsgi.application)"

cat <<EOF

=====================================================================
 Installatie klaar. Vul op het tabblad "Web" van PythonAnywhere in:

 Python version : $PY_VERSION
 Source code    : $PROJECT_DIR
 Working dir    : $PROJECT_DIR
 Virtualenv     : $PROJECT_DIR/.venv

 Static files   : URL  /static/
                  Map  $PROJECT_DIR/static

 Vervang de HELE inhoud van het WSGI configuration file door:

import sys
sys.path.insert(0, "$PROJECT_DIR")
from pythonanywhere_wsgi import application

 Klik daarna op de groene knop "Reload".
=====================================================================
EOF
