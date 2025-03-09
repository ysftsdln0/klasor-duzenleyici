import SwiftUI
import Cocoa

// @main özniteliğini kaldırıyorum çünkü artık main.swift dosyamız var
struct KlasorDuzenleyiciApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    private let folderModel = FolderModel.shared
    private var globalMouseMonitor: Any?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Uygulama başlatılıyor...")
        
        // Popover'ı oluştur
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 340, height: 480)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: ContentView())
        popover.delegate = self
        self.popover = popover
        
        // Status bar item'ı oluştur
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            // Daha güzel bir status bar ikonu ayarlayalım
            if let iconImage = NSImage(systemSymbolName: "folder.fill", accessibilityDescription: "Klasör Düzenleyici") {
                iconImage.isTemplate = true // Bu, ikonu sistem temasına uygun yapacak
                button.image = iconImage
            }
            button.action = #selector(togglePopover)
            button.target = self
            print("Status bar butonu oluşturuldu")
        }
        
        // Menü çubuğuna tıklanınca popover'ı kapatmak için dinleyici ekle
        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self, 
                  let popover = self.popover, 
                  popover.isShown,
                  !self.folderModel.isPanelShown, // Dosya seçim paneli görünürken popover'ı kapatma
                  !self.folderModel.isProcessing  // İşlem sırasında popover'ı kapatma
            else { return }
            
            // Fare tıklaması status item'ın dışındaysa popover'ı kapat
            if let button = self.statusItem?.button, 
               !NSPointInRect(event.locationInWindow, button.convert(button.bounds, to: nil)) {
                popover.performClose(nil)
            }
        }
        
        // Uygulamanın her zaman ön planda olmasını sağla
        NSApp.setActivationPolicy(.accessory)
        
        print("Uygulama başlatma tamamlandı")
    }
    
    deinit {
        // Tıklama izleyicisini temizle
        if let monitor = globalMouseMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        print("Popover toggle çağrıldı")
        
        // Uygulamayı aktif yap
        NSApp.activate(ignoringOtherApps: true)
        
        if let button = statusItem?.button {
            if popover?.isShown == true {
                print("Popover kapatılıyor")
                popover?.performClose(sender)
            } else {
                print("Popover açılıyor")
                
                // Her açıldığında yeni bir ContentView oluştur
                popover?.contentViewController = NSHostingController(rootView: ContentView())
                
                // Popover'ı düğmenin altında göster
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                
                // Popover penceresini aktif yap
                if let window = popover?.contentViewController?.view.window {
                    window.makeKeyAndOrderFront(nil)
                    window.makeFirstResponder(window.contentView)
                }
            }
        }
    }
    
    // Popover kapandığında çağrılır
    func popoverDidClose(_ notification: Notification) {
        print("Popover kapandı")
        
        // Eğer dosya seçici açıksa, popover kapanırken dosya seçicinin de kapanmasını engelle
        if folderModel.isPanelShown {
            // Dosya seçici açıkken popover kapandıysa yeniden aç
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let button = self.statusItem?.button {
                    self.popover?.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                }
            }
        }
    }
    
    // Uygulama kapanırken
    func applicationWillTerminate(_ notification: Notification) {
        print("Uygulama kapanıyor...")
    }
} 