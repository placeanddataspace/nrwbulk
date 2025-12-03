#' Liste aller Tabellen in der Landesdatenbank NRW (POST API)
#'
#' Ruft den Katalog der Tabellen aus der Landesdatenbank NRW (GENESIS-Webservice 2020)
#' ab und liefert die verfügbaren Tabellen mit Code, Titel und Zeitbezug.
#'
#' @param area Bereich der Datenbank. Standard `"free"`.  
#'   Weitere mögliche Werte: `"Alle"` (falls Login entsprechende Rechte hat).
#' @param searchcriterion Kriterium zur Suche, z. B. `"Code"` oder `"Content"`.
#' @param sortcriterion Sortierkriterium, z. B. `"Code"` oder `"Content"`.
#' @param pagelength Anzahl der zurückzugebenden Ergebnisse (Standard: 1000).
#' @param language Sprachcode der API-Antwort, `"de"` (Standard) oder `"en"`.
#' @param username Benutzername für die API.  
#'   Standard: Umgebungsvariable `LD_USERNAME`, ansonsten `"GAST"`.
#' @param password Passwort für die API.  
#'   Standard: Umgebungsvariable `LD_PASSWORD`, ansonsten `"GAST"`.
#'
#' @return
#' Ein `data.frame` mit den Spalten:
#' * `code` – Tabellenkennziffer  
#' * `content` – Beschreibung  
#' * `time` – Zeitspanne oder Stichtag
#'
#' @export
ld_list_tables <- function(
    area = "free",
    searchcriterion = "Code",
    sortcriterion = "Code",
    pagelength = 1000,
    language = "de",
    username = NULL,
    password = NULL
) {
  
  # Credentials
  if (is.null(username)) username <- Sys.getenv("LD_USERNAME", unset = "GAST")
  if (is.null(password)) password <- Sys.getenv("LD_PASSWORD", unset = "GAST")
  
  url <- "https://www.landesdatenbank.nrw.de/ldbnrwws/rest/2020/catalogue/tables"
  
  body <- list(
    selection = "",
    area = area,
    searchcriterion = searchcriterion,
    sortcriterion = sortcriterion,
    pagelength = pagelength,
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
  
  stopifnot(httr::status_code(res) == 200)
  
  json <- httr::content(res, as = "parsed", type = "application/json")
  
  tabs <- json$List
  
  data.frame(
    code    = vapply(tabs, `[[`, character(1), "Code"),
    content = vapply(tabs, `[[`, character(1), "Content"),
    time    = vapply(tabs, `[[`, character(1), "Time"),
    stringsAsFactors = FALSE
  )
}
