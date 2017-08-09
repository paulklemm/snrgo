#   Build and Reload Package:  'Cmd + Shift + B'
#   Check Package:             'Cmd + Shift + E'
#   Test Package:              'Cmd + Shift + T'

debug <- FALSE
debug_path <- '~/Downloads/ensembl'

get_ensembl_dataset <- function(ensembl_dataset='mmusculus_gene_ensembl', version='current') {
  # Check if the ensembl folder exists
  if (system.file("ensembl", package="sonaRGO") == '')
    dir.create(file.path(path.package('sonaRGO'), 'ensembl'))

  if (version == 'current') {
    # Get the current game version
    version <- regmatches(listEnsembl()$version[1], regexpr("([0-9]*$)", listEnsembl()$version[1]))
  }

  # Construct file name
  if (debug)
    ensembl_path <- file.path(debug_path, paste0(ensembl_dataset, '_', version, '.rdmp'))
  else
    ensembl_path <- file.path(path.package('sonaRGO'), 'ensembl', paste0(ensembl_dataset, '_', version, '.rdmp'))
  # Check if the file exists
  if (!file.exists(ensembl_path)) {
    # Get the biomart
    ensembl <- useEnsembl(biomart="ensembl", dataset=ensembl_dataset, version=version)
    gene_and_go <- getBM(attributes=c('ensembl_gene_id', 'go_id'), mart = ensembl)
    save(gene_and_go, file = ensembl_path)
  } else {
    load(file = ensembl_path)
  }
  return(list(gene_and_go = gene_and_go))
}

#' @title Get the GO term association per gene or transcript as list
#'
#' @param input Vector of Ensembl gene or transcript ids
#' @param ensembl_dataset Ensembl dataset name specifying the species
#' @param ensembl_version Ensembl version. Defaults to 'current'
#' @return List named by gene/transcript id containing a vector of associated GO terms by accession id
#' @example to_go(c("ENSMUSG00000064370", "ENSMUSG00000065947"), 'mmusculus_gene_ensembl')
#' @export
to_go <- function(input, ensembl_dataset, ensembl_version = 'current') {
  # Get the required data frames
  ensembl_go_data <- get_ensembl_dataset(ensembl_dataset = ensembl_dataset, version = ensembl_version)
  gene_and_go <- ensembl_go_data$gene_and_go
  # Convert input to uppercase
  input <- toupper(input)
  # Try to guess whether input is genes or transcripts
  # Ensembl Genes end with `G` followed by the id number, transcripts with a `t`, e.g. 'ENSMUSG00000064370'
  if (sum(grepl('(G[0-9]*$)', input)) == length(input)) {
    # Process as Genes
    return(gene_to_go(input, gene_and_go))
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
#' @param gene_and_go Data frame containing gene ids and go accession ids
#' @return List named by gene id containing a vector of associated GO terms by accession id
gene_to_go <- function(genes, gene_and_go) {
  # Populate result
  result <- list()
  for (gene in genes) {
    result[gene] <- gene_and_go %>% filter(ensembl_gene_id == gene) %>% select(go_id) %>% as.vector()
  }
  return(result)
}
