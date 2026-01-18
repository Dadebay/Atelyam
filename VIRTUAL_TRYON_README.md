# 🎨 Atelyam - AI Virtual Try-On Özelliği (ÜCRETSİZ)

## 📝 Özellik Açıklaması

Bu özellik, kullanıcıların uygulamadaki kıyafetleri sanal olarak kendi üzerlerinde deneyebilmelerine olanak tanır. **TAMAMEN ÜCRETSİZ** Hugging Face AI servisi kullanarak, kullanıcının fotoğrafına seçilen kıyafeti gerçekçi bir şekilde yerleştirir.

## 🚀 Kurulum Adımları

### 1. Hugging Face API Token Alma (ÜCRETSİZ)

1. [Hugging Face](https://huggingface.co/join) adresine gidin ve ücretsiz hesap oluşturun
2. [Settings > Access Tokens](https://huggingface.co/settings/tokens) sayfasından API tokeninizi oluşturun
3. **Tamamen ücretsiz**, limit yok!

### 2. API Token Ekleme

`lib/app/data/service/virtual_tryon_service.dart` dosyasını açın ve API tokeninizi ekleyin:

```dart
static const String _huggingFaceToken = 'BURAYA_TOKENINIZI_YAPIŞTIRIN';
```

### 3. Gerekli İzinler

#### iOS (ios/Runner/Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>Kıyafetleri üzerinizde görmek için kameranıza erişmemiz gerekiyor</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Fotoğraf seçmek için galeri erişimi gerekiyor</string>
```

#### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

## 💡 Kullanım

### 1. Ürün Detay Sayfasından Erişim

- Herhangi bir ürün kartına tıklayın
- Ürün detay sayfasının altında "Üzerimde Dene (AI)" butonunu göreceksiniz
- Butona tıklayarak sanal giyim deneme ekranına geçin

### 2. Fotoğraf Yükleme

İki seçeneğiniz var:
- **Galeriden Seç**: Telefonunuzdaki mevcut bir fotoğrafı seçin
- **Fotoğraf Çek**: Kamera ile yeni bir fotoğraf çekin

### 3. Deneme İşlemi

- Fotoğrafınızı seçtikten sonra "Üzerimde Dene" butonuna tıklayın
- AI işlemi 30-60 saniye sürebilir
- İşlem tamamlandığında sonuç gösterilir

### 4. Sonuç İşlemleri

- **Kaydet**: Oluşturulan resmi cihazınıza kaydedin
- **Paylaş**: Sosyal medyada paylaşın (yakında)

## 📁 Dosya Yapısı

```
lib/app/
├── data/
│   └── service/
│       └── virtual_tryon_service.dart         # AI servis entegrasyonu
├── modules/
│   ├── virtual_tryon/
│   │   ├── controllers/
│   │   │   └── virtual_tryon_controller.dart  # Kontrol mantığı
│   │   └── views/
│   │       └── virtual_tryon_view.dart        # Kullanıcı arayüzü
│   └── product_profil_view/
│       └── views/
│           └── product_profil_view.dart       # Güncellenmiş ürün detay
```

## 🔧 Teknik Detaylar

### Kullanılan AI Modeli (ÜCRETSİZ)

- **Model**: IDM-VTON (Image-based Virtual Try-On Network)
- **Sağlayıcı**: Hugging Face Inference API ✅ ÜCRETSIZ
- **Model**: yisol/IDM-VTON
- **Özellikler**:
  - Tamamen ücretsiz kullanım
  - Türkmenistan'dan erişilebilir
  - Yüksek kaliteli görüntü üretimi
  - Kıyafet detaylarını koruma
  - Vücut pozisyonuna uyum

### API Kullanımı

1. Kullanıcı ve kıyafet resimleri byte array'e çevrilir
2. Hugging Face Inference API'ye istek gönderilir
3. İşlem tamamlanır (ilk seferde model yüklenmesi 20 saniye sürebilir)
4. Sonuç resmi yerel olarak kaydedilir ve gösterilir

## 🎯 Özellik Geliştirmeleri

### Şu Anki Özellikler ✅
- [x] Galeriden fotoğraf seçme
- [x] Kamera ile fotoğraf çekme
- [x] AI ile kıyafet deneme
- [x] Sonuç gösterimi
- [x] Yükleme durumu göstergesi

### Gelecek Geliştirmeler 🚀
- [ ] Sonucu kaydetme özelliği
- [ ] Sosyal medya paylaşımı
- [ ] Deneme geçmişi
- [ ] Çoklu kıyafet deneme (outfit kombinasyonları)
- [ ] Farklı AI modelleri desteği (Hugging Face, Google Try-On vb.)
- [ ] Offline önbellek
- [ ] Daha hızlı işlem için optimizasyon

## ✅ TAMAMEN ÜCRETSİZ!

- **Hugging Face Inference API**: 100% ücretsiz, sınırsız kullanım
- Kredi kartı gerektirmez
- Türkmenistan'dan erişilebilir
- Hesap oluşturma: Ücretsiz
- API kullanımı: Ücretsiz

### Avantajlar
- ✅ Ücretsiz
- ✅ Erişim kısıtlaması yok
- ✅ Kolay kurulum
- ✅ Yüksek kalite
- ⏳ İlk kullanımda model yüklemesi 20 saniye sürebilir
2. **API isteği başarısız" hatası
- API tokeninizi kontrol edin
- İnternet bağlantınızı kontrol edin
- Hugging Face servisinin çalıştığını kontrol edin

### "Model yükleniyor" mesajı
- İlk kullanımda model yüklemesi 20-30 saniye sürebilir
- Sabırla bekleyin, otomatik olarak tekrar deneyecektir

### Kötü kaliteli sonuçlar
- Daha iyi ışıklandırmalı fotoğraf kullanın
- Vücudun tam görüldüğü fotoğraf seçin (tam boy fotoğraf tercih edin)
- Yüksek çözünürlüklü kıyafet resimleri kullanın
- Arka plan sade olsun

### Türkmenistan'dan erişim sorunu
- Hugging Face normal erişilebilirdir
- VHugging Face IDM-VTON Model](https://huggingface.co/yisol/IDM-VTON)
- [Hugging Face API Documentation](https://huggingface.co/docs/api-inference/index)
- [IDM-VTON Paper](https://arxiv.org/abs/2403.05139)
- [Hugging Face Space](https://huggingface.co/spaces/yisol/IDM-VTON)

## 🌍 Türkmenistan İçin Önemli Notlar

✅ **Erişilebilirlik**: Hugging Face Türkmenistan'dan erişilebilir
✅ **Ücretsiz**: Kredi kartı gerektirmez, tamamen ücretsiz
✅ **Kolay Kurulum**: Sadece ücretsiz hesap ve token gerekir
✅ **VPN Gerekmez**: Doğrudan erişim mevcut
### Kötü kaliteli sonuçlar
- Daha iyi ışıklandırmalı fotoğraf kullanın
- Vücudun tam görüldüğü fotoğraf seçin
- Yüksek çözünürlüklü kıyafet resimleri kullanın

## 📚 Kaynaklar

- [Replicate IDM-VTON Model](https://replicate.com/yisol/idm-vton)
- [IDM-VTON Paper](https://arxiv.org/abs/2403.05139)
- [Hugging Face Space](https://huggingface.co/spaces/yisol/IDM-VTON)

## 📧 Destek

Sorularınız için GitHub Issues kullanabilirsiniz.

---

**Not**: Bu özellik AI teknolojisi kullandığı için sonuçlar değişkenlik gösterebilir. En iyi sonuçlar için kaliteli ve net fotoğraflar kullanın.
