#import "DXPGlobeOptions.h"
#import "../DXHelper.h"
#import "../common.h"

static NSBundle *tweakBundle;


@implementation DXPGlobeOptions

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *snippetEntrySpecifiers = [[NSMutableArray alloc] init];

        PSSpecifier *emojiKeyboardSpecGroup = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"EMOJI_KEYBOARD") target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [snippetEntrySpecifiers addObject:emojiKeyboardSpecGroup];
        
        
        PSSpecifier *emojiKeyboardSpec = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"SKIP_EMOJI") target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
        [emojiKeyboardSpec setProperty:LOCALIZED(@"SKIP_EMOJI") forKey:@"label"];
        [emojiKeyboardSpec setProperty:kEnabledSkipEmojikey forKey:@"key"];
        [emojiKeyboardSpec setProperty:@YES forKey:@"default"];
        [emojiKeyboardSpec setProperty:kIdentifier forKey:@"defaults"];
        [emojiKeyboardSpec setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:emojiKeyboardSpec];
        
        _specifiers = snippetEntrySpecifiers;
        
    }
    
    return _specifiers;
}

- (void)viewDidLoad {
    tweakBundle = [NSBundle bundleWithPath:bundlePath];
    [tweakBundle load];
    [super viewDidLoad];
}

@end
