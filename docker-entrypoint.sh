#!/bin/sh

# PORT環境変数が設定されている場合、N8N_PORTとして使用
if [ -n "$PORT" ]; then
    export N8N_PORT="$PORT"
fi

# カスタム証明書の処理（元のエントリーポイントから）
if [ -d /opt/custom-certificates ]; then
    echo "Trusting custom certificates from /opt/custom-certificates."
    export NODE_OPTIONS="--use-openssl-ca $NODE_OPTIONS"
    export SSL_CERT_DIR=/opt/custom-certificates
    c_rehash /opt/custom-certificates
fi

# n8nの起動
if [ "$#" -gt 0 ]; then
    # 引数が指定されている場合
    exec n8n "$@"
else
    # 引数が指定されていない場合
    exec n8n
fi 