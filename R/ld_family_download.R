#' Lade alle Tabellen einer GENESIS-Statistikfamilie herunter
#'
#' Diese Funktion lädt alle verfügbaren Tabellen (CSV) einer
#' Statistikfamilie der Landesdatenbank NRW (GENESIS-API) herunter.
#' Der Familien-Prefix (z. B. `"224"`) bestimmt die Statistikfamilie.
#'
#' Für jede Tabelle wird `ld_post_tablefile()` aufgerufen, das die
#' entsprechende CSV-Tabelle von der API abruft. Die Dateien können
#' optional parallel mit `future.apply` heruntergeladen werden.
#'
#' @param prefix Zeichenkette: Statistik-Prefix, z. B. `"224"`.
#'   Bestimmt die zu ladende Statistikfamilie.
#' @param outdir Zeichenkette: Zielordner für die Downloads.
#'   Standard ist `"downloads"`. Unterordner pro Statistik (z. B. `"22411"`)
#'   werden automatisch erstellt.
#' @param parallel Logisch: Soll der Download parallel erfolgen?
#'   Wenn `TRUE`, wird `future.apply::future_lapply()` verwendet (falls verfügbar).
#'
#' @return Eine Liste der geladenen Dataframes. Tabellen, die bereits lokal
#'   gespeichert sind, werden erneut eingelesen, aber nicht erneut heruntergeladen.
#'
#' @details
#' Die Funktion ruft intern:
#' - `ld_family()` zum Abrufen der Tabellenliste,
#' - `ld_post_tablefile()` zum Abrufen der einzelnen CSV-Dateien.
#'
#' Bereits vorhandene Dateien werden übersprungen.
#'
#' @examples
#' \dontrun{
#' # Lade alle Tabellen der Statistikfamilie 224 herunter:
#' df_list <- ld_family_download("224", outdir = "downloads_224")
#' }
#'
#' @seealso [ld_family()], [ld_post_tablefile()]
#'
#' @importFrom readr read_csv write_csv
#' @importFrom future.apply future_lapply
#' @importFrom progress progress_bar
#'
#' @export
ld_family_download <- function(prefix,
                               outdir = "downloads",
                               parallel = TRUE) {
  
  # Tabellenliste laden
  tabs <- ld_family(prefix)
  if (nrow(tabs) == 0) {
    message("Keine Tabellen für Prefix ", prefix)
    return(list())
  }
  
  # Zielordner anlegen
  if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)
  
  # Fortschrittsbalken
  pb <- progress::progress_bar$new(
    format = "  ⬇️  :current/:total [:bar] :percent  :eta - :what",
    total = nrow(tabs), clear = FALSE, width = 80
  )
  
  # Download einer einzelnen Tabelle
  download_one <- function(code) {
    stat_prefix <- substr(code, 1, 5)
    stat_dir <- file.path(outdir, stat_prefix)
    if (!dir.exists(stat_dir)) dir.create(stat_dir, recursive = TRUE)
    
    outfile <- file.path(stat_dir, paste0(code, ".csv"))
    
    # Skip vorhandene Dateien
    if (file.exists(outfile)) {
      pb$tick(tokens = list(what = paste0(code, " (skip)")))
      return(readr::read_csv(outfile, show_col_types = FALSE))
    }
    
    pb$tick(tokens = list(what = code))
    
    # Download
    df <- tryCatch(
      ld_post_tablefile(code),
      error = function(e) {
        message("Fehler beim Laden von ", code, ": ", e$message)
        return(NULL)
      }
    )
    
    # Speichern
    if (!is.null(df)) {
      readr::write_csv(df, outfile)
    }
    
    df
  }
  
  # Parallel?
  if (parallel && requireNamespace("future.apply", quietly = TRUE)) {
    message("parallelmodus aktiviert (future.apply)")
    future.apply::future_lapply(tabs$code, download_one)
  } else {
    message(" Serieller Modus (kein future.apply installiert)")
    lapply(tabs$code, download_one)
  }
}
