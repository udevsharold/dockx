#import "common.h"
#import "PrefsManager.h"

static CPDistributedMessagingCenter *c = nil;

static void reloadPrefs(CFNotificationCenterRef center, void *observer, CFStringRef name,
                        const void *object, CFDictionaryRef userInfo) {
    [(__bridge PrefsManager *)observer reload];
}


@implementation PrefsManager

+ (void)load {
    @autoreleasepool {
        NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
        
        if (args.count != 0) {
            NSString *executablePath = args[0];
            
            if (executablePath) {
                NSString *processName = [executablePath lastPathComponent];
                
                BOOL isSpringBoard = [processName isEqualToString:@"SpringBoard"];
                BOOL isApplication = [executablePath rangeOfString:@"/Application"].location != NSNotFound;
                
                if (isSpringBoard || isApplication) {
                    [PrefsManager sharedInstance];
                    
                }
            }
        }
    }
}

+ (instancetype)sharedInstance {
    static dispatch_once_t predicate;
    static PrefsManager *manager;
    dispatch_once(&predicate, ^{ manager = [[self alloc] init]; });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        c = [CPDistributedMessagingCenter centerNamed:kIPCCenterPrefsManager];
        rocketbootstrap_distributedmessagingcenter_apply(c);
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)self, &reloadPrefs, (CFStringRef)kPrefsChangedIdentifier, NULL, 0);
        self.prefs = [self readPrefs];
    }
    return self;
}

-(NSDictionary *)readPrefsFromSandbox:(BOOL)isSandbox{
    if (isSandbox){
        return [c sendMessageAndReceiveReplyName:@"readPrefs" userInfo:nil];
    }else{
        return [self readPrefs];
    }
}

-(NSDictionary *)readPrefs{
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

-(void)writePrefs:(NSDictionary *)dictionary fromSandbox:(BOOL)isSandbox{
    if (isSandbox){
        [c sendMessageAndReceiveReplyName:@"writePrefs" userInfo:dictionary];
    }else{
        [self writePrefs:dictionary];
    }
}

-(void)writePrefs:(NSDictionary *)dictionary{
    CFStringRef appID = (CFStringRef)kIdentifier;
    CFPreferencesSetMultiple((__bridge CFDictionaryRef)dictionary, nil, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFPreferencesAppSynchronize(appID);
    //[self postChangedNotification];
}

-(void)setValue:(id)value forKey:(NSString *)key fromSandbox:(BOOL)isSandbox{
    if (isSandbox){
        NSDictionary *data = @{@"key":key, @"value":value};
        [c sendMessageAndReceiveReplyName:@"setValue" userInfo:data];
    }else{
        [self setValue:value forKey:key];
    }
}

-(void)setValue:(id)value forKey:(NSString *)key{
    CFStringRef appID = (CFStringRef)kIdentifier;
    CFPreferencesSetAppValue((CFStringRef)key, (CFPropertyListRef)value, appID);
    CFPreferencesAppSynchronize(appID);
    //[self postChangedNotification];
}

-(id)getValueForKey:(NSString *)key fromSandbox:(BOOL)isSandbox{
    if (isSandbox){
        NSDictionary *data = @{@"key":key};
        NSDictionary *valueData = [c sendMessageAndReceiveReplyName:@"getValueForKey" userInfo:data];
        return valueData[@"value"];
    }else{
        return [self getValueForKey:key];
    }
}

-(id)getValueForKey:(NSString *)key{
    CFStringRef appID = (CFStringRef)kIdentifier;
    CFPreferencesAppSynchronize(appID);
    return CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)key, appID));
}

-(void)removeKey:(NSString *)key fromSandbox:(BOOL)isSandbox{
    if (isSandbox){
        NSDictionary *data = @{@"key":key};
        [c sendMessageAndReceiveReplyName:@"removeKey" userInfo:data];
    }else{
        return [self removeKey:key];
    }
}

-(void)removeKey:(NSString *)key{
    [self setValue:nil forKey:key];
}

-(void)postChangedNotification{
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)kPrefsChangedIdentifier, NULL, NULL, YES);
}

- (void)reload {
    self.prefs = [self readPrefs];
}

- (void)dealloc {
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)self, (CFStringRef)kPrefsChangedIdentifier, NULL);
}

@end
