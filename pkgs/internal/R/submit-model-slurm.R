#' submit a nonmem model to slurm in parallel
#' @param .mod a bbi nonmem model object
#' @param partition name of the partition to submit the model
#' @param ncpu number of cpus to run the model against
#' @param overwrite whether to overwrite existing model results
#' @param slurm_job_template_path path to slurm job template
#' @param submission_root directory to track job submission scripts and output
#' @param bbi_config_path path to bbi config file
#' @details
#' check the partition names using `sinfo` from the terminal, provide the partition
#' name to submit to different partitions (eg general, cpu4, cpu16, etc)
#' @export
submit_parallel_model_slurm <-
  function(.mod,
           partition = "cpu4mem16gb",
           ncpu = 4,
           overwrite = FALSE,
           slurm_job_template_path = .dh$slurm_job_template_path,
           submission_root = .dh$submission_root,
           bbi_config_path = .dh$bbi_config_path) {
    if (!inherits(.mod, "bbi_nonmem_model")) {
      stop("please provide a bbi_nonmem_model created via read_model/new_model")
    }
    parallel <- if (ncpu > 1) {
      TRUE
    } else {
      FALSE
    }

    if (overwrite && fs::dir_exists(.mod$absolute_model_path)) {
      fs::dir_delete(.mod$absolute_model_path)
    }
    template_script <-
      withr::with_dir(dirname(.mod$absolute_model_path), {
        tmpl <- brio::read_file(slurm_job_template_path)
        if (!fs::is_absolute_path(bbi_config_path)) {
          rlang::abort(sprintf("bbi_config_path must be absolute, not %s", bbi_config_path))
        }
        whisker::whisker.render(
          tmpl,
          list(
            partition = partition,
            parallel = parallel,
            ncpu = ncpu,
            job_name = sprintf("nonmem-run-%s", basename(.mod$absolute_model_path)),
            bbi_exe_path = Sys.which("bbi"),
            bbi_config_path = bbi_config_path,
            model_path = .mod$absolute_model_path
          )
        )
      })
    if (!fs::dir_exists(submission_root)) {
      fs::dir_create(submission_root)
    }
    script_file_path <-
      file.path(submission_root, sprintf("%s.sh", basename(.mod$absolute_model_path)))
    brio::write_file(template_script, script_file_path)
    fs::file_chmod(script_file_path, "0755")
    withr::with_dir(submission_root, {
      processx::run("sbatch", script_file_path)
    })
  }
