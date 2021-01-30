#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface SnippetEntryController : PSListController
@property (nonatomic,readwrite) NSString *entryID;

@end

@interface PSSpecifier (SnippetEntryController)
-(void)setValues:(id)arg1 titles:(id)arg2;
@end
