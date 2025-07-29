#!/bin/bash

# 設定（実際の値に置き換えてください）
PROJECT_ID="YOUR_PROJECT_ID"
SERVICE_NAME="n8n-simple"
REGION="asia-northeast1"
IMAGE_NAME="gcr.io/${PROJECT_ID}/n8n-simple"

echo "=== Cloud Run Simple n8n Deployment ==="

# プロジェクト設定
gcloud config set project $PROJECT_ID

# Dockerイメージビルド（シンプル版使用）
echo "Building simple Docker image..."
docker build -f Dockerfile.cloudrun-simple -t $IMAGE_NAME:latest .

# Container Registryにプッシュ
echo "Pushing to Container Registry..."
docker push $IMAGE_NAME:latest

# Cloud Runにデプロイ（最小限の設定）
echo "Deploying to Cloud Run..."
gcloud run deploy $SERVICE_NAME \
  --image=$IMAGE_NAME:latest \
  --platform=managed \
  --region=$REGION \
  --allow-unauthenticated \
  --memory=2Gi \
  --cpu=1 \
  --max-instances=5 \
  --min-instances=0 \
  --port=8080 \
  --timeout=600 \
  --set-env-vars="NODE_ENV=production,N8N_HOST=0.0.0.0,N8N_PORT=8080,GENERIC_TIMEZONE=Asia/Tokyo"

# URL取得
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format="value(status.url)")

echo "=== Deployment Complete ==="
echo "Service URL: $SERVICE_URL"
echo ""
echo "Test the service:"
echo "curl $SERVICE_URL" 