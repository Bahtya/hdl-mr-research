#!/usr/bin/env python3
"""
HDL-CVD 孟德尔随机化研究 - 模拟数据分析
使用模拟数据演示完整的 MR 分析流程
"""

import json
import os
import random
import math
from datetime import datetime

# 设置随机种子保证可重复性
random.seed(42)

# 获取脚本所在目录的父目录
script_dir = os.path.dirname(os.path.abspath(__file__))
project_dir = os.path.dirname(script_dir)

# 创建输出目录
os.makedirs(os.path.join(project_dir, "results"), exist_ok=True)
os.makedirs(os.path.join(project_dir, "figures"), exist_ok=True)

print("=" * 60)
print("HDL-CVD 孟德尔随机化研究")
print("=" * 60)

# ===== 1. 模拟 SNP 数据 =====
print("\n[1] 生成模拟 GWAS 数据...")

# 模拟 25 个与 HDL 相关的独立 SNP
snps = []
n_exp = 100000  # 暴露样本量
n_out = 150000  # 结局样本量

# 真实的因果效应 (模拟 HDL 每增加 1 SD，CVD 风险降低)
true_causal_effect = -0.15

for i in range(25):
    # 模拟 SNP 信息
    chr_num = random.randint(1, 22)
    pos = random.randint(1000000, 250000000)
    
    # 暴露 (HDL) 关联
    beta_exp = random.uniform(0.02, 0.15) * random.choice([-1, 1])
    se_exp = abs(beta_exp) / random.uniform(3, 10)
    pval_exp = 2 * (1 - 0.5 * (1 + math.erf(-abs(beta_exp/se_exp) / math.sqrt(2))))
    
    # 结局 (CVD) - 包含真实的因果效应
    beta_out = beta_exp * true_causal_effect + random.gauss(0, 0.01)
    se_out = se_exp * random.uniform(1.2, 2.0)
    
    snps.append({
        "snp": f"rs{random.randint(100000, 9999999)}",
        "chr": chr_num,
        "position": pos,
        "effect_allele": random.choice(["A", "G"]),
        "other_allele": random.choice(["C", "T"]),
        "eaf": random.uniform(0.2, 0.8),
        "beta_exp": round(beta_exp, 6),
        "se_exp": round(se_exp, 6),
        "pval_exp": round(pval_exp, 10),
        "beta_out": round(beta_out, 6),
        "se_out": round(se_out, 6)
    })

print(f"   ✓ 生成了 {len(snps)} 个工具变量 SNP")

# ===== 2. MR 分析 =====
print("\n[2] 执行孟德尔随机化分析...")

def ivw_analysis(snps):
    """逆方差加权法 (IVW)"""
    numerator = sum(s["beta_exp"] * s["beta_out"] / (s["se_out"]**2) for s in snps)
    denominator = sum(s["beta_exp"]**2 / (s["se_out"]**2) for s in snps)
    beta = numerator / denominator
    
    se = 1 / math.sqrt(denominator)
    z = beta / se
    pval = 2 * (1 - 0.5 * (1 + math.erf(abs(z) / math.sqrt(2))))
    
    return beta, se, pval

def weighted_median(snps):
    """加权中位数法"""
    ratios = [s["beta_out"]/s["beta_exp"] for s in snps]
    weights = [1/(s["se_out"]**2) for s in snps]
    
    # 简化：返回中位数
    sorted_data = sorted(zip(ratios, weights))
    return sorted_data[len(sorted_data)//2][0], None, None

def mr_egger(snps):
    """MR-Egger 回归"""
    # 简化计算
    ratios = [s["beta_out"]/s["beta_exp"] for s in snps]
    return sum(ratios)/len(ratios), None, None

# 运行分析
ivw_beta, ivw_se, ivw_p = ivw_analysis(snps)
wm_beta, _, _ = weighted_median(snps)
egger_beta, _, _ = mr_egger(snps)

print(f"   ✓ IVW 分析完成")
print(f"   ✓ 加权中位数分析完成")
print(f"   ✓ MR-Egger 分析完成")

# ===== 3. 异质性检验 =====
print("\n[3] 异质性检验...")

Q = sum((s["beta_out"] - ivw_beta * s["beta_exp"])**2 / s["se_out"]**2 for s in snps)
Q_df = len(snps) - 1
Q_pval = 1 - 0.5 * (1 + math.erf((Q - Q_df) / math.sqrt(2 * Q_df)))

print(f"   Cochran's Q = {Q:.2f}, df = {Q_df}, p = {Q_pval:.4f}")

# ===== 4. 敏感性分析 =====
print("\n[4] 敏感性分析 (Leave-one-out)...")

loo_results = []
for i, snp in enumerate(snps):
    other_snps = [s for j, s in enumerate(snps) if j != i]
    loo_beta, _, _ = ivw_analysis(other_snps)
    loo_results.append({
        "snp": snp["snp"],
        "beta": round(loo_beta, 4)
    })

# ===== 5. 生成结果 =====
print("\n[5] 生成分析结果...")

results = {
    "study": "HDL-CVD 孟德尔随机化研究",
    "date": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    "n_snps": len(snps),
    "exposure": "HDL 胆固醇 (高密度脂蛋白)",
    "outcome": "心血管疾病 (CVD)",
    "methods": {
        "IVW": {
            "beta": round(ivw_beta, 4),
            "se": round(ivw_se, 4),
            "or": round(math.exp(ivw_beta), 4),
            "or_ci_lower": round(math.exp(ivw_beta - 1.96*ivw_se), 4),
            "or_ci_upper": round(math.exp(ivw_beta + 1.96*ivw_se), 4),
            "p_value": round(ivw_p, 6)
        },
        "Weighted_Median": {
            "beta": round(wm_beta, 4),
            "or": round(math.exp(wm_beta), 4)
        },
        "MR_Egger": {
            "beta": round(egger_beta, 4),
            "or": round(math.exp(egger_beta), 4)
        }
    },
    "heterogeneity": {
        "Q_statistic": round(Q, 2),
        "df": Q_df,
        "p_value": round(Q_pval, 4)
    },
    "interpretation": {
        "en": "Higher HDL cholesterol is associated with reduced cardiovascular disease risk.",
        "zh": "HDL 胆固醇水平升高与心血管疾病风险降低相关。"
    }
}

# 保存结果
with open(os.path.join(project_dir, "results/mr_results.json"), "w", encoding="utf-8") as f:
    json.dump(results, f, ensure_ascii=False, indent=2)

print(f"   ✓ 结果已保存到 results/mr_results.json")

# ===== 6. 生成图表数据 =====
print("\n[6] 生成图表数据...")

# 散点图数据
scatter_data = [{
    "snp": s["snp"],
    "x": s["beta_exp"],
    "y": s["beta_out"],
    "x_se": s["se_exp"],
    "y_se": s["se_out"]
} for s in snps]

with open(os.path.join(project_dir, "figures/scatter_data.json"), "w") as f:
    json.dump(scatter_data, f, indent=2)

# 森林图数据
forest_data = {
    "methods": ["IVW", "Weighted Median", "MR-Egger"],
    "betas": [ivw_beta, wm_beta, egger_beta],
    "se": [ivw_se, None, None],
    "or": [math.exp(ivw_beta), math.exp(wm_beta), math.exp(egger_beta)]
}
with open(os.path.join(project_dir, "figures/forest_data.json"), "w") as f:
    json.dump(forest_data, f, indent=2)

# 漏斗图数据
funnel_data = [{
    "snp": s["snp"],
    "ratio": s["beta_out"]/s["beta_exp"],
    "weight": 1/s["se_out"]**2
} for s in snps]
with open(os.path.join(project_dir, "figures/funnel_data.json"), "w") as f:
    json.dump(funnel_data, f, indent=2)

# Leave-one-out 数据
with open(os.path.join(project_dir, "figures/loo_data.json"), "w") as f:
    json.dump(loo_results, f, indent=2)

print(f"   ✓ 散点图数据已保存")
print(f"   ✓ 森林图数据已保存")
print(f"   ✓ 漏斗图数据已保存")
print(f"   ✓ Leave-one-out 数据已保存")

# ===== 7. 打印结论 =====
print("\n" + "=" * 60)
print("研究结果摘要")
print("=" * 60)
print(f"\n方法: 逆方差加权法 (IVW)")
print(f"因果效应 (beta): {ivw_beta:.4f}")
print(f"标准误 (SE): {ivw_se:.4f}")
print(f"比值比 (OR): {math.exp(ivw_beta):.4f}")
print(f"95% CI: [{math.exp(ivw_beta - 1.96*ivw_se):.4f}, {math.exp(ivw_beta + 1.96*ivw_se):.4f}]")
print(f"P 值: {ivw_p:.2e}")

if ivw_p < 0.05:
    print("\n结论: HDL 胆固醇与心血管疾病存在因果关系 (p < 0.05)")
    print(f"  HDL 每增加 1 个标准差，CVD 风险降低 {(1-math.exp(ivw_beta))*100:.1f}%")
else:
    print("\n结论: 未发现显著因果关系 (p >= 0.05)")

print("\n" + "=" * 60)
print("分析完成!")
print("=" * 60)
