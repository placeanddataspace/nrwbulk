#' Liste aller Tabellen einer GENESIS-Statistikfamilie abrufen
#'
#' Diese Funktion durchsucht die GENESIS-Webservice-API der
#' Landesdatenbank NRW (`ldbnrwApi`) nach allen Tabellen, die zu einer
#' bestimmten Statistikfamilie gehören.  
#'
#' Eine Statistikfamilie ist durch einen gemeinsamen Präfix gekennzeichnet
#' (z. B. `"224"` für alle Tabellen der Familie 224xx).  
#'
#' `ld_family()` führt zwei Schritte aus:
#'
#' 1. Abruf aller Statistikcodes via [`ld_list_statistics()`]  
#' 2. Suche aller Tabellencodes je Statistik über [`ld_search_tables()`]
#'
#' Die Ergebnisse aller passenden Statistiken werden zu einem Dataframe
#' zusammengeführt.
#'
#' @param prefix Zeichenkette: Gemeinsamer Präfix der Statistikfamilie,
#'   z. B. `"224"`.  
#'   Alle Statistikcodes, die mit diesem Präfix beginnen, werden berücksichtigt.
#'
#' @param pagelength Anzahl der maximal abzurufenden Treffer pro API-Seite.  
#'   Standard ist `500`.
#'
#' @param language Sprache der API-Ergebnisse, z. B. `"de"` oder `"en"`.
#'
#' @param username Benutzername für die GENESIS-API.  
#'   Standard: Umgebungsvariable `LD_USERNAME`, sonst `"GAST"`.
#'
#' @param password Passwort für die GENESIS-API.  
#'   Standard: Umgebungsvariable `LD_PASSWORD`, sonst `"GAST"`.
#'
#' @return
#' Ein Dataframe mit allen gefundenen Tabellencodes der Statistikfamilie,
#' typischerweise mit Spalten wie:
#' - `code`  
#' - `content` (Tabellenbeschreibung)
#'
#' Falls keine Tabellen gefunden werden, gibt die Funktion ein leeres Dataframe
#' mit den Spalten `code` und `content` zurück.
#'
#' @examples
#' \dontrun{
#' # Lade alle Tabellen der Familie "224" (z. B. Arbeitsmarktstatistik)
#' tabs <- ld_family("224")
#' head(tabs)
#' }
#'
#' @seealso 
#'   [ld_list_statistics()],  
#'   [ld_search_tables()],  
#'   [ld_family_download()]
#'
#' @export
ld_family <- function(prefix,
                      pagelength = 500,
                      language = "de",
                      username = NULL,
                      password = NULL) {
  
  # Credentials
  if (is.null(username)) username <- Sys.getenv("LD_USERNAME", unset = "GAST")
  if (is.null(password)) password <- Sys.getenv("LD_PASSWORD", unset = "GAST")
  
  # ---- 1) Statistiken holen ----
  stats <- ld_list_statistics()
  stats_codes <- stats$code[startsWith(stats$code, prefix)]
  
  if (length(stats_codes) == 0) {
    message("Keine Statistikcodes gefunden für Prefix ", prefix)
    return(data.frame(code = character(), content = character()))
  }
  
  # ---- 2) FIND-Suche je Statistik ----
  all_tabs <- list()
  
  for (st in stats_codes) {
    message("Suche Tabellen für Statistik ", st)
    
    df <- ld_search_tables(
      term = st,  
      pagelength = pagelength,
      language = language,
      username = username,
      password = password
    )
    
    if (nrow(df) == 0) {
      message("   Keine Tabellen gefunden für ", st)
      next
    }
    
    # Filter: Code beginnt wirklich mit Statistikcode (echt)
    df <- df[startsWith(df$code, st), ]
    
    if (nrow(df) == 0) {
      message("Tabellen gefunden, aber keine mit Code-Präfix ", st)
      next
    }
    
    all_tabs[[st]] <- df
  }
  
  # ---- 3) Zusammenführen ----
  if (length(all_tabs) == 0) {
    message("Keine Tabellen für Präfix ", prefix)
    return(data.frame(code = character(), content = character()))
  }
  
  result <- do.call(rbind, all_tabs)
  rownames(result) <- NULL
  result
}
