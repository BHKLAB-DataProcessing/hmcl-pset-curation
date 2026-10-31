# Reference: hmcl-pharmacoset-pipeline/pipeline/HMCL_Pipeline.Rmd.
# Public source-normalized curves are retained; these are not raw luminescence.
source("workflow/scripts/common.R")
x <- fread(source_file("screen", "/drugs/drug_curves.tsv$"))
require_columns(x, c("cell_line", "drug_id", "plate_id", "dose_0", "conc_0"))
published <- x[, c("cell_line", "drug_id", "plate_id", "slope", "lower_limit", "upper_limit", "ac50", "lac50", "ac50_pval"), with=FALSE]
setnames(published, c("cell_line", "drug_id", "plate_id"), c("sampleid", "treatment1id", "plateid"))
long <- melt(x, id.vars=c("cell_line", "drug_id", "plate_id"),
             measure.vars=list(paste0("dose_", 0:10), paste0("conc_", 0:10)),
             value.name=c("viability_percent_published", "treatment1dose"), variable.name="dose_index")
setnames(long, c("cell_line", "drug_id", "plate_id"), c("sampleid", "treatment1id", "plateid"))
long[, `:=`(viability=viability_percent_published / 100,
            wellid=as.character(dose_index), dose_unit="M")]
long <- canonical_response(long)
drugs <- fread(source_file("screen", "/drugs/metadata.tsv$"))
setnames(drugs, c("sample_id", "sample_name"), c("treatmentid", "treatment_name"))
drugs <- unique(drugs, by="treatmentid")
samples <- unique(long[, .(sampleid, sample_name=sampleid, tissueid="haematopoietic_and_lymphoid")])
write_tsv(published, "published_profiles")
save_rds(list(response=long, sample=samples, treatment=drugs, published=published), "data/procdata/response.rds")
