import UIKit

protocol PermissionControllerDelegate: class {
  func permissionControllerDidFinish(_ controller: PermissionController)
}

class PermissionController: UIViewController {

  lazy var permissionView: PermissionView = self.makePermissionView()

  weak var delegate: PermissionControllerDelegate?

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setup()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    requestPermission()
  }

  // MARK: - Setup

  func setup() {
    view.addSubview(permissionView)
    permissionView.closeButton.addTarget(self, action: #selector(closeButtonTouched(_:)),
                                         for: .touchUpInside)
    permissionView.settingButton.addTarget(self, action: #selector(settingButtonTouched(_:)),
                                           for: .touchUpInside)
    permissionView.g_pinEdges()
  }

  // MARK: - Logic

  func requestPermission() {
    Permission.Photos.request {
      self.check()
    }

    Permission.Camera.request {
      self.check()
    }
  }

  func check() {
    if Permission.hasPermissions {
      DispatchQueue.main.async {
        self.delegate?.permissionControllerDidFinish(self)
      }
    }
  }

  // MARK: - Action

    @objc func settingButtonTouched(_ button: UIButton) {
    DispatchQueue.main.async {
      if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
        //UIApplication.shared.openURL(settingsURL)
        self.extensionContext?.open(settingsURL)
      }
    }
  }

    @objc func closeButtonTouched(_ button: UIButton) {
    EventHub.shared.close?()
  }

  // MARK: - Controls

  func makePermissionView() -> PermissionView {
    let view = PermissionView()

    return view
  }
}
