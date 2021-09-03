#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface DXPCustomActionViewController : PSViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic,readwrite) NSString *identifier;
@property (nonatomic,readwrite) NSString *keyID;
@property (nonatomic, strong) NSArray *fullOrder;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath2;
@property (nonatomic, strong) NSMutableDictionary *prefs;
@property(nonatomic, retain) UIBarButtonItem *defaultBtn;
@end
