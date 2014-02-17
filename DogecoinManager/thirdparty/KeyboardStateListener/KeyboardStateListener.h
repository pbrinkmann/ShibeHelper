//
// From: http://stackoverflow.com/questions/1490573/how-to-programatically-check-whether-a-keyboard-is-present-in-iphone-app?rq=1
//


@interface KeyboardStateListener : NSObject {
    BOOL _isVisible;
}

+ (KeyboardStateListener *)sharedInstance;
@property (nonatomic, readonly, getter=isVisible) BOOL visible;
@end
