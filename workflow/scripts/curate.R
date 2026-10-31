source("workflow/scripts/common.R")
suppressPackageStartupMessages({library(PharmacoGx); library(MultiAssayExperiment)})
bundle <- readRDS("data/procdata/fitted_response.rds")
annotations <- readRDS("data/procdata/annotations.rds")
profiles <- readRDS("data/procdata/molecular_profiles.rds")
x <- bundle$response
samples <- as.data.frame(annotations$sample)
treatments <- as.data.frame(annotations$treatment)
needed <- unique(c(x$treatment1id, na.omit(x$treatment2id)))
if (length(setdiff(needed, treatments$treatmentid))) stop("Missing treatment metadata: ", paste(setdiff(needed, treatments$treatmentid), collapse=", "))
treatments <- treatments[treatments$treatmentid %in% needed, , drop=FALSE]
if (anyDuplicated(samples$sampleid) || anyDuplicated(treatments$treatmentid)) stop("Nonunique public metadata IDs")
rownames(samples) <- samples$sampleid
rownames(treatments) <- treatments$treatmentid
row_keys <- c("treatment1id", "treatment2id", "treatment1dose", "treatment2dose", "dose_unit")
if (cfg$dataset$id == "GDSC_ANCHOR") row_keys <- c(row_keys, "library_doses", "anchor_doses")
column_keys <- c("sampleid", "tech_rep", "plateid")
if (cfg$dataset$id == "GDSC_MATRIX") column_keys <- c(column_keys, "matrixid")
measurement_columns <- setdiff(names(x)[vapply(x, is.numeric, logical(1))], c(row_keys, column_keys, "dose_index"))
# Aggregate repeated wells only within identical source contexts, retaining n.
source("workflow/scripts/aggregate_response.R")
response <- summarize_response(x, c(row_keys, column_keys), measurement_columns)
dm <- CoreGx::TREDataMapper(response, rowDataMap=list(row_keys, character()),
  colDataMap=list(column_keys, character()),
  assayMap=list(raw=list(c(row_keys, column_keys), c(measurement_columns, "n_observations"))), metadataMap=list())
tre <- CoreGx::metaConstruct(dm)
# Fits are retained as separate measurements, never substituted for observations.
mono <- copy(bundle$monotherapy_profiles)
if (nrow(mono)) {
  mono_assay <- copy(mono)
  if (cfg$dataset$id == "GDSC_MATRIX") {
    # Matrix observations contain pairs only. Attach each fit in its pair role,
    # rather than inventing monotherapy rows for drugs observed only as drug 2.
    mono_assay <- unique(x[, c(column_keys, "treatment1id", "treatment2id"), with=FALSE])
    context <- c(column_keys, "treatment1id")
    values <- setdiff(names(mono), context)
    for (side in 1:2) {
      part <- copy(mono)
      setnames(part, values, paste0(values, "_", side))
      if (side == 2L) setnames(part, "treatment1id", "treatment2id")
      join <- c(column_keys, paste0("treatment", side, "id"))
      mono_assay <- merge(mono_assay, part, by=join, all.x=TRUE, sort=FALSE)
    }
  }
  tre[["profiles"]] <- mono_assay
}
combo <- copy(bundle$combination_profiles)
if (nrow(combo)) tre[["combination_profiles"]] <- combo
if (!is.null(bundle$published)) tre[["published_profiles"]] <- copy(bundle$published)
source("workflow/scripts/molecular_annotations.R")
profiles <- annotate_molecular_types(profiles)
for (name in names(profiles)) {
  colData(profiles[[name]])$sampleid <- colnames(profiles[[name]])
  # Source processing cohort identifier; not an inferred experimental batch.
  colData(profiles[[name]])$batchid <- paste(cfg$dataset$id, name, sep="_")
}
mae <- MultiAssayExperiment::MultiAssayExperiment(experiments=profiles,
  colData=S4Vectors::DataFrame(samples, row.names=samples$sampleid))
curation <- list(sample=data.frame(sampleid=samples$sampleid, sampleid_dataset=samples$sampleid, row.names=samples$sampleid),
  treatment=data.frame(treatmentid=treatments$treatmentid, treatmentid_dataset=treatments$treatmentid, row.names=treatments$treatmentid),
  tissue=data.frame())
pset <- PharmacoGx::PharmacoSet2(name=paste(cfg$dataset$id, cfg$dataset$version, sep="_"),
  sample=samples, treatment=treatments, molecularProfiles=mae, treatmentResponse=tre,
  curation=curation, datasetType="sensitivity")
source("workflow/scripts/portable_annotations.R")
annotation(pset) <- portable_annotations(annotation(pset))
methods::validObject(pset)
save_rds(pset, cfg$outputs$pharmacoset)
write_tsv(samples, "samples", cfg$outputs$tables)
write_tsv(curation$sample, "curation_samples", cfg$outputs$tables)
write_tsv(curation$treatment, "curation_treatments", cfg$outputs$tables)
write_tsv(treatments, "treatments", cfg$outputs$tables)
write_tsv(response, "sensitivity", cfg$outputs$tables)
write_tsv(mono, "monotherapy_profiles", cfg$outputs$tables)
write_tsv(combo, "combination_profiles", cfg$outputs$tables)
if (!is.null(bundle$published)) write_tsv(bundle$published, "published_profiles", cfg$outputs$tables)
summary <- rbindlist(lapply(names(profiles), function(n) data.table(assay=n, features=nrow(profiles[[n]]), samples=ncol(profiles[[n]]))))
write_tsv(summary, "molecular_summary")
write_tsv(summary, "molecular_summary", cfg$outputs$tables)
receipts <- lapply(cfg$sources, function(s) as.data.table(jsonlite::fromJSON(file.path("data/rawdata/downloads", s$id, "receipt.json"))))
write_tsv(rbindlist(receipts, fill=TRUE), "downloads")
writeLines(capture.output(sessionInfo()), "data/procdata/metadata/session_info.txt")
write_tsv(data.table(check=c("validObject", "samples", "treatments", "source_observations", "dose_response_rows", "molecular_assays"),
  value=c("TRUE", nrow(samples), nrow(treatments), nrow(x), nrow(response), length(profiles))), "object_validation")
