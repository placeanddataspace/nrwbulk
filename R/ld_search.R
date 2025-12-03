#' Allgemeine Suche in der Landesdatenbank NRW (GENESIS find-API)
#'
#' Diese Funktion führt eine Volltextsuche über die GENESIS-API der
#' Landesdatenbank NRW durch. Sie nutzt den Endpunkt
#' `/rest/2020/find/find` und liefert Treffer aus verschiedenen
#' Kategorien wie Tabellen, Statistiken, Variablen oder Zeitreihen.
#'
#' Die categories sind in Englisch anzugeben (z. B. `"tables"`), werden aber
#' intern automatisch in die von der API erwarteten deutschen Begriffe
#' übersetzt (z. B. `"Tabellen"`).
#'
#' @param term Suchbegriff, z. B. `"Bevölkerung"`.
#' @param category Suchkategorie. Eine der:
#'   `"all"`, `"tables"`, `"variables"`, `"statistics"`, `"cubes"`, `"timeseries"`.
#'   Standard: `"all"`.
#' @param pagelength Maximale Anzahl Treffer. Standard: `200`.
#' @param language Antwortsprache der API (`"de"` oder `"en"`).  
#'   Standard `"de"`.
#' @param username API-Benutzername.  
#'   Standard: Umgebungsvariable `LD_USERNAME`, sonst `"GAST"`.
#' @param password API-Passwort.  
#'   Standard: Umgebungsvariable `LD_PASSWORD`, sonst `"GAST"`.
#'
#' @return
#' Ein `data.frame` mit den Spalten:
#'
#' * `type` – Kategorie des Treffers (Tables, Statistics, Variables, ...)  
#' * `code` – Tabellen-/Variablen-/Statistikcode  
#' * `content` – Beschreibung / Label  
#'
#' Wenn keine Treffer existieren, wird ein leeres Dataframe zurückgegeben.
#'
#' @examples
#' \dontrun{
#' ld_search("Bevölkerung")
#' ld_search("Arbeitslose", category = "tables")
#' }
#'
#' @seealso 
#'   [ld_search_tables()],  
#'   [ld_search_all()],  
#'   [ld_list_tables()],  
#'   [ld_list_statistics()]
#'
#' @importFrom httr POST add_headers status_code content
#'
#' @export
ld_search <- function(term,
                      category = "all",
                      pagelength = 200,
                      language = "de",
                      username = NULL,
                      password = NULL) {
  
  # Credentials
  if (is.null(username)) username <- Sys.getenv("LD_USERNAME", unset = "GAST")
  if (is.null(password)) password <- Sys.getenv("LD_PASSWORD", unset = "GAST")
  
  # Category translation EN -> DE (API erwartet DE)
  category_map <- c(
    all        = "Alle",
    tables     = "Tabellen",
    variables  = "Variablen",
    statistics = "Statistiken",
    cubes      = "Würfel",
    timeseries = "Zeitreihen"
  )
  
  if (!category %in% names(category_map)) {
    stop("Unknown category: ", category)
  }
  
  api_category <- category_map[[category]]
  
  url <- "https://www.landesdatenbank.nrw.de/ldbnrwws/rest/2020/find/find"
  
  body <- list(
    term = term,
    category = api_category,
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
  
  # Extract result sections
  parts <- list(
    Tables     = json$Tables,
    Statistics = json$Statistics,
    Variables  = json$Variables,
    Cubes      = json$Cubes,
    Timeseries = json$Timeseries
  )
  
  dfs <- lapply(names(parts), function(type) {
    items <- parts[[type]]
    if (is.null(items)) return(NULL)
    
    data.frame(
      type    = type,
      code    = vapply(items, `[[`, character(1), "Code"),
      content = vapply(items, `[[`, character(1), "Content"),
      stringsAsFactors = FALSE
    )
  })
  
  result <- do.call(rbind, dfs)
  
  if (is.null(result)) {
    return(data.frame(type = character(), code = character(), content = character()))
  }
  
  result
}



#' Suche nach Tabellen (vereinfachte Version von `ld_search()`)
#'
#' Diese Funktion durchsucht ausschließlich die Tabellen der
#' Landesdatenbank NRW und gibt nur die Spalten `code` und `content` zurück.
#'
#' Sie ist ein bequemer Wrapper für:
#' `ld_search(term, category = "tables")`.
#'
#' @inheritParams ld_search
#'
#' @return Dataframe mit zwei Spalten:
#' * `code`
#' * `content`
#'
#' @examples
#' \dontrun{
#' ld_search_tables("Arbeitsmarkt")
#' }
#'
#' @export
ld_search_tables <- function(term,
                             pagelength = 200,
                             language = "de",
                             username = NULL,
                             password = NULL) {
  
  res <- ld_search(
    term = term,
    category = "tables",
    pagelength = pagelength,
    language = language,
    username = username,
    password = password
  )
  
  if (nrow(res) == 0) return(res)
  
  res[, c("code", "content")]
}



#' Suche über alle Kategorien hinweg (Wrapper für `ld_search()`)
#'
#' Diese Funktion führt eine Suche über *alle* von der GENESIS API
#' unterstützten Kategorien aus.
#'
#' Sie ist ein einfacher Wrapper:
#' `ld_search(term, category = "all")`.
#'
#' @inheritParams ld_search
#'
#' @examples
#' \dontrun{
#' ld_search_all("Migration")
#' }
#'
#' @export
ld_search_all <- function(term,
                          pagelength = 200,
                          language = "de",
                          username = NULL,
                          password = NULL) {
  ld_search(
    term = term,
    category = "all",
    pagelength = pagelength,
    language = language,
    username = username,
    password = password
  )
}
