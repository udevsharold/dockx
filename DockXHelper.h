@interface DockXHelper : NSObject
+(UIImage *)imageForDockXWithPlaceholder:(BOOL)placeholder;
+(UIImage *)imageForName:(NSString *)imageName withSystemColor:(BOOL)withSystemColor completion:(void (^)(BOOL isThirteen, BOOL isCustomImagePath))handler;
+(UIImage *)imageFromArray:(NSArray *)array atIndex:(NSUInteger)index withSystemColor:(BOOL)withSystemColor completion:(void (^)(BOOL isThirteen, BOOL isCustomImagePath))handler;
+(NSString *)labelFromArray:(NSArray *)array atIndex:(NSUInteger)index;
+(NSString *)actionNameFromArray:(NSArray *)array atIndex:(NSUInteger)index;
+(void)showSearchCountEasterAlertFor:(id)object searchController:(UISearchController *)searchController count:(NSUInteger)count delay:(double)delay;
+(NSString *)localizedStringForActionNamed:(NSString *)actionName shortName:(BOOL)shortName bundle:(NSBundle *)tweakBundle;
+(NSString *)localizedStringOfToastForActionNamed:(NSString *)actionName bundle:(NSBundle *)tweakBundle;
@end

