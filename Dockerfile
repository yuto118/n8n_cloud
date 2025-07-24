FROM n8nio/n8n:latest

# 環境変数の設定
ENV NODE_ENV=production
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678

# ポートの公開
EXPOSE 5678

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:5678/healthz || exit 1

# n8nの起動
CMD ["n8n"] 