#!/bin/bash

# Simge oluşturma scripti

echo "Klasör Düzenleyici simgesi oluşturuluyor..."

# Hazır .icns dosyası kontrolü
if [ -f "AppIcon.icns" ]; then
    echo "Hazır .icns dosyası bulundu, bu dosya doğrudan kullanılacak."
    mkdir -p ./build/KlasorDuzenleyici.app/Contents/Resources
    cp AppIcon.icns ./build/KlasorDuzenleyici.app/Contents/Resources/AppIcon.icns
    echo "Simge kopyalama tamamlandı!"
    exit 0
fi

# Geçici klasör oluştur
mkdir -p iconbuild/KlasorDuzenleyici.iconset

# Basit bir komut ile folder simgesi kullanarak geçici bir PNG oluştur
sips -s format png /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/FolderIcon.icns --out iconbuild/folder_icon.png > /dev/null 2>&1 || {
    echo "Sistem klasör simgesi kopyalanamadı, varsayılan bir simge kullanılacak."
    
    # Varsayılan bir png dosyası oluştur
    cat > iconbuild/template.svg << EOF
<svg width="1024" height="1024" xmlns="http://www.w3.org/2000/svg">
  <rect width="1024" height="1024" fill="#f0f0f0" rx="128" ry="128"/>
  <rect x="128" y="256" width="768" height="640" fill="#4a86e8" rx="64" ry="64"/>
  <rect x="128" y="256" width="768" height="128" fill="#2a56a8"/>
  <path d="M256 448 L512 640 L768 448" stroke="#f0f0f0" stroke-width="48" fill="none"/>
</svg>
EOF
    
    # SVG'yi PNG'ye dönüştür (eğer rsvg-convert yüklüyse)
    if command -v rsvg-convert > /dev/null; then
        rsvg-convert iconbuild/template.svg -o iconbuild/folder_icon.png
    else
        echo "rsvg-convert bulunamadı, simge oluşturma atlanıyor."
        exit 1
    fi
}

# Farklı boyutlarda simgeler oluştur
sizes=(16 32 64 128 256 512 1024)
for size in "${sizes[@]}"; do
    # Normal boyut
    sips -z $size $size iconbuild/folder_icon.png --out iconbuild/KlasorDuzenleyici.iconset/icon_${size}x${size}.png > /dev/null 2>&1
    
    # @2x boyutu (Retina ekranlar için)
    if [ $size -lt 512 ]; then
        double_size=$((size * 2))
        sips -z $double_size $double_size iconbuild/folder_icon.png --out iconbuild/KlasorDuzenleyici.iconset/icon_${size}x${size}@2x.png > /dev/null 2>&1
    fi
done

# iconutil ile .icns dosyası oluştur
mkdir -p ./build/KlasorDuzenleyici.app/Contents/Resources
iconutil -c icns iconbuild/KlasorDuzenleyici.iconset -o ./build/KlasorDuzenleyici.app/Contents/Resources/AppIcon.icns

# Geçici dosyaları temizle
rm -rf iconbuild

echo "Simge oluşturma tamamlandı!" 