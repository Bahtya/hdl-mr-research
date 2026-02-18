# MR 研究提示词模板

> 使用此提示词可以让 AI 大模型快速实现类似的孟德尔随机化研究

---

## 🎯 完整提示词

```
请帮我完成一个两样本孟德尔随机化（Two-sample MR）研究，分析 [暴露因素] 对 [结局变量] 的因果效应。

## 研究要求

### 1. 数据来源
- 暴露因素：[因素名称]，数据集 ID：[ieu-a-xxx]，来源：[GWAS 联盟名称]
- 结局变量：[疾病名称]，数据集 ID：[ieu-a-xxx]，来源：[GWAS 联盟名称]
- 数据库：OpenGWAS (https://gwas.mrcieu.ac.uk/)

### 2. 分析流程
1. 从 OpenGWAS 获取暴露和结局的 GWAS 汇总数据
2. 选择工具变量（P < 5×10⁻⁸, clumping r² < 0.001）
3. harmonise 数据（对齐效应等位基因）
4. 运行 MR 分析（IVW, MR-Egger, 加权中位数等 5 种方法）
5. 敏感性分析：
   - 异质性检验（Cochran's Q）
   - 多效性检验（MR-Egger 截距）
   - Leave-One-Out 分析
   - Steiger 因果方向检验
6. 生成可视化图表：
   - 散点图 (scatter plot)
   - 森林图 (forest plot)
   - 漏斗图 (funnel plot)
   - Leave-One-Out 图
7. 生成研究报告（HTML/PDF）

### 3. 技术环境
- 使用 Docker 容器：rocker/r-ver:4.3.0
- R 包：TwoSampleMR, ieugwasr, ggplot2, dplyr
- 需要配置代理（如在中国）：HTTP_PROXY=http://your-proxy:port
- 需要 OpenGWAS API Token：设置环境变量 OPENGWAS_JWT

### 4. 输出要求
- 创建项目目录结构：data/, scripts/, results/, figures/, report/
- 结果保存为 CSV 和 JSON 格式
- 图表保存为 PNG 格式
- 生成完整的 README.md 文档
- 推送到 GitHub 仓库

## 预期结果
- 因果效应估计（OR, 95% CI, P 值）
- 敏感性分析结果
- 论文级可视化图表
- 可分享的研究报告
```

---

## 📋 常用数据集 ID 参考

### 血脂指标（暴露因素）
| 指标 | 数据集 ID | 来源 |
|------|-----------|------|
| HDL 胆固醇 | ieu-a-299 | GLGC |
| LDL 胆固醇 | ieu-a-300 | GLGC |
| 总胆固醇 | ieu-a-301 | GLGC |
| 甘油三酯 | ieu-a-302 | GLGC |

### 心血管疾病（结局变量）
| 疾病 | 数据集 ID | 来源 |
|------|-----------|------|
| 冠心病 | ieu-a-7 | CARDIoGRAMplusC4D |
| 中风 | ebi-a-GCST006906 | MEGASTROKE |
| 心衰 | ebi-a-GCST009541 | HERMES |
| 房颤 | ebi-a-GCST006414 | AFGen |

### 代谢指标
| 指标 | 数据集 ID | 来源 |
|------|-----------|------|
| BMI | ieu-b-40 | GIANT |
| 空腹血糖 | ebi-a-GCST000018 | MAGIC |
| 2型糖尿病 | ebi-a-GCST006867 | DIAGRAM |

---

## 🔧 技术配置要点

### Docker 代理配置
```bash
# 构建时配置代理
docker build --build-arg HTTP_PROXY=http://192.168.1.18:7890 \
             --build-arg HTTPS_PROXY=http://192.168.1.18:7890 \
             --network=host -t mr-research:latest .
```

### OpenGWAS API Token
```bash
# 获取 Token: https://api.opengwas.io/
export OPENGWAS_JWT="your-token-here"
```

### R 脚本模板
```r
library(TwoSampleMR)

# 1. 获取暴露数据
exposure_dat <- extract_instruments("ieu-a-299")

# 2. 获取结局数据
outcome_dat <- extract_outcome_data(snps = exposure_dat$SNP,
                                     outcomes = "ieu-a-7")

# 3. Harmonise
dat <- harmonise_data(exposure_dat, outcome_dat)

# 4. MR 分析
res <- mr(dat)

# 5. 敏感性分析
het <- mr_heterogeneity(dat)
pleio <- mr_pleiotropy_test(dat)
loo <- mr_leaveoneout(dat)

# 6. 生成图表
p1 <- mr_scatter_plot(res, dat)
p2 <- mr_forest_plot(res)
p3 <- mr_funnel_plot(dat)
p4 <- mr_leaveoneout_plot(loo)
```

---

## 📁 项目目录结构

```
mr-research/
├── README.md           # 项目说明
├── Dockerfile          # Docker 配置
├── data/               # 原始数据
├── scripts/            # R 分析脚本
│   ├── 01_extract_data.R
│   ├── 02_mr_analysis.R
│   ├── 03_sensitivity.R
│   └── 04_visualization.R
├── results/            # 分析结果
│   ├── mr_results.csv
│   ├── heterogeneity.csv
│   ├── pleiotropy.csv
│   └── sensitivity/
├── figures/            # 图表
│   ├── scatter_plot.png
│   ├── forest_plot.png
│   ├── funnel_plot.png
│   └── leave_one_out.png
├── report/             # 报告
│   ├── report.html
│   └── report.pdf
└── docs/               # GitHub Pages
    └── index.html
```

---

## ⚠️ 常见问题

### 1. OpenGWAS API 401 错误
**原因：** 未配置 API Token  
**解决：** 注册 https://api.opengwas.io/ 获取 Token，设置 `OPENGWAS_JWT` 环境变量

### 2. Docker 无法访问 GitHub
**原因：** 网络限制  
**解决：** 添加 `--build-arg HTTP_PROXY=xxx --network=host`

### 3. TwoSampleMR 安装失败
**原因：** 缺少依赖  
**解决：** 先安装 `ieugwasr` 包

### 4. 异质性显著
**原因：** 可能存在多效性  
**解决：** 关注 MR-Egger 和加权中位数结果

### 5. Steiger 检验失败
**原因：** 因果方向错误  
**解决：** 检查暴露-结局关系，可能需要反向 MR

---

## 📚 参考资料

- [TwoSampleMR 文档](https://mrcieu.github.io/TwoSampleMR/)
- [OpenGWAS 数据库](https://gwas.mrcieu.ac.uk/)
- [MR 方法学指南](https://doi.org/10.1038/s41588-019-0355-0)
- [本项目完整示例](https://github.com/Bahtya/hdl-mr-research)
