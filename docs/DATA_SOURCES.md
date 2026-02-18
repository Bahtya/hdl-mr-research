# 数据来源说明

## GWAS 数据集

本研究使用以下公开可用的 GWAS 数据：

### 暴露变量：HDL-C (高密度脂蛋白胆固醇)

| 属性 | 值 |
|------|-----|
| 数据来源 | GLGC (Global Lipids Genetics Consortium) |
| GWAS ID | ieu-a-299 |
| 样本量 | ~100,000 |
| 人群 | 欧洲人群 |

### 结局变量：冠心病 (CHD)

| 属性 | 值 |
|------|-----|
| 数据来源 | CARDIoGRAMplusC4D |
| GWAS ID | ieu-a-7 |
| 样本量 | ~185,000 |
| 病例数 | ~60,000 |
| 对照数 | ~125,000 |

## 数据获取方式

数据通过 TwoSampleMR R 包从 IEU GWAS 数据库自动获取：
```r
library(TwoSampleMR)
exposure <- extract_instruments(outcomes = 'ieu-a-299')
outcome <- extract_outcome_data(snps = exposure$SNP, outcomes = 'ieu-a-7')
```

## 参考文献

1. Willer CJ, et al. (2013). Discovery and refinement of loci associated with lipid levels. Nature Genetics.
2. Deloukas P, et al. (2013). Large-scale association analysis identifies new risk loci for coronary artery disease. Nature Genetics.
3. Hemani G, et al. (2018). The MR-Base platform supports systematic causal inference across the human phenome. eLife.
