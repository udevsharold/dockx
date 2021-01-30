#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface PasteOptions : PSListController <UISearchBarDelegate>
@end

@interface PSSpecifier (PasteOptions)
-(void)setValues:(id)arg1 titles:(id)arg2;
@end
