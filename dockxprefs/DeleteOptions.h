#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface DeleteOptions : PSListController <UISearchBarDelegate>
@property (nonatomic,readwrite) NSString *entryID;
@end
