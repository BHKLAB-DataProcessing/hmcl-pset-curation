# Validation status

The full HMCL run and final consumer-compatibility checks completed. The saved PSet was reloaded and validated; source measurements and fit values remain unchanged. Scientific review remains pending.

| Check | Result |
|---|---|
| PharmacoGx PR178 installed | PASS: 3.14.1, `28c58707eece80086bee75d8ef0e8afae96389ca` |
| CoreGx installed | PASS: 2.7.3, `bf6d814abd3dc0fc98f9f419f430cc6473046cb2` |
| Full public response import | PASS: 904,376 source dose/well observations, 43 sample IDs, 1,912 treatment IDs |
| Full sample/compound annotation | PASS; unmapped/ambiguous matches are audited |
| Full molecular import | PASS |
| Actual-source integration subset | PASS: 132 observations through fitting, synergy and PSet assembly |
| Subset RDS round trip | PASS: valid object, explicit dose units, E0/Rsquare, AUC + AAC = 1 |
| Complete workflow dry-run | PASS |
| Full-scale PSet and full QC | PASS: `data/results/HMCL_PSet.rds` reloads successfully, `validObject` is TRUE, and [full QC](pset_qc.html) rendered |

All 82,216 monotherapy fits completed with status `ok`. Median Rsquare is 0.7677621; 22,778 fits have Rsquare below 0.5. Successful optimization does not establish biological fit quality, particularly for inactive or flat curves. AnnotationDB mapped 40/43 samples and 1,365/1,912 treatments; unmatched records retain source identifiers. The mutation assay contains 6,178 genes across 42 samples, with `ARP1_JJKsccF8` absent. The three unmapped sample labels are `U266_ATCC`, `LP1_DSMZ`, and `H1112_PLB`. The response input consists of publicly supplied normalized curves, matching the peer workflow, rather than a reconstruction from raw luminescence. Logs and checkpoints are under `data/procdata/`; they are not committed.

Verification covered a clean macOS ARM64 installation of the shared dependency lock, each dataset’s setup checks, all four isolated workflow graphs, access to every configured source URL, and selected fresh download/extraction stages. The fresh HMCL response stage reproduced all 904,376 observations and its sample, treatment and published-profile tables exactly. Full fitting and end-to-end regeneration of all four PSets were not repeated; current final objects retain their previously verified fitted measurements.



## Conformance and remaining work

The ADAPT static check has no failures. Remaining warnings cover intentionally deferred template/publishing/release automation and full-run artifacts. This implementation keeps the user's minimal four-repository setup; no documentation site, release automation or container workflow was added. Pixi is the requested environment manager. The static checker does not prove numerical concordance or full-run success.

Inspect fit/annotation coverage and full QC, review numerical correspondence to the reference pipeline, and independently validate a clean environment before release. Nothing has been uploaded to ORCESTRA.

## Current MCP compatibility

The molecular experiment now carries its required assay-type annotation, and monotherapy fits use the canonical `profiles` assay name. All source and fit records were compared before and after this assembly change and match. A current-MCP binary-molecular `drugSensitivitySig` API probe passed on 42 samples using an explicitly selected numeric AAC response matrix; this is an API check, not a biological benchmark result. Full HTML QC passed on the final serialized artifact. Previous artifacts are preserved in `data/procdata/artifact_history/`. The current RDS SHA256 is `a9450c5140d1a9e6085acd560d3153c0ec6fb62d3fd023e57082f480ba5c2e48`.

## Exact validation environment

Validation uses the isolated Pixi R library with PharmacoGx 3.14.1 (`28c58707eece80086bee75d8ef0e8afae96389ca`) and CoreGx 2.7.3 (`bf6d814abd3dc0fc98f9f419f430cc6473046cb2`). Setup verifies all locked R dependencies and rejects global libraries or mismatched revisions.

Generated validation metadata records code/config fingerprints and source receipts alongside the artifact. These records are excluded from Git.

## Portable artifact verification

Local package-description paths and absolute BLAS/LAPACK installation paths were removed from the public annotation while retaining package versions, GitHub SHAs and library basenames. All response, molecular, sample and treatment slots were verified unchanged. The final RDS was reloaded and passed QC. `data/procdata/metadata/artifact_versions.tsv` records current and preserved-artifact checksums.

## Scientific QC revision

The expanded `pset_qc.html` rendered successfully from the unchanged final object. It contains 80,192 finite source-AC50/current-EC50 pairs (2,024 source estimates missing), matched by cell/compound/plate. On log10(M), all-pair Pearson=0.22483 and Spearman=0.75622; among 56,362 pairs with both estimates within measured doses, Pearson=0.82485 and Spearman=0.84608. Source extrapolation strongly affects agreement. 54,429 of 80,192 finite pairs are within twofold. The source `lac50` field has a six-log offset from log10(source AC50) and is not used as log10(M).

The report includes missingness, bias/difference plots, named outliers, representative source/current curve overlays, an AAC heatmap/PCA, and a source-annotated TP53–Nutlin-3 example. That exploratory example has only 4 WT versus 32 altered lines (7 unclassified), so it is not a validated biomarker. Supporting numbers/PNG plots are in `docs/qc-data/`.

Numeric comparison helpers passed tests for missing pairs, negative correlation, bias and constant vectors. Generated plots were visually inspected and the self-contained HTML image/table structure checked. Browser-layout review was blocked by the browser tool's prohibition on local file URLs; no bypass was attempted. Separate subset QC reports are archived outside PGx and no longer published.

The final refresh also compares predictions at measured doses: 882,112 paired values from 80,192 curves, Pearson 0.996471, Spearman 0.992378, MAE 0.005372 and mean bias −0.000424 viability fraction. Thus poor all-curve EC50 agreement is not equivalent to poor agreement in predicted responses within the assayed range. This remains in-sample model agreement, not external predictive validation. Final HTML table formatting was verified (no escaped Markdown tables); PNG visual inspection completed.

## Constructor-key hazard review

A separate synthetic test reproduced entity-only-key record collapse on the exact intended PR178 dependency pair. This pipeline uses explicit dose and technical-context dimensions. The current saved PSet passed all 13 exact pre-constructor-source-to-object checks across 904,376 rows, including key uniqueness, identifiers and every retained numeric source measurement. No constructor-related record or value loss was detected. The regression fixture also rejects deliberately collapsed records and altered values. These checks are now part of full QC; they do not substitute for upstream normalization or scientific model validation. Details are in `data/procdata/metadata/source_roundtrip.tsv`.

## Returned-curve fit quality

The pinned package computes its variance-based reported R² before clipping the returned asymptotes. A full evaluation of all 82,216 stored mono curves at their actual clipped modeling inputs found 2,615 differences above 1e-8; the largest absolute difference was 0.3058846363. All 57,612 interior-parameter curves matched to numerical precision. Among 24,604 boundary curves, some lie naturally at the boundary and do not differ. In 217 contexts the returned-curve variance R² fell below 0.5 despite reported R² of at least 0.5. The full counts below 0.5 are 22,778 for reported R², 22,995 for returned variance R², and 23,184 for returned SSE/SST R². These thresholds are review flags, not exclusion rules.

`docs/qc-data/returned-fit-quality.tsv` retains every context, dose support, parameter and quality definition; summary and largest-discrepancy tables appear in the full report. Dose counts matched the saved fit records for every curve. The second statistic uses `1 - SSE/SST` so constant prediction bias is not removed. This is in-sample fidelity, not generalization. No RDS, parameter, fit checkpoint or package was changed for this diagnostic.
