import Cocoa
import SceneKit
import UniformTypeIdentifiers

final class ViewerWindowController: NSWindowController {

    private let sceneView = ViewerSceneView()
    private let cameraNode = SCNNode()
    private let sphereNode = SCNNode()

    private var yaw: Float = 0
    private var pitch: Float = 0
    private var distance: Float = 0
    
    private let titleLabel = NSTextField(
        labelWithString: "Open 360° sphere"
    )

    private let hintLabel = NSTextField(
        labelWithString: "Drop a 360° sphere JPG here"
    )

    private let openButton = NSButton(
        title: "Open 360° Image…",
        target: nil,
        action: nil
    )

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: 1000,
                height: 700
            ),
            styleMask: [
                .titled,
                .closable,
                .resizable,
                .miniaturizable
            ],
            backing: .buffered,
            defer: false
        )

        window.title = "360° Viewer"
        window.center()

        self.init(window: window)

        setupScene()
    }

    func openImage(url: URL) {
        print("📷 Kép megnyitása:", url.path)

        guard
            let source = CGImageSourceCreateWithURL(url as CFURL, nil),
            let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else {
            print("❌ CGImage betöltés sikertelen")
            return
        }

        print("✅ Kép betöltve: \(image.width)x\(image.height)")

        var transform = SCNMatrix4MakeScale(-1, 1, 1)
        transform.m41 = 1

        sphereNode.geometry?.firstMaterial?.diffuse.contentsTransform = transform
        sphereNode.geometry?.firstMaterial?.diffuse.contents = image
        
        hideWelcomeUI()
    }
    
    private func openImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.jpeg]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true

        guard panel.runModal() == .OK,
              let url = panel.url else {
            return
        }

        openImage(url: url)
    }
    
    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.contains(.command),
           event.keyCode == 1 { // Cmd+S
            openImage()
            return
        }

        super.keyDown(with: event)
    }
    
    @objc private func handlePan(_ gesture: NSPanGestureRecognizer) {
        let translation = gesture.translation(in: sceneView)

        yaw += Float(translation.x) * 0.006
        pitch -= Float(translation.y) * 0.006

        pitch = max(-1.45, min(1.45, pitch))

        cameraNode.eulerAngles = SCNVector3(
            pitch,
            yaw,
            0
        )

        gesture.setTranslation(.zero, in: sceneView)
    }
    
    @objc private func handleScroll(_ event: NSEvent) {
        // később ide kerül a zoom
    }
    
    override func scrollWheel(with event: NSEvent) {
        guard let camera = cameraNode.camera else {
            return
        }

        let delta = event.scrollingDeltaY

        if event.isDirectionInvertedFromDevice {
            camera.fieldOfView += delta * 0.05
        } else {
            camera.fieldOfView -= delta * 0.05
        }

        camera.fieldOfView = max(
            30,
            min(100, camera.fieldOfView)
        )
    }
    
    private func setupScene() {
        let container = NSView(
            frame: NSRect(
                x: 0,
                y: 0,
                width: 1000,
                height: 700
            )
        )

        container.autoresizingMask = [.width, .height]

        sceneView.frame = container.bounds
        sceneView.autoresizingMask = [.width, .height]

        sceneView.backgroundColor = .black
        sceneView.onFileDropped = { [weak self] url in
            self?.openImage(url: url)
        }

        container.addSubview(sceneView)
        window?.contentView = container

        let scene = SCNScene()
        sceneView.scene = scene
        
        let camera = SCNCamera()
        camera.fieldOfView = 75
        camera.zNear = 0.01
        camera.zFar = 100

        cameraNode.camera = camera
        scene.rootNode.addChildNode(cameraNode)
        
        let sphere = SCNSphere(radius: 10)
        sphere.segmentCount = 128

        let material = SCNMaterial()
        material.isDoubleSided = true
        material.lightingModel = .constant
        material.diffuse.contents = NSColor.black

        sphere.firstMaterial = material
        
        sphereNode.geometry = sphere

        scene.rootNode.addChildNode(sphereNode)
        
        let panGesture = NSPanGestureRecognizer(
            target: self,
            action: #selector(handlePan(_:))
        )

        sceneView.addGestureRecognizer(panGesture)
        sceneView.registerForDraggedTypes([.fileURL])
        
        openButton.target = self
        openButton.action = #selector(openButtonClicked)
        openButton.bezelStyle = NSButton.BezelStyle.rounded
        openButton.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(openButton)

        titleLabel.font = NSFont.systemFont(ofSize: 22, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.alignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(titleLabel)

        hintLabel.font = NSFont.systemFont(ofSize: 14)
        hintLabel.textColor = .lightGray
        hintLabel.alignment = .center
        hintLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(hintLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -55),

            hintLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            hintLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),

            openButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            openButton.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 20)
        ])
    }

    private func hideWelcomeUI() {
        titleLabel.isHidden = true
        hintLabel.isHidden = true
        openButton.isHidden = true
    }
    
    @objc private func openButtonClicked() {
        openImage()
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
}
