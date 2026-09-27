import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var viewerWindowController: ViewerWindowController?
    private var receivedOpenURL = false

    func applicationDidFinishLaunching(_ notification: Notification) {

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            // Ha a Finder fájlt adott át, az open metódus már
            // létrehozta / megnyitotta az ablakot.
            if !self.receivedOpenURL {
                self.showWelcomeWindow()
            }
        }
    }

    func application(_ application: NSApplication,
                     open urls: [URL]) {

        guard let url = urls.first else {
            return
        }

        receivedOpenURL = true
        openFile(url)
    }

    private func openFile(_ url: URL) {

        if viewerWindowController == nil {
            viewerWindowController = ViewerWindowController()
        }

        viewerWindowController?.showWindow(nil)
        viewerWindowController?.window?.makeKeyAndOrderFront(nil)
        viewerWindowController?.openImage(url: url)
    }

    private func showWelcomeWindow() {

        if viewerWindowController == nil {
            viewerWindowController = ViewerWindowController()
        }

        viewerWindowController?.showWindow(nil)
        viewerWindowController?.window?.makeKeyAndOrderFront(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(
        _ sender: NSApplication
    ) -> Bool {
        return true
    }
}
