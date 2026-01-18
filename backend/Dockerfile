# Python 3.11 slim image kullan
FROM python:3.11-slim

# Çalışma dizini
WORKDIR /app

# Sistem bağımlılıkları
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Python bağımlılıkları
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Uygulama kodunu kopyala
COPY main.py .

# Port
ENV PORT=8080
EXPOSE 8080

# Uygulamayı başlat
CMD ["python", "main.py"]
