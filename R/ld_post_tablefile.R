#' Tabellendaten aus der Landesdatenbank NRW herunterladen
#'
#' Diese Funktion lädt eine Tabelle (als CSV-Datei) aus der
#' GENESIS-Webservice-API der Landesdatenbank NRW herunter.
#' 
#' Der Endpunkt `/rest/2020/data/tablefile` liefert die Daten als ZIP-Archiv,
#' das automatisch entpackt und eingelesen wird.  
#' Die Funktion gibt ein Dataframe mit den statistischen Ergebnissen zurück.
#'
#' Standardmäßig werden alle optionalen Parameter der API leer gelassen,
#' sodass die komplette Tabelle in der Standardstruktur geladen wird.
#' 
#' @param name Tabellen-Code, z. B. `"22421-02i"`.
#'
#' @param username API-Benutzername.  
#'   Standard: Umgebungsvariable `LD_USERNAME`, sonst `"GAST"`.
#'
#' @param password API-Passwort.  
#'   Standard: Umgebungsvariable `LD_PASSWORD`, sonst `"GAST"`.
#'
#' @param area Bereich der Datenbank: `"free"` (Standard) oder `"Alle"`.
#'
#' @param format Exportformat der API. Standard: `"ffcsv"`  
#'   (`"ffcsv"` = kommaparserfreundliches CSV-Format)
#'
#' @param language Sprachcode der API-Antwort (`"de"` oder `"en"`).
#'
#' @return  
#' Ein `data.frame` mit den in der Tabelle enthaltenen Messwerten.
#' Spalten und Struktur hängen von der jeweiligen GENESIS-Tabelle ab.
#'
#' @examples
#' \dontrun{
#' df <- ld_post_tablefile("22421-02i")
#' head(df)
#' }
#'
#' @seealso 
#'   [ld_get_metadata()],  
#'   [ld_get_variables()],  
#'   [ld_family_download()]
#'
#' @importFrom httr POST add_headers status_code content
#' @importFrom readr read_delim locale
#' @importFrom utils unzip
#'
#' @export
ld_post_tablefile <- function(name,
                              username = NULL,
                              password = NULL,
                              area = "free",
                              format = "ffcsv",
                              language = "de") {
  
  if (is.null(username)) username <- Sys.getenv("LD_USERNAME", unset = "GAST")
  if (is.null(password)) password <- Sys.getenv("LD_PASSWORD", unset = "GAST")
  
  message("Verwende Login: ", username)
  
  url <- "https://www.landesdatenbank.nrw.de/ldbnrwws/rest/2020/data/tablefile"
  
  body <- list(
    name = name,
    area = area,
    regionalkey = "",
    regionalvariable = "",
    timeslices = "",
    startyear = "",
    endyear = "",
    classifyingvariable1 = "",
    classifyingkey1 = "",
    classifyingvariable2 = "",
    classifyingkey2 = "",
    classifyingvariable3 = "",
    classifyingkey3 = "",
    classifyingvariable4 = "",
    classifyingkey4 = "",
    classifyingvariable5 = "",
    classifyingkey5 = "",
    compress = "false",
    transpose = "false",
    contents = name,
    quality = "off",
    job = "false",
    stand = "01.01.1970 01:00",
    language = language,
    format = format
  )
  
  res <- httr::POST(
    url,
    httr::add_headers(
      "username" = username,
      "password" = password
    ),
    encode = "form",
    body = body
  )
  
  stopifnot(httr::status_code(res) == 200)
  
  raw <- httr::content(res, as = "raw")
  
  zipfile <- tempfile(fileext = ".zip")
  writeBin(raw, zipfile)
  
  exdir <- tempfile()
  dir.create(exdir, showWarnings = FALSE)
  utils::unzip(zipfile, exdir = exdir)
  
  csvfile <- list.files(exdir, pattern = "\\.csv$", full.names = TRUE)[1]
  
  df <- readr::read_delim(
    csvfile,
    delim = ";",
    locale = readr::locale(encoding = "UTF-8"),
    show_col_types = FALSE
  )
  
  return(df)
}
