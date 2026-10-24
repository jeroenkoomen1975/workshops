# Stappenplan: workshop-app online op PythonAnywhere

Eindresultaat: de app draait op **https://workshops.jouwsite.nl** (vervang overal
`jouwsite.nl` door je eigen domein). Je hoofdwebsite bij Hostinger blijft gewoon werken.

Reken op ongeveer een uur, inclusief wachten op DNS.

---

## Stap 0 – Wat je nodig hebt

- De laatste versie van de app (de zip) op je computer.
- Toegang tot hPanel van Hostinger (voor de DNS van je domein).
- Een PythonAnywhere-account met het goedkoopste **betaalde** pakket (ca. $5 per maand).
  Dat is nodig voor een eigen domeinnaam. Wil je eerst gratis testen? Dat kan op
  `gebruikersnaam.eu.pythonanywhere.com`; sla dan stap 6 en 7 over.

---

## Stap 1 – Code in GitHub zetten

De deployment-bestanden staan al in `https://github.com/jeroenkoomen1975/workshops`.
Voeg daar de code van de app aan toe:

1. Pak de zip uit op je computer.
2. Ga naar de repository op GitHub → **Add file → Upload files**.
3. Sleep de **inhoud** van de map erin: `app.py`, `academics.py`, `requirements.txt`,
   de mappen `templates`, `static`, `tests` en de overige bestanden.
4. Sleep **NIET** mee:
   - `.data` – daarin staan namen en resultaten van studenten. De repository is
     **openbaar**; deze map mag nooit op GitHub komen.
   - `.venv` – werkt alleen op Windows; wordt op PythonAnywhere opnieuw gemaakt.
5. Overschrijf **niet** `.gitignore`, `pythonanywhere_wsgi.py` en de map `deploy`.
6. Klik op **Commit changes**.

> Controleer na het uploaden op GitHub dat er geen map `.data` zichtbaar is.
> Staat die er toch? Verwijder hem meteen en laat het me weten.

---

## Stap 2 – Account op PythonAnywhere (EU)

1. Ga naar **https://eu.pythonanywhere.com** en maak een account aan.
   Kies de EU-versie: dan staan de gegevens van studenten in Europa (AVG).
2. Neem via **Account** het betaalde pakket (voor het eigen subdomein).

---

## Stap 3 – Code ophalen en installeren

1. Open op PythonAnywhere **Consoles → Bash**.
2. Voer uit:

   ```bash
   git clone https://github.com/jeroenkoomen1975/workshops.git ~/workshops
   cd ~/workshops
   bash deploy/pythonanywhere_setup.sh
   ```

Het script maakt de virtuele omgeving, installeert de pakketten, maakt een geheime
sleutel aan in `.env` en controleert of de app start. Aan het eind toont het precies
wat je in stap 4 moet invullen. **Laat dit venster open.**

---

## Stap 4 – Web-app aanmaken

1. Ga naar het tabblad **Web** → **Add a new web app**.
2. Domeinnaam:
   - betaald pakket: vul `workshops.jouwsite.nl` in;
   - gratis testen: laat de voorgestelde naam staan.
3. Kies **Manual configuration** (niet "Flask") en dezelfde **Python-versie** die het
   script toonde.
4. Vul op de pagina die verschijnt in (de exacte paden staan in de uitvoer van het script):

   | Veld | Waarde |
   |------|--------|
   | Source code | `/home/GEBRUIKERSNAAM/workshops` |
   | Working directory | `/home/GEBRUIKERSNAAM/workshops` |
   | Virtualenv | `/home/GEBRUIKERSNAAM/workshops/.venv` |

5. Klik op de link van het **WSGI configuration file**, verwijder **alles** en plak:

   ```python
   import sys
   sys.path.insert(0, "/home/GEBRUIKERSNAAM/workshops")
   from pythonanywhere_wsgi import application
   ```

   Klik op **Save**.
6. Bij **Static files**: URL `/static/`, map `/home/GEBRUIKERSNAAM/workshops/static`.
7. Klik bovenaan op de groene knop **Reload**.

---

## Stap 5 – Bestaande gegevens overzetten (optioneel)

Wil je de huidige inschrijvingen, accounts en planning meenemen?

1. Stop de app op je Windows-computer.
2. Maak een zip van **alleen** de map `.data` (bijvoorbeeld `data.zip`).
3. Op PythonAnywhere: **Files** → ga naar `/home/GEBRUIKERSNAAM/workshops` → **Upload a file**.
4. In de Bash console:

   ```bash
   cd ~/workshops
   rm -rf .data          # lege map van de installatie weghalen
   unzip data.zip
   rm data.zip
   ls .data              # controle: je bestanden staan erin
   ```

5. Tabblad **Web** → **Reload**.

> Komt na het uitpakken een map `data/` of `workshops/.data/` tevoorschijn in plaats
> van `.data`? Verplaats die dan naar `~/workshops/.data`.

---

## Stap 6 – Subdomein koppelen bij Hostinger

1. Op het tabblad **Web** van PythonAnywhere staat bij **DNS setup** een adres zoals
   `webapp-1234567.eu.pythonanywhere.com`. Kopieer dat.
2. In hPanel: **Domeinen → jouw domein → DNS / Nameservers**.
3. Bestaat er al een record met de naam `workshops`? Verwijder het.
4. Voeg toe:

   | Type | Naam | Wijst naar | TTL |
   |------|------|------------|-----|
   | CNAME | `workshops` | `webapp-1234567.eu.pythonanywhere.com` | standaard |

5. Wacht 15–60 minuten. Daarna opent `http://workshops.jouwsite.nl` de app.

---

## Stap 7 – HTTPS aanzetten

1. PythonAnywhere → **Web** → sectie **Security**.
2. Bij **HTTPS certificate**: kies **Auto-renewing Let's Encrypt certificate**.
   (Lukt dat niet, dan is de DNS nog niet actief: wacht even en probeer opnieuw.)
3. Zet **Force HTTPS** aan.
4. Klik op **Reload**.

De app staat nu online op **https://workshops.jouwsite.nl**.

---

## Stap 8 – Automatische back-up

1. Tabblad **Tasks** → nieuwe dagelijkse taak, bijvoorbeeld om 02:00:

   ```bash
   bash /home/GEBRUIKERSNAAM/workshops/deploy/backup_data.sh
   ```

2. De back-ups komen in `/home/GEBRUIKERSNAAM/backups` (de laatste 30 blijven bewaard).
3. Download af en toe een back-up naar je eigen computer via **Files**.

---

## Stap 9 – Controleren

- [ ] Inloggen als beheerder werkt.
- [ ] Wachtwoord van de beheerder is sterk (verander het als het nog een testwachtwoord is).
- [ ] Een student kan zich inschrijven en ziet zijn punten.
- [ ] Een docent kan aftekenen; de stempel verschijnt op de stempelkaart.
- [ ] Het slotje (HTTPS) staat in de adresbalk.
- [ ] Op GitHub staat geen map `.data`.

---

## Later: een nieuwe versie zetten

1. Zet de gewijzigde bestanden op GitHub (zoals in stap 1, nooit `.data`).
2. In de Bash console van PythonAnywhere:

   ```bash
   cd ~/workshops
   bash deploy/update.sh
   ```

Het script maakt eerst een back-up, haalt de nieuwe code op, werkt de pakketten bij en
herlaadt de website. `.data`, `.venv` en `.env` blijven staan.

---

## Problemen oplossen

| Wat je ziet | Wat te doen |
|-------------|-------------|
| "Something went wrong" of foutpagina | **Web** → **Error log** onderaan; de laatste regels vertellen wat er mis is. |
| `app.py niet gevonden` bij het script | De code is nog niet op GitHub gezet (stap 1), of je zit in de verkeerde map. Voer `cd ~/workshops && git pull` uit. |
| `Geen webapp gevonden in app.py` | De app heeft een andere naam dan `app`; stuur me de foutmelding. |
| Opmaak ontbreekt (kale pagina) | Controleer de **Static files**-regel uit stap 4. |
| Subdomein opent niets | DNS nog niet actief, of het oude `workshops`-record staat nog in hPanel. |
| Uitgelogd na elke herlaadbeurt | De app leest de geheime sleutel mogelijk niet uit `SECRET_KEY`; laat het me weten. |

## Belangrijk over privacy

De app bevat persoonsgegevens van studenten. Overleg met de ICT-afdeling of de
privacyfunctionaris van school of hosting bij PythonAnywhere (EU) is toegestaan.
