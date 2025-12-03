#' Metadaten einer GENESIS-Tabelle abrufen
#'
#' Diese Funktion ruft die Metadaten einer Tabelle der
#' Landesdatenbank NRW (GENESIS-Webservice 2020) ab.
#'
#' Die API liefert Informationen wie Struktur, Beschreibungstexte,
#' verfügbare Merkmale, Zeiträume und Datenquellen der jeweiligen Tabelle.
#'
#' Falls im Bereich `area = "free"` keine Metadaten verfügbar sind,
#' erfolgt automatisch ein Fallback auf `area = "Alle"`.
#'
#' @param code Zeichenkette: Tabellencode, z. B. `"22411-01i"`.
#' @param area Bereich der Datenbank: `"free"` (Standard) oder `"Alle"`.
#'   `"free"` liefert nur frei verfügbare Inhalte.  
#'   `"Alle"` liefert vollständige Metadaten, benötigt aber ggf. einen Account.
#' @param language Sprache der Metadaten, `"de"` oder `"en"`.
#' @param username API-Benutzername.  
#'   Standard: Umgebungsvariable `LD_USERNAME`, sonst `"GAST"`.
#' @param password API-Passwort.  
#'   Standard: Umgebungsvariable `LD_PASSWORD`, sonst `"GAST"`.
#'
#' @return Eine Liste (JSON-ähnliche Struktur) mit den vollständigen Metadaten
#'   der Tabelle. Bei Fehlern wird ein `stop()` ausgelöst.
#'
#' @examples
#' \dontrun{
#' meta <- ld_get_metadata("22411-01i")
#' str(meta)
#' }
#'
#' @seealso 
#'   [ld_get_variables()],  
#'   [ld_post_tablefile()],  
#'   [ld_search_tables()]
#'
#' @importFrom httr POST add_headers status_code content
#'
#' @export
ld_get_metadata <- function(code,
                            area = "free",
                            language = "de",
                            username = NULL,
                            password = NULL) {
  
  # Credential-Fallback
  if (is.null(username)) username <- Sys.getenv("LD_USERNAME", unset = "GAST")
  if (is.null(password)) password <- Sys.getenv("LD_PASSWORD", unset = "GAST")
  
  url <- "https://www.landesdatenbank.nrw.de/ldbnrwws/rest/2020/metadata/table"
  
  body <- list(
    name = code,
    area = area,
    language = language
  )
  
  res <- httr::POST(
    url,
    httr::add_headers(
      username = username,
      password = password
    ),
    encode = "form",
    body = body
  )
  
  if (httr::status_code(res) != 200) {
    stop("HTTP Fehler: ", httr::status_code(res))
  }
  
  out <- httr::content(res, as = "parsed", type = "application/json")
  
  # IT.NRW liefert bei falscher area NULL zurück → automatisch fallback testen
  if (is.null(out$Object) && area == "free") {
    message("Keine Metadaten unter area='free'. Versuche area='Alle' …")
    return(ld_get_metadata(code, area = "Alle", language = language,
                           username = username, password = password))
  }
  
  return(out)
}
