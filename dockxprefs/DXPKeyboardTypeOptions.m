#import "../common.h"
#import "DXPKeyboardTypeOptions.h"
#import "../DXShortcutsGenerator.h"

static NSBundle *tweakBundle;

@implementation DXPKeyboardTypeOptions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return LOCALIZED(@"ENABLED_INPUT_TYPE");
        case 1:
            return LOCALIZED(@"DISABLED_INPUT_TYPE");
        default:
            return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self.currentOrder[0] count];
        case 1:
            return [self.currentOrder[1] count];
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return LOCALIZED(@"FOOTER_ENABLED");
        case 1:
            return @"";
        default:
            return @"";
            
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DockXKBTypeCell" forIndexPath:indexPath];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DockXKBTypeCell"];
    
    switch(indexPath.section) {
        case 0: {
            if (self.currentOrder[0] == nil || [self.currentOrder[0] count] <= indexPath.row)
                return nil;
            //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K != nil", @"label"];
            NSArray* labelTextlistDict = [self.currentOrder[0] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%@ IN self.@allKeys" , @"label" ]];
            NSArray *labelTextlist = [labelTextlistDict valueForKey:@"label"];
            cell.textLabel.text = [labelTextlist objectAtIndex:indexPath.row];
            break;
        }
        case 1: {
            if (self.currentOrder[1] == nil || [self.currentOrder[1] count] <= indexPath.row)
                return nil;
            NSArray* labelTextlistDict = [self.currentOrder[1] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%@ IN self.@allKeys" , @"label" ]];
            NSArray *labelTextlist = [labelTextlistDict valueForKey:@"label"];
            cell.textLabel.text = [labelTextlist objectAtIndex:indexPath.row];
        }
            break;
    }
    return cell;
}
/*
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
 DXPCustomActionViewController *actionViewController = [[CustomActionViewController alloc] init];
 
 actionViewController.fullOrder = @[self.firstOrder, self.fullOrder];
 actionViewController.identifier = self.currentOrder[indexPath.section][indexPath.row][@"data"];
 actionViewController.title = self.currentOrder[indexPath.section][indexPath.row][@"label"];
 
 [actionViewController setRootController: [self rootController]];
 [actionViewController setParentController: [self parentController]];
 [self pushController:actionViewController];
 [tableView deselectRowAtIndexPath:indexPath animated:YES];
 
 }
 */
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (self.tableView == nil)
        return;
    
    if (self.currentOrder[0] == nil)
        [self updateOrder:NO];
    
    NSString *objectToMove = [self.currentOrder[0] objectAtIndex:sourceIndexPath.row];
    [self.currentOrder[0] removeObjectAtIndex:sourceIndexPath.row];
    [self.currentOrder[0] insertObject:objectToMove atIndex:destinationIndexPath.row];
    [self.tableView reloadData];
    [self writeToFile];
    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            if ([self.currentOrder[0][indexPath.row][@"data"] isEqual:@-1]){
                return NO;
            }
            return [self.currentOrder[0] count] == 1?NO:YES;
        case 1:
            return NO;
        default:
            return NO;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0: {
            return YES;
            break;
        }
        case 1: {
            return YES;
            break;
        }
        default:
            return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            if (editingStyle == UITableViewCellEditingStyleDelete) {
                // Delete the row from the data source
                [tableView beginUpdates];
                [self.currentOrder[1] addObject:self.currentOrder[0][indexPath.row]];
                [self.currentOrder[0] removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                //[tableView endUpdates];
                
                //[tableView beginUpdates];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.currentOrder[1] count] - 1 inSection:1];
                [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                [tableView endUpdates];
                [self writeToFile];
                
            }
        }
            break;
        case 1: {
            if (editingStyle == UITableViewCellEditingStyleInsert) {
                [tableView beginUpdates];
                [self.currentOrder[0] addObject:self.currentOrder[1][indexPath.row]];
                [self.currentOrder[1] removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.currentOrder[0] count] - 1  inSection:0];
                [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                [tableView endUpdates];
                [self writeToFile];
                
                
            }
            
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            if ([self.currentOrder[0][indexPath.row][@"data"] isEqual:@-1]){
                return UITableViewCellEditingStyleNone;
            }
            return [self.currentOrder[0] count] == 2?UITableViewCellEditingStyleNone:UITableViewCellEditingStyleDelete;
        case 1:
            //return [self.currentOrder[0] count] == maxshortcuts?UITableViewCellEditingStyleNone:UITableViewCellEditingStyleInsert;
            return [self.currentOrder[1] count] == 0?UITableViewCellEditingStyleNone:UITableViewCellEditingStyleInsert;
        default:
            return UITableViewCellEditingStyleNone;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


- (void)writeToFile {
    
    PSSpecifier *defaultOrderSpecifier = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSLinkListCell edit:nil];
    [defaultOrderSpecifier setProperty:self.currentOrder forKey:@"default"];
    [defaultOrderSpecifier setProperty:kIdentifier forKey:@"defaults"];
    [defaultOrderSpecifier setProperty:@"keyboardtype" forKey:@"key"];
    [defaultOrderSpecifier setProperty:@"" forKey:@"label"];
    [defaultOrderSpecifier setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
    [self setPreferenceValue:self.currentOrder specifier:defaultOrderSpecifier];
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)kPrefsChangedIdentifier, NULL, NULL, YES);
    
}

- (void)updateOrder:(BOOL)reset{
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsPath] ?: [NSMutableDictionary dictionary];
    
    //BOOL newShortcutsAvailable = ([tweakVersion compare:prefs[@"version"] options:NSNumericSearch] == NSOrderedDescending);
    /*
     if (forceDefault){
     [prefs removeObjectForKey:@"shortcuts"];
     prefs[@"version"] = tweakVersion;
     [prefs writeToFile:kPrefsPath atomically:NO];
     }
     */
    //NSMutableDictionary *currentOrderDefault = [[NSMutableDictionary alloc] init];
    DXShortcutsGenerator *shortcutsGenerator = [DXShortcutsGenerator sharedInstance];
    NSArray *defaultOrderData = [shortcutsGenerator keyboardTypeData];
    NSArray *defaultOrderLabel = [shortcutsGenerator keyboardTypeLabel];
    
    //self.fullOrder = @[defaultOrderLabel, defaultOrderSelector, defaultOrderSelectorLP, defaultOrder12, defaultOrder13];
    
    NSMutableArray *fullOrderDict = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [defaultOrderLabel count]; i++){
        [fullOrderDict addObject: @{
            @"label" : defaultOrderLabel[i],
            @"data" : defaultOrderData[i],
        }];
    }
    self.fullOrder = fullOrderDict;
    
    
    //reset custom long press actions
    if (reset){
        //prefs[kKeyboardTypekey] = @[];
        [prefs removeObjectForKey:kKeyboardTypekey];
        [[DXPrefsManager sharedInstance] writePrefs:prefs];
    }
    
    //NSArray *defaultOrder = @[@"Select All", @"Copy", @"Paste", @"Cut", @"Undo", @"Redo"];
    BOOL newShortcutsAvailable = NO;
    if (prefs[@"keyboardtype"] && ([prefs[@"keyboardtype"] firstObject] != nil)){
        newShortcutsAvailable = defaultOrderLabel.count > ((NSArray *)prefs[@"keyboardtype"][0]).count + ((NSArray *)prefs[@"keyboardtype"][1]).count;
    }
    self.currentOrder = [NSMutableArray array];
    self.currentOrder[0] = [NSMutableArray array];
    self.currentOrder[1] = [NSMutableArray array];
    if (prefs[@"keyboardtype"][0]  && ([prefs[@"keyboardtype"][0] firstObject] != nil) && !reset){
        NSMutableArray *currentOrderDefault = [prefs[@"keyboardtype"][0] mutableCopy];
        for (NSInteger i = 0; i < [currentOrderDefault count]; i++){
            [self.currentOrder[0] addObject:[currentOrderDefault objectAtIndex:i]];
        }
    }else{
        self.currentOrder[0] = [NSMutableArray array];
        NSMutableArray *defaultOrderDict = [[NSMutableArray alloc] init];
        
        for (int i = 0 ; i < maxdefaultshortcutskbtype ; i++) {
            [defaultOrderDict addObject: @{
                @"label" : defaultOrderLabel[i],
                @"data" : defaultOrderData[i],
            }];
        }
        self.currentOrder[0] = defaultOrderDict;
    }
    if (prefs[@"keyboardtype"][1]  && ([prefs[@"keyboardtype"][1] firstObject] != nil) && !reset){
        NSMutableArray *currentOrderDefault = [prefs[@"keyboardtype"][1] mutableCopy];
        for (NSInteger i = 0; i < [currentOrderDefault count]; i++){
            [self.currentOrder[1] addObject:[currentOrderDefault objectAtIndex:i]];
        }
        if (newShortcutsAvailable){
            NSMutableArray *fullOrderDict = [[NSMutableArray alloc] init];
            for (int i = 0 ; i < [defaultOrderLabel count] ; i++) {
                [fullOrderDict addObject: @{
                    @"label" : defaultOrderLabel[i],
                    @"data" : defaultOrderData[i]
                }];
            }
            NSMutableArray *newShortcuts = [NSMutableArray arrayWithArray:fullOrderDict];
            [newShortcuts removeObjectsInArray:self.currentOrder[0]];
            [newShortcuts removeObjectsInArray:self.currentOrder[1]];
            for (NSInteger i = 0; i < [newShortcuts count]; i++){
                [self.currentOrder[1] addObject:[newShortcuts objectAtIndex:i]];
            }
            [[DXPrefsManager sharedInstance] writePrefs:prefs];
            
            /*
             //[prefs writeToFile:kPrefsPath atomically:NO];
             if ([NSHomeDirectory() isEqualToString:@"/var/mobile"]) {
             CFPreferencesSetMultiple((__bridge CFDictionaryRef)prefs, nil, (CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
             CFPreferencesSynchronize((CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
             } else {
             [prefs writeToFile:kPrefsPath atomically:NO];
             }
             */
        }
    }else if ([prefs[@"keyboardtype"][0] count] != defaultOrderLabel.count){
        self.currentOrder[1] = [NSMutableArray array];
        NSMutableArray *defaultOrderDict = [[NSMutableArray alloc] init];
        
        for (int i = maxdefaultshortcutskbtype ; i < [defaultOrderLabel count] ; i++) {
            [defaultOrderDict addObject: @{
                @"label" : defaultOrderLabel[i],
                @"data" : defaultOrderData[i]
            }];
        }
        self.currentOrder[1] = defaultOrderDict;
    }
    
}

-(void)reset{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DockX" message:LOCALIZED(@"RESET_TO_DEFAULT_MESSAGE") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *resetAction = [UIAlertAction actionWithTitle:LOCALIZED(@"ANSWER_YES") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self updateOrder:YES];
        [self.tableView reloadData];
        [self writeToFile];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LOCALIZED(@"ANSWER_NO") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:resetAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if( sourceIndexPath.section != proposedDestinationIndexPath.section )
    {
        return sourceIndexPath;
    }
    else
    {
        return proposedDestinationIndexPath;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[self writeToFile];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateOrder:NO];
}

- (void)viewDidLoad {
    tweakBundle = [NSBundle bundleWithPath:bundlePath];
    [tweakBundle load];
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"DockXKBTypeCell"];
    [self.tableView setEditing:YES];
    [self.tableView setAllowsSelection:NO];
    //self.tableView.allowsSelectionDuringEditing=YES;
    
    ((UIViewController *)self).title = LOCALIZED(@"KEYBOARD_INPUT_TYPE_TITLE");
    self.view = self.tableView;
    
    self.resetBtn = [[UIBarButtonItem alloc] initWithTitle:LOCALIZED(@"RESET") style:UIBarButtonItemStylePlain target:self action:@selector(reset)];
    //self.addSnippetBtn.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = self.resetBtn;
    
}


@end


