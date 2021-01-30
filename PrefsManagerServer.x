#include "common.h"
#include "PrefsManagerServer.h"
#include "PrefsManager.h"

@implementation PrefsManagerServer

+ (void)load {
    @autoreleasepool {
        NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
        
        if (args.count != 0) {
            NSString *executablePath = args[0];
            
            if (executablePath) {
                NSString *processName = [executablePath lastPathComponent];
                
                BOOL isSpringBoard = [processName isEqualToString:@"SpringBoard"];
                
                if (isSpringBoard) {
                    [self sharedInstance];
                    
                }
            }
        }
    }
}

+ (instancetype)sharedInstance {
    static dispatch_once_t once = 0;
    __strong static id sharedInstance = nil;
    dispatch_once(&once, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _messagingCenter = [CPDistributedMessagingCenter centerNamed:kIPCCenterPrefsManager];
        rocketbootstrap_distributedmessagingcenter_apply(_messagingCenter);
        
        [_messagingCenter runServerOnCurrentThread];
        [_messagingCenter registerForMessageName:@"readPrefs" target:self selector:@selector(readPrefs:withUserInfo:)];
        [_messagingCenter registerForMessageName:@"writePrefs" target:self selector:@selector(writePrefs:withUserInfo:)];
        [_messagingCenter registerForMessageName:@"setValue" target:self selector:@selector(setValue:withUserInfo:)];
        [_messagingCenter registerForMessageName:@"getValueForKey" target:self selector:@selector(getValueForKey:withUserInfo:)];
        [_messagingCenter registerForMessageName:@"removeKey" target:self selector:@selector(removeKey:withUserInfo:)];

        
        
    }
    
    return self;
}

-(NSDictionary *)readPrefs:(NSString *)name withUserInfo:(NSDictionary *)userInfo{
    CFStringRef appID = (CFStringRef)kIdentifier;
    CFPreferencesAppSynchronize(appID);
    CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (!keyList) {
        return @{};
    }
    NSDictionary *dictionary = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
    CFRelease(keyList);
    return dictionary;
}

-(NSDictionary *)writePrefs:(NSString *)name withUserInfo:(NSDictionary *)userInfo{
    CFStringRef appID = (CFStringRef)kIdentifier;
    CFPreferencesSetMultiple((__bridge CFDictionaryRef)userInfo, nil, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFPreferencesAppSynchronize(appID);
    //[self postChangedNotification];
    return nil;
}

-(NSDictionary *)setValue:(NSString *)name withUserInfo:(NSDictionary *)userInfo{
    CFPreferencesSetAppValue((CFStringRef)userInfo[@"key"], (CFPropertyListRef)userInfo[@"value"], (CFStringRef)kIdentifier);
    CFPreferencesAppSynchronize((CFStringRef)kIdentifier);
    //[self postChangedNotification];
    return nil;
}

-(NSDictionary *)getValueForKey:(NSString *)name withUserInfo:(NSDictionary *)userInfo{
    CFStringRef appID = (CFStringRef)kIdentifier;
    CFPreferencesAppSynchronize(appID);
    return @{@"value":CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)userInfo[@"key"], appID))};
}

-(NSDictionary *)removeKey:(NSString *)name withUserInfo:(NSDictionary *)userInfo{
    [self setValue:nil withUserInfo:userInfo];
    return nil;
}

-(void)postChangedNotification{
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)kPrefsChangedIdentifier, NULL, NULL, YES);
}
@end

