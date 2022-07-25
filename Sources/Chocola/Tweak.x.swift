import Orion
import ChocolaC
import CoreGraphics

struct Core: HookGroup {}
struct Main: HookGroup {}
struct Home: HookGroup {}
struct Lock: HookGroup {}

// Add the video wallpaper, created in ChocolaController, to the stock wallpaper view

class WallpaperVCHook: ClassHook<SBWallpaperViewController> {
	typealias Group = Main
	
	func viewDidLoad() {
		orig.viewDidLoad()
		
		ChocolaController.shared.setWallpaper(withFrame: target.view.layer.bounds)
		target.view.layer.addSublayer(ChocolaController.shared.playerLayer)
	}
}

// Rotation and notification center fix

class WallpaperHook: ClassHook<SBFWallpaperView> {
	typealias Group = Main
	
	func layoutSubviews() {
		orig.layoutSubviews()
		
		for subview in target.subviews {
			subview.removeFromSuperview()
		}
		
		ChocolaController.shared.playerLayer.frame = target.layer.bounds
	}
}

// Pause when entering apps, play when going back home

class SpringBoardHook: ClassHook<SpringBoard> {
	typealias Group = Core
	
	func frontDisplayDidChange(_ arg0: Any?) {
		orig.frontDisplayDidChange(arg0)
        
        ChocolaController.shared.inApp = arg0 != nil
		arg0 == nil ? ChocolaController.shared.playQueue() : ChocolaController.shared.pauseQueue()
	}
}

// Pause when sleeping, play when waking

class BacklightHook: ClassHook<SBBacklightController> {
	typealias Group = Core
	
	func _notifyObserversDidAnimateToFactor(_ arg0: Double, source arg1: Int64) {
        orig._notifyObserversDidAnimateToFactor(arg0, source: arg1)
        
        arg0 == 0.0 ? ChocolaController.shared.pauseQueue() : ChocolaController.shared.playQueue()
	}
}

// Pause when enabling LPM, play when disabling. Configured in Preferences

class LPMHook: ClassHook<_CDBatterySaver> {
    typealias Group = Core
    
    func setPowerMode(_ arg0: Int64, error arg1: Any?) -> Bool {
        if Preferences.shared.lpmPause {
            ChocolaController.shared.isLPMPaused = arg0 == 1
            arg0 == 1 ? ChocolaController.shared.pauseQueue() : ChocolaController.shared.playQueue()
        }
        
        return orig.setPowerMode(arg0, error: arg1)
    }
}

// Constructor

class Chocola: Tweak {
	required init() {
		if Preferences.shared.enabled {
			Core().activate()
			
			if Preferences.shared.sync && FileManager.default.fileExists(atPath: "/var/mobile/Library/Preferences/emt.paisseon.chocola/customVideo-VID.mp4") {
				Main().activate()
				return
			}
			
			if Preferences.shared.homescreen && FileManager.default.fileExists(atPath: "/var/mobile/Library/Preferences/emt.paisseon.chocola/hsVideo-VID.mp4") {
				Home().activate()
			}
			
			if Preferences.shared.lockscreen && FileManager.default.fileExists(atPath: "/var/mobile/Library/Preferences/emt.paisseon.chocola/lsVideo-VID.mp4") {
				Lock().activate()
			}
		}
	}
}