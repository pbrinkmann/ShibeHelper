#import "KeyboardStateListener.h"

static KeyboardStateListener *sharedInstance;

@implementation KeyboardStateListener

+ (KeyboardStateListener *)sharedInstance
{
    return sharedInstance;
}

+ (void)load
{
    sharedInstance = [[self alloc] init];
}

- (BOOL)isVisible
{
    return _isVisible;
}

- (void)didShow
{
    _isVisible = YES;
}

- (void)didHide
{
    _isVisible = NO;
}

- (id)init
{
    if ((self = [super init])) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(didShow) name:UIKeyboardDidShowNotification object:nil];
        [center addObserver:self selector:@selector(didHide) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

@end
