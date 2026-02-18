# HDL-C 与心血管疾病孟德尔随机化研究 - 完整过程文档

> 文档创建时间：2026-02-18
> 项目仓库：https://github.com/Bahtya/hdl-mr-research

---

## 一、研究概述

### 1.1 研究目标
使用两样本孟德尔随机化（Two-Sample Mendelian Randomization, MR）方法探索高密度脂蛋白胆固醇（HDL-C）与心血管疾病（CVD）之间的因果关系。

### 1.2 研究设计
| 要素 | 内容 |
|------|------|
| 暴露因素 | HDL-C (IEU GWAS: ieu-a-299) |
| 结局变量 | 冠心病 CHD (CARDIoGRAM: ieu-a-7) |
| 工具变量 | 86个全基因组显著性SNPs (P < 5×10⁻⁸) |
| MR方法 | IVW, MR-Egger, Weighted Median, Weighted Mode |

### 1.3 主要结论
| 指标 | 结果 |
|------|------|
| OR (95% CI) | **0.838 (0.755-0.930)** |
| P值 | **8.89×10⁻⁴** |
| 结论 | HDL-C水平升高对心血管疾病具有显著保护作用 ✅ |

---

## 二、执行命令记录

### 2.1 环境准备

```bash
# 1. 创建项目目录
mkdir -p /root/.nanobot/workspace/hdl-mr-research
cd /root/.nanobot/workspace/hdl-mr-research

# 2. 创建子目录结构
mkdir -p data scripts results figures report docs

# 3. 创建 Python 虚拟环境
python3 -m venv .venv
source .venv/bin/activate

# 4. 安装 Python 依赖
pip install pandas numpy scipy matplotlib seaborn
```

### 2.2 Docker 镜像构建

```bash
# 构建命令（需要代理才能访问 GitHub）
docker build \
  --build-arg HTTP_PROXY=http://192.168.1.18:7890 \
  --build-arg HTTPS_PROXY=http://192.168.1.18:7890 \
  --network=host \
  -t hdl-mr-research:latest .

# 后台构建（推荐）
nohup docker build \
  --build-arg HTTP_PROXY=http://192.168.1.18:7890 \
  --build-arg HTTPS_PROXY=http://192.168.1.18:7890 \
  --network=host \
  -t hdl-mr-research:latest . > /tmp/docker-build.log 2>&1 &

# 查看构建日志
tail -f /tmp/docker-build.log

# 查看构建结果
docker images | grep hdl-mr-research
```

### 2.3 运行 MR 分析

```bash
# 方法1: 在 Docker 容器中运行
docker run --rm \
  -v $(pwd)/results:/research/results \
  -v $(pwd)/figures:/research/figures \
  hdl-mr-research:latest \
  Rscript scripts/analysis.R

# 方法2: 使用 OpenGWAS API Token（推荐）
docker run --rm \
  -e OPENGWAS_JWT="your_token_here" \
  -v $(pwd)/results:/research/results \
  -v $(pwd)/figures:/research/figures \
  hdl-mr-research:latest \
  Rscript scripts/analysis.R

# 方法3: 进入容器交互模式
docker run -it --rm \
  -v $(pwd):/research \
  hdl-mr-research:latest \
  /bin/bash
```

### 2.4 GitHub 操作

```bash
# 配置代理（必须）
export https_proxy=http://192.168.1.18:7890
export http_proxy=http://192.168.1.18:7890

# 初始化仓库
git init
git remote add origin git@github.com:Bahtya/hdl-mr-research.git

# 添加所有文件
git add .

# 提交
git commit -m "feat: 完成 MR 分析和可视化"

# 推送
git push -u origin main
```

### 2.5 验证安装

```bash
# 验证 TwoSampleMR 安装
docker run --rm hdl-mr-research:latest \
  R -e "packageVersion('TwoSampleMR')"

# 验证 ieugwasr 安装
docker run --rm hdl-mr-research:latest \
  R -e "packageVersion('ieugwasr')"

# 测试 API 连接
docker run --rm \
  -e OPENGWAS_JWT="your_token" \
  hdl-mr-research:latest \
  R -e "ieugwasr::api_status()"
```

---

## 三、项目结构

```
hdl-mr-research/
├── README.md                    # 项目说明
├── Dockerfile                   # Docker 环境定义
├── .gitignore                   # Git 忽略规则
│
├── scripts/                     # 分析脚本
│   ├── analysis.R               # 主要 MR 分析脚本
│   └── mr_analysis_simple.py    # Python 辅助脚本
│
├── data/                        # 原始数据（空，在线获取）
│
├── results/                     # 分析结果
│   ├── mr_results.csv           # MR 分析结果
│   ├── harmonised_data.csv      # 协调后的数据
│   ├── heterogeneity.csv        # 异质性检验结果
│   ├── pleiotropy.csv           # 多效性检验结果
│   └── conclusion.txt           # 研究结论
│
├── figures/                     # 可视化图表
│   ├── scatter_plot.png         # 散点图
│   ├── forest_plot.png          # 森林图
│   ├── funnel_plot.png          # 漏斗图
│   └── leave_one_out.png        # Leave-one-out 图
│
├── docs/                        # 文档
│   ├── index.html               # 交互式报告
│   ├── METHODOLOGY.md           # 方法说明
│   ├── DATA_SOURCES.md          # 数据来源
│   └── RESEARCH_PROCESS.md      # 本文档
│
└── report/                      # 完整报告
    └── index.html               # HTML 报告
```

---

## 四、遇到的问题及解决方案

### 4.1 Docker 构建无法访问 GitHub API

**问题描述：**
```
Error: Failed to install package from GitHub
Could not resolve host: github.com
```

**原因分析：**
- Docker 容器默认不使用宿主机代理
- TwoSampleMR 和 ieugwasr 需要从 GitHub 安装

**解决方案：**
```dockerfile
# 在 Dockerfile 中添加代理参数
ARG HTTP_PROXY
ARG HTTPS_PROXY
```

```bash
# 构建时传入代理
docker build \
  --build-arg HTTP_PROXY=http://192.168.1.18:7890 \
  --build-arg HTTPS_PROXY=http://192.168.1.18:7890 \
  --network=host \
  -t hdl-mr-research:latest .
```

---

### 4.2 TwoSampleMR 缺少 ieugwasr 依赖

**问题描述：**
```
Error: package 'ieugwasr' is required
```

**原因分析：**
- TwoSampleMR 依赖 ieugwasr 进行 API 调用
- 两个包都需要从 GitHub 安装
- 安装顺序有依赖关系

**解决方案：**
```dockerfile
# 修改 Dockerfile，先安装 ieugwasr
RUN R -e "remotes::install_github('mrcieu/ieugwasr', upgrade='never')"
RUN R -e "remotes::install_github('MRCIEU/TwoSampleMR', upgrade='never')"
```

---

### 4.3 OpenGWAS API 需要认证

**问题描述：**
```
Error in ieugwasr::api_status() : Status 401
API requires authentication
```

**原因分析：**
- OpenGWAS API 从 2024 年 5 月起需要 Token 认证
- 免费注册后可获得 API Token

**解决方案：**
1. 注册 https://api.opengwas.io/ 获取 JWT Token
2. 配置环境变量：
```bash
export OPENGWAS_JWT="eyJhbGciOiJSUzI1NiIs..."
```
3. 在 R 脚本中设置：
```r
Sys.setenv(OPENGWAS_JWT = "your_token_here")
```

---

### 4.4 LLM API 速率限制

**问题描述：**
```
litellm.RateLimitError: Rate limit exceeded
```

**原因分析：**
- 短时间内发送过多 API 请求
- AI 模型 API 有请求频率限制

**解决方案：**
- 减少并发请求
- 在批量操作间添加延迟
- 使用后台任务处理长时间操作

---

### 4.5 gh CLI 无法连接 GitHub

**问题描述：**
```
HTTP 403: API rate limit exceeded
Could not resolve host: api.github.com
```

**原因分析：**
- gh CLI 默认不使用系统代理
- 需要显式配置代理

**解决方案：**
```bash
# 配置 Git 代理
git config --global http.proxy http://192.168.1.18:7890

# 临时设置环境变量
export https_proxy=http://192.168.1.18:7890

# SSH 配置（~/.ssh/config）
Host github.com
  ProxyCommand nc -X connect -x 192.168.1.18:7890 %h %p
```

---

### 4.6 uv pip 安装需要虚拟环境

**问题描述：**
```
error: Cannot find virtual environment
pip is not found
```

**原因分析：**
- 系统使用 `uv` 作为包管理器
- `uv pip install` 需要在虚拟环境中

**解决方案：**
```bash
# 创建虚拟环境
python3 -m venv .venv

# 激活
source .venv/bin/activate

# 然后安装
pip install pandas numpy
```

---

## 五、关键技术要点

### 5.1 代理配置汇总

| 服务 | 代理配置 |
|------|----------|
| Docker 构建 | `--build-arg HTTP_PROXY=http://192.168.1.18:7890` |
| Git | `git config --global http.proxy http://192.168.1.18:7890` |
| SSH | `ProxyCommand nc -X connect -x 192.168.1.18:7890 %h %p` |
| 环境变量 | `export https_proxy=http://192.168.1.18:7890` |

### 5.2 OpenGWAS Token 配置

| 方式 | 命令 |
|------|------|
| 环境变量 | `export OPENGWAS_JWT="your_token"` |
| R 脚本 | `Sys.setenv(OPENGWAS_JWT = "your_token")` |
| Docker | `-e OPENGWAS_JWT="your_token"` |

### 5.3 文件权限

```bash
# 确保目录可写
chmod -R 755 results/ figures/

# Docker 挂载卷
-v $(pwd)/results:/research/results
```

---

## 六、参考资源

- [TwoSampleMR 文档](https://mrcieu.github.io/TwoSampleMR/)
- [OpenGWAS 数据库](https://gwas.mrcieu.ac.uk/)
- [OpenGWAS API 注册](https://api.opengwas.io/)
- [Docker 官方文档](https://docs.docker.com/)
- [Mendelian Randomization 教程](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6085986/)

---

## 七、版本历史

| 日期 | 版本 | 更新内容 |
|------|------|----------|
| 2026-02-18 | 1.0 | 初始版本，完成 MR 分析 |

---

*文档由 nanobot 自动生成*
