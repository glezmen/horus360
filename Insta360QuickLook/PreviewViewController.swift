import Cocoa
import Quartz
import SceneKit
import ImageIO

final class PreviewViewController: NSViewController, QLPreviewingController {

    private let sceneView = SCNView()
    private let cameraNode = SCNNode()
    private let sphereNode = SCNNode()

    private var yaw: Float = 0
    private var pitch: Float = 0
    private var distance: Float = 0.0

    override func loadView() {
        print("🔥🔥🔥 LOADVIEW - SAJÁT EXTENSION 🔥🔥🔥")
        sceneView.frame = .zero
        sceneView.autoresizingMask = [.width, .height]

        sceneView.backgroundColor = .black
        sceneView.allowsCameraControl = false
        sceneView.antialiasingMode = .multisampling4X

        view = sceneView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = SCNScene()
        sceneView.scene = scene

        // Camera
        let camera = SCNCamera()
        camera.fieldOfView = 75
        camera.zNear = 0.01
        camera.zFar = 100.0

        cameraNode.camera = camera
        scene.rootNode.addChildNode(cameraNode)

        // 360° sphere
        let sphere = SCNSphere(radius: 10.0)
        sphere.segmentCount = 128

        let material = SCNMaterial()
        material.isDoubleSided = true
        material.cullMode = .front
        material.lightingModel = .constant

        sphere.firstMaterial = material

        sphereNode.geometry = sphere
        scene.rootNode.addChildNode(sphereNode)

        updateCamera()
    }

    func preparePreviewOfFile(at url: URL) async throws {
            print("🔥 INSTA360 QUICKLOOK CALLED:", url.path)
        guard
            let source = CGImageSourceCreateWithURL(
                url as CFURL,
                nil
            ),
            let image = CGImageSourceCreateImageAtIndex(
                source,
                0,
                nil
            )
        else {
            throw CocoaError(.fileReadCorruptFile)
        }

        let width = image.width
        let height = image.height

        guard height > 0 else {
            throw CocoaError(.fileReadCorruptFile)
        }

        let ratio = Double(width) / Double(height)

        // Insta360 equirectangular panorama ≈ 2:1
        guard ratio > 1.90 && ratio < 2.10 else {
            throw CocoaError(.fileReadUnsupportedScheme)
        }

        let nsImage = NSImage(
            cgImage: image,
            size: NSSize(
                width: width,
                height: height
            )
        )

        await MainActor.run {
            guard
                let material = self.sphereNode.geometry?
                    .firstMaterial
            else {
                return
            }

            material.diffuse.contents = nsImage

            self.yaw = 0
            self.pitch = 0
            self.distance = 2.2

            self.updateCamera()
        }
    }

    private func updateCamera() {

        cameraNode.position = SCNVector3(
            0,
            0,
            distance
        )

        cameraNode.eulerAngles = SCNVector3(
            pitch,
            yaw,
            0
        )
    }

    // MARK: - Mouse interaction

    override func mouseDragged(with event: NSEvent) {

        yaw += Float(event.deltaX) * 0.006
        pitch -= Float(event.deltaY) * 0.006

        pitch = max(
            -1.45,
            min(1.45, pitch)
        )

        updateCamera()
    }

    override func scrollWheel(with event: NSEvent) {

        distance += Float(event.scrollingDeltaY) * 0.01

        distance = max(
            1.05,
            min(4.0, distance)
        )

        updateCamera()
    }

    override func mouseDown(with event: NSEvent) {

        if event.clickCount == 2 {

            yaw = 0
            pitch = 0
            distance = 2.2

            updateCamera()
        }
    }
}
