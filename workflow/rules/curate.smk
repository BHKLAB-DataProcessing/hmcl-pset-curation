rule curate:
    input:
        fitted="data/procdata/fitted_response.rds",
        annotations="data/procdata/annotations.rds",
        molecular="data/procdata/molecular_profiles.rds",
        receipts=expand("data/rawdata/downloads/{source}/receipt.json", source=list(SOURCES)),
        script="workflow/scripts/curate.R",
        molecular_annotations="workflow/scripts/molecular_annotations.R",
        aggregate="workflow/scripts/aggregate_response.R",
        portable_annotations="workflow/scripts/portable_annotations.R",
        environment_guard="workflow/scripts/check_environment.R",
        common="workflow/scripts/common.R"
    output:
        pset=config["outputs"]["pharmacoset"],
        samples=config["outputs"]["tables"] + "/samples.tsv",
        treatments=config["outputs"]["tables"] + "/treatments.tsv",
        sensitivity=config["outputs"]["tables"] + "/sensitivity.tsv",
        mono=config["outputs"]["tables"] + "/monotherapy_profiles.tsv",
        combo=config["outputs"]["tables"] + "/combination_profiles.tsv",
        molecular_summary=config["outputs"]["tables"] + "/molecular_summary.tsv",
        validation="data/procdata/metadata/object_validation.tsv"
    params:
        dataset=config["dataset"]
    shell:
        "Rscript --vanilla workflow/scripts/curate.R"
