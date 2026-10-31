# Development decisions

See [processing decisions](implementation.md), [source provenance](data_sources.md) and [validation](validation.md). Dependencies and source checksums are pinned; generated data and diagnostic artifacts remain outside Git.

### Molecular assay type annotations

Assembly sets each molecular experiment's `metadata$annotation` to its explicit assay type; each assay retains its correct molecular type. This is required by the current MCP `drugSensitivitySig` consumer. Source values and units are unchanged. Proteomics, methylation and heterogeneous DTP experiments retain their true types even though that consumer does not currently support all of them. Use explicit numeric `sProfiles` for combination-response analyses; do not delete descriptive profile fields merely to make a consumer run.

The HMCL monotherapy fit assay is named `profiles`, as required by the standard PharmacoGx profile accessor. Fit-status fields and the complete TSV export remain available. For association consumers, explicitly select the numeric response metric into `sProfiles`, retaining diagnostic fields in the PSet. The subset reassembly check confirms source and fitted values are unchanged.

Package-description installation paths (`file` attributes and `LibPath`) are removed from the public object annotation. Package versions and GitHub revisions remain intact, and full local session/package manifests are retained outside the RDS under `data/procdata/metadata`. QC checks that the serialized annotation is already portable.
