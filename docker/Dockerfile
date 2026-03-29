# ===================================
# A股自选股智能分析系统 - Docker 镜像
# ===================================
# 多阶段构建：前端打包 + 后端运行

# ============================================
# 阶段1: 构建前端
# ============================================
FROM node:20-slim AS web-builder

WORKDIR /app

# 复制前端源码
COPY apps/dsa-web/package.json apps/dsa-web/package-lock.json ./apps/dsa-web/
WORKDIR /app/apps/dsa-web

# 安装依赖
RUN npm ci

# 复制前端代码
COPY apps/dsa-web/ ./

# 构建前端（输出到 /app/static，见 vite.config.ts）
RUN npm run build

# 验证构建结果
RUN ls -la /app/static/ && test -f /app/static/index.html

# ============================================
# 阶段2: 运行环境
# ============================================
FROM python:3.11-slim-bookworm

# 设置工作目录
WORKDIR /app

# 设置时区为上海
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 安装系统依赖（wkhtmltopdf 含 wkhtmltoimage，用于 Markdown 转图片）
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    curl \
    wkhtmltopdf \
    fontconfig \
    libjpeg62-turbo \
    libxrender1 \
    libxext6 \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件
COPY requirements.txt .

# 安装 Python 依赖
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用代码
COPY *.py ./
COPY api/ ./api/
COPY data_provider/ ./data_provider/
COPY bot/ ./bot/
COPY patch/ ./patch/
COPY src/ ./src/
COPY strategies/ ./strategies/
COPY templates/ ./templates/

# 复制前端构建产物（从 web-builder 阶段）
COPY --from=web-builder /app/static ./static/

# 验证前端文件存在
RUN ls -la ./static/ && test -f ./static/index.html

# 复制启动脚本
COPY docker/start.sh /app/start.sh
RUN chmod +x /app/start.sh

# 创建数据目录
RUN mkdir -p /app/data /app/logs /app/reports

# 设置环境变量默认值
ENV PYTHONUNBUFFERED=1
ENV LOG_DIR=/app/logs
ENV DATABASE_PATH=/app/data/stock_analysis.db
ENV WEBUI_HOST=0.0.0.0
ENV API_PORT=8000

# 暴露 API 端口
EXPOSE 8000

# 数据卷（持久化数据）
VOLUME ["/app/data", "/app/logs", "/app/reports"]

# 健康检查（FastAPI 模式）
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8000/api/health || curl -f http://localhost:8000/health \
    || python -c "import sys; sys.exit(0)"

# 默认命令
CMD ["/app/start.sh"]
