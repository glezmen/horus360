import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var viewerWindowController: ViewerWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        viewerWindowController = ViewerWindowController()
        viewerWindowController?.showWindow(nil)
        viewerWindowController?.window?.makeKeyAndOrderFront(nil)
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else {
            return
        }

        print("📂 Megnyitott fájl:", url.path)

        if viewerWindowController == nil {
            viewerWindowController = ViewerWindowController()
        }

        viewerWindowController?.showWindow(nil)
        viewerWindowController?.window?.makeKeyAndOrderFront(nil)
        viewerWindowController?.openImage(url: url)
    }
}
