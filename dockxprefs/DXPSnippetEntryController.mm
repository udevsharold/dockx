#import "DXPSnippetEntryController.h"
#import "../common.h"

static NSMutableDictionary *settings;
static NSBundle *tweakBundle;

@implementation DXPSnippetEntryController

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *snippetEntrySpecifiers = [[NSMutableArray alloc] init];
        
        PSSpecifier *singleTapGroup = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"SINGLE_TAP") target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [singleTapGroup setProperty:LOCALIZED(@"SINGLE_TAP") forKey:@"label"];
        [singleTapGroup setProperty:LOCALIZED(@"FOOTER_SHELL_SINGLE_TAP") forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:singleTapGroup];
        
        
        PSSpecifier *entryTitle = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"SHELL_TITLE") target:self set:@selector(setValue:specifier:) get:@selector(readValue:) detail:nil cell:PSEditTextCell edit:nil];
        [entryTitle setProperty:@YES forKey:@"noAutoCorrect"];
        [entryTitle setProperty:@"title" forKey:@"key"];
        [entryTitle setProperty:kIdentifier forKey:@"defaults"];
        [entryTitle setProperty:LOCALIZED(@"SHELL_TITLE") forKey:@"label"];
        [entryTitle setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:entryTitle];
        
        /*
         PSSpecifier *entryDescription = [PSSpecifier preferenceSpecifierNamed:@"Description" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSEditTextCell edit:@YES];
         [entryDescription setProperty:@NO forKey:@"noAutoCorrect"];
         [entryDescription setProperty:@"description" forKey:@"key"];
         [entryDescription setProperty:kIdentifier forKey:@"defaults"];
         [entryDescription setProperty:@"Description" forKey:@"label"];
         [entryDescription setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
         [snippetEntrySpecifiers addObject:entryDescription];
         */
        
        PSSpecifier *entryCommand = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"SHELL_COMMAND") target:self set:@selector(setValue:specifier:) get:@selector(readValue:) detail:nil cell:PSEditTextCell edit:nil];
        [entryCommand setProperty:@YES forKey:@"noAutoCorrect"];
        [entryCommand setProperty:@"command" forKey:@"key"];
        [entryCommand setProperty:kIdentifier forKey:@"defaults"];
        [entryCommand setProperty:LOCALIZED(@"SHELL_COMMAND") forKey:@"label"];
        [entryCommand setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:entryCommand];
        
        /*
         PSSpecifier *entryIconType = [PSSpecifier preferenceSpecifierNamed:@"IconType" target:self set:@selector(setValue:specifier:) get:@selector(readValue:) detail:nil cell:PSSegmentCell edit:nil];
         [entryIconType setValues:@[@(0), @(1)] titles:@[@"Icon Path", @"Emoji"]];
         [entryIconType setProperty:@"0" forKey:@"default"];
         [entryIconType setProperty:@"isEmoji" forKey:@"key"];
         [entryIconType setProperty:kIdentifier forKey:@"defaults"];
         [entryIconType setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
         [snippetEntrySpecifiers addObject:entryIconType];
         
         PSSpecifier *entryIcon = [PSSpecifier preferenceSpecifierNamed:@"Icon" target:self set:@selector(setValue:specifier:) get:@selector(readValue:) detail:nil cell:PSEditTextCell edit:@YES];
         [entryIcon setProperty:@YES forKey:@"noAutoCorrect"];
         [entryIcon setProperty:@"icon" forKey:@"key"];
         [entryIcon setProperty:kIdentifier forKey:@"defaults"];
         [entryIcon setProperty:@"Icon Path" forKey:@"label"];
         [entryIcon setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
         [snippetEntrySpecifiers addObject:entryIcon];
         */
        
        PSSpecifier *longPressGroup = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"LONG_PRESS") target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [longPressGroup setProperty:LOCALIZED(@"LONG_PRESS") forKey:@"label"];
        [longPressGroup setProperty:LOCALIZED(@"FOOTER_SHELL_LONG_PRESS") forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:longPressGroup];
        
        PSSpecifier *entryTitleLP = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"SHELL_TITLE") target:self set:@selector(setValue:specifier:) get:@selector(readValue:) detail:nil cell:PSEditTextCell edit:nil];
        [entryTitleLP setProperty:@YES forKey:@"noAutoCorrect"];
        [entryTitleLP setProperty:@"titleLP" forKey:@"key"];
        [entryTitleLP setProperty:kIdentifier forKey:@"defaults"];
        [entryTitleLP setProperty:LOCALIZED(@"SHELL_TITLE") forKey:@"label"];
        [entryTitleLP setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:entryTitleLP];
        
        PSSpecifier *entryCommandLP = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"SHELL_COMMAND") target:self set:@selector(setValue:specifier:) get:@selector(readValue:) detail:nil cell:PSEditTextCell edit:nil];
        [entryCommandLP setProperty:@YES forKey:@"noAutoCorrect"];
        [entryCommandLP setProperty:@"commandLP" forKey:@"key"];
        [entryCommandLP setProperty:kIdentifier forKey:@"defaults"];
        [entryCommandLP setProperty:LOCALIZED(@"SHELL_COMMAND") forKey:@"label"];
        [entryCommandLP setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:entryCommandLP];
        
        
        
        _specifiers = snippetEntrySpecifiers;
        
        if (!settings) settings = [[[DXPrefsManager sharedInstance] readPrefs] mutableCopy];
        
    }
    
    return _specifiers;
}

- (id)readValue:(PSSpecifier*)specifier {
    //NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
    //NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    //settings = [[[DXPrefsManager sharedInstance] readPrefs] mutableCopy];
    
    //[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    
    
    NSArray *arrayWithEntryID = [settings[@"snippets"] valueForKey:@"entryID"];
    HBLogDebug(@"array ID: %@", arrayWithEntryID);
    NSUInteger index = [arrayWithEntryID indexOfObject:self.entryID];
    HBLogDebug(@"index: %lu", (unsigned long)index);
    NSMutableDictionary *settingsSnippet = index != NSNotFound ? settings[@"snippets"][index] : nil;
    
    return (settingsSnippet[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setValue:(id)value specifier:(PSSpecifier*)specifier {
    //NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
    //NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    //settings = [[[DXPrefsManager sharedInstance] readPrefs] mutableCopy];
    HBLogDebug(@"settings: %@", settings);
    NSMutableArray *snippets;
    NSMutableDictionary *snippet;
    //[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    if (settings[@"snippets"] && [settings[@"snippets"] firstObject] != nil){
        snippets = [settings[@"snippets"] mutableCopy];
        NSArray *arrayWithEntryID = [settings[@"snippets"] valueForKey:@"entryID"];
        NSUInteger index = [arrayWithEntryID indexOfObject:self.entryID];
        HBLogDebug(@"index: %lu", (unsigned long)index);
        snippet = index != NSNotFound ? [[snippets objectAtIndex:index] mutableCopy] : [[NSMutableDictionary alloc] init];
        HBLogDebug(@"value: %@", value);
        
        //[snippet setObject:value forKey:specifier.properties[@"key"]];
        //[snippets replaceObjectAtIndex:index withObject:snippet];
        //[settings setObject:snippets forKey:@"snippets"];
        snippet[specifier.properties[@"key"]] = value;
        snippet[@"entryID"] = self.entryID;
        HBLogDebug(@"XXXXXXXX SNIPPET: %@", snippet);
        if (index != NSNotFound){
            [snippets replaceObjectAtIndex:index withObject:snippet];
        }else{
            [snippets addObject:snippet];
        }
    }else{
        snippets = [[NSMutableArray alloc] init];
        snippet = [[NSMutableDictionary alloc] init];
        snippet[specifier.properties[@"key"]] = value;
        snippet[@"entryID"] = self.entryID;
        [snippets addObject:snippet];
        
    }
    
    settings[@"snippets"] = snippets;
    HBLogDebug(@"settings: %@", settings);
    HBLogDebug(@"snippets: %@", settings[@"snippets"]);
    //[settings setObject:value atIndex:index];
    //[settings writeToFile:path atomically:YES];
    [[DXPrefsManager sharedInstance] writePrefs:settings];
    
    CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
    if (notificationName) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
    }
}

- (void)viewDidLoad {
    tweakBundle = [NSBundle bundleWithPath:bundlePath];
    [tweakBundle load];
    [super viewDidLoad];
}

@end
