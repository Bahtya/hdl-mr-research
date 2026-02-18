# HDL与心血管疾病孟德尔随机化研究

## 研究背景

高密度脂蛋白胆固醇 (HDL-C) 水平较高的人群心血管疾病发病率较低。本研究使用孟德尔随机化方法探索 HDL-C 与心血管疾病之间的因果关系。

## 研究假设

- 原假设 (H0): HDL-C 对心血管疾病无因果影响
- 备择假设 (H1): HDL-C 对心血管疾病有保护作用

## 项目结构

```
hdl-mr-research/
├── data/           # 数据文件
├── scripts/        # R分析脚本
├── results/        # 分析结果
├── figures/        # 图表文件
├── report/         # 前端汇报页面
└── Dockerfile      # Docker环境配置
```

## 使用方法

```bash
# 构建Docker镜像
docker build -t hdl-mr-research .

# 运行分析
docker run -v $(pwd):/research hdl-mr-research Rscript scripts/analysis.R
```

## 技术栈

- R 4.3.0
- TwoSampleMR (孟德尔随机化)
- ggplot2 (可视化)
