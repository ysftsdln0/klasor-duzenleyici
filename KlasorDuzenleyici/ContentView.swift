import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var folderModel = FolderModel.shared
    @State private var hoverSelect: Bool = false
    @State private var hoverOrganize: Bool = false
    
    var body: some View {
        ZStack {
            // Arka plan rengi
            Color(NSColor.windowBackgroundColor)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                // Başlık alanı
                HStack {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                    
                    Text("Klasör Düzenleyici")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .padding(.top, 16)
                
                // Seçili klasör bilgisi
                VStack(alignment: .leading, spacing: 8) {
                    Text("Seçilen Klasör")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.textBackgroundColor))
                                .frame(height: 36)
                            
                            HStack {
                                Image(systemName: folderModel.selectedFolderURL == nil ? "folder.badge.questionmark" : "folder.badge.checkmark")
                                    .foregroundColor(folderModel.selectedFolderURL == nil ? .gray : .green)
                                
                                Text(folderModel.selectedFolderName)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .foregroundColor(folderModel.selectedFolderURL == nil ? .secondary : .primary)
                                
                                Spacer()
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
                                .background(hoverSelect ? Color.blue : Color.blue.opacity(0.8))
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
                            Color.gray.opacity(0.3) :
                            (hoverOrganize ? Color.green : Color.green.opacity(0.8))
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
                    }
                    
                    // Durum mesajı
                    HStack {
                        Image(systemName: statusSystemImage)
                            .foregroundColor(statusIconColor)
                        
                        Text(folderModel.statusMessage)
                            .font(.footnote)
                            .foregroundColor(statusTextColor)
                    }
                    .padding(10)
                    .background(statusBackgroundColor.opacity(0.15))
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
                            CategoryItem(name: "Resimler", icon: "photo.fill", color: .blue)
                            CategoryItem(name: "Belgeler", icon: "doc.fill", color: .orange)
                            CategoryItem(name: "Videolar", icon: "film.fill", color: .red)
                            CategoryItem(name: "Sesler", icon: "music.note", color: .purple)
                            CategoryItem(name: "Arşivler", icon: "archivebox.fill", color: .gray)
                            CategoryItem(name: "Kodlar", icon: "chevron.left.forwardslash.chevron.right", color: .green)
                            CategoryItem(name: "Diğer", icon: "questionmark.folder.fill", color: .secondary)
                        }
                        .padding(.horizontal, 4)
                    }
                    .frame(height: 120)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Alt bilgi
                Text("Klasör Düzenleyici v1.0")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
            }
            .padding(.vertical, 10)
        }
        .frame(width: 340, height: 480)
        .onAppear {
            print("ContentView görünür hale geldi - Klasör: \(folderModel.selectedFolderName)")
        }
    }
    
    // Duruma göre ikon ve renkler
    var statusSystemImage: String {
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
    
    var statusIconColor: Color {
        if folderModel.isProcessing {
            return .blue
        } else if folderModel.statusMessage.contains("tamamlandı") {
            return .green
        } else if folderModel.statusMessage.contains("Hata") {
            return .red
        } else {
            return .secondary
        }
    }
    
    var statusTextColor: Color {
        if folderModel.statusMessage.contains("Hata") {
            return .red
        } else if folderModel.statusMessage.contains("tamamlandı") {
            return .green
        } else {
            return .primary
        }
    }
    
    var statusBackgroundColor: Color {
        if folderModel.isProcessing {
            return .blue
        } else if folderModel.statusMessage.contains("tamamlandı") {
            return .green
        } else if folderModel.statusMessage.contains("Hata") {
            return .red
        } else {
            return .secondary
        }
    }
}

// Kategori bilgisi için özel görünüm
struct CategoryItem: View {
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