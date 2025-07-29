# Cloud Run n8n デプロイスクリプト (PowerShell版)

# 設定 - 実際の値に置き換えてください
$PROJECT_ID = "YOUR_PROJECT_ID"
$SERVICE_NAME = "n8n-service"
$REGION = "asia-northeast1"
$IMAGE_NAME = "gcr.io/$PROJECT_ID/n8n"

Write-Host "=== Cloud Run n8n Deployment ===" -ForegroundColor Green

# 1. Google Cloud CLIの確認
Write-Host "Checking Google Cloud CLI..." -ForegroundColor Yellow
try {
    gcloud --version
} catch {
    Write-Host "Error: Google Cloud CLI not found. Please install it first." -ForegroundColor Red
    Write-Host "Download from: https://cloud.google.com/sdk/docs/install" -ForegroundColor Cyan
    exit 1
}

# 2. プロジェクト設定
Write-Host "Setting project: $PROJECT_ID" -ForegroundColor Yellow
gcloud config set project $PROJECT_ID

# 3. 認証確認
Write-Host "Checking authentication..." -ForegroundColor Yellow
$authAccount = gcloud auth list --filter="status:ACTIVE" --format="value(account)"
if (-not $authAccount) {
    Write-Host "Not authenticated. Please run: gcloud auth login" -ForegroundColor Red
    exit 1
}
Write-Host "Authenticated as: $authAccount" -ForegroundColor Green

# 4. Container Registry認証
Write-Host "Configuring Docker for Container Registry..." -ForegroundColor Yellow
gcloud auth configure-docker

# 5. Dockerイメージのビルド
Write-Host "Building Docker image..." -ForegroundColor Yellow
docker build -f Dockerfile.cloudrun-simple -t $IMAGE_NAME`:latest .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker build failed" -ForegroundColor Red
    exit 1
}

# 6. イメージをContainer Registryにプッシュ
Write-Host "Pushing image to Container Registry..." -ForegroundColor Yellow
docker push $IMAGE_NAME`:latest
if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker push failed" -ForegroundColor Red
    exit 1
}

# 7. Cloud Runサービスをデプロイ
Write-Host "Deploying to Cloud Run..." -ForegroundColor Yellow
gcloud run deploy $SERVICE_NAME `
  --image=$IMAGE_NAME`:latest `
  --platform=managed `
  --region=$REGION `
  --allow-unauthenticated `
  --memory=2Gi `
  --cpu=1 `
  --max-instances=5 `
  --min-instances=0 `
  --port=8080 `
  --timeout=600 `
  --set-env-vars="NODE_ENV=production,N8N_HOST=0.0.0.0,N8N_PORT=8080,GENERIC_TIMEZONE=Asia/Tokyo,N8N_BASIC_AUTH_ACTIVE=true,N8N_BASIC_AUTH_USER=admin,N8N_BASIC_AUTH_PASSWORD=changeme123"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Cloud Run deployment failed" -ForegroundColor Red
    exit 1
}

# 8. デプロイされたURLを取得
Write-Host "Getting service URL..." -ForegroundColor Yellow
$SERVICE_URL = gcloud run services describe $SERVICE_NAME --region=$REGION --format="value(status.url)"

Write-Host "=== Deployment Complete ===" -ForegroundColor Green
Write-Host "Service URL: $SERVICE_URL" -ForegroundColor Cyan
Write-Host ""
Write-Host "Access n8n at: $SERVICE_URL" -ForegroundColor Cyan
Write-Host "Login: admin / changeme123" -ForegroundColor Yellow
Write-Host ""
Write-Host "To view logs:" -ForegroundColor Yellow
Write-Host "gcloud run services logs read $SERVICE_NAME --region=$REGION" -ForegroundColor Gray 