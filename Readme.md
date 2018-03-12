# SNR-GO Package

<!-- TOC -->

* [SNR-GO Package](#snr-go-package)
  * [Sample Usage](#sample-usage)
  * [Remarks on File Buffering of `get_go_summary`](#remarks-on-file-buffering-of-get_go_summary)
  * [GO Term Ids](#go-term-ids)
  * [Running Roxygen](#running-roxygen)
  * [Bioconductor Dependency](#bioconductor-dependency)
  * [Relavant Posts and Information](#relavant-posts-and-information)

<!-- /TOC -->

Derive GO terms based on Ensembl gene- and transcript ids.

## Sample Usage

Get GO terms for a selection of Ensembl genes:

```r
to_go(c("ENSMUSG00000064370", "ENSMUSG00000065947"), 'mmusculus_gene_ensembl')
```

## Remarks on File Buffering of `get_go_summary`

The `get_go_summary` function takes some minutes to complete as it downloads the GO terms for all genes. Therefore the result of these queries are stored locally to make future queries faster by reading the results from disk.

Therefore the first time the command is called it will take some time to install. The intermediate files are stored in the package installation folder, e.g. `/usr/local/lib/opencpu/site-library/sonaRGO/ensembl`.

**BUG IN `get_go_summary`**

When the temporary files are created as result of a OpenCPU call, the buffer files are created as part of the session and are _not_ stored in the local file system. See here the output for example. This needs to be fixed!

```
/ocpu/tmp/x00f4253126/R/get_go_summary
/ocpu/tmp/x00f4253126/R/.val
/ocpu/tmp/x00f4253126/messages
/ocpu/tmp/x00f4253126/stdout
/ocpu/tmp/x00f4253126/warnings
/ocpu/tmp/x00f4253126/source
/ocpu/tmp/x00f4253126/console
/ocpu/tmp/x00f4253126/info
/ocpu/tmp/x00f4253126/files/DESCRIPTION
/ocpu/tmp/x00f4253126/files/~/Downloads/ensembl/mmusculus_gene_ensembl_90_genes.RData
/ocpu/tmp/x00f4253126/files/~/Downloads/ensembl/mmusculus_gene_ensembl_90_go.RData
/ocpu/tmp/x00f4253126/files/~/Downloads/ensembl/mmusculus_gene_ensembl_90_transcripts.RData
```

**Temporary Workaround**

Run `get_go_summary()` from the RStudio session of the docker image to create the temporary file. This is currently done automatically in the dockerfile, see [https://github.sf.mpg.de/pklemm/snr-docker/commit/c8a3a184783400d80bad0be1b655d269f7f80eb6](https://github.sf.mpg.de/pklemm/snr-docker/commit/c8a3a184783400d80bad0be1b655d269f7f80eb6) for details

**How to FIX**

Save the OpenCPU result using a shell script to disk, as described using the function `testScript` calling the `testScript.sh` function.

## GO Term Ids

The Biomart IDs for GO terms are in parts obscure. Here a translation.

* `name_1006`: "GO term name"
* `definition_1006`: "GO term definition"
* `namespace_1003`: "GO domain"

## Running Roxygen

Roxygen takes care of which functions and libraries are exported. To run Roxygen, execute:

```r
roxygen2::roxygenise()
```

## Bioconductor Dependency

SNR-GO depends on a couple of Bioconductor packages. In order to install them, Bioconductor needs to be added to the available repositories using `setRepositories(ind=c(1,2))`.

So to install it, you can do:

```bash
RUN Rscript -e "setRepositories(ind=c(1,2)); devtools::install_github('paulklemm/snrgo')"
```

## Relavant Posts and Information

* [How to use global variables in `R`](https://stackoverflow.com/questions/12598242/global-variables-in-packages-in-r)
* [How namespaces works](http://r-pkgs.had.co.nz/namespace.html)
* [How Roxygen helps with namespaces](http://kbroman.org/pkg_primer/pages/depends.html)
* [How to use Roxygen2](https://github.com/yihui/roxygen2)
* [R package with CRAN and Bioconductor dependencies](https://stackoverflow.com/questions/34617306/r-package-with-cran-and-bioconductor-dependencies)
