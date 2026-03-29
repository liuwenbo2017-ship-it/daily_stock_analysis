#!/bin/bash
# Railway 启动脚本

set -e

echo "Starting daily_stock_analysis..."

# 检查前端是否已构建（Docker 构建阶段已完成）
if [ ! -d "/app/static" ] || [ ! -f "/app/static/index.html" ]; then
    echo "ERROR: Frontend not built. This should not happen in Docker deployment."
    echo "Frontend should be built during Docker image build stage."
    echo "Please check Dockerfile build process."
    exit 1
fi

echo "Frontend files found, starting server..."

# 启动 FastAPI 服务
# 使用 uvicorn 启动 server:app（server.py 中的 app 对象）
echo "Starting FastAPI server on port ${API_PORT:-8000}..."
exec uvicorn server:app --host 0.0.0.0 --port ${API_PORT:-8000}
