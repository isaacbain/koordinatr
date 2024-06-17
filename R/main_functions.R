#' Get a spatial layer and return it as an sf object
#'
#' @param api_key The API key for the agency
#' @param agency The agency from which to get the layer. Options are 'mfe', 'linz', 'stats', or 'custom'
#' @param id The ID of the layer to get
#' @param custom_url The custom URL for the agency. Required if agency is 'custom'
#'
#' @return An sf object
#' @export
#'
#' @examples
#' # Get a layer from LINZ
#' result_sf <- get_layer_as_sf(api_key, agency = "linz", id = "50088")
get_layer_as_sf <- function(api_key, agency, id, custom_url = NULL) {

  # Define the base URLs for the agencies
  base_urls <- list(
    mfe = "https://data.mfe.govt.nz/services;key=",
    linz = "https://data.linz.govt.nz/services;key=",
    statsnz = "https://datafinder.stats.govt.nz/services;key="
  )

  # Determine the base URL based on the agency argument
  if (agency == "custom") {
    if (is.null(custom_url)) {
      stop("For custom agency, you must provide a custom_url.")
    }
    base_url <- custom_url
  } else if (agency %in% names(base_urls)) {
    base_url <- base_urls[[agency]]
  } else {
    stop("Invalid agency. Please choose either 'mfe', 'linz', or 'custom'.")
  }

  # Construct the URL for the GetFeature request
  get_feature_url <- paste0(base_url, api_key, "/wfs/", "layer-", id, "/?service=WFS&request=GetCapabilities")

  # Read the layer as an sf object
  sf_object <- tryCatch({
    sf::st_read(get_feature_url)
  }, error = function(e) {
    stop("Failed to read the layer. Error: ", e$message)
  })

  # Check geometry type and cast if necessary
  geom_type <- sf::st_geometry_type(sf_object, by_geometry = FALSE)

  if (geom_type == "MULTISURFACE") {
    sf_object <- sf::st_cast(sf_object, "GEOMETRYCOLLECTION") |>
      sf::st_collection_extract("POLYGON")
  } else if (geom_type == "CURVEPOLYGON") {
    sf_object <- sf::st_cast(sf_object, "GEOMETRYCOLLECTION") |>
      sf::st_collection_extract("LINESTRING")  |>
      sf::st_cast("POLYGON")
  } else if (geom_type == "COMPOUNDCURVE") {
    sf_object <- st_cast(sf_object, "GEOMETRYCOLLECTION") |>
      st_collection_extract("LINESTRING")
  }

  return(sf_object)
}

#' Get a table and return it as a tibble
#'
#' @param api_key The API key for the agency
#' @param agency The agency from which to get the table. Options are 'mfe', 'linz', 'stats', or 'custom'
#' @param id The ID of the table to get
#' @param custom_url The custom URL for the agency. Required if agency is 'custom'
#'
#' @return A tibble
#' @export
#'
#' @examples
#' # Get a table from the Ministry for the Environment
#' result_tibble <- get_table_as_tibble(api_key, agency = "mfe", id = "53606")
get_table_as_tibble <- function(api_key, agency, id, custom_url = NULL) {
  # Define the base URLs for the agencies
  base_urls <- list(
    mfe = "https://data.mfe.govt.nz/services;key=",
    linz = "https://data.linz.govt.nz/services;key=",
    statsnz = "https://datafinder.stats.govt.nz/services;key="
  )

  # Determine the base URL based on the agency argument
  if (agency == "custom") {
    if (is.null(custom_url)) {
      stop("For custom agency, you must provide a custom_url.")
    }
    base_url <- custom_url
  } else if (agency %in% names(base_urls)) {
    base_url <- base_urls[[agency]]
  } else {
    stop("Invalid agency. Please choose either 'mfe', 'linz', or 'custom'.")
  }

  # Construct the URL for the GetFeature request
  get_feature_url <- paste0(base_url, api_key, "/wfs/", "table-", id, "/?service=WFS&request=GetCapabilities")

  # Read the layer as a tibble
  data <- tryCatch({
    sf::st_read(get_feature_url, stringsAsFactors = FALSE, quiet = TRUE) |>
      dplyr::as_tibble() |>
      readr::type_convert()
  }, error = function(e) {
    stop("Failed to read the layer. Error: ", e$message)
  })

  return(data)
}
