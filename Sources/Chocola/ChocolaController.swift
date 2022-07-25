import CoreGraphics
import AVFoundation

final class ChocolaController {
	static let shared        = ChocolaController() // this synchronises the video wallpaper
	
	public var playerQueue   = AVQueuePlayer()     // the actual video player we will use
	public var playerLayer   = AVPlayerLayer()     // the layer on which we host the playerQueue
	
	public var playerQueueLS = AVQueuePlayer()
	public var playerLayerLS = AVPlayerLayer()
	
	public var playerQueueHS = AVQueuePlayer()
	public var playerLayerHS = AVPlayerLayer()
	
	public var setting       = 0 // 0 = shared, 1 = lock, 2 = home
	
	public var isLPMPaused   = false
    public var inApp         = false
	
	private init() {}
    
    // Create a video wallpaper from .mp4 file, size it to fill the screen, and prepare an observer to loop when it completed
	
	public func setWallpaper(withFrame frame: CGRect) {
		let videoURL                = URL(fileURLWithPath: "/var/mobile/Library/Preferences/emt.paisseon.chocola/customVideo-VID.mp4")
		let playerItem              = AVPlayerItem(url: videoURL)
		playerQueue                 = AVQueuePlayer(playerItem: playerItem)
		
        playerQueue.preventsDisplaySleepDuringVideoPlayback = Preferences.shared.caffeine
		playerQueue.actionAtItemEnd = .none
		playerLayer.player          = playerQueue
		playerLayer.videoGravity    = .resizeAspectFill
		playerLayer.frame           = frame
		
		if Preferences.shared.mute {
			playerQueue.isMuted     = true
			playerQueue.volume      = 0.0
			try? AVAudioSession.sharedInstance().setCategory( .playback, options: .mixWithOthers)
		}
		
		setting = 0
		ChocolaController.shared.playerQueue.play()
		
		NotificationCenter.default.addObserver(
			self,
			selector : #selector(playerItemDidReachEnd(notification:)),
			name     : .AVPlayerItemDidPlayToEndTime,
			object   : playerQueue.currentItem
		)
	}
    
    // Same as above, but for LS and HS
	
	public func setSeparateWallpaper(withFrame frame: CGRect, onLockscreen isLS: Bool) {
		if isLS {
			let videoURL                  = URL(fileURLWithPath: "/var/mobile/Library/Preferences/emt.paisseon.chocola/lsVideo-VID.mp4")
			let playerItem                = AVPlayerItem(url: videoURL)
			playerQueueLS                 = AVQueuePlayer(playerItem: playerItem)
			
            playerQueueLS.preventsDisplaySleepDuringVideoPlayback = Preferences.shared.caffeine
			playerQueueLS.actionAtItemEnd = .none
			playerLayerLS.player          = playerQueueLS
			playerLayerLS.videoGravity    = .resizeAspectFill
			playerLayerLS.frame           = frame
			
			if Preferences.shared.mute {
				playerQueueLS.isMuted     = true
				playerQueueLS.volume      = 0.0
				try? AVAudioSession.sharedInstance().setCategory( .playback, options: .mixWithOthers)
			}
			
			setting = 1
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
			
            playerQueueHS.preventsDisplaySleepDuringVideoPlayback = Preferences.shared.caffeine
			playerQueueHS.actionAtItemEnd = .none
			playerLayerHS.player          = playerQueueHS
			playerLayerHS.videoGravity    = .resizeAspectFill
			playerLayerHS.frame           = frame
			
			if Preferences.shared.mute {
				playerQueueHS.isMuted     = true
				playerQueueHS.volume      = 0.0
				try? AVAudioSession.sharedInstance().setCategory( .playback, options: .mixWithOthers)
			}
			
			setting = 2
			ChocolaController.shared.playerQueueHS.play()
			
			NotificationCenter.default.addObserver(
				self,
				selector : #selector(playerItemDidReachEnd(notification:)),
				name     : .AVPlayerItemDidPlayToEndTime,
				object   : playerQueueHS.currentItem
			)
		}
	}
    
    // When the video finishes, go to the beginning (loop)
	
	@objc func playerItemDidReachEnd(notification: Notification) {
		if let playerItem = notification.object as? AVPlayerItem {
			playerItem.seek(to: CMTime.zero, completionHandler: nil)
		}
	}
    
    // Play the video conditionally
    
    public func playQueue() {
        if inApp || isLPMPaused {
            pauseQueue()
            return
        }
        
        switch setting {
            case 0:
                playerQueue.play()
            case 1:
                playerQueueLS.play()
            case 2:
                playerQueueHS.play()
            default:
                break
        }
    }
    
    // Pause the video
    
    public func pauseQueue() {
        switch setting {
            case 0:
                playerQueue.pause()
            case 1:
                playerQueueLS.pause()
            case 2:
                playerQueueHS.pause()
            default:
                break
        }
    }
}