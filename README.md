# nrwbulk

Werkzeug für den Massendownload von Tabellen, Metadaten und gesamten
Statistikfamilien aus der Landesdatenbank NRW (GENESIS-Webservice 2020).

Das Paket richtet sich an Anwenderinnen und Anwender, die regelmäßig große
Datenmengen aus der Landesdatenbank benötigen – z. B. für Forschung,
Berichterstattung, Monitoring, Planung oder automatisierte Datenpipelines.
`nrwbulk` automatisiert wiederkehrende Abrufe und erleichtert es, ganze
Themenbereiche oder vollständige Tabellenstrukturen in einem Arbeitsschritt
herunterzuladen und ohne Umlautfehler in R zu überführen.

---

## Inhalt

- [Funktionen des Pakets](#funktionen-des-pakets)
- [Installation](#installation)
- [Zugangsdaten einrichten](#zugangsdaten-einrichten)
- [Grundlegende Nutzung](#grundlegende-nutzung)
- [Beispiele](#beispiele)
  - [1. Verfügbare Statistiken abrufen](#1-verfügbare-statistiken-abrufen)
  - [2. Tabellenübersicht laden](#2-tabellenübersicht-laden)
  - [3. Metadaten zu einer Tabelle](#3-metadaten-zu-einer-tabelle)
  - [4. Eine komplette Statistikfamilie herunterladen](#4-eine-komplette-statistikfamilie-herunterladen)
- [Hinweise und Grenzen der API](#hinweise-und-grenzen-der-api)
- [Lizenz](#lizenz)

---

## Funktionen des Pakets

`nrwbulk` stellt mehrere Kernfunktionen bereit:

### ✔ Tabellen- und Statistikübersichten laden
- `ld_list_statistics()` – Liste aller verfügbaren Statistikbereiche  
- `ld_list_tables()` – Liste aller Tabellencodes und Titel

### ✔ Metadaten einsehen
- `ld_get_metadata()` – Struktur und Beschreibung einer Tabelle  
- `ld_get_variables()` – Variablen und Klassifikationen (falls vorhanden)

### ✔ Daten herunterladen
- `ld_post_tablefile()` – Tabelle als Datei (flat CSV) herunterladen  
- `ld_family_download()` – gesamte Statistikfamilie in einem Schritt herunterladen

Der Schwerpunkt des Pakets liegt auf **Massendownloads**, die das Web-Interface
der Landesdatenbank nicht effizient unterstützt.

---

## Installation

```r
# Installation von GitHub (devtools erforderlich)
install.packages("devtools")
devtools::install_github("placeanddataspace/nrwbulk")

Zugangsdaten einrichten

Für den Zugriff auf viele Tabellen ist ein Benutzerkonto der Landesdatenbank NRW notwendig.
Benutzername und Passwort müssen hinterlegt sein, damit nrwbulk Daten abrufen kann.

Am einfachsten geschieht dies über die Datei .Renviron, die im Projekt- oder Home-Verzeichnis
erstellt werden kann:

LD_USERNAME=username
LD_PASSWORD=password

Danach R neu starten.

Falls keine Zugangsdaten gesetzt sind, verwendet das Paket automatisch:

    Benutzer: GAST

    Passwort: GAST

Grundlegende Nutzung

Nach der Installation:

library(nrwbulk)

Beispiele
1. Verfügbare Statistiken abrufen

stats <- ld_list_statistics()
head(stats)

Lieferung: Statistik-Code + Beschreibung.
2. Tabellenübersicht laden

tabs <- ld_list_tables()
head(tabs)

Ergebnis: Tabellencode, Titel, Zeitraum.
3. Metadaten zu einer Tabelle

meta <- ld_get_metadata("22411-01i")
meta$Object$Content     # Titel
meta$Object$Time        # Zeiträume

4. Eine komplette Statistikfamilie herunterladen

Damit lassen sich alle Tabellen eines Bereichs („Familie“) automatisiert herunterladen.
Dies ist eine zentrale Funktion des Pakets.

ld_family_download("224", parallel = FALSE)

Das Ergebnis sind mehrere .csv- oder .ffc-Dateien im Unterordner:

downloads/224/

Optional parallel:

ld_family_download("224", parallel = TRUE)

Hinweise und Grenzen der API

    Der GENESIS-Webservice ermöglicht pro Anfrage nur eine einzelne Tabelle.
    nrwbulk automatisiert deren Zusammenstellung.

    Nicht alle Tabellen enthalten Klassifikationen.
    In diesem Fall liefert ld_get_variables() NULL.

    Zeiträume und verfügbare Merkmale variieren je nach Tabelle und Datenstand.

Lizenz

Dieses Projekt steht unter der MIT-Lizenz.
Daten: © IT.NRW, jeweils mit den in den Metadaten angegebenen Lizenzbedingungen.