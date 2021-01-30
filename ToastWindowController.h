#import <RocketBootstrap/rocketbootstrap.h>

@interface UIWindow ()
- (void)_setSecure:(BOOL)arg1;
@end

@interface UIApplication ()
- (UIDeviceOrientation)_frontMostAppOrientation;
@end

@interface ToastWindow : UIWindow
@end

@interface ToastWindowController : NSObject{
    CPDistributedMessagingCenter * _messagingCenter;
}
@property (strong, nonatomic) ToastWindow *toastWindow;
@property (strong, strong) UILabel *label;
@property (strong, strong) UIView *backView;
@property (strong, strong) UIView *content;
+ (instancetype)sharedInstance;
- (NSDictionary *)showToastRequest:(NSString *)name withUserInfo:(NSDictionary *)userInfo;
-(void)presentToastWindowWithMessage:(NSString *)kMessage Width:(int)kWidth Height:(int)kHeight X:(int)kLocX Y:(int)kLocY Alpha:(float)kAlpha Radius:(float)kRadius backgroundColor:(UIColor *)kColor textColor:(UIColor *)kColorLabel numberOfLines:(int)kLines imagePath:(NSString *)kImagePath imageTint:(UIColor *)kImageTint displayType:(int)kDisplayType;
-(void)dismissToastWithDelay;
- (NSDictionary *)orientationChanged;
-(NSDictionary *)updateToastXY;
-(BOOL)_ignoresHitTest;
-(UIColor *)convertStringToColor:(NSString *)colorname;
@end

