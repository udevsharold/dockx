#include "GesturePickerController.h"
#include "CustomActionViewController.h"
#include "../common.h"

static NSBundle *tweakBundle;


@implementation GesturePickerController

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *snippetEntrySpecifiers = [[NSMutableArray alloc] init];
        
        PSSpecifier *gestureTypeGroup = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"GESTURES") target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [gestureTypeGroup setProperty:LOCALIZED(@"FOOTER_SHOOTING_STAR") forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:gestureTypeGroup];

        PSSpecifier *longPressSpec = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"LONG_PRESS") target:nil set:nil get:nil detail:NSClassFromString(@"GesturePickerController") cell:PSLinkListCell edit:nil];
        [longPressSpec setProperty:LOCALIZED(@"LONG_PRESS") forKey:@"label"];
        [snippetEntrySpecifiers addObject:longPressSpec];
        
        PSSpecifier *doubleTapSpec = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"DOUBLE_TAP") target:nil set:nil get:nil detail:NSClassFromString(@"GesturePickerController") cell:PSLinkListCell edit:nil];
        [doubleTapSpec setProperty:LOCALIZED(@"DOUBLE_TAP") forKey:@"label"];
        [snippetEntrySpecifiers addObject:doubleTapSpec];
        
        PSSpecifier *shootingStarSpec = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"SHOOTING_STAR") target:nil set:nil get:nil detail:NSClassFromString(@"GesturePickerController") cell:PSLinkListCell edit:nil];
        [shootingStarSpec setProperty:LOCALIZED(@"SHOOTING_STAR") forKey:@"label"];
        [snippetEntrySpecifiers addObject:shootingStarSpec];
        
    
        
        _specifiers = snippetEntrySpecifiers;
        
    }
    
    return _specifiers;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    CustomActionViewController *actionViewController = [[CustomActionViewController alloc] init];

    actionViewController.fullOrder = self.fullOrder;
    actionViewController.identifier = self.identifier;
    
    switch (indexPath.row) {
        case 0:
            actionViewController.keyID = kCustomActionskey;
            break;
        case 1:
            actionViewController.keyID = kCustomActionsDTkey;
            break;
        case 2:
            actionViewController.keyID = kCustomActionsSTkey;
            break;
        default:
            actionViewController.keyID = kCustomActionskey;
            break;
    }
    
    actionViewController.title = cell.textLabel.text;
    
    [actionViewController setRootController: [self rootController]];
    [actionViewController setParentController: [self parentController]];
    [self pushController:actionViewController];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    

}

- (void)viewDidLoad {
    tweakBundle = [NSBundle bundleWithPath:bundlePath];
    [tweakBundle load];
    [super viewDidLoad];
}
@end
