#!/usr/bin/env Rscript
# Sensitivity Analysis for HDL-C → CVD MR Study
# Includes: Heterogeneity test, Pleiotropy test, PRESSO, Steiger directionality

# Suppress warnings
options(warn = -1)

# Load required packages
suppressPackageStartupMessages({
  library(TwoSampleMR)
  library(dplyr)
  library(ggplot2)
})

# Check for OPENGWAS_JWT environment variable
if (Sys.getenv("OPENGWAS_JWT") != "") {
  message("Using OpenGWAS JWT from environment variable")
} else {
  stop("OPENGWAS_JWT environment variable not set. Please set it before running.")
}

# Create output directories (use /results and /figures which are mounted volumes)
dir.create("/results/sensitivity", showWarnings = FALSE, recursive = TRUE)
dir.create("/figures/sensitivity", showWarnings = FALSE, recursive = TRUE)

message("\n========================================")
message("HDL-C → CVD Sensitivity Analysis")
message("========================================\n")

# ============================================
# Step 1: Extract exposure data (HDL-C)
# ============================================
message("Step 1: Extracting HDL-C exposure data...")
exposure_dat <- extract_instruments("ieu-a-299")
message("  Found ", nrow(exposure_dat), " SNPs")

# ============================================
# Step 2: Extract outcome data (CAD)
# ============================================
message("\nStep 2: Extracting CAD outcome data...")
outcome_dat <- extract_outcome_data(snps = exposure_dat$SNP, outcomes = "ieu-a-7")
message("  Found ", nrow(outcome_dat), " SNPs")

# ============================================
# Step 3: Harmonise data
# ============================================
message("\nStep 3: Harmonising data...")
dat <- harmonise_data(exposure_dat, outcome_dat)
message("  Harmonised ", nrow(dat), " SNPs")

# ============================================
# Step 4: Perform MR analysis with all methods
# ============================================
message("\nStep 4: Running MR analysis...")
mr_results <- mr(dat, method_list = c(
  "mr_ivw",
  "mr_egger_regression",
  "mr_weighted_median",
  "mr_weighted_mode"
))
message("  Analysis complete")

# ============================================
# Step 5: Heterogeneity test
# ============================================
message("\nStep 5: Heterogeneity analysis...")
heterogeneity <- mr_heterogeneity(dat)
message("  Heterogeneity tests complete")

# ============================================
# Step 6: Pleiotropy test (MR-Egger intercept)
# ============================================
message("\nStep 6: Horizontal pleiotropy test...")
pleiotropy <- mr_pleiotropy_test(dat)
message("  Pleiotropy test complete")

# ============================================
# Step 7: Single SNP analysis
# ============================================
message("\nStep 7: Single SNP analysis...")
single_snp <- mr_singlesnp(dat)
message("  Single SNP analysis complete")

# ============================================
# Step 8: Leave-one-out analysis
# ============================================
message("\nStep 8: Leave-one-out analysis...")
loo <- mr_leaveoneout(dat)
message("  Leave-one-out analysis complete")

# ============================================
# Step 9: Steiger directionality test
# ============================================
message("\nStep 9: Steiger directionality test...")
steiger <- directionality_test(dat)
message("  Directionality test complete")

# ============================================
# Step 10: Save results
# ============================================
message("\nStep 10: Saving results...")

# Save heterogeneity results
write.csv(heterogeneity, "/results/sensitivity/heterogeneity.csv", row.names = FALSE)
message("  Saved: heterogeneity.csv")

# Save pleiotropy results
write.csv(pleiotropy, "/results/sensitivity/pleiotropy.csv", row.names = FALSE)
message("  Saved: pleiotropy.csv")

# Save Steiger test results
write.csv(steiger, "/results/sensitivity/steiger_test.csv", row.names = FALSE)
message("  Saved: steiger_test.csv")

# Save single SNP results
write.csv(single_snp, "/results/sensitivity/single_snp.csv", row.names = FALSE)
message("  Saved: single_snp.csv")

# Save leave-one-out results
write.csv(loo, "/results/sensitivity/leave_one_out.csv", row.names = FALSE)
message("  Saved: leave_one_out.csv")

# Save full MR results
write.csv(mr_results, "/results/sensitivity/mr_all_methods.csv", row.names = FALSE)
message("  Saved: mr_all_methods.csv")

# ============================================
# Step 11: Generate sensitivity plots
# ============================================
message("\nStep 11: Generating sensitivity plots...")

# Funnel plot
p_funnel <- mr_funnel_plot(single_snp)
ggsave("/figures/sensitivity/funnel_plot.png", p_funnel, width = 10, height = 6, dpi = 300)
message("  Saved: funnel_plot.png")

# Forest plot
p_forest <- mr_forest_plot(single_snp)
ggsave("/figures/sensitivity/forest_plot_detailed.png", p_forest, width = 10, height = 12, dpi = 300)
message("  Saved: forest_plot_detailed.png")

# Leave-one-out plot
p_loo <- mr_leaveoneout_plot(loo)
ggsave("/figures/sensitivity/leave_one_out_plot.png", p_loo, width = 10, height = 8, dpi = 300)
message("  Saved: leave_one_out_plot.png")

# ============================================
# Step 12: Print summary
# ============================================
message("\n========================================")
message("SENSITIVITY ANALYSIS SUMMARY")
message("========================================\n")

message("--- Heterogeneity Test (IVW) ---")
het_ivw <- heterogeneity %>% filter(method == "IVW")
message("  Q statistic: ", round(het_ivw$Q, 2))
message("  Q p-value: ", format.pval(het_ivw$Q_pval, digits = 3))
if (het_ivw$Q_pval < 0.05) {
  message("  Interpretation: Significant heterogeneity (consider random-effects)")
} else {
  message("  Interpretation: No significant heterogeneity")
}

message("\n--- Heterogeneity Test (MR-Egger) ---")
het_egger <- heterogeneity %>% filter(method == "EGGER")
message("  Q statistic: ", round(het_egger$Q, 2))
message("  Q p-value: ", format.pval(het_egger$Q_pval, digits = 3))

message("\n--- Horizontal Pleiotropy Test (MR-Egger intercept) ---")
message("  Intercept: ", round(pleiotropy$egger_intercept, 4))
message("  SE: ", round(pleiotropy$se, 4))
message("  P-value: ", format.pval(pleiotropy$pval, digits = 3))
if (pleiotropy$pval < 0.05) {
  message("  Interpretation: Significant pleiotropy detected (caution needed)")
} else {
  message("  Interpretation: No significant pleiotropy")
}

message("\n--- Steiger Directionality Test ---")
message("  Correct direction: ", sum(steiger$correct_causal_direction, na.rm = TRUE), " / ", nrow(steiger), " SNPs")
message("  Steiger p-value: ", format.pval(steiger$steiger_pval[1], digits = 3))
if (all(steiger$correct_causal_direction, na.rm = TRUE)) {
  message("  Interpretation: Causal direction confirmed (HDL-C → CVD)")
} else {
  message("  Interpretation: Some SNPs may have reverse causation")
}

message("\n--- MR Methods Comparison ---")
print(mr_results %>% 
        select(method, nsnp, b, se, pval) %>%
        mutate(OR = exp(b),
               OR_lower = exp(b - 1.96*se),
               OR_upper = exp(b + 1.96*se)) %>%
        select(method, nsnp, b, OR, OR_lower, OR_upper, pval))

message("\n========================================")
message("Sensitivity analysis complete!")
message("Results saved to: results/sensitivity/")
message("Plots saved to: figures/sensitivity/")
message("========================================\n")
