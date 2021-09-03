#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface DXPDeleteOptions : PSListController <UISearchBarDelegate>
@property (nonatomic,readwrite) NSString *entryID;
@end
