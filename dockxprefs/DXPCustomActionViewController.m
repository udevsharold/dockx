#import "DXPCustomActionViewController.h"
#import "../DXHelper.h"
#import "../common.h"

static NSBundle *tweakBundle;

@implementation DXPCustomActionViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return LOCALIZED(@"FIRST_ACTION");
        default:
            return LOCALIZED(@"SECOND_ACTION");
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return LOCALIZED(@"FOOTER_FIRST_ACTION");
        default:
            return @"";
            
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self.fullOrder[0] count];
        default:
            return [self.fullOrder[1] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DockXLPItemCell" forIndexPath:indexPath];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DockXLPItemCell"];
    
    UIImage *image;
    NSString *label;
    
    dispatch_semaphore_t smp = dispatch_semaphore_create(0);
    __block BOOL isCustomImagePath = NO;
    __block BOOL isThirteen = NO;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    switch(indexPath.section) {
        case 0: {
            if (self.fullOrder[0] == nil || [self.fullOrder[0] count] <= indexPath.row)
                return nil;
            
            label = [DXHelper localizedStringForActionNamed:[DXHelper actionNameFromArray:self.fullOrder[0] atIndex:indexPath.row] shortName:NO bundle:tweakBundle];
           // label = [DXHelper labelFromArray:self.fullOrder[0] atIndex:indexPath.row];
            image = [DXHelper imageFromArray:self.fullOrder[0] atIndex:indexPath.row withSystemColor:YES completion:^(BOOL thirteen, BOOL customPath){
                isThirteen = thirteen;
                isCustomImagePath = customPath;
                dispatch_semaphore_signal(smp);
            }];
            dispatch_semaphore_wait(smp, DISPATCH_TIME_FOREVER);
            if (!isThirteen && isCustomImagePath){
                [cell.imageView setTintColor:[UIColor blackColor]];
            }
            
            if ([self.selectedIndexPath compare:indexPath] == NSOrderedSame  && self.selectedIndexPath != nil){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
        }
        case 1: {
            if (self.fullOrder[1] == nil || [self.fullOrder[1] count] <= indexPath.row)
                return nil;
            
            label = [DXHelper localizedStringForActionNamed:[DXHelper actionNameFromArray:self.fullOrder[1] atIndex:indexPath.row] shortName:NO bundle:tweakBundle];

            //label = [DXHelper labelFromArray:self.fullOrder[1] atIndex:indexPath.row];
            image = [DXHelper imageFromArray:self.fullOrder[1] atIndex:indexPath.row withSystemColor:YES completion:^(BOOL thirteen, BOOL customPath){
                isThirteen = thirteen;
                isCustomImagePath = customPath;
                dispatch_semaphore_signal(smp);
            }];
            dispatch_semaphore_wait(smp, DISPATCH_TIME_FOREVER);
            if (!isThirteen && isCustomImagePath){
                [cell.imageView setTintColor:[UIColor blackColor]];
            }
            
            if ([self.selectedIndexPath2 compare:indexPath] == NSOrderedSame  && self.selectedIndexPath2 != nil){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
        }
    }
    cell.textLabel.text = label;
    cell.imageView.image = image;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *customActionsArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *customActionsEntry = [[NSMutableDictionary alloc] init];
    NSUInteger index = 0;
    BOOL exist = NO;
    if (self.prefs[self.keyID] && [self.prefs[self.keyID] firstObject] != nil){
        customActionsArray = [self.prefs[self.keyID] mutableCopy];
        NSArray *arrayWithListenerID = [self.prefs[self.keyID] valueForKey:@"identifier"];
        index = [arrayWithListenerID indexOfObject:self.identifier];
        customActionsEntry = index != NSNotFound ? [[customActionsArray objectAtIndex:index] mutableCopy] : customActionsEntry;
        if ([customActionsEntry count] > 0){
            exist = YES;
        }
    }
    customActionsEntry[@"identifier"] = self.identifier;
    
    UITableViewCell *currentCell =  [tableView cellForRowAtIndexPath:indexPath];
    
    UITableViewCell *oldCell;
    
    switch(indexPath.section) {
        case 0: {
            oldCell =  [tableView cellForRowAtIndexPath:self.selectedIndexPath];
            if (currentCell.accessoryType == UITableViewCellAccessoryNone){
                currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
                [customActionsEntry setObject:self.fullOrder[0][indexPath.row][@"selector"] forKey:@"selector"];
                //customActionsEntry[@"selector"] = self.fullOrder[0][indexPath.row][@"selector"];
            }else{
                currentCell.accessoryType = UITableViewCellAccessoryNone;
                [customActionsEntry setObject:@"" forKey:@"selector"];
                //customActionsEntry[@"selector"] = @"";
                
            }
            if ([self.selectedIndexPath compare:indexPath] != NSOrderedSame && self.selectedIndexPath != nil){
                if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark ){
                    oldCell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
            self.selectedIndexPath = indexPath;
            break;
        }
        case 1:{
            oldCell =  [tableView cellForRowAtIndexPath:self.selectedIndexPath2];
            if (currentCell.accessoryType == UITableViewCellAccessoryNone){
                currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
                [customActionsEntry setObject:self.fullOrder[1][indexPath.row][@"selector"] forKey:@"selector2"];
                //customActionsEntry[@"selector2"] = self.fullOrder[1][indexPath.row][@"selector"];
            }else{
                currentCell.accessoryType = UITableViewCellAccessoryNone;
                [customActionsEntry setObject:@"" forKey:@"selector2"];
                //customActionsEntry[@"selector2"] = @"";
                
            }
            if ([self.selectedIndexPath2 compare:indexPath] != NSOrderedSame && self.selectedIndexPath2 != nil){
                if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark ){
                    oldCell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
            self.selectedIndexPath2 = indexPath;
            break;
        }
    }
    
    if (!customActionsEntry[@"selector"]){
        [customActionsEntry setObject:@"" forKey:@"selector"];
    }
    if (!customActionsEntry[@"selector2"]){
        [customActionsEntry setObject:@"" forKey:@"selector2"];
    }
    
    if (exist) {
        [customActionsArray replaceObjectAtIndex:index withObject:customActionsEntry];
    }else{
        
        [customActionsArray addObject:customActionsEntry];
    }
    [self.prefs setObject:customActionsArray forKey:self.keyID];
    
    [[DXPrefsManager sharedInstance] writePrefs:self.prefs];
    //[self.prefs writeToFile:kPrefsPath atomically:YES];
    
    
    CFStringRef notificationName = (__bridge CFStringRef)kPrefsChangedIdentifier;
    if (notificationName) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    
}

-(void)resetToDefault{
    self.selectedIndexPath = nil;
    self.selectedIndexPath2 = nil;
    
    NSMutableArray *customActionsArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *customActionsEntry = [[NSMutableDictionary alloc] init];
    NSUInteger index = 0;
    BOOL exist = NO;
    if (self.prefs[self.keyID] && [self.prefs[self.keyID] firstObject] != nil){
        customActionsArray = [self.prefs[self.keyID] mutableCopy];
        NSArray *arrayWithListenerID = [self.prefs[self.keyID] valueForKey:@"identifier"];
        index = [arrayWithListenerID indexOfObject:self.identifier];
        customActionsEntry = index != NSNotFound ? [[customActionsArray objectAtIndex:index] mutableCopy] : customActionsEntry;
        if ([customActionsEntry count] > 0){
            exist = YES;
        }
    }
    if (exist){
        [customActionsArray removeObjectAtIndex:index];
        self.prefs[self.keyID] = customActionsArray;
        [[DXPrefsManager sharedInstance] writePrefs:self.prefs];
    }
    [self.tableView reloadData];
    
    CFStringRef notificationName = (__bridge CFStringRef)kPrefsChangedIdentifier;
    if (notificationName) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
    }
    
    
    
}

- (void)viewDidLoad {
    tweakBundle = [NSBundle bundleWithPath:bundlePath];
    [tweakBundle load];
    [super viewDidLoad];
    self.prefs = [[[DXPrefsManager sharedInstance] readPrefs] mutableCopy];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"DockXLPItemCell"];
    //[self.tableView setEditing:YES];
    [self.tableView setAllowsSelection:YES];
    self.tableView.allowsMultipleSelection = NO;
    //self.tableView.allowsSelectionDuringEditing=YES;
    
    //((UIViewController *)self).title = @"Long Press Action";
    //self.selectedIndexPath2 = self.selectedIndexPath2 ? : [NSIndexPath indexPathForRow:0 inSection:0];
    //self.prefs = [self fetchPrefs];
    
    
    //self.selectedIndexPath2 = [NSIndexPath indexPathForRow:0 inSection:0];
    if ( [self.prefs[self.keyID] count] > 0 ){
        NSArray* arrayWithID = [self.prefs[self.keyID] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%@ IN self.@allKeys" , @"identifier" ]];
        NSArray *IDList = [arrayWithID valueForKey:@"identifier"];
        NSUInteger index = [IDList indexOfObject:self.identifier];
        HBLogDebug(@"index of id: %ld", index);
        
        if (index != NSNotFound){
            NSString *selectedAction = self.prefs[self.keyID][index][@"selector"];
            NSString *selectedAction2 = self.prefs[self.keyID][index][@"selector2"];
            HBLogDebug(@"selectedAction: %@", selectedAction);
            HBLogDebug(@"selectedAction2: %@", selectedAction2);
            
            NSArray* arrayWithSelector = [self.fullOrder[0] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%@ IN self.@allKeys" , @"selector" ]];
            NSArray* arrayWithSelector2 = [self.fullOrder[1] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%@ IN self.@allKeys" , @"selector" ]];
            NSArray *selectorList = [arrayWithSelector valueForKey:@"selector"];
            NSArray *selectorList2 = [arrayWithSelector2 valueForKey:@"selector"];
            
            NSUInteger selectorindex = [selectorList indexOfObject:selectedAction];
            NSUInteger selectorindex2 = [selectorList2 indexOfObject:selectedAction2];
            
            HBLogDebug(@"selectorindex: %ld",selectorindex);
            HBLogDebug(@"selectorindex2: %ld",selectorindex2);
            
            if (selectorindex != NSNotFound){
                self.selectedIndexPath = [NSIndexPath indexPathForRow:selectorindex inSection:0];
            }
            
            if (selectorindex2 != NSNotFound){
                self.selectedIndexPath2 = [NSIndexPath indexPathForRow:selectorindex2 inSection:1];
            }
        }
    }
    self.view = self.tableView;
    
    self.defaultBtn = [[UIBarButtonItem alloc] initWithTitle:LOCALIZED(@"DEFAULT") style:UIBarButtonItemStylePlain target:self action:@selector(resetToDefault)];
    self.navigationItem.rightBarButtonItem = self.defaultBtn;
    
    //self.addcustomActionsEntryBtn.tintColor = [UIColor blackColor];
}
@end
