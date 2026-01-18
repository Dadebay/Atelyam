# Virtual Try-On Backend API

FastAPI backend for virtual try-on using Hugging Face Kolors model.

## Local Test

### 1. Python Environment Kurulumu
```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # macOS/Linux
pip install -r requirements.txt
```

### 2. Backend'i Çalıştır
```bash
python main.py
```

Backend şu adreste çalışacak: `http://localhost:8080`

### 3. Test Et

#### Basit Health Check:
```bash
curl http://localhost:8080/
```

#### Virtual Try-On Test (2 resimle):
```bash
curl -X POST http://localhost:8080/api/tryon \
  -F "person_image=@/path/to/person.jpg" \
  -F "garment_image=@/path/to/garment.jpg" \
  -o result.jpg
```

## Google Cloud Run Deployment

### 1. Google Cloud Project Oluştur
- https://console.cloud.google.com adresine git
- Yeni proje oluştur

### 2. gcloud CLI Kur (eğer yoksa)
```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud init
```

### 3. Docker Build & Push
```bash
# Project ID'nizi buraya yazın
PROJECT_ID="your-project-id"

# Docker image build et
gcloud builds submit --tag gcr.io/$PROJECT_ID/virtual-tryon

# Cloud Run'a deploy et
gcloud run deploy virtual-tryon \
  --image gcr.io/$PROJECT_ID/virtual-tryon \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --memory 2Gi \
  --timeout 300
```

### 4. URL'i Al
Deploy sonrası size verilen URL'i kopyalayın:
```
https://virtual-tryon-xxxxxx-uc.a.run.app
```

Bu URL'i Flutter uygulamanızda kullanın!

## API Endpoints

### GET /
Status kontrolü

### GET /health
Health check

### POST /api/tryon
Multipart form-data ile virtual try-on
- `person_image`: File
- `garment_image`: File

### POST /api/tryon-base64
Base64 formatında virtual try-on
```json
{
  "person_image": "data:image/jpeg;base64,...",
  "garment_image": "data:image/jpeg;base64,..."
}
```

Response:
```json
{
  "status": "success",
  "result_image": "data:image/jpeg;base64,..."
}
```

## Ücretsiz Kota
- İlk 2 milyon istek/ay ücretsiz
- İşlem süresi: ~15-20 saniye
- Bellek: 2GB
