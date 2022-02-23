#import <UIKit/UIKit.h>
#import "GcUniversal/GcImagePickerUtils.h"

@interface SpringBoard : UIApplication
- (void) frontDisplayDidChange: (id) arg0;
@end

@interface SBWallpaperViewController : UIViewController
@end

@interface SBFWallpaperView : UIView
@end

@interface CSCoverSheetViewController : UIViewController
- (void) setInScreenOffMode: (bool) arg0;
@end

@interface SBBacklightController : NSObject
- (void) _notifyObserversDidAnimateToFactor: (double) arg0 source: (long long) arg1;
@end

NSURL *getVideoURLFromPrefs() {
	return [GcImagePickerUtils videoURLFromDefaults:@"emt.paisseon.chocola" withKey:@"customVideo"];
}