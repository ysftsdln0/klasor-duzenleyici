#!/bin/bash

# Hata durumunda script'i durdur
set -e

echo "KlasorDuzenleyici DMG oluşturucu"
echo "--------------------------------"

# Scriptleri çalıştırılabilir yap
chmod +x ./icon.sh
chmod +x ./create-background.sh

# Klasörleri temizle
echo "Eski dosyalar temizleniyor..."
rm -rf ./build/KlasorDuzenleyici.app
mkdir -p ./build

# Önceki DMG dosyalarını temizle
echo "Önceki DMG dosyaları temizleniyor..."
rm -f ./build/KlasorDuzenleyici.dmg
rm -f ./build/tmp.dmg

# Release modunda derle
echo "Uygulama derleniyor..."
swift build -c release

# Info.plist dosyasını kontrol et
if [ ! -f "./KlasorDuzenleyici/Info.plist" ]; then
    echo "Hata: Info.plist dosyası bulunamadı!"
    exit 1
fi

# Uygulama paketini oluştur
echo "Uygulama paketi oluşturuluyor..."

# Klasör yapısını oluştur
mkdir -p "./build/KlasorDuzenleyici.app/Contents/MacOS"
mkdir -p "./build/KlasorDuzenleyici.app/Contents/Resources"

# Çalıştırılabilir dosyayı kopyala
cp ".build/release/KlasorDuzenleyici" "./build/KlasorDuzenleyici.app/Contents/MacOS/"

# Info.plist dosyasını kopyala
cp "./KlasorDuzenleyici/Info.plist" "./build/KlasorDuzenleyici.app/Contents/"

# PkgInfo dosyası oluştur
echo "APPL????" > "./build/KlasorDuzenleyici.app/Contents/PkgInfo"

# İkon oluştur
./icon.sh

# DMG arkaplan görüntüsü oluştur
./create-background.sh

# DMG için profesyonel düzen oluştur
echo "DMG içeriği hazırlanıyor..."
mkdir -p ./build/dmg-contents

# DMG içeriği oluştur
rm -rf ./build/dmg-contents/* # Önceki içeriği temizle
cp -R ./build/KlasorDuzenleyici.app ./build/dmg-contents/
ln -s /Applications ./build/dmg-contents/
mkdir -p ./build/dmg-contents/.background
cp ./build/dmg-resources/background.png ./build/dmg-contents/.background/

# Simgelerin konumlarını ayarla
echo "DMG düzeni hazırlanıyor..."

# Geçici DMG oluştur
tmp_dmg="./build/tmp.dmg"
final_dmg="./build/KlasorDuzenleyici.dmg"

# Geçici DMG
hdiutil create -volname "KlasorDuzenleyici" -srcfolder ./build/dmg-contents -ov -format UDRW "$tmp_dmg"

# DMG'yi bağla
echo "DMG özelleştiriliyor..."
device=$(hdiutil attach -readwrite -noverify -noautoopen "$tmp_dmg" | grep -E '^/dev/' | sed 1q | awk '{print $1}')

# Biraz bekle - volume'un tam olarak bağlanmasını bekle
sleep 2

# Volume adını al
volume_name="/Volumes/KlasorDuzenleyici"

# DMG görünümünü ayarla
echo '
   tell application "Finder"
     tell disk "KlasorDuzenleyici"
           open
           set current view of container window to icon view
           set toolbar visible of container window to false
           set statusbar visible of container window to false
           set the bounds of container window to {400, 100, 1000, 500}
           set theViewOptions to the icon view options of container window
           set arrangement of theViewOptions to not arranged
           set icon size of theViewOptions to 72
           set background picture of theViewOptions to file ".background:background.png"
           
           -- Uygulamanın konumunu ayarla
           set position of item "KlasorDuzenleyici.app" of container window to {150, 200}
           
           -- Applications kısayolunun konumunu ayarla
           set position of item "Applications" of container window to {450, 200}
           
           update without registering applications
           delay 5
           close
     end tell
   end tell
' | osascript

# Değişiklikleri kaydet
sync

# DMG'yi ayır
hdiutil detach "$device"

# Son DMG oluştur
echo "Final DMG oluşturuluyor..."
rm -f "$final_dmg" # Eğer varsa önceki final DMG'yi sil
hdiutil convert "$tmp_dmg" -format UDZO -o "$final_dmg"

# Geçici DMG'yi sil
rm -f "$tmp_dmg"

echo "İşlem tamamlandı!"
echo "DMG dosyası: ./build/KlasorDuzenleyici.dmg"
echo "Uygulamanız: ./build/KlasorDuzenleyici.app" 