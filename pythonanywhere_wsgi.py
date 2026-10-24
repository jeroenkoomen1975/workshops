"""Startpunt voor PythonAnywhere.

Het WSGI-bestand op PythonAnywhere (onder /var/www/) importeert alleen
`application` uit dit bestand. Hier wordt:
  1. de projectmap de werkmap, zodat `.data` op de juiste plek wordt gevonden;
  2. het bestand `.env` ingelezen (geheime sleutel en andere instellingen);
  3. de webapp uit app.py geladen.
"""

import os
import sys
from pathlib import Path

PROJECT_DIR = Path(__file__).resolve().parent


def _load_env(path):
    """Lees KEY=waarde-regels uit .env; bestaande omgevingsvariabelen winnen."""
    if not path.exists():
        return
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        os.environ.setdefault(key.strip(), value.strip().strip('"').strip("'"))


def _find_application(module):
    """Ondersteun `app = Flask(...)`, `application = ...` en `create_app()`."""
    for name in ("application", "app"):
        candidate = getattr(module, name, None)
        if callable(candidate):
            return candidate
    factory = getattr(module, "create_app", None)
    if callable(factory):
        return factory()
    raise RuntimeError(
        "Geen webapp gevonden in app.py: verwacht `app`, `application` of `create_app()`."
    )


os.chdir(PROJECT_DIR)
if str(PROJECT_DIR) not in sys.path:
    sys.path.insert(0, str(PROJECT_DIR))
_load_env(PROJECT_DIR / ".env")

import app as _app_module  # noqa: E402  (pas na chdir en .env laden)

application = _find_application(_app_module)
