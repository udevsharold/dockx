#import "common.h"
#import "DXServer.h"
#import "DockX.h"
#import "NSTask.h"
#import <dlfcn.h>
#import <objc/runtime.h>

static KeyboardController *kbController;

@implementation DXServer
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
    if ((self = [super init])) {
        
        _messagingCenter = [CPDistributedMessagingCenter centerNamed:kIPCCenterDockX];
        rocketbootstrap_distributedmessagingcenter_apply(_messagingCenter);

        [_messagingCenter runServerOnCurrentThread];
        [_messagingCenter registerForMessageName:@"getAutoCorrectionValue" target:self selector:@selector(getAutoCorrectionValue:withUserInfo:)];
        [_messagingCenter registerForMessageName:@"setAutoCorrectionValue" target:self selector:@selector(setAutoCorrectionValue:withUserInfo:)];
        [_messagingCenter registerForMessageName:@"getAutoCapitalizationValue" target:self selector:@selector(getAutoCapitalizationValue:withUserInfo:)];
        [_messagingCenter registerForMessageName:@"setAutoCapitalizationValue" target:self selector:@selector(setAutoCapitalizationValue:withUserInfo:)];
        [_messagingCenter registerForMessageName:@"runCommand" target:self selector:@selector(runCommand:withUserInfo:)];
    }

    return self;
}


-(NSDictionary *)getAutoCorrectionValue:(NSString *)name withUserInfo:(NSDictionary *)userInfo{
    [[objc_getClass("UIKeyboardPreferencesController") sharedPreferencesController] synchronizePreferences];
    return @{@"value":[NSNumber numberWithBool:[[objc_getClass("UIKeyboardPreferencesController") sharedPreferencesController] boolForKey:7]]};
}

-(NSDictionary *)setAutoCorrectionValue:(NSString *)name withUserInfo:(NSDictionary *)userInfo{
    BOOL value = [userInfo[@"value"] boolValue];
    [[objc_getClass("UIKeyboardPreferencesController") sharedPreferencesController] setValue:[NSNumber numberWithBool:value] forKey:7];
    [[objc_getClass("UIKeyboardPreferencesController") sharedPreferencesController] synchronizePreferences];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("AppleKeyboardsSettingsChangedNotification"), NULL, NULL, YES);

    return nil;
}

-(NSDictionary *)getAutoCapitalizationValue:(NSString *)name withUserInfo:(NSDictionary *)userInfo{
    [[objc_getClass("UIKeyboardPreferencesController") sharedPreferencesController] synchronizePreferences];
    return @{@"value":[NSNumber numberWithBool:[[objc_getClass("UIKeyboardPreferencesController") sharedPreferencesController] boolForKey:8]]};
}

-(NSDictionary *)setAutoCapitalizationValue:(NSString *)name withUserInfo:(NSDictionary *)userInfo{
    BOOL value = [userInfo[@"value"] boolValue];
    if (!kbController){
        
        dlopen("/System/Library/PreferenceBundles/KeyboardSettings.bundle/KeyboardSettings", RTLD_LAZY);
        PSRootController *rootController = [[PSRootController alloc] initWithTitle:@"Preferences" identifier:@"com.apple.Preferences"];
        kbController = [[NSClassFromString(@"KeyboardController") alloc] init];
        if ([kbController respondsToSelector:@selector(setRootController:)]){
            [kbController setRootController:rootController];
        }
        if ([kbController respondsToSelector:@selector(setParentController:)]){
            [kbController setParentController:rootController];
        }
        //if ([kbController respondsToSelector:@selector(specifiersWithSpecifier:)])
        //[kbController specifiersWithSpecifier:nil];
    }
    NSArray *specifiers = [kbController loadAllKeyboardPreferences];
    PSSpecifier *autoCapsSpecifier;
    for (PSSpecifier *sp in specifiers){
        if ([sp.identifier isEqualToString:@"KeyboardAutocapitalization"]){
            autoCapsSpecifier = sp;
            break;
        }
    }
    if (autoCapsSpecifier){
        [kbController setKeyboardPreferenceValue:[NSNumber numberWithBool:value] forSpecifier:autoCapsSpecifier];
    }
    //[[objc_getClass("UIKeyboardPreferencesController") sharedPreferencesController] setValue:[NSNumber numberWithBool:value] forKey:8];
    //[[objc_getClass("UIKeyboardPreferencesController") sharedPreferencesController] synchronizePreferences];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("AppleKeyboardsSettingsChangedNotification"), NULL, NULL, YES);
    
    return nil;
}

-(NSDictionary *)runCommand:(NSString *)name withUserInfo:(NSDictionary *)userInfo{
    NSString *cmd = userInfo[@"value"];
    if ([cmd length] != 0){
        NSMutableArray *taskArgs = [[NSMutableArray alloc] init];
        taskArgs = [NSMutableArray arrayWithObjects:@"-c", cmd, nil];
        //taskArgs = [NSMutableArray arrayWithObjects:@"-c", @"stb -m $(date +'%T')", nil];
        NSTask * task = [[NSTask alloc] init];
        [task setLaunchPath:@"/bin/bash"];
        //[task setCurrentDirectoryPath:@"/"];
        [task setArguments:taskArgs];
        [task launch];
    }
    return nil;

}
@end
