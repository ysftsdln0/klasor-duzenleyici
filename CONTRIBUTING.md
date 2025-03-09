# Katkıda Bulunma Rehberi

Klasör Düzenleyici projesine katkıda bulunmak istediğiniz için teşekkür ederiz! Bu belge, projeye nasıl katkıda bulunabileceğinizi açıklar.

## Geliştirme Ortamı

1. Bu projeyi fork edin ve bilgisayarınıza klonlayın:
   ```bash
   git clone https://github.com/KULLANICI_ADINIZ/klasor-duzenleyici.git
   cd klasor-duzenleyici
   ```

2. Uygulamayı derleyin:
   ```bash
   swift build
   ```

3. Xcode projesi oluşturmak için:
   ```bash
   swift package generate-xcodeproj
   open KlasorDuzenleyici.xcodeproj
   ```

## Kod Stili

- Kodunuzun mevcut kod stiliyle uyumlu olmasına dikkat edin
- Değişkenler ve fonksiyonlar için anlamlı isimler kullanın
- Karmaşık kod bloklarını açıklayan yorumlar ekleyin
- Türkçe kullanıcı arayüzü metinleri için doğru dil kurallarına uyun

## Pull Request Süreci

1. Kendi feature branch'inizi oluşturun:
   ```bash
   git checkout -b feature/amazing-feature
   ```

2. Değişikliklerinizi commit edin:
   ```bash
   git commit -m 'Add some amazing feature'
   ```

3. Branch'inizi push edin:
   ```bash
   git push origin feature/amazing-feature
   ```

4. GitHub üzerinden Pull Request açın

## Hata Raporları

Bir hata bulduğunuzda, lütfen aşağıdaki bilgileri içeren bir GitHub issue açın:

- Hatanın açık bir açıklaması
- Hatayı yeniden oluşturmak için adımlar
- Beklenen davranış ve gerçekleşen davranış
- macOS sürümünüz
- Uygulama sürümünüz

## Özellik İstekleri

Yeni bir özellik önermek için, lütfen aşağıdaki bilgileri içeren bir GitHub issue açın:

- Özelliğin açık bir açıklaması
- Bu özelliğin neden faydalı olacağına dair bir açıklama
- Mümkünse, özelliğin nasıl uygulanabileceğine dair öneriler

## Lisans

Projeye katkıda bulunarak, katkılarınızın projenin [MIT Lisansı](LICENSE) altında lisanslanacağını kabul etmiş olursunuz. 