import SwiftUI

struct ViewerView: NSViewControllerRepresentable {

    func makeNSViewController(context: Context) -> ViewerViewController {
        ViewerViewController()
    }

    func updateNSViewController(
        _ nsViewController: ViewerViewController,
        context: Context
    ) {
    }
}

struct ContentView: View {
    var body: some View {
        ViewerView()
            .frame(minWidth: 800, minHeight: 600)
    }
}

#Preview {
    ContentView()
}
