import Orion
import ChocolaC
import CoreGraphics

class HomeHook: ClassHook<UIView> {
	static let targetName = "SBHomeScreenView"
	typealias Group       = Home
	
	func didMoveToWindow() {
		orig.didMoveToWindow()
		
		ChocolaController.shared.setSeparateWallpaper(withFrame: target.layer.bounds, onLockscreen: false)
		let wpView = UIView(frame: target.layer.bounds)
		target.insertSubview(wpView, at: 0)
		wpView.layer.addSublayer(ChocolaController.shared.playerLayerHS)
	}
	
	func layoutSubviews() {
		orig.layoutSubviews()
		
		ChocolaController.shared.playerLayerHS.frame = target.layer.bounds
	}
}