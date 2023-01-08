import AVFoundation
import CoreGraphics
import mryipc
import UIKit

final class Chocola {
    static let shared: Chocola = .init()
    
    var queue: AVQueuePlayer = .init()
    var layer: AVPlayerLayer = .init()
    var layer2: AVPlayerLayer = .init()
    
    var isPlaying: Bool = false
    var isInApp: Bool = false
    var isLowPower: Bool = false
    
    func play() {
        if isInApp || isLowPower {
            pause()
            return
        }
        
        isPlaying = true
        queue.play()
    }
    
    func pause() {
        isPlaying = false
        queue.pause()
    }
    
    @objc func loop(
        notification: Notification
    ) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: .zero, completionHandler: nil)
        }
    }
    
    private init() {}
    
    func setWallpaper(
        on frame: CGRect
    ) {
        if layer.videoGravity == .resizeAspectFill {
            return
        }
        
        let prefs: Preferences = .shared
        let url: URL = .init(fileURLWithPath: "/var/mobile/Library/Preferences/emt.paisseon.chocola/wallpaper-VID.mp4")
        let item: AVPlayerItem = .init(url: url)
        
        queue = AVQueuePlayer(playerItem: item)
        queue.preventsDisplaySleepDuringVideoPlayback = prefs.isCaffeinated
        queue.actionAtItemEnd = .none
        layer.player = queue
        layer.videoGravity = .resizeAspectFill
        layer.frame = frame
        
        layer2.player = queue
        layer2.videoGravity = .resizeAspectFill
        layer2.frame = frame
        
        if prefs.isMuted {
            queue.isMuted = true
            queue.volume = 0.0
            
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
            } catch {}
        }
        
        play()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loop(notification:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: queue.currentItem
        )
    }
}
