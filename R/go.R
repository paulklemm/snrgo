#   Build and Reload Package:  'Cmd + Shift + B'
#   Check Package:             'Cmd + Shift + E'
#   Test Package:              'Cmd + Shift + T'

debug <- TRUE
# Set debug path to downloads because rebuilding the package will delete the ensembl files in its folder
debug_path <- '~/Downloads/ensembl'

count_go_terms <- function(gene_and_go, transcript_and_go) {
  # Process genes and select only required columns
  gene_and_go_select <- gene_and_go %>% select(ensembl_gene_id, go_id)
  # Iterate over all go ids
  go_id_name <- c()
  go_id_count <- c()
  for (current_go_id in unique(gene_and_go_select$go_id)) {
    # If go_id is empty skip this one
    if (current_go_id == '')
      next
    # Filter for current go_id
    current_count <- gene_and_go_select %>% filter(go_id == current_go_id) %>% unique(x = .$ensembl_gene_id) %>% data.frame() %>% nrow()
    # Add the result to the arrays
    go_id_name <- c(go_id_name, current_go_id)
    go_id_count <- c(go_id_count, current_count)
  }
  # Attach to the original data frame
  gene_and_go <- gene_and_go %>% left_join(data.frame(go_id = go_id_name, count = go_id_count))
  return(gene_and_go)
}

#' The data frames are stored in individual folders to make loading more efficient
#' @param type Ensembl data to return. Has to be `gene_to_go`, `transcripts_to_go` or `go_description`
get_ensembl_data <- function(type='gene_to_go', ensembl_dataset='mmusculus_gene_ensembl', version='current') {
  # Check if the ensembl folder exists
  if (system.file("ensembl", package="sonaRGO") == '')
    dir.create(file.path(path.package('sonaRGO'), 'ensembl'))

  if (version == 'current') {
    # Get the current ensembl version
    version <- regmatches(listEnsembl()$version[1], regexpr("([0-9]*$)", listEnsembl()$version[1]))
  }

  # Construct file names
  if (debug) {
    ensembl_path_genes <- file.path('~/Downloads', 'ensembl', paste0(ensembl_dataset, '_', version, '_genes.RData'))
    ensembl_path_transcripts <- file.path('~/Downloads', 'ensembl', paste0(ensembl_dataset, '_', version, '_transcripts.RData'))
    ensembl_path_go <- file.path('~/Downloads', 'ensembl', paste0(ensembl_dataset, '_', version, '_go.RData'))
  } else {
    ensembl_path_genes <- file.path(path.package('sonaRGO'), 'ensembl', paste0(ensembl_dataset, '_', version, '_genes.RData'))
    ensembl_path_transcripts <- file.path(path.package('sonaRGO'), 'ensembl', paste0(ensembl_dataset, '_', version, '_transcripts.RData'))
    ensembl_path_go <- file.path(path.package('sonaRGO'), 'ensembl', paste0(ensembl_dataset, '_', version, '_go.RData'))
  }

  # If any of the files do not exist, download all of them again
  if (!file.exists(ensembl_path_genes) || !file.exists(ensembl_path_transcripts) || !file.exists(ensembl_path_go)) {
    # Get the biomart
    ensembl <- useEnsembl(biomart="ensembl", dataset=ensembl_dataset, version=version)
    # Genes
    gene_and_go <- getBM(attributes=c('ensembl_gene_id', 'go_id'), mart = ensembl)
    # Transcripts
    transcript_and_go <- getBM(attributes=c('ensembl_transcript_id', 'go_id'), mart = ensembl)
    # GO-Terms
    go_description <- getBM(attributes=c('go_id', 'name_1006', 'definition_1006', 'namespace_1003'), mart = ensembl)
    # Fix the dimension names to be expressive
    colnames(go_description) <- c('go_id', 'go_term_name', 'go_term_definition', 'go_domain')
    # Only include GO-Terms that are in the transcript table. This will likely not reduce the number of GO terms at all but doesn't hurt either
    go_description <- go_description %>% filter(go_id %in% unique(transcript_and_go$go_id)) %>% nrow()

    # Save the files
    save(gene_and_go, file = ensembl_path_genes)
    save(transcript_and_go, file = ensembl_path_transcripts)
    save(go_description, file = ensembl_path_go)
  }

  # Return the requested frame
  if (type == gene_and_go) {
    load(ensembl_path_genes)
    return(gene_and_go)
  } else if (type == transcript_and_go) {
    load(ensembl_path_transcripts)
    return(transcript_and_go)
  } else if (type == transcript_and_go) {
    load(ensembl_path_go)
    return(go_description)
  } else {
    # Fail
    stop(paste0('Invalid option ', type, ". Choose `gene_to_go`, `transcripts_to_go` or `go_description`"))
  }
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
  # Convert input to uppercase
  input <- toupper(input)
  # Try to guess whether input is genes or transcripts
  # Ensembl Genes end with `G` followed by the id number, transcripts with a `t`, e.g. 'ENSMUSG00000064370'
  if (sum(grepl('(G[0-9]*$)', input)) == length(input)) {
    # Process as Genes
    # Get the required data frames
    gene_and_go <- get_ensembl_data('gene_and_go', ensembl_dataset = ensembl_dataset, version = ensembl_version)
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
