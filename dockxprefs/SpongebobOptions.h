#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface SpongebobOptions : PSListController <UISearchBarDelegate>
@end

@interface PSSpecifier (SpongebobOptions)
-(void)setValues:(id)arg1 titles:(id)arg2;
@end
