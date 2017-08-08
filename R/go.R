#   Build and Reload Package:  'Cmd + Shift + B'
#   Check Package:             'Cmd + Shift + E'
#   Test Package:              'Cmd + Shift + T'

#' @title Set Ensembl dataset for the package
#'
#' @param ensembl_dataset Ensembl dataset name
#' @export
set_ensembl_dataset <- function(ensembl_dataset) {
  pkg.env <<- new.env()
  pkg.env$dataset <- ensembl_dataset
  pkg.env$ensembl <- useMart("ensembl",dataset=pkg.env$dataset)
  pkg.env$gene_and_go <- getBM(attributes=c('ensembl_gene_id', 'go_id'), mart = pkg.env$ensembl)
  # pkg.env$transcript_to_go <- getBM(attributes=c('ensembl_transcript_id', 'go_id'), mart = pkg.env$ensembl)
}

#' @title Get the GO term association per gene or transcript as list
#'
#' @param input Vector of Ensembl gene or transcript ids
#' @return List named by gene/transcript id containing a vector of associated GO terms by accession id
#' @example to_go(c("ENSMUTG00000064370", "ENSMUST00000065947"))
#' @export
to_go <- function(input) {
  # Convert input to uppercase
  input <- toupper(input)
  # Try to guess whether input is genes or transcripts
  # Ensembl Genes end with `G` followed by the id number, transcripts with a `t`, e.g. 'ENSMUSG00000064370'
  if (sum(grepl('(G[0-9]*$)', input)) == length(input)) {
    # Process as Genes
    return(gene_to_go(input))
  } else if (sum(grepl('(T[0-9]*$)', input)) == length(input)) {
    # TODO
    # Process as Transcripts.
  } else {
    stop('Input must be Ensembl genes or transcripts')
  }
}

#' @title Get the GO term association per gene as list
#'
#' @import biomaRt
#' @import dplyr
#' @param genes Vector of Ensembl gene names
#' @return List named by gene id containing a vector of associated GO terms by accession id
gene_to_go <- function(genes) {
  result <- list()
  for (gene in genes) {
    result[gene] <- pkg.env$gene_and_go %>% filter(ensembl_gene_id == gene) %>% select(go_id) %>% as.vector()
  }
  return(result)
}

# Set default environment to mouse genes
set_ensembl_dataset('mmusculus_gene_ensembl')
