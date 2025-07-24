FROM n8nio/n8n:latest

# 環境変数の設定
ENV NODE_ENV=production
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=${PORT:-5678}

# ポートの公開（デフォルトは5678だが、PORTが設定されればそれを使用）
EXPOSE ${PORT:-5678}

# curlをインストール（ヘルスチェック用）
USER root
RUN apk add --no-cache curl
USER node

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:${PORT:-5678}/healthz || exit 1

# エントリーポイントスクリプトの作成
COPY --chown=node:node docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# エントリーポイントの設定
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["n8n"] 