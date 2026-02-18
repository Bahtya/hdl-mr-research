# HDL-C与心血管疾病孟德尔随机化研究

## 📋 研究概述

使用两样本孟德尔随机化（MR）方法探索高密度脂蛋白胆固醇（HDL-C）与心血管疾病（CHD）之间的因果关系。

## 🎯 主要发现

| 指标 | 结果 |
|------|------|
| **OR (95% CI)** | **0.838 (0.755-0.930)** |
| **P值** | **8.89×10⁻⁴** |
| **结论** | HDL-C水平升高对心血管疾病具有显著保护作用 ✅ |

## 📊 MR分析结果

| 方法 | SNPs | OR | 95% CI | P值 |
|------|------|-----|--------|-----|
| **IVW** | 84 | 0.838 | 0.755-0.930 | **8.89×10⁻⁴** |
| Weighted Median | 84 | 0.884 | 0.816-0.958 | 2.78×10⁻³ |
| MR-Egger | 84 | 0.988 | 0.838-1.166 | 0.891 |
| Weighted Mode | 84 | 0.915 | 0.257-3.263 | 0.892 |

---

## 📈 可视化图表

### 1. 散点图 (Scatter Plot)
展示每个 SNP 对暴露（HDL-C）和结局（CHD）的效应关系

![散点图](figures/scatter_plot.png)

### 2. 森林图 (Forest Plot)
展示 MR 各方法的因果效应估计及置信区间

![森林图](figures/forest_plot.png)

### 3. 漏斗图 (Funnel Plot)
评估潜在的方向性多效性偏倚

![漏斗图](figures/funnel_plot.png)

### 4. Leave-One-Out 图
评估单个 SNP 对整体结果的影响

![Leave-One-Out](figures/leave_one_out.png)

---

## 📄 研究报告

👉 **[Nature 风格专业报告](docs/report/nature_style_report.html)**

---

## 📁 项目结构

```
hdl-mr-research/
├── scripts/
│   └── analysis.R              # MR分析脚本
├── results/
│   ├── mr_results.csv          # MR结果
│   ├── harmonised_data.csv     # 协调后数据
│   ├── sensitivity/            # 敏感性分析结果
│   │   ├── heterogeneity.csv   # 异质性检验
│   │   └── pleiotropy.csv      # 多效性检验
│   └── conclusion.txt          # 结论
├── figures/
│   ├── scatter_plot.png        # 散点图
│   ├── forest_plot.png         # 森林图
│   ├── funnel_plot.png         # 漏斗图
│   └── leave_one_out.png       # Leave-one-out图
├── report/
│   ├── report.html             # 基础HTML报告
│   └── nature_style_report.html # Nature风格报告
├── docs/
│   ├── MR_PROMPT_TEMPLATE.md   # AI提示词模板
│   ├── RESEARCH_PROCESS.md     # 研究过程文档
│   └── report/                 # 报告文件
└── Dockerfile                  # Docker环境
```

---

## 🔬 方法

- **暴露数据**: HDL-C (ieu-a-299)
- **结局数据**: 冠心病 (ieu-a-7)
- **工具变量**: 86个全基因组显著性SNPs (P < 5×10⁻⁸)
- **MR方法**: IVW, MR-Egger, Weighted Median, Weighted Mode

---

## 🔍 敏感性分析

### 异质性检验 (Heterogeneity)

| 方法 | Q统计量 | df | P值 |
|------|---------|-----|-----|
| IVW | - | - | - |
| MR-Egger | - | - | - |

### 多效性检验 (Pleiotropy)

| 检验 | 截距 | SE | P值 |
|------|------|-----|-----|
| MR-Egger intercept | - | - | - |

---

## 🛠️ 环境要求

- Docker
- R 4.3.0+
- TwoSampleMR, ggplot2, dplyr, patchwork

---

## 📅 生成时间

2026-02-19

---

## 📖 参考文献

1. Hemani G, et al. The MR-Base platform supports systematic causal inference across the human phenome. eLife 2018.
2. Bowden J, et al. Mendelian randomization with invalid instruments. Int J Epidemiol 2015.
