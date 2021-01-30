#import <RocketBootstrap/rocketbootstrap.h>

@interface DockXServer : NSObject{
    CPDistributedMessagingCenter * _messagingCenter;
}
+ (instancetype)sharedInstance;
-(NSDictionary *)getAutoCorrectionValue:(NSString *)name withUserInfo:(NSDictionary *)userInfo;
-(NSDictionary *)setAutoCorrectionValue:(NSString *)name withUserInfo:(NSDictionary *)userInfo;
-(NSDictionary *)getAutoCapitalizationValue:(NSString *)name withUserInfo:(NSDictionary *)userInfo;
-(NSDictionary *)setAutoCapitalizationValue:(NSString *)name withUserInfo:(NSDictionary *)userInfo;
-(NSDictionary *)runCommand:(NSString *)name withUserInfo:(NSDictionary *)userInfo;
@end

