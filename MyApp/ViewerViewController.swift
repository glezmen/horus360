import Cocoa
import SceneKit
import ImageIO

final class ViewerViewController: NSViewController {

    private let sceneView = SCNView()
    private let cameraNode = SCNNode()
    private let sphereNode = SCNNode()

    private var yaw: Float = 0
    private var pitch: Float = 0
    private var distance: Float = 0

    override func loadView() {
        sceneView.frame = .zero
        sceneView.autoresizingMask = [.width, .height]

        sceneView.backgroundColor = .black
        sceneView.allowsCameraControl = false
        sceneView.antialiasingMode = .multisampling4X

        view = sceneView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔥🔥🔥 ViewerViewController.viewDidLoad()")

        let scene = SCNScene()
        sceneView.scene = scene

        // Camera
        let camera = SCNCamera()
        camera.fieldOfView = 75
        camera.zNear = 0.01
        camera.zFar = 100

        cameraNode.camera = camera
        scene.rootNode.addChildNode(cameraNode)

        // 360° sphere
        let sphere = SCNSphere(radius: 10)
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

    func loadImage(from url: URL) {

        guard
            let source = CGImageSourceCreateWithURL(url as CFURL, nil),
            let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else {
            return
        }

        let nsImage = NSImage(
            cgImage: image,
            size: NSSize(
                width: image.width,
                height: image.height
            )
        )

        guard let material = sphereNode.geometry?.firstMaterial else {
            return
        }

        material.diffuse.contents = nsImage

        yaw = 0
        pitch = 0
        distance = 0

        updateCamera()
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

    override func mouseDragged(with event: NSEvent) {

        yaw += Float(event.deltaX) * 0.006
        pitch -= Float(event.deltaY) * 0.006

        pitch = max(-1.45, min(1.45, pitch))

        updateCamera()
    }

    override func scrollWheel(with event: NSEvent) {

        distance += Float(event.scrollingDeltaY) * 0.01
        distance = max(1.05, min(4.0, distance))

        updateCamera()
    }

    override func mouseDown(with event: NSEvent) {

        if event.clickCount == 2 {
            yaw = 0
            pitch = 0
            distance = 0

            updateCamera()
        }
    }
}
