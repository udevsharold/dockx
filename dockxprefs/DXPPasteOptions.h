#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface DXPPasteOptions : PSListController <UISearchBarDelegate>
@end

@interface PSSpecifier (DXPPasteOptions)
-(void)setValues:(id)arg1 titles:(id)arg2;
@end
