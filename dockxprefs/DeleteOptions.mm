#include "DeleteOptions.h"
#include "../DockXHelper.h"
#include "../common.h"

static NSBundle *tweakBundle;


@implementation DeleteOptions

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *snippetEntrySpecifiers = [[NSMutableArray alloc] init];

        PSSpecifier *smartDeleteSpecGroup = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"SMART_DELETE") target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [smartDeleteSpecGroup setProperty:LOCALIZED(@"FOOTER_DELETE") forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:smartDeleteSpecGroup];
        
        NSString *deleteDirectionKey = kEnabledSmartDeletekey;
        if ([self.entryID containsString:@"deleteForwardAction:"]){
            deleteDirectionKey = kEnabledSmartDeleteForwardkey;
        }

        PSSpecifier *smartDeleteSpec = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"SMART_DELETE") target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
        [smartDeleteSpec setProperty:LOCALIZED(@"SMART_DELETE") forKey:@"label"];
        [smartDeleteSpec setProperty:deleteDirectionKey forKey:@"key"];
        [smartDeleteSpec setProperty:@NO forKey:@"default"];
        [smartDeleteSpec setProperty:kIdentifier forKey:@"defaults"];
        [smartDeleteSpec setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:smartDeleteSpec];
        
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
