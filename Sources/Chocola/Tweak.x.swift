import Orion
import ChocolaC
import CoreGraphics
import AVFoundation

struct Main: HookGroup {}

class ChocolaController {
	static let shared = ChocolaController()  // this synchronises the video wallpaper
	
	public var playerQueue = AVQueuePlayer() // the actual video player we will use
	public var playerLayer = AVPlayerLayer() // the layer on which we host the playerQueue
	public var isInApp     = false
	
	private init() {}
	
	public func setWallpaper(_ frame: CGRect) {
		if let videoURL    = try? URL(resolvingAliasFileAt: getVideoURLFromPrefs()) { // get video from prefs (see Tweak.h)
			let playerItem = AVPlayerItem(url: videoURL)                              // get a player item from a file
			playerQueue    = AVQueuePlayer(playerItem: playerItem)                    // create a queue with that item
		}
		
		playerQueue.isMuted         = true              // muted
		playerQueue.actionAtItemEnd = .none             // looper without a looper
		playerLayer.player          = playerQueue       // set the player for layer
		playerLayer.videoGravity    = .resizeAspectFill // fill the screen
		playerLayer.frame           = frame             // size to the given frame
		
		try? AVAudioSession.sharedInstance().setCategory( .playback, options: .mixWithOthers) // prevent pausing when music plays
		
		NotificationCenter.default.addObserver(
			self,
			selector : #selector(playerItemDidReachEnd(notification:)),
			name     : .AVPlayerItemDidPlayToEndTime,
			object   : playerQueue.currentItem
		) // observe when the video finishes...
	}
	
	@objc func playerItemDidReachEnd(notification: Notification) {
		if let playerItem = notification.object as? AVPlayerItem {
			playerItem.seek(to: CMTime.zero, completionHandler: nil)
		}
	} // ...then loop it
}

class WallpaperVCHook: ClassHook<SBWallpaperViewController> {
	typealias Group = Main
	
	func viewDidLoad() {
		orig.viewDidLoad()
		
		ChocolaController.shared.setWallpaper(target.view.layer.bounds)     // create the wallpaper with the size of the screen
		target.view.layer.addSublayer(ChocolaController.shared.playerLayer) // add the shared wallpaper to our layer
	}
}

class SpringBoardHook: ClassHook<SpringBoard> {
	typealias Group = Main
	
	func frontDisplayDidChange(_ arg0: Any?) {           // this is called when an app is opened, including SpringBoard
		orig.frontDisplayDidChange(arg0)
		
		if arg0 != nil {                                 // nil = SpringBoard
			ChocolaController.shared.isInApp = true      // currently in an app. used for determining whether to play on lock screen
			ChocolaController.shared.playerQueue.pause() // if the app is *not* SpringBoard, pause the player to save battery
		} else {
			ChocolaController.shared.isInApp = false     // not currently in an app
			ChocolaController.shared.playerQueue.play()  // if we are showing the home screen, play it
		}
	}
}

class BacklightHook: ClassHook<SBBacklightController> {
	typealias Group = Main
	
	func _notifyObserversDidAnimateToFactor(_ arg0: Double, source arg1: Int64) {
		orig._notifyObserversDidAnimateToFactor(arg0, source: arg1)
		
		if arg0 == 0.0 {
			ChocolaController.shared.playerQueue.pause() // pause if sleeping
		} else {
			ChocolaController.shared.playerQueue.play()  // play if waking
		}
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

class Chocola: Tweak {
	required init() {
		if Preferences.shared.enabled.boolValue {
			Main().activate()
		}
	}
}