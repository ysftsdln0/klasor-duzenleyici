#!/bin/bash

# DMG arkaplan görüntüsü oluşturma scripti

echo "DMG arkaplan görüntüsü oluşturuluyor..."

# Geçici klasör oluştur
mkdir -p dmgbuild

# SVG arkaplan resmi oluştur
cat > dmgbuild/background.svg << EOF
<svg width="600" height="400" xmlns="http://www.w3.org/2000/svg">
  <!-- Arkaplan -->
  <rect width="600" height="400" fill="#f0f0f0"/>
  
  <!-- Mavi gradient -->
  <linearGradient id="blueGradient" x1="0%" y1="0%" x2="100%" y2="100%">
    <stop offset="0%" stop-color="#4a86e8"/>
    <stop offset="100%" stop-color="#2a56a8"/>
  </linearGradient>
  <rect width="600" height="400" fill="url(#blueGradient)" opacity="0.3"/>
  
  <!-- Desen -->
  <rect width="600" height="400" fill="url(#pattern)" opacity="0.2"/>
  
  <!-- Logo alanı sol taraf -->
  <circle cx="150" cy="200" r="110" fill="#ffffff" opacity="0.9"/>
  
  <!-- Logo alanı sağ taraf -->
  <circle cx="450" cy="200" r="110" fill="#ffffff" opacity="0.9"/>
  
  <!-- Ok sol->sağ -->
  <path d="M220 200 L380 200 M350 170 L380 200 L350 230" 
        stroke="#4a86e8" stroke-width="6" fill="none" stroke-linecap="round"/>
  
  <!-- Metin -->
  <text x="300" y="320" font-family="Arial" font-size="16" font-weight="bold" fill="#333" text-anchor="middle">Kurulum için sürükleyiniz</text>
  
  <!-- Simgeler -->
  <text x="150" y="200" font-family="Arial" font-size="60" fill="#4a86e8" text-anchor="middle" dominant-baseline="middle">📁</text>
  <text x="450" y="200" font-family="Arial" font-size="60" fill="#4a86e8" text-anchor="middle" dominant-baseline="middle">📂</text>
</svg>
EOF

# SVG'yi PNG'ye dönüştür
if command -v rsvg-convert > /dev/null; then
    rsvg-convert dmgbuild/background.svg -o dmgbuild/background.png -w 600 -h 400
    
    # Başarılı olup olmadığını kontrol et
    if [ ! -f dmgbuild/background.png ]; then
        echo "SVG dönüştürme başarısız. Alternatif yöntem deneniyor..."
        convert dmgbuild/background.svg dmgbuild/background.png 2>/dev/null || {
            echo "SVG dönüştürme başarısız. Basit bir arkaplan oluşturuluyor..."
            # Basit bir PNG oluştur
            convert -size 600x400 gradient:blue-lightblue -gravity center \
                -font Arial -pointsize 30 -annotate 0 "Kurulum için sürükleyiniz" \
                dmgbuild/background.png 2>/dev/null || {
                echo "Görüntü oluşturulamadı. Arkaplan olmadan devam ediliyor."
                touch dmgbuild/background.png
            }
        }
    fi
else
    echo "rsvg-convert bulunamadı. Alternatif yöntem deneniyor..."
    # ImageMagick veya başka bir alternatif aracı dene
    convert dmgbuild/background.svg dmgbuild/background.png 2>/dev/null || {
        echo "SVG dönüştürme başarısız. Basit bir arkaplan oluşturuluyor..."
        # Basit bir PNG oluştur
        convert -size 600x400 gradient:blue-lightblue -gravity center \
            -font Arial -pointsize 30 -annotate 0 "Kurulum için sürükleyiniz" \
            dmgbuild/background.png 2>/dev/null || {
            echo "Görüntü oluşturulamadı. Arkaplan olmadan devam ediliyor."
            touch dmgbuild/background.png
        }
    }
fi

# Arkaplan görüntüsünü build klasörüne kopyala
mkdir -p ./build/dmg-resources
cp dmgbuild/background.png ./build/dmg-resources/

# Geçici dosyaları temizle
rm -rf dmgbuild

echo "DMG arkaplan görüntüsü oluşturma tamamlandı." 