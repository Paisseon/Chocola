import Orion
import ChocolaC
import CoreGraphics

class LockHook: ClassHook<UIView> {
	static let targetName = "SBFStatusBarLegibilityView"
	typealias Group       = Lock
	
	func didMoveToWindow() {
		orig.didMoveToWindow()
		
		ChocolaController.shared.setSeparateWallpaper(withFrame: target.layer.bounds, onLockscreen: true)
		target.layer.addSublayer(ChocolaController.shared.playerLayerLS)
	}
	
	func layoutSubviews() {
		orig.layoutSubviews()
		
		ChocolaController.shared.playerLayerLS.frame = target.layer.bounds
	}
}