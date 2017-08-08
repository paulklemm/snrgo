#   Build and Reload Package:  'Cmd + Shift + B'
#   Check Package:             'Cmd + Shift + E'
#   Test Package:              'Cmd + Shift + T'

#' @import biomaRt
#' @import dplyr

pkg.env <- new.env()
pkg.env$dataset <- "mmusculus_gene_ensembl"
pkg.env$ensembl <- useMart("ensembl",dataset=pkg.env$dataset)
pkg.env$gene_and_go <- getBM(attributes=c('ensembl_gene_id', 'go_id'), mart = pkg.env$ensembl)
#pkg.env$transcript_to_go <- getBM(attributes=c('ensembl_transcript_id', 'go_id'), mart = pkg.env$ensembl)

#genes <- c('ENSMUSG00000064370', 'ENSMUSG00000065947')

gene_to_go <- function(genes) {
  library(magrittr)
  result <- list()
  for (gene in genes) {
    result[gene] <- pkg.env$gene_and_go %>% dyplyr::filter(ensembl_gene_id == gene) %>% dyplyr::select(go_id) %>% as.vector()
  }
  return(result)
}
