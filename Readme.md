# SonaR-GO Package

Derive GO terms based on Ensembl gene- and transcript ids.

## Handling different Ensembl versions and species

Currently the package is locked to the last set ensembl dataset of the latest release.

To fix this, the `get_go` function should also include a dataset as well as ensembl release parameter. If not available, the package downloads the data frames using the `biomaRt` package and stores them in the package folder.

- [How to add data to `R` packages](http://www.davekleinschmidt.com/r-packages/)

## Running Roxygen

Roxygen takes care of which functions and libraries are exported. To run Roxygen, execute:

```r
roxygen2::roxygenise()
```

## Relavant Posts and Information

- [How to use global variables in `R`](https://stackoverflow.com/questions/12598242/global-variables-in-packages-in-r)
- [How namespaces works](http://r-pkgs.had.co.nz/namespace.html)
- [How Roxygen helps with namespaces](http://kbroman.org/pkg_primer/pages/depends.html)
- [How to use Roxygen2](https://github.com/yihui/roxygen2)
