FROM n8nio/n8n:latest

# 環境変数の設定
ENV NODE_ENV=production
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=8080

# ポートの公開
EXPOSE 8080

# curlをインストール（ヘルスチェック用）
USER root
RUN apk add --no-cache curl
USER node

# エントリーポイントスクリプトの作成
COPY --chown=node:node docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# エントリーポイントの設定
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["n8n"] 