
# koordinatr

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/koordinatr)](https://CRAN.R-project.org/package=koordinatr)
<!-- badges: end -->

The goal of koordinatr is to provide API access to spatial and tabular
data from various New Zealand government agencies which use a
Koordinates data service.

## Installation

You can install the development version of koordinatr like so:

``` r
# install.packages("devtools")
devtools::install_github("isaacbain/koordinatr")
```

## Usage

### Authenticate

To use the package, you will need to authenticate with an API key. These
can be obtained from the respective agencies’ websites.

``` r
library(koordinatr)

api_key <- "your_api_key"
```

Alternatively, you can also store your API key in your .Renviron file,
so you don’t have to go looking for it each time. First edit your
.Renviron file with the following command:

``` r
usethis::edit_r_environ()
```

Then you can add your API key like so (referring to it as whatever you
called it in the step above):

``` r
get_layer_as_sf(api_key = Sys.getenv("koordinates_api_key") # or whatever you called it
```

### Fetch a spatial layer

This is a basic example which uses the `get_layer_as_sf` function to
fetch a spatial layer from LINZ and return it as an `sf` object.

- `agency` should be one of “linz”, “statsnz”, “mfe”. Or “custom” if you
  want to manually specify the URL for the service.

- `id` should be the ID of the layer you want to fetch.

``` r
# libraries
library(ggplot2)

# get spatial layer from MfE
result_sf <- get_layer_as_sf(Sys.getenv("mfe_api_key"),
                             agency = "mfe",
                             id = "118263")

# map
ggplot() +
  geom_sf(data = result_sf, aes(fill = LUCID_2020), colour = NA) +
  scale_fill_viridis_d() +
  theme_bw() +
  labs(title = "LUCAS Chatham Islands \nLand Use Map 2020") +
  theme(legend.position = "none") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))
```

<img src="man/figures/README-unnamed-chunk-2-1.png" width="100%" />

``` r


# get spatial layer from custom url

result_sf2 <- get_layer_as_sf(Sys.getenv("lris_api_key"),
                              agency = "custom",
                              id = "48157",
                              custom_url = "https://lris.scinfo.org.nz/services;key=")

ggplot() +
  geom_sf(data = result_sf2, aes(fill = Series_1), colour = NA) +
  scale_fill_viridis_d() +
  theme_bw() +
  labs(title = "Soil map for the Upper Plains and Downs of Canterbury") +
  theme(legend.position = "none")
```

<img src="man/figures/README-unnamed-chunk-2-2.png" width="100%" />

### Fetch a table

This is a basic example which uses the `get_table_as_tibble` function to
fetch a table from MfE and return it as a `tibble`.

``` r
# get tables
result_tibble <- get_table_as_tibble(Sys.getenv("mfe_api_key"),
                                     agency = "mfe",
                                     id = "53606")

knitr::kable(result_tibble[1:10, 1:5])
```

| gml_id         | Lake        | Status        | Date       | LakeSPI_percent |
|:---------------|:------------|:--------------|:-----------|:----------------|
| table-53606.1  | Alexandrina | High          | 7/04/2015  | 54.00%          |
| table-53606.2  | Alice       | Moderate      | 11/11/2015 | 28.00%          |
| table-53606.3  | Aniwhenua   | Poor          | 6/03/2014  | 12.00%          |
| table-53606.4  | Arapuni     | Poor          | 4/03/2009  | 12.00%          |
| table-53606.5  | Aratiatia   | Moderate      | 2/03/2009  | 27.00%          |
| table-53606.6  | Areare      | Non-vegetated | 18/05/2015 | 0.00%           |
| table-53606.7  | Atiamuri    | Poor          | 3/03/2009  | 11.00%          |
| table-53606.8  | Austria     | Moderate      | 3/11/2005  | 46.00%          |
| table-53606.9  | Aviemore    | High          | 8/04/2015  | 62.00%          |
| table-53606.10 | B           | Non-vegetated | 1/02/2007  | 0.00%           |
