source("renv/activate.R")

.dh <- new.env()
.dh$proj_root <- normalizePath(getwd())
# we need to force this so it gets stored/saved immediately
# otherwise the first time you execute it lazily references and you get the error
# Error: promise already under evaluation: recursive default argument reference or earlier problems?
.dh$slurm_job_template_path <- force(file.path(.dh$proj_root, "model", "nonmem", "slurm-job.tmpl"))
.dh$bbi_config_path <- file.path(.dh$proj_root, "model", "nonmem", "bbi.yaml")
.dh$submission_root <- file.path(.dh$proj_root, "model", "nonmem", "submission-log")

.dh$document <- function() {
  devtools::document(file.path(.dh$proj_root, "pkgs", "internal"))
}

.dh$load_internal <- function(document = TRUE) {
  if (document) {
    .dh$document()
    # document will load anyway
    return(invisible())
  }
  pkgload::load_all(file.path(.dh$proj_root, "pkgs", "internal"))
}
