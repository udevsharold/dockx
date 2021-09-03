#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface DXPSpongebobOptions : PSListController <UISearchBarDelegate>
@end

@interface PSSpecifier (DXPSpongebobOptions)
-(void)setValues:(id)arg1 titles:(id)arg2;
@end
