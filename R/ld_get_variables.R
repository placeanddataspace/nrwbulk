#' Klassifikationen (Variablen) einer GENESIS-Tabelle abrufen
#'
#' Diese Funktion extrahiert aus den Metadaten einer Tabelle der
#' Landesdatenbank NRW (GENESIS-Webservice 2020) die vorhandenen
#' Klassifikationen („Variablen“) mit ihren möglichen Ausprägungen.
#'
#' **Wichtiger Hinweis:**  
#' Die API liefert für viele Tabellen *keine* Klassifikationen zurück  
#' (insbesondere bei einfachen Tabellen, Zeitreihen oder einspaltigen Ergebnissen).
#' In diesen Fällen gibt die Funktion `NULL` zurück.  
#' Dies ist **kein Fehler**, sondern eine Eigenschaft des Webservice.
#'
#' @param code Zeichenkette: Tabellencode, z. B. `"22411-01i"`.
#' @param area Datenbereich: `"free"` (Standard) oder `"Alle"`.  
#'   Wird intern an `ld_get_metadata()` durchgereicht.
#' @param language Sprache der API („de“ oder „en“).
#' @param username API-Benutzername (Standard: Umgebungsvariable `LD_USERNAME`, sonst `"GAST"`).
#' @param password API-Passwort (Standard: Umgebungsvariable `LD_PASSWORD`, sonst `"GAST"`).
#'
#' @return
#' Eine benannte Liste von Variablen.  
#' Jede Variable enthält:
#' * `name`        – interner Variablenname  
#' * `description` – Beschreibung  
#' * `values`      – Dataframe mit `code` und `label`
#'
#' Gibt `NULL` zurück, wenn keine Klassifikationen vorhanden sind.
#'
#' @examples
#' \dontrun{
#' vars <- ld_get_variables("22411-01i")
#' vars
#' }
#'
#' @seealso
#'   [ld_get_metadata()],  
#'   [ld_post_tablefile()],  
#'   [ld_search_tables()]
#'
#' @export
ld_get_variables <- function(code,
                             area = "free",
                             language = "de",
                             username = NULL,
                             password = NULL) {
  
  # Metadaten abrufen
  meta <- ld_get_metadata(
    code = code,
    area = area,
    language = language,
    username = username,
    password = password
  )
  
  if (is.null(meta$Object)) {
    stop("Keine Metadaten gefunden für ", code)
  }
  
  vars <- meta$Object$Classifications
  
  # Keine Klassifikationen vorhanden
  if (is.null(vars) || length(vars) == 0) {
    message("ℹ️ Tabelle ", code, " enthält keine Klassifikationen.")
    return(NULL)
  }
  
  # Aufbereiten
  out <- lapply(vars, function(v) {
    # Name & Beschreibung robust auslesen
    name <- v$Classification %||% NA_character_
    desc <- v$Description %||% NA_character_
    
    # Values (können NULL oder verschieden strukturiert sein)
    vals <- v$Values
    if (is.null(vals) || length(vals) == 0) {
      df_vals <- data.frame(code = character(), label = character(), stringsAsFactors = FALSE)
    } else {
      df_vals <- data.frame(
        code  = vapply(vals, function(x) x$Code    %||% NA_character_, character(1)),
        label = vapply(vals, function(x) x$Content %||% NA_character_, character(1)),
        stringsAsFactors = FALSE
      )
    }
    
    list(
      name        = name,
      description = desc,
      values      = df_vals
    )
  })
  
  # Benennung der Liste
  names(out) <- vapply(vars, function(v) v$Classification %||% "unknown_variable", character(1))
  
  return(out)
}

# Fallback-Operator (wie in purrr)
`%||%` <- function(a, b) if (!is.null(a)) a else b
