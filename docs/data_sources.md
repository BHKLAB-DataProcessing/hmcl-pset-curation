# Human Myeloma Cell Line data sources

The production inputs are the published normalized dose-response curves and mutation predictions in the [HMCL v4 archive](https://zenodo.org/records/14902712). Upstream processing code is available at [khughitt/hmcl-drug-screen-pipeline](https://github.com/khughitt/hmcl-drug-screen-pipeline). The PSet does not reconstruct the curves from raw luminescence. The archive contains 82,216 curves for 43 cell lines and 1,912 drug IDs, expanded into 904,376 dose observations. The source drug-index table covers 47 lines; the curated cohort follows the supplied quality-filtered curves. Published fit parameters are retained separately from recomputed fits. Mutation zeros mean no variant reported in the processed source, not confirmed wild type.

## Source files

| File | Role | Bytes | Download URL |
|---|---|---:|---|
| `hmcl-drugscreen-data-package-v4.zip` | published screening archive | 196579553 | [source](https://zenodo.org/records/14902712/files/hmcl-drugscreen-data-package-v4.zip?download=1) |

## Executable sources and annotation

`config/pipeline.yaml` is the authoritative list of production/QC downloads and expected checksums. Reference-only files in the table need not be downloaded by production stages. Generated source receipts, mapping exclusions and API responses are stored under ignored `data/` directories. AnnotationDB live mode can change independently of measured data; replay mode verifies reviewed response hashes and fails on missing or changed responses. See the README for the exact replay limitation. Gene identifiers use the configured GENCODE reference; mapping does not realign or renormalize source measurements.
