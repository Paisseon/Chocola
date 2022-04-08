import Orion
import ChocolaC
import CoreGraphics

struct Alle: HookGroup {}
struct Main: HookGroup {}
struct Home: HookGroup {}
struct Lock: HookGroup {}

// this file has Main and Alle groups. if you want Home or Lock, check their respective files

class WallpaperVCHook: ClassHook<SBWallpaperViewController> {
	typealias Group = Main
	
	func viewDidLoad() {
		orig.viewDidLoad()
		
		ChocolaController.shared.setWallpaper(withFrame: target.view.layer.bounds) // create the wallpaper with the size of the screen
		target.view.layer.addSublayer(ChocolaController.shared.playerLayer)        // add the shared wallpaper to our layer
	}
}

class WallpaperHook: ClassHook<SBFWallpaperView> {
	typealias Group = Main
	
	func layoutSubviews() {
		orig.layoutSubviews()
		
		for subview in target.subviews {
			subview.removeFromSuperview() // prevent showing old wallpaper (causes icon flash bug!)
		}
		
		ChocolaController.shared.playerLayer.frame = target.layer.bounds // make sure the wallpaper frame matches the current screen bounds, e.g. on rotates
	}
}

class SpringBoardHook: ClassHook<SpringBoard> {
	typealias Group = Alle
	
	func frontDisplayDidChange(_ arg0: Any?) {               // this is called when an app is opened, including SpringBoard
		orig.frontDisplayDidChange(arg0)
		
		if arg0 != nil {                                     // nil = SpringBoard
			if ChocolaController.shared.isSetMain {
				ChocolaController.shared.playerQueue.pause() // if the app is *not* SpringBoard, pause the player to save battery
			} else {
				if ChocolaController.shared.isSetLock {
					ChocolaController.shared.playerQueueLS.pause()
				}
				
				if ChocolaController.shared.isSetHome {
					ChocolaController.shared.playerQueueHS.pause()
				}
			}
		} else {
			if ChocolaController.shared.isSetMain {
				ChocolaController.shared.playerQueue.play() // if we are showing the home screen, play it
			} else {
				if ChocolaController.shared.isSetLock {
					ChocolaController.shared.playerQueueLS.play()
				}
				
				if ChocolaController.shared.isSetHome {
					ChocolaController.shared.playerQueueHS.play()
				}
			}
		}
	}
}

class BacklightHook: ClassHook<SBBacklightController> {
	typealias Group = Alle
	
	func _notifyObserversDidAnimateToFactor(_ arg0: Double, source arg1: Int64) {
		orig._notifyObserversDidAnimateToFactor(arg0, source: arg1)
		
		if arg0 == 0.0 { // pause if sleeping
			if ChocolaController.shared.isSetMain {
				ChocolaController.shared.playerQueue.pause()
			} else {
				if ChocolaController.shared.isSetLock {
					ChocolaController.shared.playerQueueLS.pause()
				}
				
				if ChocolaController.shared.isSetHome {
					ChocolaController.shared.playerQueueHS.pause()
				}
			}
		} else {        // play if waking
			if ChocolaController.shared.isSetMain {
				ChocolaController.shared.playerQueue.play()
			} else {
				if ChocolaController.shared.isSetLock {
					ChocolaController.shared.playerQueueLS.play()
				}
				
				if ChocolaController.shared.isSetHome {
					ChocolaController.shared.playerQueueHS.play()
				}
			}
		}
	}
}

class BatteryHook: ClassHook<UIView> {
	static let targetName = "_UIBatteryView"
	typealias Group       = Alle
	
	func setSaverModeActive(_ arg0: Bool) {
		orig.setSaverModeActive(arg0)
		
		if Preferences.shared.lpmPause.boolValue {
			if ChocolaController.shared.isSetMain {
				arg0 ? ChocolaController.shared.playerQueue.pause() : ChocolaController.shared.playerQueue.play()
			} else {
				if ChocolaController.shared.isSetLock {
					arg0 ? ChocolaController.shared.playerQueueLS.pause() : ChocolaController.shared.playerQueueLS.play()
				}
				
				if ChocolaController.shared.isSetHome {
					arg0 ? ChocolaController.shared.playerQueueHS.pause() : ChocolaController.shared.playerQueueHS.play()
				}
			}
		}
	}
}

class Chocola: Tweak {
	required init() {
		if Preferences.shared.enabled.boolValue {
			Alle().activate()
			
			if Preferences.shared.sync.boolValue && FileManager.default.fileExists(atPath: "/var/mobile/Library/Preferences/emt.paisseon.chocola/customVideo-VID.mp4") {
				Main().activate()
				return
			}
			
			if Preferences.shared.homescreen.boolValue && FileManager.default.fileExists(atPath: "/var/mobile/Library/Preferences/emt.paisseon.chocola/hsVideo-VID.mp4") {
				Home().activate()
			}
			
			if Preferences.shared.lockscreen.boolValue && FileManager.default.fileExists(atPath: "/var/mobile/Library/Preferences/emt.paisseon.chocola/lsVideo-VID.mp4") {
				Lock().activate()
			}
		}
	}
}