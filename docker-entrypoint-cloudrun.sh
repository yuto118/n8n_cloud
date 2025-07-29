#!/bin/sh

echo "=== Cloud Run n8n Startup ==="
echo "Environment variables:"
echo "  PORT: ${PORT:-'not set'}"
echo "  N8N_HOST: ${N8N_HOST:-'not set'}"
echo "  NODE_ENV: ${NODE_ENV:-'not set'}"

# Cloud RunのPORT環境変数をN8N_PORTに設定（必須）
if [ -n "$PORT" ]; then
    export N8N_PORT="$PORT"
    echo "  Using Cloud Run PORT: $PORT"
else
    export N8N_PORT="8080"
    echo "  No PORT set, defaulting to 8080"
fi

echo "  Final N8N_PORT: $N8N_PORT"

# Cloud Runでは/tmp以外の書き込み権限が制限されるため、
# 必要な場合は一時ディレクトリを設定
export TMPDIR=/tmp

# カスタム証明書の処理
if [ -d /opt/custom-certificates ]; then
    echo "Trusting custom certificates from /opt/custom-certificates."
    export NODE_OPTIONS="--use-openssl-ca $NODE_OPTIONS"
    export SSL_CERT_DIR=/opt/custom-certificates
    c_rehash /opt/custom-certificates
fi

# Cloud Runのメモリ制限に対応
if [ -z "$NODE_OPTIONS" ]; then
    export NODE_OPTIONS="--max-old-space-size=2048"
    echo "  Setting NODE_OPTIONS: $NODE_OPTIONS"
fi

echo "=== Starting n8n ==="

# n8nの起動
exec "$@" 