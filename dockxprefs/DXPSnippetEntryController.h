#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface DXPSnippetEntryController : PSListController
@property (nonatomic,readwrite) NSString *entryID;

@end

@interface PSSpecifier (DXPSnippetEntryController)
-(void)setValues:(id)arg1 titles:(id)arg2;
@end
