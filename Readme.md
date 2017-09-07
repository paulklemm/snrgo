# SonaR-GO Package

Derive GO terms based on Ensembl gene- and transcript ids.

## Sample Usage

Get GO terms for a selection of Ensembl genes:

```r
to_go(c("ENSMUSG00000064370", "ENSMUSG00000065947"), 'mmusculus_gene_ensembl')
```

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

# Git Setup

This repo knows two origins:

```bash
# From https://stackoverflow.com/questions/14290113/git-pushing-code-to-two-remotes
git remote set-url --add --push origin git@github.com:paulklemm/snrgo.git
git remote set-url --add --push origin git@github.sf.mpg.de:pklemm/sonargo.git
# Check with `git remote show origin`
```

This is neccessary since the `R` devtools allow for easy installation of packages on Github.com.
