#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface DXPGesturePickerController : PSListController{
    UILabel *_label;
}
@property (nonatomic,readwrite) NSString *identifier;
@property (nonatomic, strong) NSArray *fullOrder;
@end

@interface PSSpecifier (DXPGesturePickerController)
-(void)setValues:(id)arg1 titles:(id)arg2;
@end
