#import <RocketBootstrap/rocketbootstrap.h>

@interface UIWindow ()
- (void)_setSecure:(BOOL)arg1;
@end

@interface UIApplication ()
- (UIDeviceOrientation)_frontMostAppOrientation;
@end

@interface DXToastWindow : UIWindow
@end

@interface DXToastWindowController : NSObject{
    CPDistributedMessagingCenter * _messagingCenter;
}
@property (strong, nonatomic) DXToastWindow *toastWindow;
@property (strong, strong) UILabel *label;
@property (strong, strong) UIView *backView;
@property (strong, strong) UIView *content;
+ (instancetype)sharedInstance;
- (NSDictionary *)showToastRequest:(NSString *)name withUserInfo:(NSDictionary *)userInfo;
-(void)presentToastWindowWithMessage:(NSString *)kMessage width:(int)kWidth height:(int)kHeight x:(int)kLocX y:(int)kLocY alpha:(float)kAlpha radius:(float)kRadius backgroundColor:(UIColor *)kColor textColor:(UIColor *)kColorLabel numberOfLines:(int)kLines imagePath:(NSString *)kImagePath imageTint:(UIColor *)kImageTint displayType:(int)kDisplayType;
-(void)dismissToastWithDelay;
- (NSDictionary *)orientationChanged;
-(NSDictionary *)updateToastXY;
-(BOOL)_ignoresHitTest;
-(UIColor *)convertStringToColor:(NSString *)colorname;
@end

