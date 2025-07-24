#!/bin/sh

echo "Starting n8n with the following configuration:"
echo "N8N_HOST: $N8N_HOST"
echo "N8N_PORT: $N8N_PORT"
echo "PORT: $PORT"

# PORT環境変数が設定されている場合、N8N_PORTとして使用
if [ -n "$PORT" ]; then
    echo "Using PORT environment variable: $PORT"
    export N8N_PORT="$PORT"
fi

echo "Final N8N_PORT: $N8N_PORT"

# カスタム証明書の処理（元のエントリーポイントから）
if [ -d /opt/custom-certificates ]; then
    echo "Trusting custom certificates from /opt/custom-certificates."
    export NODE_OPTIONS="--use-openssl-ca $NODE_OPTIONS"
    export SSL_CERT_DIR=/opt/custom-certificates
    c_rehash /opt/custom-certificates
fi

echo "Starting n8n..."

# n8nの起動
if [ "$#" -gt 0 ]; then
    # 引数が指定されている場合
    exec n8n "$@"
else
    # 引数が指定されていない場合
    exec n8n start
fi 