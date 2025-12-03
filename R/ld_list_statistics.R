#' Statistikkatalog der Landesdatenbank NRW abrufen
#'
#' Diese Funktion ruft aus der GENESIS-Webservice-API der
#' Landesdatenbank NRW (LDB NRW) den Statistikkatalog ab.
#'
#' Jede Statistik besitzt einen Code (z. B. `"22411"`) und eine
#' Beschreibung. Die API liefert damit eine Übersicht über alle verfügbaren
#' Statistiken, die anschließend z. B. mit [`ld_search_tables()`] oder
#' [`ld_family()`] weiterverarbeitet werden können.
#'
#' @param searchcriterion Suchkriterium der API, z. B. `"Code"` oder
#'   `"Content"`. Default: `"Code"`.
#' @param sortcriterion Sortierkriterium der Ergebnisliste. Default: `"Code"`.
#' @param pagelength Anzahl maximal zurückgegebener Einträge.  
#'   Default: `1000`.  
#'   (Die API liefert bei sehr großen Ergebnissen sonst mehrere Seiten.)
#' @param language Antwortsprache der API, `"de"` oder `"en"`.  
#'   Default: `"de"`.
#' @param username API-Benutzername.  
#'   Standard: Umgebungsvariable `LD_USERNAME`, sonst `"GAST"`.
#' @param password API-Passwort.  
#'   Standard: Umgebungsvariable `LD_PASSWORD`, sonst `"GAST"`.
#'
#' @return
#' Ein `data.frame` mit zwei Spalten:
#'
#' * `code` – Statistikcode, z. B. `"22411"`  
#' * `content` – Beschreibung der Statistik  
#'
#' Die Reihenfolge entspricht dem gewünschten Sortierkriterium.
#'
#' @examples
#' \dontrun{
#' stats <- ld_list_statistics()
#' head(stats)
#' }
#'
#' @seealso
#'   [ld_list_tables()],  
#'   [ld_family()],  
#'   [ld_search_tables()]
#'
#' @importFrom httr POST add_headers content status_code
#'
#' @export
ld_list_statistics <- function(
    searchcriterion = "Code",
    sortcriterion = "Code",
    pagelength = 1000,
    language = "de",
    username = NULL,
    password = NULL
) {
  
  if (is.null(username)) username <- Sys.getenv("LD_USERNAME", unset = "GAST")
  if (is.null(password)) password <- Sys.getenv("LD_PASSWORD", unset = "GAST")
  
  url <- "https://www.landesdatenbank.nrw.de/ldbnrwws/rest/2020/catalogue/statistics"
  
  body <- list(
    selection = "",
    searchcriterion = searchcriterion,
    sortcriterion = sortcriterion,
    pagelength = pagelength,
    language = language
  )
  
  res <- httr::POST(
    url,
    httr::add_headers(username = username, password = password),
    encode = "form",
    body = body
  )
  
  stopifnot(httr::status_code(res) == 200)
  
  json <- httr::content(res, as = "parsed", type = "application/json")
  
  items <- json$List
  
  data.frame(
    code    = vapply(items, `[[`, character(1), "Code"),
    content = vapply(items, `[[`, character(1), "Content"),
    stringsAsFactors = FALSE
  )
}
