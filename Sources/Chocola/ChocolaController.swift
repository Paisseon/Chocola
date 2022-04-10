import CoreGraphics
import AVFoundation

class ChocolaController {
	static let shared        = ChocolaController() // this synchronises the video wallpaper
	
	public var playerQueue   = AVQueuePlayer()     // the actual video player we will use
	public var playerLayer   = AVPlayerLayer()     // the layer on which we host the playerQueue
	
	public var playerQueueLS = AVQueuePlayer()
	public var playerLayerLS = AVPlayerLayer()
	
	public var playerQueueHS = AVQueuePlayer()
	public var playerLayerHS = AVPlayerLayer()
	
	public var isSetMain     = false
	public var isSetLock     = false
	public var isSetHome     = false
	
	public var isLPMPaused   = false
	
	private init() {}
	
	public func setWallpaper(withFrame frame: CGRect) {
		let videoURL                = URL(fileURLWithPath: "/var/mobile/Library/Preferences/emt.paisseon.chocola/customVideo-VID.mp4")
		let playerItem              = AVPlayerItem(url: videoURL)           // get a player item from a file
		playerQueue                 = AVQueuePlayer(playerItem: playerItem) // create a queue with that item
		
		playerQueue.actionAtItemEnd = .none                                 // looper without a looper
		playerLayer.player          = playerQueue                           // set the player for layer
		playerLayer.videoGravity    = .resizeAspectFill                     // fill the screen
		playerLayer.frame           = frame                                 // size to the given frame
		
		if Preferences.shared.mute.boolValue {
			playerQueue.isMuted     = true
			playerQueue.volume      = 0.0
			try? AVAudioSession.sharedInstance().setCategory( .playback, options: .mixWithOthers) // prevent pausing when music plays
		}
		
		isSetMain = true
		ChocolaController.shared.playerQueue.play()
		
		NotificationCenter.default.addObserver(
			self,
			selector : #selector(playerItemDidReachEnd(notification:)),
			name     : .AVPlayerItemDidPlayToEndTime,
			object   : playerQueue.currentItem
		) // observe when the video finishes...
	}
	
	public func setSeparateWallpaper(withFrame frame: CGRect, onLockscreen isLS: Bool) {
		if isLS {
			let videoURL                  = URL(fileURLWithPath: "/var/mobile/Library/Preferences/emt.paisseon.chocola/lsVideo-VID.mp4")
			let playerItem                = AVPlayerItem(url: videoURL)
			playerQueueLS                 = AVQueuePlayer(playerItem: playerItem)
			
			playerQueueLS.actionAtItemEnd = .none
			playerLayerLS.player          = playerQueueLS
			playerLayerLS.videoGravity    = .resizeAspectFill
			playerLayerLS.frame           = frame
			
			if Preferences.shared.mute.boolValue {
				playerQueueLS.isMuted     = true
				playerQueueLS.volume      = 0.0
				try? AVAudioSession.sharedInstance().setCategory( .playback, options: .mixWithOthers)
			}
			
			isSetLock = true
			ChocolaController.shared.playerQueueLS.play()
			
			NotificationCenter.default.addObserver(
				self,
				selector : #selector(playerItemDidReachEnd(notification:)),
				name     : .AVPlayerItemDidPlayToEndTime,
				object   : playerQueueLS.currentItem
			)
		} else {
			let videoURL                  = URL(fileURLWithPath: "/var/mobile/Library/Preferences/emt.paisseon.chocola/hsVideo-VID.mp4")
			let playerItem                = AVPlayerItem(url: videoURL)
			playerQueueHS                 = AVQueuePlayer(playerItem: playerItem)
			
			playerQueueHS.actionAtItemEnd = .none
			playerLayerHS.player          = playerQueueHS
			playerLayerHS.videoGravity    = .resizeAspectFill
			playerLayerHS.frame           = frame
			
			if Preferences.shared.mute.boolValue {
				playerQueueHS.isMuted     = true
				playerQueueHS.volume      = 0.0
				try? AVAudioSession.sharedInstance().setCategory( .playback, options: .mixWithOthers)
			}
			
			isSetHome = true
			ChocolaController.shared.playerQueueHS.play()
			
			NotificationCenter.default.addObserver(
				self,
				selector : #selector(playerItemDidReachEnd(notification:)),
				name     : .AVPlayerItemDidPlayToEndTime,
				object   : playerQueueHS.currentItem
			)
		}
	}
	
	@objc func playerItemDidReachEnd(notification: Notification) {
		if let playerItem = notification.object as? AVPlayerItem {
			playerItem.seek(to: CMTime.zero, completionHandler: nil)
		}
	} // ...then loop it
}