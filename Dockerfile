FROM n8nio/n8n:latest

# 環境変数を明示的に設定
ENV NODE_ENV=production
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=8080
ENV PORT=8080

# 必要なパッケージをインストール
USER root
RUN apk add --no-cache bash curl
USER node

# エントリーポイントスクリプトを作成（Cloud Run用）
RUN echo '#!/bin/bash\n\
echo "=== Cloud Run n8n Startup ==="\n\
echo "PORT env var: ${PORT}"\n\
echo "N8N_PORT env var: ${N8N_PORT}"\n\
\n\
# PORTが設定されている場合、N8N_PORTを上書き\n\
if [ ! -z "$PORT" ]; then\n\
    export N8N_PORT="$PORT"\n\
    echo "Using Cloud Run PORT: $PORT"\n\
fi\n\
\n\
echo "Final N8N_PORT: $N8N_PORT"\n\
\n\
# n8nを8080ポートで強制的に起動\n\
echo "Starting n8n on port $N8N_PORT..."\n\
exec n8n start' > /tmp/start.sh && chmod +x /tmp/start.sh

# ポート公開
EXPOSE 8080

# ヘルスチェック（起動時間を考慮）
HEALTHCHECK --interval=30s --timeout=15s --start-period=120s --retries=5 \
  CMD curl -f http://localhost:8080/healthz || curl -f http://localhost:8080/ || exit 1

# カスタムエントリーポイントを使用
CMD ["/tmp/start.sh"] 