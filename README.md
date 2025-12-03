ldbnrwApi

R-Client für die Landesdatenbank NRW (GENESIS-Webservice 2020)
Mit diesem Paket kannst du Kataloge, Tabellen, Metadaten, Klassifikationen und ganze Statistik-Familien aus der Landesdatenbank NRW automatisiert abrufen.

Die API ist kompatibel mit:

GENESIS-Webservice 2020 (neues Format)

authentifizierten & freien Bereichen

großen Tabellen (inkl. automatischem Chunking)

parallelem Download (optional)

🚀 Installation
# Von lokalem Paket-Ordner installieren
devtools::install()


Oder falls du das Paket später auf GitHub veröffentlichst:

devtools::install_github("placeanddataspace/ldbnrwApi")

🔐 Login / Zugangsdaten

Für personalisierte Tabellen brauchst du einen Account bei IT.NRW.

Empfohlen: Zugangsdaten in ~/.Renviron

LD_USERNAME=DEIN_NAME
LD_PASSWORD=DEIN_PASSWORT


R neu starten – danach funktionieren alle Funktionen ohne Angabe von User/Passwort.

Testen:

Sys.getenv("LD_USERNAME")
Sys.getenv("LD_PASSWORD")

📦 Grundfunktionen
🎯 Gesamten Statistik-Katalog abrufen
library(ldbnrwApi)

stats <- ld_list_statistics()
head(stats)


Gibt eine Liste aller verfügbaren Statistiken (EVAS-Codes).

📄 Alle Tabellen abrufen
tabs <- ld_list_tables()
head(tabs)


Gibt Tabellencode, Beschreibung und Zeitraum zurück.

🔍 Tabellen suchen
ld_search("Pflege")
ld_search("Bevölkerung", fields = "content")

📑 Metadaten & Variablen
🔎 Metadaten zu einer Tabelle
meta <- ld_get_metadata("22411-01i")
str(meta, max.level = 2)


Liefert:

Beschreibung

Zeitraum

Dimensionen

Struktur der Tabelle

Klassifikationen (falls vorhanden)

📊 Klassifikationen / Variablen einer Tabelle

Falls vorhanden:

vars <- ld_get_variables("23111-02i")
names(vars)
vars[[1]]$values


Falls nicht vorhanden (z. B. reine Zeitreihen):

ℹ️ Tabelle 12411-01i hat keine Klassifikationen (nur Werte?).

📥 Tabellendaten abrufen
Einfache Tabelle laden
df <- ld_post_tablefile("22411-01i")
head(df)


Die Funktion:

lädt die Tabelle

wandelt sie ins lange Format

toleriert große Tabellen

nutzt automatisch User/Passwort aus .Renviron

👨‍👩‍👧 Familienfunktionen (EVAS-Codes)

Viele Statistiken bestehen aus mehreren Teil-Tabellen
(z. B. 22411, 22412, 22421 → Pflege).

🔎 Tabellen einer Statistik-Familie abrufen
fam_tabs <- ld_family("224")
head(fam_tabs)

📥 Ganze Statistik-Familie herunterladen
all <- ld_family_download("224", parallel = FALSE)


Mit Parallelverarbeitung:

all <- ld_family_download("224", parallel = TRUE)

⚙️ Einstellungen & Debugging
Roh-API-Antwort anzeigen
ld_raw("22411-01i")

Nur Struktur anzeigen
ld_str("22411-01i")

Netzwerkfehler sehen
options(ldbnrwApi.verbose = TRUE)

🗂 Paketübersicht
Funktion	Beschreibung
ld_list_statistics()	Katalog der Statistiken
ld_list_tables()	Alle verfügbaren Tabellen
ld_search()	Volltextsuche
ld_get_metadata()	Metadaten einer Tabelle
ld_get_variables()	Klassifikationen (falls vorhanden)
ld_post_tablefile()	Daten abrufen
ld_family()	Tabellen einer Statistikfamilie
ld_family_download()	Alle Tabellen einer Familie laden
📝 Lizenz

Daten:
© IT.NRW — Datenlizenz Deutschland, Namensnennung 2.0

Paket:
MIT-Lizenz (siehe LICENSE.md)