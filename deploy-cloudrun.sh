#!/bin/bash

# 設定
PROJECT_ID="YOUR_PROJECT_ID"  # 実際のプロジェクトIDに置き換え
SERVICE_NAME="n8n-service"
REGION="asia-northeast1"  # 東京リージョン
IMAGE_NAME="gcr.io/${PROJECT_ID}/n8n"

echo "=== Cloud Run n8n Deployment Script ==="

# 1. プロジェクトIDの設定
echo "Setting project: $PROJECT_ID"
gcloud config set project $PROJECT_ID

# 2. Dockerイメージのビルド
echo "Building Docker image..."
docker build -f Dockerfile.cloudrun -t $IMAGE_NAME:latest .

# 3. イメージをContainer Registryにプッシュ
echo "Pushing image to Container Registry..."
docker push $IMAGE_NAME:latest

# 4. Secret Managerでシークレットを作成（初回のみ）
echo "Creating secrets (if not exists)..."
gcloud secrets create n8n-admin-password --data-file=- <<< "changeme123"
gcloud secrets create n8n-encryption-key --data-file=- <<< "$(openssl rand -base64 32)"
gcloud secrets create n8n-db-host --data-file=- <<< "localhost"
gcloud secrets create n8n-db-user --data-file=- <<< "n8n"
gcloud secrets create n8n-db-password --data-file=- <<< "$(openssl rand -base64 16)"

# 5. Cloud Runサービスをデプロイ
echo "Deploying to Cloud Run..."
gcloud run deploy $SERVICE_NAME \
  --image=$IMAGE_NAME:latest \
  --platform=managed \
  --region=$REGION \
  --allow-unauthenticated \
  --memory=4Gi \
  --cpu=2 \
  --max-instances=10 \
  --min-instances=1 \
  --port=8080 \
  --timeout=300 \
  --set-env-vars="NODE_ENV=production,GENERIC_TIMEZONE=Asia/Tokyo,TZ=Asia/Tokyo,N8N_HOST=0.0.0.0,N8N_BASIC_AUTH_ACTIVE=true,N8N_BASIC_AUTH_USER=admin" \
  --set-secrets="N8N_BASIC_AUTH_PASSWORD=n8n-admin-password:latest,N8N_ENCRYPTION_KEY=n8n-encryption-key:latest"

# 6. デプロイされたURLを取得
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format="value(status.url)")

echo "=== Deployment Complete ==="
echo "Service URL: $SERVICE_URL"
echo ""
echo "Next steps:"
echo "1. Update WEBHOOK_URL environment variable with: $SERVICE_URL"
echo "2. Set up Cloud SQL PostgreSQL instance (recommended)"
echo "3. Configure domain and SSL certificate if needed"
echo ""
echo "Access n8n at: $SERVICE_URL"
echo "Login: admin / changeme123" 