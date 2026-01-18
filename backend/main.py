from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
import os
import uuid
import base64
from gradio_client import Client
import uvicorn

app = FastAPI(title="Virtual Try-On API", version="1.0.0")

# CORS ayarları (Flutter'dan erişim için)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Geçici dosyalar için klasör
UPLOAD_DIR = "uploads"
RESULT_DIR = "results"
os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(RESULT_DIR, exist_ok=True)

# Hugging Face Gradio Space - Kolors Virtual Try-On
KOLORS_SPACE = "kwai-kolors/Kolors-Virtual-Try-On"

@app.get("/")
async def root():
    """API durumu kontrolü"""
    return {
        "status": "online",
        "message": "Virtual Try-On API is running!",
        "version": "1.0.0"
    }

@app.get("/health")
async def health_check():
    """Health check endpoint - Cloud Run için"""
    return {"status": "healthy"}

@app.post("/api/tryon")
async def virtual_tryon(
    person_image: UploadFile = File(...),
    garment_image: UploadFile = File(...)
):
    """
    Virtual Try-On işlemi
    
    Parameters:
    - person_image: Kişinin fotoğrafı
    - garment_image: Kıyafet fotoğrafı
    
    Returns:
    - result_image: Try-on sonucu
    """
    try:
        # Benzersiz ID oluştur
        request_id = str(uuid.uuid4())
        
        # Dosyaları kaydet
        person_path = os.path.join(UPLOAD_DIR, f"{request_id}_person.jpg")
        garment_path = os.path.join(UPLOAD_DIR, f"{request_id}_garment.jpg")
        
        with open(person_path, "wb") as f:
            f.write(await person_image.read())
        
        with open(garment_path, "wb") as f:
            f.write(await garment_image.read())
        
        print(f"✅ Resimler kaydedildi: {request_id}")
        
        # Kolors Virtual Try-On API'yi çağır
        print(f"📤 Kolors API'ye gönderiliyor...")
        client = Client(KOLORS_SPACE)
        
        result = client.predict(
            dict(background=person_path, layers=[], composite=None),  # person_image
            garment_path,  # garment_image
            False,  # is_checked
            True,  # is_checked_crop
            30,  # denoise_steps
            42,  # seed
            api_name="/tryon"
        )
        
        print(f"✅ Sonuç alındı: {result}")
        
        # Sonuç dosyasını kaydet
        result_path = os.path.join(RESULT_DIR, f"{request_id}_result.jpg")
        
        # Result tuple ise ilk elemanı al
        if isinstance(result, tuple):
            result_file = result[0]
        else:
            result_file = result
        
        # Dosyayı kopyala
        import shutil
        shutil.copy(result_file, result_path)
        
        # Geçici dosyaları temizle
        os.remove(person_path)
        os.remove(garment_path)
        
        print(f"✅ İşlem tamamlandı: {result_path}")
        
        # Sonuç resmini döndür
        return FileResponse(
            result_path,
            media_type="image/jpeg",
            filename=f"tryon_result_{request_id}.jpg"
        )
        
    except Exception as e:
        print(f"❌ Hata: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Virtual try-on failed: {str(e)}")

@app.post("/api/tryon-base64")
async def virtual_tryon_base64(data: dict):
    """
    Virtual Try-On işlemi (Base64 format)
    
    Body:
    {
        "person_image": "base64_string",
        "garment_image": "base64_string"
    }
    
    Returns:
    {
        "result_image": "base64_string"
    }
    """
    try:
        # Benzersiz ID oluştur
        request_id = str(uuid.uuid4())
        
        # Base64'ten decode et
        person_data = base64.b64decode(data["person_image"].split(",")[-1] if "," in data["person_image"] else data["person_image"])
        garment_data = base64.b64decode(data["garment_image"].split(",")[-1] if "," in data["garment_image"] else data["garment_image"])
        
        # Dosyaları kaydet
        person_path = os.path.join(UPLOAD_DIR, f"{request_id}_person.jpg")
        garment_path = os.path.join(UPLOAD_DIR, f"{request_id}_garment.jpg")
        
        with open(person_path, "wb") as f:
            f.write(person_data)
        
        with open(garment_path, "wb") as f:
            f.write(garment_data)
        
        print(f"✅ Base64 resimleri kaydedildi: {request_id}")
        
        # Kolors Virtual Try-On API'yi çağır
        print(f"📤 Kolors API'ye gönderiliyor...")
        client = Client(KOLORS_SPACE)
        
        result = client.predict(
            dict(background=person_path, layers=[], composite=None),
            garment_path,
            False,
            True,
            30,
            42,
            api_name="/tryon"
        )
        
        print(f"✅ Sonuç alındı")
        
        # Result tuple ise ilk elemanı al
        if isinstance(result, tuple):
            result_file = result[0]
        else:
            result_file = result
        
        # Sonucu base64'e çevir
        with open(result_file, "rb") as f:
            result_base64 = base64.b64encode(f.read()).decode()
        
        # Geçici dosyaları temizle
        os.remove(person_path)
        os.remove(garment_path)
        
        return {
            "status": "success",
            "result_image": f"data:image/jpeg;base64,{result_base64}"
        }
        
    except Exception as e:
        print(f"❌ Hata: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Virtual try-on failed: {str(e)}")

if __name__ == "__main__":
    # Local test için
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)
