#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/Preferences.h>


@interface PSControlTableCell : PSTableCell{
    UIControl * _control;
}

@property (nonatomic, retain) UIControl *control;
@end

@interface PSSwitchTableCell : PSControlTableCell
- (id)initWithStyle:(int)style reuseIdentifier:(id)identifier specifier:(id)specifier;
@end

@interface PSListController (DockX)
-(void)setPreferenceValue:(id)value forSpecifier:(PSSpecifier*)specifier;
- (void)setCellForRowAtIndexPath:(NSIndexPath *)indexPath enabled:(BOOL)enabled;
@end

@interface DXPCustomizationController : PSListController <UISearchBarDelegate>
 @property (nonatomic, retain) NSMutableDictionary *dynamicSpecifiers;
@end
