#import "DXPRootListController.h"
#import <spawn.h>
#import "../common.h"
#import "../DXHelper.h"

static UISearchController *searchController;
static NSBundle *tweakBundle;


@implementation DXPRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
        
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
/*
 -(void)reloadSpecifiers {
 [super reloadSpecifiers];
 
 NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:kPrefsPath];
 if(![preferences[@"toastBOOL"] boolValue]) {
 [self removeContiguousSpecifiers:@[self.dynamicSpecifiers[@"pyslider"]] animated:YES];
 [self removeContiguousSpecifiers:@[self.dynamicSpecifiers[@"timerslider"]] animated:YES];
 }
 }
 
 
 */

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
    //search bar
    
    
    CGRect frame = CGRectMake(0,0,self.table.bounds.size.width,170);
    CGRect Imageframe = CGRectMake(0,10,self.table.bounds.size.width,80);
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    headerView.backgroundColor = [UIColor colorWithRed: 0.20 green: 0.20 blue: 0.20 alpha: 1.00];

    //UIImage *headerImage = [UIImage systemImageNamed:@"doc.on.doc"];
    
    
    UIImage *headerImage = [[UIImage alloc]
                            initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/PreferenceBundles/DockXPrefs.bundle"] pathForResource:@"DockX512" ofType:@"png"]];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:Imageframe];
    [imageView setImage:headerImage];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [headerView addSubview:imageView];
    
    CGRect labelFrame = CGRectMake(0,imageView.frame.origin.y + 90 ,self.table.bounds.size.width,80);
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:40];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [headerLabel setText:@"DockX"];
    [headerLabel setFont:font];
    [headerLabel setTextColor:[UIColor colorWithRed: 0.60 green: 0.60 blue: 0.60 alpha: 1.00]];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [headerLabel setContentMode:UIViewContentModeScaleAspectFit];
    [headerLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [headerView addSubview:headerLabel];
    
    
    self.table.tableHeaderView = headerView;
    
    self.respringBtn = [[UIBarButtonItem alloc] initWithTitle:LOCALIZED(@"RESPRING") style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
    //self.addSnippetBtn.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = self.respringBtn;
    
    NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:kPrefsPath];
    if(![preferences[@"toastBOOL"] boolValue]) {
        [(PSSpecifier *)self.dynamicSpecifiers[@"pyslider"] setProperty:@NO forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"timerslider"] setProperty:@NO forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"displaytypeselection"] setProperty:@NO forKey:@"enabled"];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"pyslider"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"timerslider"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"displaytypeselection"] animated:NO];
    }else if(![preferences[@"enabledSpaceBarScrollingBOOL"] boolValue]){
        [(PSSpecifier *)self.dynamicSpecifiers[@"granularityslider"] setProperty:@NO forKey:@"enabled"];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"granularityslider"] animated:NO];
    }else if([preferences[@"dockmode"] intValue] == 3){
        [(PSSpecifier *)self.dynamicSpecifiers[@"gesturebuttonselection"] setProperty:@NO forKey:@"enabled"];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"gesturebuttonselection"] animated:NO];
    }else if([preferences[@"gesturebutton"] intValue] == 0){
        [(PSSpecifier *)self.dynamicSpecifiers[@"gesturetypeselection"] setProperty:@NO forKey:@"enabled"];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"gesturetypeselection"] animated:NO];
    }
}

-(id)readPreferenceValue:(PSSpecifier*)specifier{
    
    id value = [super readPreferenceValue:specifier];
    NSString *key = [specifier propertyForKey:@"key"];
    if([key isEqualToString:@"toastBOOL"]) {
        [(PSSpecifier *)self.dynamicSpecifiers[@"pyslider"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"timerslider"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"displaytypeselection"] setProperty:value forKey:@"enabled"];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"pyslider"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"timerslider"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"displaytypeselection"] animated:NO];
    }else if([key isEqualToString:@"enabledSpaceBarScrollingBOOL"]){
        [(PSSpecifier *)self.dynamicSpecifiers[@"granularityslider"] setProperty:value forKey:@"enabled"];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"granularityslider"] animated:NO];
    }else if([key isEqualToString:@"dockmode"]){
        if ([value intValue] < 3){
            [(PSSpecifier *)self.dynamicSpecifiers[@"gesturebuttonselection"] setProperty:@YES forKey:@"enabled"];
            [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"gesturebuttonselection"] animated:NO];
        }else{
            [(PSSpecifier *)self.dynamicSpecifiers[@"gesturebuttonselection"] setProperty:@NO forKey:@"enabled"];
            [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"gesturebuttonselection"] animated:NO];
        }
    }else if([key isEqualToString:@"dockmode"]){
        if ([value intValue] < 3){
            [(PSSpecifier *)self.dynamicSpecifiers[@"gesturebuttonselection"] setProperty:@YES forKey:@"enabled"];
            [(PSSpecifier *)self.dynamicSpecifiers[@"gesturetypeselection"] setProperty:@YES forKey:@"enabled"];
            [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"gesturebuttonselection"] animated:NO];
            [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"gesturetypeselection"] animated:NO];
        }else{
            [(PSSpecifier *)self.dynamicSpecifiers[@"gesturebuttonselection"] setProperty:@NO forKey:@"enabled"];
            [(PSSpecifier *)self.dynamicSpecifiers[@"gesturetypeselection"] setProperty:@NO forKey:@"enabled"];
            [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"gesturebuttonselection"] animated:NO];
            [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"gesturetypeselection"] animated:NO];
        }
    }else if([key isEqualToString:@"gesturebutton"]){
        if ([value intValue] > 0 && [[specifier propertyForKey:@"enabled"] boolValue]){
            [(PSSpecifier *)self.dynamicSpecifiers[@"gesturetypeselection"] setProperty:@YES forKey:@"enabled"];
            [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"gesturetypeselection"] animated:NO];
        }else{
            [(PSSpecifier *)self.dynamicSpecifiers[@"gesturetypeselection"] setProperty:@NO forKey:@"enabled"];
            [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"gesturetypeselection"] animated:NO];
        }
    }
    return value;
}


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier{
    [super setPreferenceValue:value specifier:specifier];
    NSString *key = [specifier propertyForKey:@"key"];
    if([key isEqualToString:@"toastBOOL"]) {
        [(PSSpecifier *)self.dynamicSpecifiers[@"pyslider"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"timerslider"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"displaytypeselection"] setProperty:value forKey:@"enabled"];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"pyslider"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"timerslider"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"displaytypeselection"] animated:NO];
    }else if([key isEqualToString:@"enabledSpaceBarScrollingBOOL"]){
        [(PSSpecifier *)self.dynamicSpecifiers[@"granularityslider"] setProperty:value forKey:@"enabled"];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"granularityslider"] animated:NO];
    }else if([key isEqualToString:@"dockmode"]){
        if ([value intValue] < 3){
            [(PSSpecifier *)self.dynamicSpecifiers[@"gesturebuttonselection"] setProperty:@YES forKey:@"enabled"];
            [(PSSpecifier *)self.dynamicSpecifiers[@"gesturetypeselection"] setProperty:@YES forKey:@"enabled"];
            [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"gesturebuttonselection"] animated:NO];
            [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"gesturetypeselection"] animated:NO];
        }else{
            [(PSSpecifier *)self.dynamicSpecifiers[@"gesturebuttonselection"] setProperty:@NO forKey:@"enabled"];
            [(PSSpecifier *)self.dynamicSpecifiers[@"gesturetypeselection"] setProperty:@NO forKey:@"enabled"];
            [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"gesturebuttonselection"] animated:NO];
            [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"gesturetypeselection"] animated:NO];
        }
    }else if([key isEqualToString:@"gesturebutton"]){
        if ([value intValue] > 0 && [[specifier propertyForKey:@"enabled"] boolValue]){
            [(PSSpecifier *)self.dynamicSpecifiers[@"gesturetypeselection"] setProperty:@YES forKey:@"enabled"];
            [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"gesturetypeselection"] animated:NO];
        }else{
            [(PSSpecifier *)self.dynamicSpecifiers[@"gesturetypeselection"] setProperty:@NO forKey:@"enabled"];
            [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"gesturetypeselection"] animated:NO];
        }
    }
}

- (void)donation {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.me/udevs"] options:@{} completionHandler:nil];
}

- (void)twitter {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/udevs9"] options:@{} completionHandler:nil];
}

- (void)reddit {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.reddit.com/user/h4roldj"] options:@{} completionHandler:nil];
}

- (void)respring {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DockX" message:LOCALIZED(@"RESPRING_MESSAGE") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *respringAction = [UIAlertAction actionWithTitle:LOCALIZED(@"ANSWER_YES") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSURL *relaunchURL = [NSURL URLWithString:@"prefs:root=DockX"];
        SBSRelaunchAction *restartAction = [NSClassFromString(@"SBSRelaunchAction") actionWithReason:@"RestartRenderServer" options:4 targetURL:relaunchURL];
        [[NSClassFromString(@"FBSSystemService") sharedService] sendActions:[NSSet setWithObject:restartAction] withResult:nil];
        
        /*
         pid_t pid;
         int status;
         const char *args[] = {"killall", "-9", "SpringBoard", NULL};
         posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char * const *)args, NULL);
         waitpid(pid, &status, WEXITED);
         */
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LOCALIZED(@"ANSWER_NO") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:respringAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
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
