#   Build and Reload Package:  'Cmd + Shift + B'
#   Check Package:             'Cmd + Shift + E'
#   Test Package:              'Cmd + Shift + T'
pkg.env <- new.env()
pkg.env$dataset <- "mmusculus_gene_ensembl"
pkg.env$ensembl <- useMart("ensembl",dataset=pkg.env$dataset)
pkg.env$gene_and_go <- getBM(attributes=c('ensembl_gene_id', 'go_id'), mart = pkg.env$ensembl)
# pkg.env$transcript_to_go <- getBM(attributes=c('ensembl_transcript_id', 'go_id'), mart = pkg.env$ensembl)


#' @title Get the GO term association per gene as list
#'
#' @import biomaRt
#' @import dplyr
#' @param genes Vector of Ensembl gene names
#' @return List named by gene id containing a vector of associated GO terms by accession id
#' @export
gene_to_go <- function(genes) {
  result <- list()
  for (gene in genes) {
    result[gene] <- pkg.env$gene_and_go %>% filter(ensembl_gene_id == gene) %>% select(go_id) %>% as.vector()
  }
  return(result)
}
