#import <Preferences/PSViewController.h>
#import <Preferences/PSSpecifier.h>

@interface KeyboardTypeOptions : PSViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *currentOrder;
@property (nonatomic, strong) NSArray *fullOrder;
@property(nonatomic, retain) UIBarButtonItem *resetBtn;
@end
