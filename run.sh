#!/bin/bash
# HDL-MR 研究运行脚本

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONTAINER_NAME="hdl-mr-analysis"

echo "=== HDL-MR 研究分析 ==="
echo ""

# 检查Docker镜像是否存在
if ! docker images | grep -q hdl-mr-research; then
    echo "构建Docker镜像..."
    docker build -t hdl-mr-research "$PROJECT_DIR"
fi

# 运行分析
echo "启动分析容器..."
docker run --rm \
    --name "$CONTAINER_NAME" \
    -v "$PROJECT_DIR/data:/research/data" \
    -v "$PROJECT_DIR/scripts:/research/scripts" \
    -v "$PROJECT_DIR/results:/research/results" \
    -v "$PROJECT_DIR/figures:/research/figures" \
    hdl-mr-research \
    Rscript /research/scripts/analysis.R

echo ""
echo "=== 分析完成 ==="
echo "结果保存在: $PROJECT_DIR/results/"
echo "图表保存在: $PROJECT_DIR/figures/"
