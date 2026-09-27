import Cocoa
import SceneKit

final class ViewerSceneView: SCNView {

    var onFileDropped: ((URL) -> Void)?

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let url = sender.draggingPasteboard.readObjects(
            forClasses: [NSURL.self],
            options: [.urlReadingFileURLsOnly: true]
        )?.first as? URL else {
            return false
        }

        print("📂 Drag & drop fájl:", url.path)

        onFileDropped?(url)

        return true
    }
}
