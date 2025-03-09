import SwiftUI
import Combine

class FolderModel: ObservableObject {
    @Published var selectedFolderURL: URL? = nil
    @Published var selectedFolderName: String = "Klasör seçilmedi"
    @Published var isProcessing = false
    @Published var statusMessage = "Klasör seçilmedi"
    @Published var processedFiles = 0
    @Published var isPanelShown = false // Dosya seçim paneli görünürlüğünü takip etmek için bayrak
    
    static let shared = FolderModel()
    
    // Dosya uzantılarını kategorilere eşleyen sözlük
    private let extensionCategories: [String: String] = [
        // Resimler
        "jpg": "Resimler",
        "jpeg": "Resimler",
        "png": "Resimler",
        "gif": "Resimler",
        "svg": "Resimler",
        "webp": "Resimler",
        "heic": "Resimler",
        "heif": "Resimler",
        "bmp": "Resimler",
        "tiff": "Resimler",
        
        // Belgeler
        "pdf": "Belgeler",
        "doc": "Belgeler",
        "docx": "Belgeler",
        "ppt": "Belgeler",
        "pptx": "Belgeler",
        "xls": "Belgeler",
        "xlsx": "Belgeler",
        "txt": "Belgeler",
        "rtf": "Belgeler",
        "pages": "Belgeler",
        "numbers": "Belgeler",
        "keynote": "Belgeler",
        "odt": "Belgeler",
        "ods": "Belgeler",
        "odp": "Belgeler",
        
        // Videolar
        "mp4": "Videolar",
        "mov": "Videolar",
        "avi": "Videolar",
        "mkv": "Videolar",
        "wmv": "Videolar",
        "flv": "Videolar",
        "webm": "Videolar",
        "m4v": "Videolar",
        
        // Sesler
        "mp3": "Sesler",
        "wav": "Sesler",
        "ogg": "Sesler",
        "aac": "Sesler",
        "flac": "Sesler",
        "m4a": "Sesler",
        
        // Arşivler
        "zip": "Arşivler",
        "rar": "Arşivler",
        "7z": "Arşivler",
        "tar": "Arşivler",
        "gz": "Arşivler",
        "iso": "Arşivler",
        "dmg": "Arşivler",
        
        // Kodlar
        "html": "Kodlar",
        "css": "Kodlar",
        "js": "Kodlar",
        "json": "Kodlar",
        "xml": "Kodlar",
        "swift": "Kodlar",
        "java": "Kodlar",
        "c": "Kodlar",
        "cpp": "Kodlar",
        "py": "Kodlar",
        "php": "Kodlar",
        "rb": "Kodlar",
        "go": "Kodlar",
        "ts": "Kodlar",
        "sh": "Kodlar",
        "bat": "Kodlar",
        "sql": "Kodlar"
    ]
    
    private init() {}
    
    func selectFolder() {
        print("Klasör seçme fonksiyonu başlatıldı")
        
        DispatchQueue.main.async {
            // Panel görünürlük bayrağını true yap
            self.isPanelShown = true
            
            let panel = NSOpenPanel()
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
            panel.allowsMultipleSelection = false
            panel.message = "Lütfen düzenlemek istediğiniz klasörü seçin"
            panel.prompt = "Klasörü Seç"
            
            NSApp.activate(ignoringOtherApps: true)
            
            panel.beginSheetModal(for: NSApp.keyWindow ?? NSWindow()) { [weak self] response in
                guard let self = self else { return }
                
                // Panel kapandığında bayrağı false yap
                DispatchQueue.main.async {
                    self.isPanelShown = false
                }
                
                if response == .OK, let url = panel.url {
                    print("Klasör seçildi: \(url.path)")
                    
                    DispatchQueue.main.async {
                        self.selectedFolderURL = url
                        self.selectedFolderName = url.lastPathComponent
                        self.statusMessage = "Klasör seçildi: \(url.lastPathComponent)"
                        print("Durum güncellendi - Klasör: \(self.selectedFolderName)")
                    }
                } else {
                    print("Klasör seçimi iptal edildi veya seçilemedi")
                }
            }
        }
    }
    
    func organizeFiles() {
        guard let folderURL = selectedFolderURL else { return }
        
        // UI güncellemelerini ana iş parçacığında yap
        DispatchQueue.main.async {
            self.isProcessing = true
            self.statusMessage = "Dosyalar düzenleniyor..."
            self.processedFiles = 0
        }
        
        DispatchQueue.global(qos: .background).async {
            do {
                // Kategoriler için alt klasörler oluştur
                let uniqueCategories = Set(self.extensionCategories.values)
                let fileManager = FileManager.default
                
                for category in uniqueCategories {
                    let categoryFolderURL = folderURL.appendingPathComponent(category, isDirectory: true)
                    if !fileManager.fileExists(atPath: categoryFolderURL.path) {
                        try fileManager.createDirectory(at: categoryFolderURL, withIntermediateDirectories: true)
                    }
                }
                
                // "Diğer" klasörü oluştur
                let otherFolderURL = folderURL.appendingPathComponent("Diğer", isDirectory: true)
                if !fileManager.fileExists(atPath: otherFolderURL.path) {
                    try fileManager.createDirectory(at: otherFolderURL, withIntermediateDirectories: true)
                }
                
                // Dosyaları tara ve kategorilere taşı
                let contentURLs = try fileManager.contentsOfDirectory(
                    at: folderURL,
                    includingPropertiesForKeys: nil,
                    options: [.skipsHiddenFiles]
                )
                
                // İşlenen dosya sayısını ana iş parçacığına döndürmek için yerel değişken kullan
                var localProcessedFiles = 0
                
                for fileURL in contentURLs {
                    // Sadece düzenli dosyaları işle, klasörleri değil
                    var isDirectory: ObjCBool = false
                    if fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory), !isDirectory.boolValue {
                        let fileExtension = fileURL.pathExtension.lowercased()
                        
                        // Dosya uzantısına göre kategori belirle
                        let targetFolderName: String
                        if fileExtension.isEmpty {
                            targetFolderName = "Diğer"
                        } else if let category = self.extensionCategories[fileExtension] {
                            targetFolderName = category
                        } else {
                            targetFolderName = "Diğer"
                        }
                        
                        // Zaten kategori klasörlerinin içinde mi kontrolü
                        if ["Resimler", "Belgeler", "Videolar", "Sesler", "Arşivler", "Kodlar", "Diğer"].contains(fileURL.deletingLastPathComponent().lastPathComponent) {
                            continue
                        }
                        
                        let targetFolderURL = folderURL.appendingPathComponent(targetFolderName, isDirectory: true)
                        
                        // Dosyayı taşı
                        let targetFileURL = targetFolderURL.appendingPathComponent(fileURL.lastPathComponent)
                        try fileManager.moveItem(at: fileURL, to: targetFileURL)
                        
                        // Yerel değişkeni güncelle
                        localProcessedFiles += 1
                        
                        // Her 5 dosyada bir ana iş parçacığına durumu bildir
                        if localProcessedFiles % 5 == 0 {
                            DispatchQueue.main.async {
                                self.processedFiles = localProcessedFiles
                            }
                        }
                    }
                }
                
                // İşlem bittiğinde sonuçları ana iş parçacığında güncelle
                DispatchQueue.main.async {
                    self.processedFiles = localProcessedFiles
                    self.isProcessing = false
                    self.statusMessage = "İşlem tamamlandı: \(localProcessedFiles) dosya düzenlendi."
                }
            } catch {
                // Hata durumunda ana iş parçacığında güncelle
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.statusMessage = "Hata oluştu: \(error.localizedDescription)"
                }
            }
        }
    }
} 