# SonaR-GO Package

Derive GO terms based on Ensembl gene- and transcript ids.

## GO Term Ids

The Biomart IDs for GO terms are in parts obscure. Here a translation.

- `name_1006`: "GO term name"
- `definition_1006`: "GO term definition"
- `namespace_1003`: "GO domain"

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
