# AI 孟德尔随机化研究提示词模板

> 本文档提供完整的提示词模板，可用于指导 AI 大模型完成类似的孟德尔随机化 (MR) 研究。

---

## 📋 完整研究提示词

```
请帮我完成一个两样本孟德尔随机化 (Two-Sample MR) 研究，研究 [暴露因素] 对 [结局疾病] 的因果效应。

## 研究要求

### 1. 数据来源
- 暴露数据: 从 IEU GWAS 数据库获取 (提供 GWAS ID，如 ieu-a-XXX)
- 结局数据: 从 IEU GWAS 数据库获取 (提供 GWAS ID，如 ieu-a-XXX)
- 使用 OpenGWAS API 获取数据 (需要 JWT Token)

### 2. 分析方法
- 工具变量选择: P < 5×10⁻⁸, LD 去除 (r² < 0.001)
- MR 方法:
  - 逆方差加权法 (IVW) - 主要分析
  - MR-Egger 回归 - 多效性检测
  - 加权中位数法
  - 加权众数法

### 3. 敏感性分析
- 异质性检验 (Cochran's Q)
- 水平多效性检验 (MR-Egger intercept)
- Steiger 方向性检验
- Leave-one-out 分析

### 4. 输出内容
- MR 分析结果表 (β, SE, OR, 95% CI, P 值)
- 散点图 (Scatter plot)
- 森林图 (Forest plot)
- 漏斗图 (Funnel plot)
- Leave-one-out 图
- 完整的 HTML 研究报告

### 5. 技术要求
- 使用 R 语言和 TwoSampleMR 包
- Docker 容器化环境
- 代码推送到 GitHub
- 发布 GitHub Pages 可视化页面

### 6. OpenGWAS API Token
[在此填入你的 JWT Token]
```

---

## 🔧 逐步执行提示词

### 步骤 1: 环境准备

```
创建 Docker 镜像用于 MR 分析，基础镜像使用 rocker/r-ver:4.3.0，需要安装以下 R 包：
- TwoSampleMR (从 GitHub: MRCIEU/TwoSampleMR)
- ggplot2, dplyr, forestplot, patchwork, knitr, rmarkdown
- ieugwasr

Dockerfile 需要配置代理访问 GitHub: http://192.168.1.18:7890
```

### 步骤 2: 获取 GWAS 数据

```
使用 TwoSampleMR 包从 OpenGWAS 获取数据：

暴露: [GWAS ID] - [暴露名称]
结局: [GWAS ID] - [结局名称]

代码示例：
library(TwoSampleMR)
exposure_dat <- extract_instruments("[暴露GWAS_ID]")
outcome_dat <- extract_outcome_data(snps = exposure_dat$SNP, outcomes = "[结局GWAS_ID]")

需要设置环境变量: OPENGWAS_JWT="[你的Token]"
```

### 步骤 3: 运行 MR 分析

```
使用 TwoSampleMR 运行 MR 分析：

1. 调和暴露和结局数据
2. 运行多种 MR 方法
3. 进行敏感性分析
4. 生成可视化图表

保存结果到 results/ 目录，图表保存到 figures/ 目录
```

### 步骤 4: 生成报告

```
生成完整的研究报告，包括：
1. 研究摘要
2. 方法描述
3. 结果表格
4. 可视化图表
5. 敏感性分析结果
6. 讨论与结论

输出格式: HTML (可转换为 PDF)
```

### 步骤 5: GitHub 发布

```
将代码和结果推送到 GitHub：
1. 初始化 Git 仓库
2. 添加所有文件
3. 推送到远程仓库

配置 GitHub Pages:
1. 创建 docs/index.html
2. 在仓库设置中启用 GitHub Pages
3. 选择 docs 目录作为源
```

---

## 📝 常用 GWAS 数据集

### 血脂指标
| ID | 名称 | 样本量 |
|---|---|---|
| ieu-a-299 | HDL cholesterol | 99,900 |
| ieu-a-300 | LDL cholesterol | 95,454 |
| ieu-a-301 | Total cholesterol | 94,595 |
| ieu-a-302 | Triglycerides | 88,989 |

### 心血管疾病
| ID | 名称 | 样本量 |
|---|---|---|
| ieu-a-7 | Coronary heart disease | 184,305 |
| ebi-a-GCST006414 | Stroke | 446,696 |
| ebi-a-GCST006415 | Ischemic stroke | 440,328 |

### 代谢指标
| ID | 名称 | 样本量 |
|---|---|---|
| ieu-a-301 | Fasting glucose | 58,074 |
| ebi-a-GCST90002232 | Type 2 diabetes | 898,130 |
| ieu-b-40 | BMI | 681,275 |

### 炎症指标
| ID | 名称 | 样本量 |
|---|---|---|
| ebi-a-GCST009627 | CRP | 575,531 |
| ebi-a-GCST90014607 | IL-6 | 462,468 |

---

## ⚠️ 常见问题及解决

### 1. OpenGWAS API 认证
```
问题: Status 401 Unauthorized
解决: 注册 https://api.opengwas.io/ 获取免费 JWT Token
配置: export OPENGWAS_JWT="你的Token"
```

### 2. Docker 构建代理
```
问题: 无法访问 GitHub
解决: docker build --build-arg HTTP_PROXY=http://代理地址:端口 \
                 --build-arg HTTPS_PROXY=http://代理地址:端口 \
                 --network=host -t 镜像名 .
```

### 3. R 包安装失败
```
问题: TwoSampleMR 安装失败
解决: 先安装依赖 ieugwasr
      install.packages("ieugwasr", repos = c("https://mrcieu.r-universe.dev"))
      remotes::install_github("MRCIEU/TwoSampleMR")
```

### 4. 图表保存失败
```
问题: ggsave 找不到函数
解决: 确保加载 library(ggplot2)
```

---

## 📚 参考资源

- TwoSampleMR 文档: https://mrcieu.github.io/TwoSampleMR/
- OpenGWAS 数据库: https://gwas.mrcieu.ac.uk/
- IEU GWAS 数据集: https://gwas.mrcieu.ac.uk/datasets/
- MR 基础教程: https://cdn1.sph.harvard.edu/wp-content/uploads/sites/1268/2022/10/MR-Primer.pdf

---

## 💡 使用建议

1. **明确研究问题**: 确定暴露因素和结局疾病的生物学合理性
2. **选择合适数据**: 使用大规模 GWAS 汇总数据，确保样本量充足
3. **验证结果稳健性**: 多种 MR 方法和敏感性分析结果一致
4. **注意局限性**: 人群特异性、多效性、反向因果等问题

---

*此模板基于 HDL-C → 心血管疾病 MR 研究项目生成*
