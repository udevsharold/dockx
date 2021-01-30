#import <RocketBootstrap/rocketbootstrap.h>

@interface PrefsManagerServer : NSObject{
    CPDistributedMessagingCenter * _messagingCenter;
}
+ (instancetype)sharedInstance;
-(NSDictionary *)readPrefs:(NSString *)name withUserInfo:(NSDictionary *)userInfo;
-(NSDictionary *)writePrefs:(NSString *)name withUserInfo:(NSDictionary *)userInfo;
-(NSDictionary *)setValue:(NSString *)name withUserInfo:(NSDictionary *)userInfo;
-(NSDictionary *)getValueForKey:(NSString *)name withUserInfo:(NSDictionary *)userInfo;
-(NSDictionary *)removeKey:(NSString *)name withUserInfo:(NSDictionary *)userInfo;
-(void)postChangedNotification;
@end

