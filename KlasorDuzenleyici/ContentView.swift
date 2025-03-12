import SwiftUI
import AppKit

// macOS 12 ve üzeri için tema yapısı
@available(macOS 12.0, *)
struct AppTheme {
    // Sabit renk tanımları
    static let primary = Color.indigo
    static let secondary = Color.teal
    static let success = Color.mint
    static let warning = Color.orange
    static let error = Color.red
    static let neutral = Color.gray
    
    // Özelleştirilebilir renkler
    static var customPrimary: Color = primary
    static var customSuccess: Color = success
    static var customAccent: Color = primary.opacity(0.7)
    
    static func applyTheme(primary: Color, success: Color, accent: Color) {
        customPrimary = primary
        customSuccess = success
        customAccent = accent
    }
}

// Eski macOS sürümleri için tema yapısı
struct LegacyTheme {
    // Sabit renk tanımları
    static let primary = Color.blue
    static let secondary = Color.purple
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let neutral = Color.gray
    
    // Özelleştirilebilir renkler
    static var customPrimary: Color = primary
    static var customSuccess: Color = success
    static var customAccent: Color = primary.opacity(0.7)
    
    static func applyTheme(primary: Color, success: Color, accent: Color) {
        customPrimary = primary
        customSuccess = success
        customAccent = accent
    }
}

// Ana görünüm
struct ContentView: View {
    @ObservedObject var folderModel = FolderModel.shared
    @State private var hoverSelect: Bool = false
    @State private var hoverOrganize: Bool = false
    @State private var hoverClear: Bool = false
    @Environment(\.colorScheme) var colorScheme // Koyu/Açık mod için
    
    var body: some View {
        if #available(macOS 12.0, *) {
            // Modern macOS 12.0+ tasarımı
            modernContentView
        } else {
            // Eski macOS sürümler için uyumlu tasarım
            legacyContentView
        }
    }
    
    // macOS 12.0+ için modern UI
    @available(macOS 12.0, *)
    var modernContentView: some View {
        ZStack {
            // Daha yumuşak gradyan
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? 
                        Color(NSColor.windowBackgroundColor).opacity(0.8) : 
                        AppTheme.customPrimary.opacity(0.1),
                    colorScheme == .dark ? 
                        Color(NSColor.windowBackgroundColor) : 
                        Color(NSColor.white)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Başlık alanı
                HStack(spacing: 15) {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 32))
                        .foregroundColor(AppTheme.customPrimary)
                        .shadow(color: AppTheme.customPrimary.opacity(0.4), radius: 4, x: 0, y: 2)
                    
                    Text("Klasör Düzenleyici")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                }
                .padding(.top, 10)
                
                // Seçili klasör bilgisi - iyileştirilmiş görünüm
                VStack(alignment: .leading, spacing: 10) {
                    Text("Seçilen Klasör")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        ZStack(alignment: .leading) {
                            // Daha iyi arka plan
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colorScheme == .dark ? 
                                      Color(NSColor.controlBackgroundColor) : 
                                      Color(NSColor.white))
                                .shadow(color: Color.black.opacity(0.15), radius: 3, x: 1, y: 1)
                                .frame(height: 42)
                            
                            HStack {
                                Image(systemName: folderModel.selectedFolderURL == nil ? "folder.badge.questionmark" : "folder.badge.checkmark")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(folderModel.selectedFolderURL == nil ? 
                                                     .gray : AppTheme.success)
                                
                                Text(folderModel.selectedFolderName)
                                    .font(.system(size: 14))
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .foregroundColor(folderModel.selectedFolderURL == nil ? .secondary : .primary)
                                
                                Spacer()
                                
                                // Seçili klasörü temizleme butonu
                                if folderModel.selectedFolderURL != nil {
                                    Button(action: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                            folderModel.clearSelectedFolder()
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 18))
                                            .symbolRenderingMode(.hierarchical)
                                            .foregroundColor(hoverClear ? .red.opacity(0.8) : .gray)
                                    }
                                    .buttonStyle(.plain)
                                    .scaleEffect(hoverClear ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: hoverClear)
                                    .help("Seçili klasörü temizle")
                                    .onHover { hovering in
                                        withAnimation {
                                            hoverClear = hovering
                                            if hovering {
                                                NSCursor.pointingHand.set()
                                            } else {
                                                NSCursor.arrow.set()
                                            }
                                        }
                                    }
                                    .padding(.trailing, 8)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                        }
                        
                        // Modern "Seç" butonu
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                folderModel.selectFolder()
                            }
                        }) {
                            Text("Seç")
                                .font(.system(size: 14, weight: .semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(minWidth: 70)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.customPrimary)
                        .scaleEffect(hoverSelect ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: hoverSelect)
                        .onHover { hovering in
                            withAnimation {
                                hoverSelect = hovering
                                if hovering {
                                    NSCursor.pointingHand.set()
                                } else {
                                    NSCursor.arrow.set()
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Dosyaları Düzenle butonu - modern tasarım
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        folderModel.organizeFiles()
                    }
                }) {
                    HStack(spacing: 14) {
                        Image(systemName: folderModel.isProcessing ? "arrow.clockwise" : "rectangle.stack.fill.badge.plus")
                            .font(.system(size: 18))
                            .symbolRenderingMode(.hierarchical)
                            .rotationEffect(folderModel.isProcessing ? .degrees(360) : .degrees(0))
                            .animation(folderModel.isProcessing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: folderModel.isProcessing)
                        
                        Text(folderModel.isProcessing ? "Düzenleniyor..." : "Dosyaları Düzenle")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(folderModel.selectedFolderURL == nil || folderModel.isProcessing ?
                      AppTheme.neutral.opacity(0.3) : AppTheme.success)
                .disabled(folderModel.selectedFolderURL == nil || folderModel.isProcessing)
                .scaleEffect((folderModel.selectedFolderURL == nil || folderModel.isProcessing) ? 1.0 : (hoverOrganize ? 1.02 : 1.0))
                .animation(.easeInOut(duration: 0.2), value: hoverOrganize)
                .onHover { hovering in
                    if !(folderModel.selectedFolderURL == nil || folderModel.isProcessing) {
                        hoverOrganize = hovering
                        if hovering {
                            NSCursor.pointingHand.set()
                        } else {
                            NSCursor.arrow.set()
                        }
                    }
                }
                .padding(.horizontal)
                
                // İlerleme durumu - geliştirilmiş görselleştirme
                VStack(spacing: 12) {
                    if folderModel.isProcessing {
                        VStack(spacing: 8) {
                            // İlerleme çubuğu eklendi
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.customPrimary))
                                .scaleEffect(0.8)
                                .padding(.bottom, 4)
                            
                            // Sayaç
                            Text("\(folderModel.processedFiles) dosya işlendi")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .animation(.easeInOut, value: folderModel.processedFiles)
                        }
                    }
                    
                    // Durum mesajı
                    HStack(spacing: 10) {
                        Image(systemName: statusSystemImage)
                            .font(.system(size: 16, weight: .medium))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(statusIconColor)
                        
                        Text(folderModel.statusMessage)
                            .font(.system(size: 13))
                            .foregroundColor(statusTextColor)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(statusBackgroundColor.opacity(colorScheme == .dark ? 0.2 : 0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(statusBackgroundColor.opacity(0.2), lineWidth: 1)
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
                // Kategori bilgileri - geliştirilmiş görsel tasarım
                VStack(alignment: .leading, spacing: 14) {
                    Text("Dosya Kategorileri")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 2)
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(alignment: .leading, spacing: 10) {
                            ModernCategoryItem(name: "Resimler", icon: "photo.fill", color: .blue, description: "JPG, PNG, GIF, SVG, HEIC")
                            ModernCategoryItem(name: "Belgeler", icon: "doc.fill", color: .orange, description: "PDF, DOC, DOCX, TXT, RTF")
                            ModernCategoryItem(name: "Videolar", icon: "film.fill", color: .red, description: "MP4, MOV, AVI, MKV")
                            ModernCategoryItem(name: "Sesler", icon: "music.note", color: .purple, description: "MP3, WAV, FLAC, M4A")
                            ModernCategoryItem(name: "Arşivler", icon: "archivebox.fill", color: .gray, description: "ZIP, RAR, 7Z, TAR, DMG")
                            ModernCategoryItem(name: "Kodlar", icon: "chevron.left.forwardslash.chevron.right", color: .teal, description: "HTML, CSS, JS, SWIFT, PY")
                            ModernCategoryItem(name: "Diğer", icon: "questionmark.folder.fill", color: .secondary, description: "Diğer tüm dosya türleri")
                        }
                        .padding(.horizontal, 4)
                    }
                    .frame(height: 150)
                    .background(colorScheme == .dark ? 
                                Color(NSColor.windowBackgroundColor).opacity(0.3) : 
                                Color(NSColor.windowBackgroundColor).opacity(0.2))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
                    )
                }
                .padding(.horizontal)
                
                Spacer(minLength: 20)
                
                // Alt bilgi - geliştirilmiş
                HStack {
                    Text("Klasör Düzenleyici v2.0")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Tema değiştirme butonu (örnek için)
                    Button(action: {
                        // Basit renk teması değişimi
                        withAnimation {
                            if AppTheme.customPrimary == AppTheme.primary {
                                // Alternatif tema
                                AppTheme.applyTheme(
                                    primary: .purple,
                                    success: .mint,
                                    accent: .purple.opacity(0.7)
                                )
                            } else {
                                // Varsayılan tema
                                AppTheme.applyTheme(
                                    primary: AppTheme.primary,
                                    success: AppTheme.success,
                                    accent: AppTheme.primary.opacity(0.7)
                                )
                            }
                        }
                    }) {
                        Image(systemName: "paintbrush.fill")
                            .font(.system(size: 12))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Temayı değiştir")
                }
                .padding(.horizontal)
                .padding(.bottom, 15)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 5)
        }
        .frame(width: 360, height: 580)
        .onAppear {
            print("ContentView görünür hale geldi - Klasör: \(folderModel.selectedFolderName)")
        }
    }
    
    // Eski macOS sürümleri için uyumlu UI
    var legacyContentView: some View {
        ZStack {
            Color(NSColor.windowBackgroundColor)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Başlık
                HStack {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.blue)
                    
                    Text("Klasör Düzenleyici")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .padding(.top, 10)
                
                // Seçili klasör bilgisi
                VStack(alignment: .leading, spacing: 8) {
                    Text("Seçilen Klasör")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(NSColor.textBackgroundColor))
                                .frame(height: 36)
                            
                            HStack {
                                Image(systemName: folderModel.selectedFolderURL == nil ? "folder.badge.questionmark" : "folder.badge.checkmark")
                                    .foregroundColor(folderModel.selectedFolderURL == nil ? .gray : .green)
                                
                                Text(folderModel.selectedFolderName)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .foregroundColor(folderModel.selectedFolderURL == nil ? .secondary : .primary)
                                
                                Spacer()
                                
                                // Seçili klasörü temizleme butonu - sadece klasör seçiliyken görünür
                                if folderModel.selectedFolderURL != nil {
                                    Button(action: {
                                        folderModel.clearSelectedFolder()
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 5)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .help("Seçili klasörü temizle")
                                    .onHover { hovering in
                                        if hovering {
                                            NSCursor.pointingHand.set()
                                        } else {
                                            NSCursor.arrow.set()
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                        }
                        
                        Button(action: {
                            folderModel.selectFolder()
                        }) {
                            Text("Seç")
                                .font(.system(size: 13, weight: .medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(hoverSelect ? LegacyTheme.customPrimary : LegacyTheme.customPrimary.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onHover { hovering in
                            hoverSelect = hovering
                        }
                    }
                }
                .padding(.horizontal)
                
                // Dosyaları Düzenle butonu
                Button(action: {
                    folderModel.organizeFiles()
                }) {
                    HStack {
                        Image(systemName: folderModel.isProcessing ? "arrow.clockwise" : "rectangle.stack.fill.badge.plus")
                            .font(.system(size: 15))
                            .rotationEffect(folderModel.isProcessing ? .degrees(360) : .degrees(0))
                            .animation(folderModel.isProcessing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: folderModel.isProcessing)
                        
                        Text(folderModel.isProcessing ? "Düzenleniyor..." : "Dosyaları Düzenle")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        (folderModel.selectedFolderURL == nil || folderModel.isProcessing) ?
                            LegacyTheme.neutral.opacity(0.3) :
                            (hoverOrganize ? LegacyTheme.customSuccess : LegacyTheme.customSuccess.opacity(0.8))
                    )
                    .foregroundColor((folderModel.selectedFolderURL == nil || folderModel.isProcessing) ? .gray : .white)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(folderModel.selectedFolderURL == nil || folderModel.isProcessing)
                .onHover { hovering in
                    if !(folderModel.selectedFolderURL == nil || folderModel.isProcessing) {
                        hoverOrganize = hovering
                    }
                }
                .padding(.horizontal)
                
                // İlerleme durumu
                VStack(spacing: 12) {
                    if folderModel.isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(0.8)
                            .padding(.bottom, 4)
                        
                        Text("\(folderModel.processedFiles) dosya işlendi")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    // Durum mesajı
                    HStack {
                        Image(systemName: legacyStatusSystemImage)
                            .foregroundColor(legacyStatusIconColor)
                        
                        Text(folderModel.statusMessage)
                            .font(.footnote)
                            .foregroundColor(legacyStatusTextColor)
                    }
                    .padding(10)
                    .background(legacyStatusBackgroundColor.opacity(0.15))
                    .cornerRadius(6)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
                // Kategori bilgileri
                VStack(alignment: .leading, spacing: 12) {
                    Text("Dosya Kategorileri")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(alignment: .leading, spacing: 8) {
                            LegacyCategoryItem(name: "Resimler", icon: "photo.fill", color: .blue)
                            LegacyCategoryItem(name: "Belgeler", icon: "doc.fill", color: .orange)
                            LegacyCategoryItem(name: "Videolar", icon: "film.fill", color: .red)
                            LegacyCategoryItem(name: "Sesler", icon: "music.note", color: .purple)
                            LegacyCategoryItem(name: "Arşivler", icon: "archivebox.fill", color: .gray)
                            LegacyCategoryItem(name: "Kodlar", icon: "chevron.left.forwardslash.chevron.right", color: .green)
                            LegacyCategoryItem(name: "Diğer", icon: "questionmark.folder.fill", color: .secondary)
                        }
                        .padding(.horizontal, 4)
                    }
                    .frame(height: 140)
                }
                .padding(.horizontal)
                
                Spacer(minLength: 20)
                
                // Alt bilgi
                HStack {
                    Text("Klasör Düzenleyici v2.0")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Tema değiştirme butonu
                    Button(action: {
                        // Basit renk teması değişimi
                        withAnimation {
                            if LegacyTheme.customPrimary == LegacyTheme.primary {
                                // Alternatif tema
                                LegacyTheme.applyTheme(
                                    primary: .purple,
                                    success: .orange,
                                    accent: .purple.opacity(0.7)
                                )
                            } else {
                                // Varsayılan tema
                                LegacyTheme.applyTheme(
                                    primary: LegacyTheme.primary,
                                    success: LegacyTheme.success,
                                    accent: LegacyTheme.primary.opacity(0.7)
                                )
                            }
                        }
                    }) {
                        Image(systemName: "paintbrush.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Temayı değiştir")
                }
                .padding(.horizontal)
                .padding(.bottom, 15)
            }
            .padding(.vertical, 10)
        }
        .frame(width: 340, height: 550)
        .onAppear {
            print("ContentView görünür hale geldi - Klasör: \(folderModel.selectedFolderName)")
        }
    }
    
    // Modern macOS 12.0+ için durum göstergeleri
    @available(macOS 12.0, *)
    var statusSystemImage: String {
        if folderModel.isProcessing {
            return "hourglass.circle.fill"
        } else if folderModel.statusMessage.contains("tamamlandı") {
            return "checkmark.circle.fill"
        } else if folderModel.statusMessage.contains("Hata") {
            return "exclamationmark.circle.fill"
        } else {
            return "info.circle.fill"
        }
    }
    
    @available(macOS 12.0, *)
    var statusIconColor: Color {
        if folderModel.isProcessing {
            return AppTheme.customPrimary
        } else if folderModel.statusMessage.contains("tamamlandı") {
            return AppTheme.success
        } else if folderModel.statusMessage.contains("Hata") {
            return AppTheme.warning
        } else {
            return .secondary
        }
    }
    
    @available(macOS 12.0, *)
    var statusTextColor: Color {
        if folderModel.statusMessage.contains("Hata") {
            return colorScheme == .dark ? AppTheme.warning.opacity(0.9) : AppTheme.warning
        } else if folderModel.statusMessage.contains("tamamlandı") {
            return colorScheme == .dark ? AppTheme.success.opacity(0.9) : AppTheme.success
        } else {
            return .primary
        }
    }
    
    @available(macOS 12.0, *)
    var statusBackgroundColor: Color {
        if folderModel.isProcessing {
            return AppTheme.customPrimary
        } else if folderModel.statusMessage.contains("tamamlandı") {
            return AppTheme.success
        } else if folderModel.statusMessage.contains("Hata") {
            return AppTheme.warning
        } else {
            return .secondary
        }
    }
    
    // Eski macOS sürümleri için durum göstergeleri
    var legacyStatusSystemImage: String {
        if folderModel.isProcessing {
            return "hourglass"
        } else if folderModel.statusMessage.contains("tamamlandı") {
            return "checkmark.circle"
        } else if folderModel.statusMessage.contains("Hata") {
            return "exclamationmark.triangle"
        } else {
            return "info.circle"
        }
    }
    
    var legacyStatusIconColor: Color {
        if folderModel.isProcessing {
            return LegacyTheme.customPrimary
        } else if folderModel.statusMessage.contains("tamamlandı") {
            return LegacyTheme.customSuccess
        } else if folderModel.statusMessage.contains("Hata") {
            return LegacyTheme.warning
        } else {
            return .secondary
        }
    }
    
    var legacyStatusTextColor: Color {
        if folderModel.statusMessage.contains("Hata") {
            return colorScheme == .dark ? LegacyTheme.warning.opacity(0.9) : LegacyTheme.warning
        } else if folderModel.statusMessage.contains("tamamlandı") {
            return colorScheme == .dark ? LegacyTheme.customSuccess.opacity(0.9) : LegacyTheme.customSuccess
        } else {
            return .primary
        }
    }
    
    var legacyStatusBackgroundColor: Color {
        if folderModel.isProcessing {
            return LegacyTheme.customPrimary
        } else if folderModel.statusMessage.contains("tamamlandı") {
            return LegacyTheme.customSuccess
        } else if folderModel.statusMessage.contains("Hata") {
            return LegacyTheme.warning
        } else {
            return .secondary
        }
    }
}

// macOS 12.0+ için geliştirilmiş kategori öğesi
@available(macOS 12.0, *)
struct ModernCategoryItem: View {
    let name: String
    let icon: String
    let color: Color
    let description: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // İkon kısmı
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(color)
            }
            
            // Metin kısmı
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(colorScheme == .dark ? 
                      Color(NSColor.controlBackgroundColor).opacity(0.3) : 
                      Color.white.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// Eski macOS sürümleri için kategori öğesi
struct LegacyCategoryItem: View {
    let name: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(color)
                .cornerRadius(6)
            
            Text(name)
                .font(.system(size: 13))
            
            Spacer()
        }
    }
} 