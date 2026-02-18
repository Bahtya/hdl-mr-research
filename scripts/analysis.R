# HDL与心血管疾病孟德尔随机化分析
# ====================================

# 加载必要的包
library(TwoSampleMR)
library(ggplot2)
library(dplyr)
library(tidyr)
library(patchwork)

# 设置输出目录
results_dir <- "/research/results"
figures_dir <- "/research/figures"

cat("=== HDL与心血管疾病孟德尔随机化研究 ===\n\n")

# ============================================
# 第一步：获取暴露数据 (HDL-C)
# ============================================
cat("1. 获取HDL-C暴露数据...\n")

# 使用GLGC GWAS数据作为HDL-C暴露
hdl_exposure <- extract_instruments(
  outcomes = 'ieu-a-299',  # HDL-C GWAS ID
  p1 = 5e-8,               # 全基因组显著性阈值
  clump = TRUE,            # 去除连锁不平衡
  r2 = 0.001               # LD clumping参数
)

cat(sprintf("  - 获取到 %d 个HDL-C相关SNPs\n\n", nrow(hdl_exposure)))

# ============================================
# 第二步：获取结局数据 (冠心病CHD)
# ============================================
cat("2. 获取冠心病(CHD)结局数据...\n")

# 使用CARDIoGRAM GWAS数据作为CHD结局
chd_outcome <- extract_outcome_data(
  snps = hdl_exposure$SNP,
  outcomes = 'ieu-a-7',    # 冠心病GWAS ID
)

cat(sprintf("  - 匹配到 %d 个SNPs\n\n", nrow(chd_outcome)))

# ============================================
# 第三步：数据协调
# ============================================
cat("3. 协调暴露和结局数据...\n")

harmonised_data <- harmonise_data(
  exposure_dat = hdl_exposure,
  outcome_dat = chd_outcome
)

cat(sprintf("  - 协调后 %d 个SNPs可用\n\n", nrow(harmonised_data)))

# ============================================
# 第四步：孟德尔随机化分析
# ============================================
cat("4. 执行孟德尔随机化分析...\n\n")

mr_results <- mr(harmonised_data, method_list = c(
  "mr_ivw",           # 逆方差加权法
  "mr_egger_regression",  # MR-Egger
  "mr_weighted_median",   # 加权中位数
  "mr_weighted_mode"      # 加权众数
))

print(mr_results)

# ============================================
# 第五步：敏感性分析
# ============================================
cat("\n5. 敏感性分析...\n\n")

# 异质性检验
heterogeneity <- mr_heterogeneity(harmonised_data)
cat("异质性检验:\n")
print(heterogeneity)

# 多效性检验 (MR-Egger截距)
pleiotropy <- mr_pleiotropy_test(harmonised_data)
cat("\n多效性检验 (MR-Egger截距):\n")
print(pleiotropy)

# Leave-one-out分析
loo_results <- mr_leaveoneout(harmonised_data)

# 单SNP分析
single_results <- mr_singlesnp(harmonised_data)

# ============================================
# 第六步：保存结果
# ============================================
cat("\n6. 保存分析结果...\n")

# 保存MR结果
write.csv(mr_results, file.path(results_dir, "mr_results.csv"), row.names = FALSE)
write.csv(heterogeneity, file.path(results_dir, "heterogeneity.csv"), row.names = FALSE)
write.csv(pleiotropy, file.path(results_dir, "pleiotropy.csv"), row.names = FALSE)
write.csv(harmonised_data, file.path(results_dir, "harmonised_data.csv"), row.names = FALSE)

cat("  - 结果已保存到 results/ 目录\n\n")

# ============================================
# 第七步：生成图表
# ============================================
cat("7. 生成图表...\n")

# 图1: 森林图
p1 <- mr_forest_plot(single_results)
ggsave(file.path(figures_dir, "forest_plot.png"), p1[[1]], 
       width = 10, height = 8, dpi = 300)

# 图2: 漏斗图
p2 <- mr_funnel_plot(single_results)
ggsave(file.path(figures_dir, "funnel_plot.png"), p2[[1]], 
       width = 10, height = 8, dpi = 300)

# 图3: Leave-one-out图
p3 <- mr_leaveoneout_plot(loo_results)
ggsave(file.path(figures_dir, "leave_one_out.png"), p3[[1]], 
       width = 10, height = 8, dpi = 300)

# 图4: 散点图
p4 <- mr_scatter_plot(mr_results, harmonised_data)
ggsave(file.path(figures_dir, "scatter_plot.png"), p4[[1]], 
       width = 10, height = 8, dpi = 300)

cat("  - 图表已保存到 figures/ 目录\n\n")

# ============================================
# 第八步：生成结论
# ============================================
cat("=== 研究结论 ===\n\n")

# 提取IVW结果
ivw_result <- mr_results %>% filter(method == "Inverse variance weighted")

# 判断因果效应
if(ivw_result$pval < 0.05) {
  if(ivw_result$b < 0) {
    conclusion <- "HDL-C水平升高对心血管疾病具有显著的保护作用（P < 0.05），支持研究假设。"
  } else {
    conclusion <- "HDL-C水平升高可能增加心血管疾病风险，与研究假设相反。"
  }
} else {
  conclusion <- "未发现HDL-C与心血管疾病之间存在显著的因果关系。"
}

cat("主要发现:\n")
cat(sprintf("  - IVW方法 OR = %.3f (95%% CI: %.3f-%.3f)\n", 
            exp(ivw_result$b), 
            exp(ivw_result$b - 1.96*ivw_result$se),
            exp(ivw_result$b + 1.96*ivw_result$se)))
cat(sprintf("  - P值 = %.2e\n", ivw_result$pval))
cat(sprintf("  - 结论: %s\n", conclusion))

# 保存结论
writeLines(conclusion, file.path(results_dir, "conclusion.txt"))

cat("\n分析完成！\n")
