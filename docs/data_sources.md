# Human Myeloma Cell Line data sources

Status: source review pending. This is a candidate registry, not an approved input manifest. `config/pipeline.yaml` is the source of truth for URLs and selected versions.

| Source | Version/release | URL / access | Format |
|---|---|---|---|
| HMCL drug-screen data package | Zenodo record 14902712; local archive named v4 | https://zenodo.org/records/14902712 | ZIP containing TSV files |

Direct Figshare URLs, where present, were recovered from historical local article metadata and have not been revalidated in this task. Confirm availability, licensing/access, exact release, raw-versus-derived status, expected files and checksums before adding download rules. HMCL and NCI direct URLs remain unset until exact assets are selected. Automatic direct downloads should be the first DAG stage wherever public access permits.

HCML in the task refers to HMCL. Review the archive contents, mutation provenance and published versus recomputed response metrics before implementation.

Expected generated output: `data/results/HMCL_PSet.rds` plus secondary TSV exports. No input files or generated PSets have been copied into this repo.

Legacy processing references (inspect before porting):
- `/Users/michael/Projects/BHKLab/hmcl-pharmacoset-pipeline/pipeline/HMCL_Pipeline.Rmd`
