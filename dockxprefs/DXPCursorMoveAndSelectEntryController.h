#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface DXPCursorMoveAndSelectEntryController : PSListController
@property (nonatomic,readwrite) NSString *entryID;
@property (nonatomic,retain) PSSpecifier *textSpecifier;
@property (nonatomic,retain) PSSpecifier *textSpecifierLP;
@end

@interface PSSpecifier (DXPCursorMoveAndSelectEntryController)
-(void)setValues:(id)arg1 titles:(id)arg2;
@end
