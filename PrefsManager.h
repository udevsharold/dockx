#import <RocketBootstrap/rocketbootstrap.h>

@interface PrefsManager : NSObject{
    CPDistributedMessagingCenter * _messagingCenter;
}
@property(nonatomic, strong) NSDictionary *prefs;
+ (instancetype)sharedInstance;
-(NSDictionary *)readPrefs;
-(NSDictionary *)readPrefsFromSandbox:(BOOL)isSandbox;
-(void)writePrefs:(NSDictionary *)dictionary;
-(void)writePrefs:(NSDictionary *)dictionary fromSandbox:(BOOL)isSandbox;
-(void)setValue:(id)value forKey:(NSString *)key fromSandbox:(BOOL)isSandbox;
-(void)setValue:(id)value forKey:(NSString *)key;
-(id)getValueForKey:(NSString *)key fromSandbox:(BOOL)isSandbox;
-(id)getValueForKey:(NSString *)key;
-(void)removeKey:(NSString *)key fromSandbox:(BOOL)isSandbox;
-(void)removeKey:(NSString *)key;
-(void)reload;
-(void)postChangedNotification;
@end
