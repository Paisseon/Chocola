import Orion
import ChocolaC
import UIKit

struct ChocolaGroup: HookGroup {}

extension UIImage {
	public static func chocola(_ data: Data) -> UIImage? {
		guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
			return Self(data: data)
		} // create a cgimagesource from the gif data
		
		let frames: [(image: CGImage, duration: TimeInterval)] = (0 ..< CGImageSourceGetCount(source)).compactMap { index in // this creates array of frames
			guard let image: CGImage = CGImageSourceCreateImageAtIndex(source, index, nil) else { // make cgimage from source
				return nil
			}
			
			guard let properties: [String: Any] = (CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [String: Any]) else { // get gif properties
				return nil
			}
			
			let duration: TimeInterval = max(properties["UnclampedDelayTime"] as? TimeInterval, 0.0) // get duration for the frame using unclamped delays
			
			return (image, duration) // return the finalised frame
		}
		
		var images: [UIImage] = [] // array of images, this will include all frames
		var duration: TimeInterval = 0.0 // get the full gif duration
		for frame in frames {
			let image = UIImage(cgImage: frame.image)
			for _ in 0 ..< Int(frame.duration * 100.0) {
				images.append(image) // add frame to the array
			}
			duration += frame.duration // and add the frame's duration to the animated image
		}
		return animatedImage(with: images, duration: round(duration * 10.0) / 10.0) // return an animated image using the gif frames
	}
}

class Vanilla {
	static let shared = Vanilla()
	private init() {}
	
	func wallpaper(withBounds bounds: CGRect) -> UIImageView {
		let image = UIImage.chocola(try! Data(contentsOf: URL(fileURLWithPath: "/var/mobile/Chocola/image.gif"))) // get the gif as an animated image
		let imageView = UIImageView(image: image)
		imageView.frame = bounds
		return imageView
	}
}

class WallpaperHook: ClassHook<UIView> {
	static let targetName = "SBFWallpaperView"
	typealias Group = ChocolaGroup
	
	func didMoveToWindow() {
		orig.didMoveToWindow()
		for subview in target.subviews {
			subview.removeFromSuperview() // clear unwanted subviews, i.e. the original wallpaper
		}
		target.addSubview(Vanilla.shared.wallpaper(withBounds: target.bounds)) // add our subview as a singleton to the wallpaper
	}
}

class FolderHook: ClassHook<UIView> {
	static let targetName = "SBFolderIconImageView"
	typealias Group = ChocolaGroup
	
	func didMoveToWindow() {
		orig.didMoveToWindow()
		target.subviews[0].removeFromSuperview() // hide the wallpaper from folders because it gets out of sync
	}
}

class Chocola: Tweak {
	required init() {
		ChocolaGroup().activate()
	}
}