#import "DXPCustomizationController.h"
#import "../common.h"
#import "../DXHelper.h"

static UISearchController *searchController;
static NSBundle *tweakBundle;


@implementation DXPCustomizationController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Customization" target:self];
        
        NSArray *dynamicCell = @[@"pyslider", @"timerslider",@"shortcutstintpicker",@"toasttintpicker",@"toastbackgroundtintpicker", @"granularityslider", @"displaytypeselection", @"gesturetypeselection", @"gesturebuttonselection",@"shortcutstintselection", @"toasttintselection", @"toastbackgroundtintselection", @"shortcutsbackgroundtintpicker", @"shortcutsbackgroundtintselection"];
        self.dynamicSpecifiers = (!self.dynamicSpecifiers) ? [[NSMutableDictionary alloc] init] : self.dynamicSpecifiers;
        for(PSSpecifier *specifier in _specifiers) {
            if([dynamicCell containsObject:[specifier propertyForKey:@"id"]]) {
                [self.dynamicSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
            }
        }
    }
    
    
    return _specifiers;
}

-(void)viewDidLoad  {
    tweakBundle = [NSBundle bundleWithPath:bundlePath];
    [tweakBundle load];
    [super viewDidLoad];
    
    //search bar
    
    searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.definesPresentationContext = YES;
    searchController.hidesNavigationBarDuringPresentation = YES;
    //searchController.searchBar.delegate = self;
    searchController.searchBar.placeholder = LOCALIZED(@"SEARCHBAR_PLACEHOLDER");
    [searchController.searchBar setImage:[DXHelper imageForDockXWithPlaceholder:YES] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    if (@available(iOS 13.0, *)){
        searchController.dimsBackgroundDuringPresentation = NO;
    } else {
        searchController.obscuresBackgroundDuringPresentation = NO;
    }
    
    if (@available(iOS 11.0, *)){
        self.navigationItem.searchController = searchController;
        self.navigationItem.hidesSearchBarWhenScrolling = YES;
    }
    
    NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:kPrefsPath];
    if(![preferences[@"colorBOOL"] boolValue]){
        [(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintpicker"] setProperty:@NO forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toasttintpicker"] setProperty:@NO forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintpicker"] setProperty:@NO forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"shortcutsbackgroundtintpicker"] setProperty:@NO forKey:@"enabled"];

        [(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintselection"] setProperty:@NO forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toasttintselection"] setProperty:@NO forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintselection"] setProperty:@NO forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"shortcutsbackgroundtintselection"] setProperty:@NO forKey:@"enabled"];
        
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintpicker"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toasttintpicker"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintpicker"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"shortcutsbackgroundtintpicker"] animated:NO];

        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintselection"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toasttintselection"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintselection"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"shortcutsbackgroundtintselection"] animated:NO];
    }
}

-(id)readPreferenceValue:(PSSpecifier*)specifier{
    
    id value = [super readPreferenceValue:specifier];
    NSString *key = [specifier propertyForKey:@"key"];
    if([key isEqualToString:@"colorBOOL"]){
        [(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintpicker"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toasttintpicker"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintpicker"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"shortcutsbackgroundtintpicker"] setProperty:value forKey:@"enabled"];
        
        [(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintselection"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toasttintselection"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintselection"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"shortcutsbackgroundtintselection"] setProperty:value forKey:@"enabled"];

        //[self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintpicker"] animated:NO];
        //[self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toasttintpicker"] animated:NO];
        //[self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintpicker"] animated:NO];
        //[self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"shortcutsbackgroundtintpicker"] animated:NO];

        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintselection"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toasttintselection"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintselection"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"shortcutsbackgroundtintselection"] animated:NO];

    }
    return value;
}


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier{
    [super setPreferenceValue:value specifier:specifier];
    NSString *key = [specifier propertyForKey:@"key"];
    if([key isEqualToString:@"colorBOOL"]){
        [(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintpicker"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toasttintpicker"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintpicker"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"shortcutsbackgroundtintpicker"] setProperty:value forKey:@"enabled"];

        [(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintselection"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toasttintselection"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintselection"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"shortcutsbackgroundtintselection"] setProperty:value forKey:@"enabled"];

        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintpicker"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toasttintpicker"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintpicker"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"shortcutsbackgroundtintpicker"] animated:NO];

        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintselection"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toasttintselection"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintselection"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"shortcutsbackgroundtintselection"] animated:NO];

    }
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    DXPrefsManager *prefsManager = [DXPrefsManager sharedInstance];
    NSUInteger tappedCount = [[prefsManager getValueForKey:@"searchedc"] longValue];
    [prefsManager setValue:@(tappedCount + 1) forKey:@"searchedc"];
    if (tappedCount + 1 == searchedCountEaster){
        [DXHelper showSearchCountEasterAlertFor:self searchController:searchController count:tappedCount+1 delay:0.5];
    }
    return YES;
}

@end
