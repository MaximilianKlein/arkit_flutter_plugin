import Foundation
import ARKit

@available(iOS 13.0, *)
class FlutterArkitView: NSObject, FlutterPlatformView {
    let sceneView: ARSCNView
    let channel: FlutterMethodChannel
    
    var forceTapOnCenter: Bool = false
    var configuration: ARConfiguration? = nil

    var device: Device? = nil
    var face: Face? = nil

    var capture: ARCapture?
    
    init(withFrame frame: CGRect, viewIdentifier viewId: Int64, messenger msg: FlutterBinaryMessenger) {
        self.sceneView = ARSCNView(frame: frame)
        self.channel = FlutterMethodChannel(name: "arkit_\(viewId)", binaryMessenger: msg)
        
        super.init()

        self.capture = ARCapture(view: sceneView)
        
        self.sceneView.delegate = self
        self.channel.setMethodCallHandler(self.onMethodCalled)

        let face = Face()
        self.sceneView.scene.rootNode.addChildNode(face.node)
        self.face = face

        let device = Device(type: .iPad)
        self.sceneView.scene.rootNode.addChildNode(device.node)
        self.device = device
    }
    
    func view() -> UIView { return sceneView }
    
    var recording: Bool = false

    func onMethodCalled(_ call :FlutterMethodCall, _ result:@escaping FlutterResult) {
        let arguments = call.arguments as? Dictionary<String, Any>
        
        if configuration == nil && call.method != "init" {
            logPluginError("plugin is not initialized properly", toChannel: channel)
            result(nil)
            return
        }
        
        switch call.method {
        case "init":
            initalize(arguments!, result)
            result(nil)
            break
        case "recordStart":
            if recording {
                capture?.stop({ (status) in
                    print("Video exported: \(status)")
                })
            }
            print("stopping capture \(capture)")
            capture?.start()
            if let args = arguments {
                if let videoUrl = args["videoUrl"] as? String {
                    capture?.videoUrl = URL(string: videoUrl)
                }
            }
            recording = true;
            break
        case "recordStop":
            print("stopping capture \(capture)")
            capture?.stop({ (status) in
                print("Video exported: \(status)")
                result(self.capture?.videoUrl?.absoluteString)
            })
            recording = false
            break
        case "addARKitNode":
            onAddNode(arguments!)
            result(nil)
            break
        case "onUpdateNode":
            onUpdateNode(arguments!)
            result(nil)
            break
        case "removeARKitNode":
            onRemoveNode(arguments!)
            result(nil)
            break
        case "removeARKitAnchor":
            onRemoveAnchor(arguments!)
            result(nil)
            break
        case "getNodeBoundingBox":
            onGetNodeBoundingBox(arguments!, result)
            break
        case "transformationChanged":
            onTransformChanged(arguments!)
            result(nil)
            break
        case "isHiddenChanged":
            onIsHiddenChanged(arguments!)
            result(nil)
            break
        case "updateSingleProperty":
            onUpdateSingleProperty(arguments!)
            result(nil)
            break
        case "updateMaterials":
            onUpdateMaterials(arguments!)
            result(nil)
            break
        case "performHitTest":
            onPerformHitTest(arguments!, result)
            break
        case "updateFaceGeometry":
            onUpdateFaceGeometry(arguments!)
            result(nil)
            break
        case "getLightEstimate":
            onGetLightEstimate(result)
            result(nil)
            break
        case "projectPoint":
            onProjectPoint(arguments!, result)
            break
        case "cameraProjectionMatrix":
            onCameraProjectionMatrix(result)
            break
        case "pointOfViewTransform":
            onPointOfViewTransform(result)
            break
        case "playAnimation":
            onPlayAnimation(arguments!)
            result(nil)
            break
        case "stopAnimation":
            onStopAnimation(arguments!)
            result(nil)
            break
        case "dispose":
            onDispose(result)
            result(nil)
            break
        case "cameraEulerAngles":
            onCameraEulerAngles(result)
            break
        case "snapshot":
            onGetSnapshot(result)
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
    
    func onDispose(_ result:FlutterResult) {
        sceneView.session.pause()
        result(nil)
    }
}
