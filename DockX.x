#include "common.h"
#include "DockX.h"
#import "ToastWindowController.h"
#import <SparkColourPicker/SparkColourPickerUtils.h>
#include "NSTask.h"
#include "LoremIpsum.h"
#include "DockXHelper.h"
#include "UIShortTapGestureRecognizer.h"
#import <dlfcn.h>

static id delegate;
static UIKeyboardImpl *kbImpl;
static UIColor *currentTintColor;
static UIColor *toastTintColor;
static UIColor *toastBackgroundTintColor;
static UIColor *currentBackgroundTintColor;
static BOOL isLandscape = NO;
static NSMutableDictionary *prefs;
static BOOL isDictating = NO;
static BOOL toggledOn = YES;
static UIKeyboardDockView *dockView;
//static BOOL isSandboxed = NO;
static CGPoint startPosition;
static CGPoint endPosition;
static NSDate *prevTime = nil;
static BOOL singleTapDictationEnabled = NO;
static BOOL singleTapGlobeEnabled = NO;
static BOOL isTrackPadMode = NO;
static BOOL isSpringBoard = YES;
static BOOL isApplication = NO;
static BOOL isSafari = NO;
static KeyboardController *kbController;
static BOOL shouldUpdateTrueKBType = NO;
static BOOL shouldPerformBatchUpdate = YES;
//static BOOL shouldSendScrollExecution = YES;
static NSString *key;
static BOOL isDraggedGesture = NO;
static UIKeyboardDockView *dockV;
static BOOL isPossibleDraggingForShootingStar = NO;
static BOOL isPagingEnabled = YES;
static BOOL useShortenedLabel = NO;
static NSBundle *tweakBundle;
static BOOL firstInit = YES;

float topInset = topInsetDefault;
float bottomInset = bottomInsetDefault;
float leftInset = leftInsetDefault;
float rightInset = rightInsetDefault;

float buttonRadius = cellsRadiusDefault;
float buttonHeight = cellsHeightDefault;
float buttonSpacing = spacingBetweenCellsDefault;

CGFloat leadingOffset = leadingOffsetDefault;
CGFloat trailingOffset = trailingOffsetDefault;
CGFloat heightOffset = heightOffsetDefault;
CGFloat bottomOffset = bottomOffsetDefault;

CGFloat leadingHBRightOffset = leadingOffsetHandBiasRightDefault;
CGFloat trailingHBRightOffset = trailingOffsetHandBiasRightDefault;

CGFloat leadingHBLeftOffset = leadingOffsetHandBiasLeftDefault;
CGFloat trailingHBLeftOffset = trailingOffsetHandBiasLeftDefault;

BOOL preferencesBool(NSString* key, BOOL fallback) {
    NSNumber* value;
    if (prefs) value = prefs[key];
    return value ? [value boolValue] : fallback;
}

float preferencesFloat(NSString* key, float fallback) {
    NSNumber* value;
    if (prefs) value = prefs[key];
    return value ? [value floatValue] : fallback;
}

int preferencesInt(NSString* key, int fallback) {
    NSNumber* value;
    if (prefs) value = prefs[key];
    return value ? [value intValue] : fallback;
}

NSString *preferencesSelectorForIdentifier(NSString* identifier, int selectorNum, int gestureType, NSString *fallback) {
    //HBLogDebug(@"identifier: %@", identifier);
    //0-long press
    //1-double tap
    //2-shooting star
    NSString *k;
    switch (gestureType) {
        case 0:
            k = kCustomActionskey;
            break;
        case 1:
            k = kCustomActionsDTkey;
            break;
        case 2:
            k = kCustomActionsSTkey;
            break;
        default:
            k = kCustomActionskey;
            break;
    }
    
    NSArray* arrayWithID = [prefs[k] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%@ IN self.@allKeys" , @"identifier" ]];
    NSArray* arrayWithSelector = [prefs[k] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%@ IN self.@allKeys" , @"selector" ]];
    NSArray* arrayWithSelector2 = [prefs[k] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%@ IN self.@allKeys" , @"selector2" ]];
    
    NSArray *IDList = [arrayWithID valueForKey:@"identifier"];
    NSArray *selectorList = [arrayWithSelector valueForKey:@"selector"];
    NSArray *selectorList2 = [arrayWithSelector2 valueForKey:@"selector2"];
    
    NSUInteger index = [IDList indexOfObject:identifier];
    //HBLogDebug(@"prefs: %@", prefs[k]);
    
    //HBLogDebug(@"arrayWithSelector: %@", arrayWithSelector);
    
    //HBLogDebug(@"selectorList: %@", selectorList);
    //HBLogDebug(@"index: %ld", index);
    
    //HBLogDebug(@"return %@", index != NSNotFound ? selectorList[index] : fallback);
    //HBLogDebug(@"return2 %@", index != NSNotFound ? selectorList2[index] : fallback);
    
    //NSMutableDictionary *IDDict = index != NSNotFound ? prefs[kCustomActionskey][index] : nil;
    if (selectorNum == 1){
        return index != NSNotFound && (index <= [selectorList count] -1) ? selectorList[index] : fallback;
    }else{
        return index != NSNotFound  && (index <= [selectorList2 count] -1)  ? selectorList2[index] : fallback;
    }
}

@implementation DockXCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor clearColor];
        //self.backgroundColor = [UIColor clearColor];
        
        //_btn = [[UIButton alloc] initWithFrame:CGRectZero];
        _btn = [UIButton buttonWithType:UIButtonTypeSystem];
        
        //[_btn setTitle:_btn.title];
        _btn.translatesAutoresizingMaskIntoConstraints = NO;
        //[self.contentView addSubview:_btn];
        [self.contentView addSubview:_btn];
        
        [NSLayoutConstraint activateConstraints: @[
            [_btn.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
            [_btn.bottomAnchor constraintEqualToAnchor: self.contentView.bottomAnchor],
            [_btn.leadingAnchor constraintLessThanOrEqualToAnchor: self.contentView.leadingAnchor constant:-5],
            [_btn.trailingAnchor constraintLessThanOrEqualToAnchor: self.contentView.trailingAnchor constant:-5],
            [_btn.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor]
        ]];
    }
    return self;
}

-(void)shakeCell:(NSNotification*)notification{
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
    [shake setDuration:0.05];
    [shake setRepeatCount:2];
    [shake setAutoreverses:YES];
    [shake setFromValue:[NSValue valueWithCGPoint:
                         CGPointMake(self.center.x - 5,self.center.y)]];
    [shake setToValue:[NSValue valueWithCGPoint:
                       CGPointMake(self.center.x + 5, self.center.y)]];
    [self.layer removeAllAnimations];
    [self.layer addAnimation:shake forKey:@"position"];
}

@end

@implementation DockXCollectionView
/*
 +(BOOL)supportsSecureCoding{
 return YES;
 }
 
 -(void)encodeWithCoder:(NSCoder *)encoder {
 
 //[encoder encodeObject:self forKey:@"self"];
 [super encodeWithCoder:encoder];
 [encoder encodeObject:self.shortcuts forKey:@"shortcuts"];
 
 
 [encoder encodeObject:self.fullshortcuts forKey:@"fullshortcuts"];
 
 
 
 //[encoder encodeObject:self.keyboardTypeDataFull forKey:@"keyboardTypeDataFull"];
 //[encoder encodeObject:self.keyboardTypeLabelFull forKey:@"keyboardTypeLabelFull"];
 
 //[encoder encodeObject:self.kbType forKey:@"kbType"];
 //[encoder encodeObject:self.kbTypeLabel forKey:@"kbTypeLabel"];
 
 
 /*
 [encoder encodeObject:@(self.hapticType) forKey:@"hapticType"];
 [encoder encodeObject:@(self.refreshView) forKey:@"refreshView"];
 [encoder encodeObject:@(self.firstCellVisible) forKey:@"firstCellVisible"];
 [encoder encodeObject:self.commandTitle forKey:@"commandTitle"];
 [encoder encodeObject:@(self.insertTextActionType) forKey:@"insertTextActionType"];
 [encoder encodeObject:@(self.isWordSender) forKey:@"isWordSender"];
 
 [encoder encodeObject:self.backgroundColor forKey:@"backgroundColor"];
 [encoder encodeObject:self.delegate forKey:@"delegate"];
 [encoder encodeObject:self.dataSource forKey:@"dataSource"];
 [encoder encodeObject:@(self.showsVerticalScrollIndicator) forKey:@"showsVerticalScrollIndicator"];
 [encoder encodeObject:@(self.showsHorizontalScrollIndicator) forKey:@"showsHorizontalScrollIndicator"];
 [encoder encodeObject:@(self.pagingEnabled) forKey:@"pagingEnabled"];
 [encoder encodeObject:@(self.moveCursorWithSelect) forKey:@"moveCursorWithSelect"];
 
 [encoder encodeObject:@(self.trueKBType) forKey:@"trueKBType"];
 [encoder encodeObject:self.keyboardInputTypeCell forKey:@"keyboardInputTypeCell"];
 *
 
 }
 
 -(id)initWithCoder:(NSCoder *)decoder {
 //if (self = [super initWithCoder:decoder]) {
 //self = [decoder decodeObjectForKey:@"self"];
 UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
 flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
 flowLayout.minimumInteritemSpacing = currentBackgroundTintColor?buttonSpacing:0;
 flowLayout.minimumLineSpacing = 0;
 
 if (self = [super initWithFrame:CGRectZero collectionViewLayout:flowLayout]){
 
 self.shortcuts = [decoder decodeObjectOfClass:[NSArray class] forKey:@"shortcuts"];
 self.fullshortcuts = [decoder decodeObjectOfClass:[NSArray class] forKey:@"fullshortcuts"];
 
 self.hapticType = 1;
 self.refreshView = YES;
 self.firstCellVisible = YES;
 
 self.keyboardTypeDataFull = [decoder decodeObjectOfClass:[NSArray class] forKey:@"keyboardTypeDataFull"];
 self.keyboardTypeLabelFull = [decoder decodeObjectOfClass:[NSArray class] forKey:@"keyboardTypeLabelFull"];
 self.kbType = [decoder decodeObjectOfClass:[NSArray class] forKey:@"kbType"];
 self.kbTypeLabel = [decoder decodeObjectOfClass:[NSArray class] forKey:@"kbTypeLabel"];
 self.commandTitle = @"";
 self.insertTextActionType = 0;
 self.isWordSender = NO;
 self.moveCursorWithSelect = NO;
 
 self.backgroundColor = [UIColor clearColor];
 self.delegate = self;
 self.dataSource = self;
 self.showsVerticalScrollIndicator = NO;
 self.showsHorizontalScrollIndicator = NO;
 self.pagingEnabled = preferencesBool(kPagingkey, YES);
 [self registerClass:NSClassFromString(@"DockXCell") forCellWithReuseIdentifier:@"kDockXCellID"];
 [self keyboardRotated:nil];
 
 
 /*
 self.hapticType = [[decoder decodeObjectForKey:@"hapticType"] intValue];
 self.refreshView = [[decoder decodeObjectForKey:@"refreshView"] boolValue];
 self.firstCellVisible = [[decoder decodeObjectForKey:@"firstCellVisible"] boolValue];
 self.keyboardTypeDataFull = [decoder decodeObjectForKey:@"keyboardTypeDataFull"];
 self.keyboardTypeLabelFull = [decoder decodeObjectForKey:@"keyboardTypeLabelFull"];
 self.kbType = [decoder decodeObjectForKey:@"kbType"];
 self.kbTypeLabel = [decoder decodeObjectForKey:@"kbTypeLabel"];
 self.commandTitle = [decoder decodeObjectForKey:@"commandTitle"];
 self.insertTextActionType = [[decoder decodeObjectForKey:@"insertTextActionType"] intValue];
 self.isWordSender = [[decoder decodeObjectForKey:@"isWordSender"] boolValue];
 self.moveCursorWithSelect = [[decoder decodeObjectForKey:@"moveCursorWithSelect"] boolValue];
 
 self.trueKBType = [[decoder decodeObjectForKey:@"trueKBType"] intValue];
 self.keyboardInputTypeCell = [decoder decodeObjectForKey:@"keyboardInputTypeCell"];
 
 self.backgroundColor = [decoder decodeObjectForKey:@"backgroundColor"];
 self.delegate = [decoder decodeObjectForKey:@"delegate"];
 self.dataSource = [decoder decodeObjectForKey:@"dataSource"];
 self.showsVerticalScrollIndicator = [[decoder decodeObjectForKey:@"showsVerticalScrollIndicator"] boolValue];
 self.showsHorizontalScrollIndicator = [[decoder decodeObjectForKey:@"showsHorizontalScrollIndicator"] boolValue];
 self.pagingEnabled = [[decoder decodeObjectForKey:@"pagingEnabled"] boolValue];
 
 [self registerClass:NSClassFromString(@"DockXCell") forCellWithReuseIdentifier:@"kDockXCellID"];
 [self keyboardRotated:nil];
 *
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dockXLayoutChanged:) name:@"dockXLayoutChanged" object:nil];
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardRotated:) name:UIDeviceOrientationDidChangeNotification object:nil];
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollBackward:) name:@"scrollBackward" object:nil];
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollForward:) name:@"scrollForward" object:nil];
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAutoCorrection:) name:@"updateAutoCorrection" object:nil];
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAutoCapitalization:) name:@"updateAutoCapitalization" object:nil];
 
 }
 return self;
 }
 */

- (instancetype)init{
    /*
     //if (!updateCache){
     if (@available(iOS 11.0, *)){
     //NSArray *extendedClasses = [@[[DockXCollectionView class]] arrayByAddingObjectsFromArray:@[[NSArray class], [NSMutableArray class], [NSDictionary class], [NSMutableDictionary class], [NSDate class], [NSNumber class]]];
     NSError *error = nil;
     /*DockXCollectionView *cached = /[NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithObjects:[NSArray class], [NSMutableArray class], [NSObject class], [DockXCollectionView class], nil] fromData:prefs[@"prevState"] error:&error];
     if (!error){
     HBLogDebug(@"init from cache");
     //return cached;
     }else{
     HBLogDebug(@"Error %@", error.localizedDescription);
     }
     }
     //}
     HBLogDebug(@"init normally");
     */
    
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = currentBackgroundTintColor?buttonSpacing:0;
    flowLayout.minimumLineSpacing = 0;
    
    
    if (self = [super initWithFrame:CGRectZero collectionViewLayout:flowLayout]) {
        self.shortcutsGenerator = [ShortcutsGenerator sharedInstance];
        
        
        if (!prefs){
            //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //prefs = [[[PrefsManager sharedInstance] readPrefsFromSandbox:!isSpringBoard] mutableCopy];
            prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsPath];
            //});
        }
        
        
        
        if (prefs[kCachekey]){
            NSDictionary *cache = prefs[kCachekey];
            self.shortcuts = cache[@"shortcuts"];
            self.fullshortcuts = cache[@"fullshortcuts"];
            self.kbType = cache[@"kbType"];
            self.kbTypeLabel = cache[@"kbTypeLabel"];
            self.keyboardTypeDataFull = cache[@"keyboardTypeDataFull"];
            self.keyboardTypeLabelFull = cache[@"keyboardTypeLabelFull"];
            HBLogDebug(@"Utilized cache");
        }else{
            HBLogDebug(@"Update cache");
            
            NSMutableDictionary *cache = [[NSMutableDictionary alloc] init];
            
            self.keyboardTypeDataFull = [self.shortcutsGenerator keyboardTypeData];
            self.keyboardTypeLabelFull = [self.shortcutsGenerator keyboardTypeLabel];
            cache[@"keyboardTypeDataFull"] = self.keyboardTypeDataFull;
            cache[@"keyboardTypeLabelFull"] = self.keyboardTypeLabelFull;
            
            NSMutableArray *currentOrderDefault12 = [[self.shortcutsGenerator imageNameArrayForiOS:0] mutableCopy];
            NSMutableArray *currentOrderDefault13 =  [[self.shortcutsGenerator imageNameArrayForiOS:1] mutableCopy];
            NSMutableArray *selectorsDefault = [[self.shortcutsGenerator selectorNameForLongPress:NO] mutableCopy];
            NSMutableArray *selectorsLPDefault = [[self.shortcutsGenerator selectorNameForLongPress:YES] mutableCopy];
            //NSMutableArray *shortLabelDefault = [[self.shortcutsGenerator shortenedlabelName] mutableCopy];
            
            NSMutableArray *currentOrder12 = [[NSMutableArray alloc] init];
            NSMutableArray *currentOrder13 = [[NSMutableArray alloc] init];
            NSMutableArray *selectors = [[NSMutableArray alloc] init];
            NSMutableArray *selectorsLP = [[NSMutableArray alloc] init];
            //NSMutableArray *shortLabel = [[NSMutableArray alloc] init];
            
            cache[@"copyLogDylibExist"] = @(self.shortcutsGenerator.copyLogDylibExist);
            cache[@"translomaticDylibExist"] = @(self.shortcutsGenerator.translomaticDylibExist);
            cache[@"wasabiDylibExist"] = @(self.shortcutsGenerator.wasabiDylibExist);
            cache[@"pasitheaDylibExist"] = @(self.shortcutsGenerator.pasitheaDylibExist);
            
            
            if (prefs[@"shortcuts"]){
                
                for (NSDictionary *item in prefs[@"shortcuts"][0]){
                    if ([item[@"selector"] isEqualToString:@"copyLogAction:"] && !self.shortcutsGenerator.copyLogDylibExist){
                        continue;
                    }
                    if ([item[@"selector"] isEqualToString:@"translomaticAction:"] && !self.shortcutsGenerator.translomaticDylibExist){
                        continue;
                    }
                    if ([item[@"selector"] isEqualToString:@"wasabiAction:"] && !self.shortcutsGenerator.wasabiDylibExist){
                        continue;
                    }
                    if ([item[@"selector"] isEqualToString:@"pasitheaAction:"] && !self.shortcutsGenerator.pasitheaDylibExist){
                        continue;
                    }
                    [currentOrder12 addObject:item[@"images12"]];
                    [currentOrder13 addObject:item[@"images13"]];
                    [selectors addObject:item[@"selector"]];
                    [selectorsLP addObject:item[@"selectorlp"]];
                    //if (item[@"slabel"]){
                    //[shortLabel addObject:item[@"slabel"]];
                    //}else{
                    //useShortenedLabel = NO;
                    //}
                }
            }else{
                for (int i = 0; i < maxdefaultshortcuts; i++ ){
                    [currentOrder12 addObject:[currentOrderDefault12 objectAtIndex:i]];
                    [currentOrder13 addObject:[currentOrderDefault13 objectAtIndex:i]];
                    [selectors addObject:[selectorsDefault objectAtIndex:i]];
                    [selectorsLP addObject:[selectorsLPDefault objectAtIndex:i]];
                    //[shortLabel addObject:[shortLabelDefault objectAtIndex:i]];
                }
                //currentOrder12 = [[currentOrderDefault12 subarrayWithRange:NSMakeRange(0, 6)] mutableCopy];
                //currentOrder12 = [[currentOrderDefault13 subarrayWithRange:NSMakeRange(0, 6)] mutableCopy];
                //selectors = [[selectorsDefault subarrayWithRange:NSMakeRange(0, 6)] mutableCopy];
                //selectorsLP = [[selectorsLPDefault subarrayWithRange:NSMakeRange(0, 6)] mutableCopy];
                
            }
            
            //self.buttonsImages12 = currentOrder12;
            //self.buttonsImages13 = currentOrder13;
            //self.buttonSelectors = selectors;
            //self.buttonLongPressSelectors = selectorsLP;
            self.shortcuts = @[currentOrder12, currentOrder13, selectors, selectorsLP];
            self.fullshortcuts = @[currentOrderDefault12, currentOrderDefault13, selectorsDefault, selectorsLPDefault];
            cache[@"shortcuts"] = self.shortcuts;
            cache[@"fullshortcuts"] = self.fullshortcuts;
            
            
            NSMutableArray *kbTypeActive = [[NSMutableArray alloc] init];
            NSMutableArray *kbTypeActiveLabel = [[NSMutableArray alloc] init];
            
            if (prefs[kKeyboardTypekey]){
                
                for (NSDictionary *item in prefs[kKeyboardTypekey][0]){
                    [kbTypeActive addObject:[NSNumber numberWithInt:[item[@"data"] intValue]]];
                    NSUInteger index = [self.keyboardTypeDataFull indexOfObject:item[@"data"]];
                    [kbTypeActiveLabel addObject:self.keyboardTypeLabelFull[index]];
                    
                }
                
            }else{
                for (int i = 0; i < maxdefaultshortcutskbtype; i++){
                    [kbTypeActive addObject:self.keyboardTypeDataFull[i]];
                    [kbTypeActiveLabel addObject:self.keyboardTypeLabelFull[i]];
                }
            }
            self.kbType = kbTypeActive;
            self.kbTypeLabel = kbTypeActiveLabel;
            cache[@"kbType"] = self.kbType;
            cache[@"kbTypeLabel"] = self.kbTypeLabel;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[PrefsManager sharedInstance] setValue:cache forKey:kCachekey fromSandbox:!isSpringBoard];
                prefs = [[[PrefsManager sharedInstance] readPrefsFromSandbox:!isSpringBoard] mutableCopy];
            });
        }
        
        self.hapticType = 1;
        self.refreshView = YES;
        self.firstCellVisible = YES;
        
        self.commandTitle = @"";
        self.insertTextActionType = 0;
        self.isWordSender = NO;
        self.moveCursorWithSelect = NO;
        //self.autoCorrectionEnabled = [self isAutoCorrectionEnabled];    //self.firstInit = YES;
        
        
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.dataSource = self;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.pagingEnabled = preferencesBool(kPagingkey, YES);
        [self registerClass:NSClassFromString(@"DockXCell") forCellWithReuseIdentifier:@"kDockXCellID"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self keyboardRotated:nil];
        });
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dockXLayoutChanged:) name:@"dockXLayoutChanged" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardRotated:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollBackward:) name:@"scrollBackward" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollForward:) name:@"scrollForward" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAutoCorrection:) name:@"updateAutoCorrection" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAutoCapitalization:) name:@"updateAutoCapitalization" object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateKeyboardType:) name:UITextFieldTextDidBeginEditingNotification object:nil];
        
    }
    
    //HBLogDebug(@"DockX Init");
    //if (!prefs[@"prevState"]){
    
    /*
     //}
     //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     if (@available(iOS 11.0, *)){
     [[PrefsManager sharedInstance] setValue:[NSKeyedArchiver archivedDataWithRootObject:self requiringSecureCoding:YES error:nil] forKey:@"prevState" fromSandbox:!isSpringBoard];
     }
     //});
     */
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dockXLayoutChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"scrollBackward" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"scrollForward" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateAutoCorrection" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateAutoCapitalization" object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
    
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    //HBLogDebug(@"willDisplayCell: %@", indexPath);
    if (indexPath.section == 0 && indexPath.row == 0){
        self.firstCellVisible = YES;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    //HBLogDebug(@"didEndDisplayingCell: %@", indexPath);
    if (indexPath.section == 0 && indexPath.row == 0){
        self.firstCellVisible = NO;
    }
    if (indexPath == self.keyboardInputTypeCellIndexPath){
        self.keyboardInputTypeCell = nil;
    }
}


-(NSArray *)synthesizeIndexingForIndexOrOffset:(BOOL)index descendingOffset:(BOOL)reverse numberOfItems:(int)itemsCount{
    NSMutableArray *indexArray = [[NSMutableArray alloc] init];
    for (int j = 0; j < 2; j ++){
        for (int i = 0; i < itemsCount; i++){
            if (index){
                [indexArray addObject:[NSNumber numberWithInt:i]];
            }else{
                [indexArray addObject:reverse ? [NSNumber numberWithInt:1 - j] : [NSNumber numberWithInt:j]];
            }
        }
    }
    return indexArray;
}

-(void)scrollBackward:(NSNotification*)notification{
    //HBLogDebug(@"scrollBackward");
    
    NSArray *indexPaths = [self indexPathsForVisibleItems];
    //NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"row" ascending:YES];
    //NSArray *orderedIndexPaths = [indexPaths sortedArrayUsingDescriptors:@[sort]];
    
    
    
    //NSInteger centerIndex = ceil((float)self.visibleCells.count/2.0f);
    NSMutableArray *universalIndexArray = [[NSMutableArray alloc] init];
    for (NSIndexPath *ip in indexPaths){
        [universalIndexArray addObject:[NSNumber numberWithLong:preferencesInt(kShortcutsPerSection, maxshortcutpersection)*ip.section + ip.row]];
    }
    
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    NSArray *orderedIndexPaths = [indexPaths sortedArrayUsingDescriptors:@[sort]];
    
    
    //HBLogDebug(@"scrollBackward SORTED: %@", orderedIndexPaths);
    
    NSIndexPath *firstCellIndexPath = [orderedIndexPaths firstObject];
    
    //NSIndexPath *scrollToIndexPath;
    //HBLogDebug(@"scrollBackwardINDEX: %@", firstCellIndexPath);
    
    /*
     if (self.touchEnded){
     self.touchEnded = NO;
     double delayInSeconds = 1;
     dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
     dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
     self.touchEnded = YES;
     });
     */
    //if (self.firstCellVisible || self.firstInit){
    if (self.firstCellVisible){
        //self.firstInit = NO;
        [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight] impactOccurred];
        return;
    }
    //}
    
    
    int x = firstCellIndexPath.section;
    int y = firstCellIndexPath.row;
    int G = preferencesInt(kGranularity, granularity) -1;
    //int ymax = [self numberOfItemsInSection:firstCellIndexPath.section] -1;
    int allowedMaxY = preferencesInt(kShortcutsPerSection, maxdefaultshortcuts);
    //HBLogDebug(@"G: %d, y: %d", G, allowedMaxY);
    G = G+1-allowedMaxY>0?allowedMaxY-1:G;
    G = G==0?1:G;
    //HBLogDebug(@"After G: %d, y: %d", G, allowedMaxY);
    
    //NSArray *indexArray = @[@0, @1, @2, @3, @4, @5, @0, @1, @2, @3, @4, @5];
    //NSArray *sectionOffsetArray = @[@1, @1, @1, @1, @1, @1, @0, @0, @0, @0, @0, @0];
    if (!self.indexArray){
        self.indexArray = [NSArray array];
        self.indexArray = [self synthesizeIndexingForIndexOrOffset:YES descendingOffset:YES numberOfItems:preferencesInt(kShortcutsPerSection, maxshortcutpersection)];
    }
    if (!self.sectionOffsetBackwardArray){
        self.sectionOffsetBackwardArray = [NSArray array];
        self.sectionOffsetBackwardArray = [self synthesizeIndexingForIndexOrOffset:NO descendingOffset:YES numberOfItems:preferencesInt(kShortcutsPerSection, maxshortcutpersection)];
    }
    //HBLogDebug(@"index: %@", indexArray);
    //HBLogDebug(@"offset: %@", sectionOffsetArray);
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.indexArray[y+allowedMaxY-(G+1)] intValue]  inSection:x - [self.sectionOffsetBackwardArray[y+allowedMaxY-(G+1)] intValue]];
    [self scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    //int firstCellGlobalIndex = preferencesInt(kShortcutsPerSection, maxshortcutpersection)*firstCellIndexPath.section + firstCellIndexPath.row;
    //int newRowIndex =  [fullIndexArray[rowIndex - G] intValue];
    
    
    /*
     NSIndexPath *newIndexPath;
     
     //HBLogDebug(@"x: %d, y: %d, ymax: %d, G: %d, allowedMaxY: %d", x, y, ymax, G, allowedMaxY);
     
     if (G-y == G && G+1==allowedMaxY){
     newIndexPath = [NSIndexPath indexPathForRow:0 inSection:x-1];
     //HBLogDebug(@"Case 1");
     }else if (G-y < 0){
     newIndexPath = [NSIndexPath indexPathForRow:[indexArray[y+allowedMaxY-(G+1)] intValue] inSection:x];
     //HBLogDebug(@"Case 2");
     }else if (G-y > 0){
     newIndexPath = [NSIndexPath indexPathForRow:[indexArray[y+allowedMaxY-(G+1)] intValue] inSection:x-1];
     //HBLogDebug(@"Case 3");
     }else{
     newIndexPath = [NSIndexPath indexPathForRow:[self numberOfItemsInSection:firstCellIndexPath.section-1] -1 inSection:x-1];
     //HBLogDebug(@"Case 4");
     }
     [self scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
     /*
     if (firstCellIndexPath.row - preferencesInt(kGranularity, granularity) < 0){
     scrollToIndexPath =  [NSIndexPath indexPathForRow:[self numberOfItemsInSection:firstCellIndexPath.section - 1] - 1 - (preferencesInt(kGranularity, granularity) - firstCellIndexPath.row) inSection:firstCellIndexPath.section - 1];
     
     }else{
     scrollToIndexPath =  [NSIndexPath indexPathForRow:firstCellIndexPath.row - preferencesInt(kGranularity, granularity) inSection:firstCellIndexPath.section];
     }
     //}
     
     [self scrollToItemAtIndexPath:scrollToIndexPath
     atScrollPosition:UICollectionViewScrollPositionLeft
     animated:YES];
     */
}

-(void)scrollForward:(NSNotification*)notification{
    //HBLogDebug(@"scrollForward");
    NSArray *indexPaths = [self indexPathsForVisibleItems];
    //NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"row" ascending:YES];
    //NSArray *orderedIndexPaths = [indexPaths sortedArrayUsingDescriptors:@[sort]];
    
    
    
    //NSInteger centerIndex = ceil((float)self.visibleCells.count/2.0f);
    NSMutableArray *universalIndexArray = [[NSMutableArray alloc] init];
    for (NSIndexPath *ip in indexPaths){
        [universalIndexArray addObject:[NSNumber numberWithLong:preferencesInt(kShortcutsPerSection, maxshortcutpersection)*ip.section + ip.row]];
    }
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    NSArray *orderedIndexPaths = [indexPaths sortedArrayUsingDescriptors:@[sort]];
    
    
    
    //NSInteger centerIndex = ceil((float)self.visibleCells.count/2.0f);
    NSIndexPath *firstCellIndexPath = [orderedIndexPaths firstObject];
    NSIndexPath *lastCellIndexPath = [orderedIndexPaths lastObject];
    //HBLogDebug(@"LAST INDEX: %@", firstCellIndexPath);
    ////HBLogDebug(@"%ld, %ld", self.numberOfSections -1, [self numberOfItemsInSection:lastCellIndexPath.section]);
    //HBLogDebug(@"SORTED: %@", orderedIndexPaths);
    //NSIndexPath *scrollToIndexPath;
    
    
    if ( (lastCellIndexPath.section == self.numberOfSections -1) && (lastCellIndexPath.row == [self numberOfItemsInSection:lastCellIndexPath.section]-1) ){
        [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight] impactOccurred];
        return;
    }
    
    int x = firstCellIndexPath.section;
    int y = firstCellIndexPath.row;
    int G = preferencesInt(kGranularity, granularity) -1;
    int allowedMaxY = preferencesInt(kShortcutsPerSection, maxdefaultshortcuts);
    //HBLogDebug(@"G: %d, y: %d", G, y);
    G = G+1-allowedMaxY>0?allowedMaxY-1:G;
    G = G==0?1:G;
    //HBLogDebug(@"After G: %d, y: %d", G, allowedMaxY);
    
    //int ymax = [self numberOfItemsInSection:firstCellIndexPath.section] -1;
    //int allowedMaxY = preferencesInt(kShortcutsPerSection, maxshortcutpersection);
    //NSArray *indexArray = @[@0, @1, @2, @3, @4, @5, @0, @1, @2, @3, @4, @5];
    //NSArray *sectionOffsetArray = @[@0, @0, @0, @0, @0, @0, @1, @1, @1, @1, @1, @1];
    if (!self.indexArray){
        self.indexArray = [NSArray array];
        self.indexArray = [self synthesizeIndexingForIndexOrOffset:YES descendingOffset:NO numberOfItems:preferencesInt(kShortcutsPerSection, maxshortcutpersection)];
    }
    if (!self.sectionOffsetForwardArray){
        self.sectionOffsetForwardArray = [NSArray array];
        self.sectionOffsetForwardArray = [self synthesizeIndexingForIndexOrOffset:NO descendingOffset:NO numberOfItems:preferencesInt(kShortcutsPerSection, maxshortcutpersection)];
    }
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.indexArray[y+G+1] intValue] inSection:x + [self.sectionOffsetForwardArray[y+G+1] intValue]];
    //HBLogDebug(@"index: %@", indexArray);
    //HBLogDebug(@"offset: %@", sectionOffsetArray);
    
    [self scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    
    //HBLogDebug(@"x: %d, y: %d, ymax: %d, G: %d, allowedMaxY: %d", x, y, ymax, G, allowedMaxY);
    /*
     if (G-y == 0 && G+1==allowedMaxY){
     newIndexPath = [NSIndexPath indexPathForRow:0 inSection:x+1];
     //HBLogDebug(@"Case 1");
     }else if (G+y > ymax){
     newIndexPath = [NSIndexPath indexPathForRow:[indexArray[y+G+1] intValue] inSection:x+1];
     //HBLogDebug(@"Case 2");
     }else if (G+y < ymax){
     newIndexPath = [NSIndexPath indexPathForRow:[indexArray[y+G+1] intValue] inSection:x];
     //HBLogDebug(@"Case 3");
     }else{
     newIndexPath = [NSIndexPath indexPathForRow:0 inSection:x+1];
     //HBLogDebug(@"Case 4");
     }
     [self scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
     */
    /*
     //if (firstCellIndexPath.section != 0){
     if (firstCellIndexPath.row ==  [self numberOfItemsInSection:firstCellIndexPath.section] -1){
     scrollToIndexPath =  [NSIndexPath indexPathForRow:preferencesInt(kGranularity, granularity) - 1 inSection:firstCellIndexPath.section + 1];
     //HBLogDebug(@"1");
     }else if (preferencesInt(kGranularity, granularity) == preferencesInt(kShortcutsPerSection, maxshortcutpersection)){
     scrollToIndexPath =  [NSIndexPath indexPathForRow:0 inSection:firstCellIndexPath.section + 1];
     //HBLogDebug(@"3");
     }else if (firstCellIndexPath.row + preferencesInt(kGranularity, granularity) > [self numberOfItemsInSection:firstCellIndexPath.section] -1){
     scrollToIndexPath =  [NSIndexPath indexPathForRow:preferencesInt(kGranularity, granularity) - ([self numberOfItemsInSection:firstCellIndexPath.section] - 1 - firstCellIndexPath.row) inSection:firstCellIndexPath.section + 1];
     //HBLogDebug(@"2, %@ - %@",preferencesInt(kGranularity, granularity),([self numberOfItemsInSection:firstCellIndexPath.section] - 1 - firstCellIndexPath.row));
     }else{
     scrollToIndexPath =  [NSIndexPath indexPathForRow:firstCellIndexPath.row + preferencesInt(kGranularity, granularity) inSection:firstCellIndexPath.section];
     //HBLogDebug(@"4");
     }
     //}
     */
    //[self scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    
}

-(UITextRange *)selectedWordTextRangeWithDelegate:(id<UITextInput>)delegate{
    BOOL hasRightText = [delegate.tokenizer isPosition:delegate.selectedTextRange.start withinTextUnit:UITextGranularityWord inDirection:UITextLayoutDirectionRight];
    UITextStorageDirection direction = hasRightText ? UITextStorageDirectionForward : UITextStorageDirectionBackward;
    UITextRange *range = [delegate.tokenizer rangeEnclosingPosition:delegate.selectedTextRange.start
                                                    withGranularity:UITextGranularityWord
                                                        inDirection:direction];
    if (!range) {
        UITextPosition *p = [delegate.tokenizer positionFromPosition:delegate.selectedTextRange.start toBoundary:UITextGranularityWord inDirection:UITextStorageDirectionBackward];
        range = [delegate.tokenizer rangeEnclosingPosition:p withGranularity:UITextGranularityWord inDirection:UITextStorageDirectionBackward];
    }
    return range;
}

-(UITextRange *)selectedWordTextRangeWithDelegate:(id<UITextInput>)delegate direction:(UITextStorageDirection)direction{
    UITextRange *range = [delegate.tokenizer rangeEnclosingPosition:delegate.selectedTextRange.start
                                                    withGranularity:UITextGranularityWord
                                                        inDirection:direction];
    if (!range) {
        if (direction == UITextStorageDirectionBackward) {
            UITextPosition *p = [delegate.tokenizer positionFromPosition:delegate.selectedTextRange.start toBoundary:UITextGranularityWord inDirection:UITextStorageDirectionBackward];
            if (!p)
                p = [delegate.tokenizer positionFromPosition:delegate.selectedTextRange.start toBoundary:UITextGranularityLine inDirection:UITextLayoutDirectionUp];
            range = [delegate.tokenizer rangeEnclosingPosition:p withGranularity:UITextGranularityWord inDirection:UITextStorageDirectionBackward];
        } else {
            UITextPosition *p = [delegate.tokenizer positionFromPosition:delegate.selectedTextRange.start toBoundary:UITextGranularityWord inDirection:UITextStorageDirectionForward];
            if (!p)
                p = [delegate.tokenizer positionFromPosition:delegate.selectedTextRange.end toBoundary:UITextGranularityLine inDirection:UITextLayoutDirectionDown];
            range = [delegate.tokenizer rangeEnclosingPosition:p withGranularity:UITextGranularityWord inDirection:UITextStorageDirectionForward];
        }
    }
    return range;
}

-(void)moveCursorVerticalWithDelegate:(id<UITextInput>)delegate direction:(UITextLayoutDirection)direction{
    UITextPosition *position = [delegate positionFromPosition:delegate.selectedTextRange.start inDirection:direction offset:1];
    if (!position) return;
    UITextRange *range = [delegate textRangeFromPosition:position toPosition:position];
    delegate.selectedTextRange = range;
    //RevealSelection(delegate);
}

-(UITextRange *)autoDirectionWordSelectedTextRangeWithDelegate:(id<UITextInput> )delegate{
    BOOL hasRightText = [delegate.tokenizer isPosition:delegate.selectedTextRange.start withinTextUnit:UITextGranularityWord inDirection:UITextLayoutDirectionRight];
    UITextStorageDirection direction = hasRightText ? UITextStorageDirectionForward : UITextStorageDirectionBackward;
    return [self selectedWordTextRangeWithDelegate:delegate direction:direction];
}


-(UITextRange *)singleWordTextRangeWithDelegate:(id<UITextInput>)delegate direction:(UITextStorageDirection)direction{
    UITextRange *range = [self selectedWordTextRangeWithDelegate:delegate direction:direction];
    if (direction == UITextStorageDirectionForward)
        return [delegate textRangeFromPosition:range.end toPosition:range.end];
    else
        return [delegate textRangeFromPosition:range.start toPosition:range.start];
}

-(UITextRange *)lineExtremityTextRangeWithDelegate:(id<UITextInput>)delegate direction:(UITextLayoutDirection)direction{
    id<UITextInputTokenizer> tokenizer = delegate.tokenizer;
    UITextPosition *lineEdgePosition = [tokenizer positionFromPosition:delegate.selectedTextRange.end toBoundary:UITextGranularityLine inDirection:direction];
    // for until iOS 6 component.
    if ([lineEdgePosition isMemberOfClass:objc_getClass("UITextPositionImpl")])
        return [delegate textRangeFromPosition:lineEdgePosition toPosition:lineEdgePosition];
    // for iOS 7 buggy _UITextKitTextPosition workaround.
    for (int i=1; i<1000; i++) {
        lineEdgePosition = [delegate positionFromPosition:delegate.selectedTextRange.start inDirection:direction offset:i];
        NSComparisonResult result = [delegate comparePosition:lineEdgePosition
                                                   toPosition:(direction == UITextLayoutDirectionLeft) ? delegate.beginningOfDocument : delegate.endOfDocument];
        if (!lineEdgePosition || result == NSOrderedSame)
            return [delegate textRangeFromPosition:lineEdgePosition toPosition:lineEdgePosition];
        UITextRange *range = [delegate textRangeFromPosition:delegate.selectedTextRange.start toPosition:lineEdgePosition];
        NSString *text = [delegate textInRange:range];
        if ([text hasPrefix:@"\n"] || [text hasSuffix:@"\n"]) {
            lineEdgePosition = [delegate positionFromPosition:delegate.selectedTextRange.start inDirection:direction offset:i-1];
            return [delegate textRangeFromPosition:lineEdgePosition toPosition:lineEdgePosition];
        }
    }
    return nil;
}

-(void)moveCursorSingleWordWithDelegate:(id <UITextInput, UITextInputTokenizer>)delegate direction:(UITextStorageDirection)direction{
    if (delegate) {
        BOOL isRTL  = [self isRTLForDelegate:delegate];
        if (isRTL){
            if (direction == UITextStorageDirectionForward){
                direction = UITextStorageDirectionBackward;
            }else{
                direction = UITextStorageDirectionForward;
            }
        }
        UITextRange *textRange = [self singleWordTextRangeWithDelegate:delegate direction:direction];
        if (!textRange) return;
        [delegate setSelectedTextRange:textRange];
    }
}

-(void)moveCursorToLineExtremityWithDelegate:(id <UITextInput, UITextInputTokenizer>)delegate direction:(UITextLayoutDirection)direction{
    if (delegate) {
        BOOL isRTL  = [self isRTLForDelegate:delegate];
        if (isRTL){
            if (direction == UITextLayoutDirectionLeft){
                direction = UITextLayoutDirectionRight;
            }else{
                direction = UITextLayoutDirectionLeft;
            }
        }
        UITextRange *textRange = [self lineExtremityTextRangeWithDelegate:delegate direction:direction];
        if (!textRange) return;
        [delegate setSelectedTextRange:textRange];
    }
}

-(BOOL)isRTLForDelegate:(UIResponder *)delegate {
    UIKeyboardExtensionInputMode *inputMode = delegate.textInputMode;
    return [inputMode isDefaultRightToLeft];
    
}

- (NSInteger)currentCursorPosition:(id <UITextInput, UITextInputTokenizer>)delegate{
    UITextRange *selectedRange = delegate.selectedTextRange;
    UITextPosition *textPosition = selectedRange.start;
    return [delegate offsetFromPosition:delegate.beginningOfDocument toPosition:textPosition];
}


-(void)moveCursorWithDelegate:(id <UITextInput, UITextInputTokenizer>)delegate offset:(int)offset{
    if (delegate) {
        BOOL isRTL  = [self isRTLForDelegate:delegate];
        UITextPosition *textPosition;
        if (isRTL){
            textPosition = [delegate positionFromPosition:delegate.beginningOfDocument offset:([self currentCursorPosition:delegate]-offset)];
        }else{
            textPosition = [delegate positionFromPosition:delegate.beginningOfDocument offset:([self currentCursorPosition:delegate]+offset)];
        }
        
        [delegate setSelectedTextRange:[delegate textRangeFromPosition:textPosition toPosition:textPosition]];
    }
}

-(void)setAutoPaginationControlEnabled{
    self.pagingEnabled = YES;
}

-(void)autoPaginationControl{
    if (isPagingEnabled && self.pagingEnabled){
        self.pagingEnabled = NO;
    }else if (isPagingEnabled && !self.pagingEnabled){
        if (!self.autoPaginationDispatchBlock){
            self.autoPaginationDispatchBlock = dispatch_block_create(0, ^{
                self.pagingEnabled = YES;
                self.autoPaginationDispatchBlock = nil;
            });
            
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), self.autoPaginationDispatchBlock);
    }
}


-(void)dockXLayoutChanged:(NSNotification*)notification{
    //self.hidden = isLandscape||isDictating?YES:NO;
    //[self reloadData];
    if (toggledOn){
        if (self.refreshView){
            //HBLogDebug(@"&&&&&&&&&& dockXLayoutChanged shouldPerformBatchUpdate: %d", shouldPerformBatchUpdate?1:0);
            [UIView performWithoutAnimation:^{
                //[self reloadItemsAtIndexPaths:[self indexPathsForVisibleItems]];
                if (shouldPerformBatchUpdate){
                    [self performBatchUpdates:^{
                        [self reloadData];
                    } completion:^(BOOL finished) {}];
                }else{
                    [self reloadData];
                    [self performBatchUpdates:^{} completion:^(BOOL finished) {
                        shouldPerformBatchUpdate = YES;
                    }];
                }
                
            }];
        }
        
        /*
         
         NSDictionary* userInfo = notification.userInfo;
         @try {
         if (self.refreshView)
         [UIView performWithoutAnimation:^{
         if ([userInfo[@"fullreload"] boolValue]){
         //HBLogDebug(@"BEFORE SHORTCUTS: %@", self.shortcuts);
         //[self reloadData];
         [self performBatchUpdates:^{
         [self reloadData];
         } completion:^(BOOL finished) {}];
         
         //HBLogDebug(@"AFTER SHORTCUTS: %@", self.shortcuts);
         }else{
         //HBLogDebug(@"BEFORE SHORTCUTS: %@", self.shortcuts);
         //[self reloadData];
         //HBLogDebug(@"VISIBLECELLS: %@", [self indexPathsForVisibleItems]);
         [self performBatchUpdates:^{
         [self reloadData];
         } completion:^(BOOL finished) {}];
         
         //[self reloadItemsAtIndexPaths:[self indexPathsForVisibleItems]];
         //HBLogDebug(@"AFTER SHORTCUTS: %@", self.shortcuts);
         
         }
         }];
         } @catch (NSException *exception) {
         if (self.refreshView)
         [UIView performWithoutAnimation:^{
         //HBLogDebug(@"BEFORE SHORTCUTS: %@", self.shortcuts);
         //[self reloadData];
         [self performBatchUpdates:^{
         [self reloadData];
         } completion:^(BOOL finished) {}];
         
         //HBLogDebug(@"AFTER SHORTCUTS: %@", self.shortcuts);                }];
         } @finally {
         
         }
         */
    }
    //[self reloadItemsAtIndexPaths:[self indexPathsForVisibleItems]] ;
}

- (void)keyboardRotated:(NSNotification *)notification {
    
    if (toggledOn){
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        isLandscape = UIInterfaceOrientationIsLandscape(orientation);
        if (self.refreshView){
            //HBLogDebug(@"&&&&&&&&&& keyboardRotated shouldPerformBatchUpdate: %d", shouldPerformBatchUpdate?1:0);
            [UIView performWithoutAnimation:^{
                //[self reloadItemsAtIndexPaths:[self indexPathsForVisibleItems]];
                if (shouldPerformBatchUpdate){
                    [self performBatchUpdates:^{
                        [self reloadData];
                    } completion:^(BOOL finished) {}];
                }else{
                    [self reloadData];
                    [self performBatchUpdates:^{} completion:^(BOOL finished) {
                        shouldPerformBatchUpdate = YES;
                    }];
                }
                
            }];
        }
    }
    
    
    
    /*
     //self.hidden = isLandscape||isDictating ? YES : NO;
     @try {
     if (self.refreshView)
     [UIView performWithoutAnimation:^{
     //[self reloadItemsAtIndexPaths:[self indexPathsForVisibleItems]];
     [self performBatchUpdates:^{
     [self reloadData];
     } completion:^(BOOL finished) {}];
     
     }];
     } @catch (NSException *exception) {
     if (self.refreshView)
     [UIView performWithoutAnimation:^{
     //[self reloadData];
     [self performBatchUpdates:^{
     [self reloadData];
     } completion:^(BOOL finished) {}];
     
     }];
     } @finally {
     
     }
     }
     */
}


-(void)shakeButton:(UIButton *)sender{
    if (preferencesBool(kShakeShortcutkey,YES)){
        BOOL doubleTapEnabled = preferencesBool(kEnabledDoubleTapkey, NO);
        if (doubleTapEnabled){
            if ([sender respondsToSelector:@selector(view)]){
                [self shakeView:((UIGestureRecognizer *)sender).view];
                return;
            }
        }
        self.refreshView = NO;
        CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
        [shake setDuration:0.05];
        [shake setRepeatCount:2];
        [shake setAutoreverses:YES];
        [shake setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake(sender.center.x - 5,sender.center.y)]];
        [shake setToValue:[NSValue valueWithCGPoint:
                           CGPointMake(sender.center.x + 5, sender.center.y)]];
        [sender.layer removeAllAnimations];
        [sender.layer addAnimation:shake forKey:@"position"];
        double delayInSeconds = 1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.refreshView = YES;
        });
    }
    HBLogDebug(@"shakeButton: %@", sender);
    
}

-(void)shakeView:(UIView *)sender{
    if (preferencesBool(kShakeShortcutkey,YES)){
        self.refreshView = NO;
        CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
        [shake setDuration:0.05];
        [shake setRepeatCount:2];
        [shake setAutoreverses:YES];
        [shake setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake(sender.center.x - 5,sender.center.y)]];
        [shake setToValue:[NSValue valueWithCGPoint:
                           CGPointMake(sender.center.x + 5, sender.center.y)]];
        [sender.layer removeAllAnimations];
        [sender.layer addAnimation:shake forKey:@"position"];
        double delayInSeconds = 1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.refreshView = YES;
        });
    }
}

-(NSString *)convertColorToString:(UIColor *)colorname{
    if(colorname==[UIColor whiteColor] ){
        colorname= [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    }
    else if(colorname==[UIColor blackColor]){
        colorname= [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    }
    CGColorRef colorRef = colorname.CGColor;
    NSString *colorString = [CIColor colorWithCGColor:colorRef].stringRepresentation;
    return colorString;
}

-(NSString *)getImageNameForActionName:(NSString *)actionname{
    
    //actionname = [actionname stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];
    
    if ([actionname isEqualToString:@"autoCorrectionAction:"]){
        if (@available(iOS 13.0, *)){
            return  !self.autoCorrectionEnabled?@"checkmark.circle.fill":@"checkmark.circle";
        }else{
            return  !self.autoCorrectionEnabled?@"UIAccessoryButtonCheckmark":@"UIAccessoryButtonX";
        }
    }else if ([actionname isEqualToString:@"autoCapitalizationAction:"]){
        if (@available(iOS 13.0, *)){
            return  !self.autoCapitalizationEnabled?@"shift.fill":@"shift";
        }else{
            return  !self.autoCapitalizationEnabled?@"shift_on_portrait":@"shift_portrait";
        }
    }
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", actionname];
    NSUInteger idx = [self.fullshortcuts[2]  indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
        return [predicate evaluateWithObject:obj];
    }];
    
    if (@available(iOS 13.0, *)){
        return self.fullshortcuts[1][idx];
    }else{
        return self.fullshortcuts[0][idx];
    }
    
}

-(void)sendShowToastRequestWithMessage:(NSString *)message imagePath:(NSString *)imagepath imageTint:(UIColor *)imagetint width:(int)width height:(int)height position:(float)position duration:(double)duration alpha:(float)alpha radius:(float)radius textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor displayType:(int)displayType{
    
    //HBLogDebug(@"%@",NSStringFromClass([[UIApplication sharedApplication] class]));
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              message, @"message",
                              imagepath, @"imagepath",
                              [NSNumber numberWithInt:width], @"width",
                              [NSNumber numberWithInt:height], @"height",
                              [NSNumber numberWithFloat:position], @"position",
                              [NSNumber numberWithDouble:duration], @"duration",
                              [NSNumber numberWithDouble:alpha], @"alpha",
                              [NSNumber numberWithDouble:radius], @"radius",
                              [self convertColorToString:textColor], @"textColor",
                              [self convertColorToString:backgroundColor], @"backgroundColor",
                              [self convertColorToString:imagetint], @"imagetint",
                              [NSNumber numberWithInt:displayType], @"displayType",
                              nil];
    
    //if (![NSStringFromClass([[UIApplication sharedApplication] class]) isEqualToString:@"SpringBoard"]){
    if (!isSpringBoard){
        if (!self.toastCenter) self.toastCenter = [self IPCCenterNamed:kIPCCenterToast];
        [self.toastCenter sendMessageAndReceiveReplyName:@"showToastRequest" userInfo:userInfo];
    }else{
        [[ToastWindowController sharedInstance] showToastRequest:@"showToastRequest" withUserInfo:userInfo];
        //SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];
        //[sb showToastRequest:@"showToastRequest" withUserInfo:userInfo];
    }
    
    
    
}

- (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

-(void)triggerImpactAndAnimationWithButton:(UIButton *)sender selectorName:(NSString *)selname toastWidthOffset:(int)woffset toastHeightOffset:(int)hoffset{
    //haptic, 0=none, 1=once, 2==success(twice)
    if ( preferencesBool(kEnabledHaptickey,YES) && self.hapticType != 0){
        self.hapticType == 1 ? ([[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight] impactOccurred]) : ([[[UINotificationFeedbackGenerator alloc] init] notificationOccurred:UINotificationFeedbackTypeSuccess], self.hapticType = 1);
    }
    if ( preferencesBool(kToastkey,YES) ){
        int th = toastHeight;
        int tw = toastWidth;
        if (preferencesInt(kDisplayTypekey, 0) == 1){
            th = 30;
            //tw = 100;
        }
        //NSString *actionName = selname;
        
        NSString *actionName = [DockXHelper localizedStringOfToastForActionNamed:selname bundle:tweakBundle];
        
        //HBLogDebug(@"^^^^^^^^^actionName: %@", actionName);
        if ([selname isEqualToString:@"keyboardTypeAction:"]){
            NSUInteger index = [self.kbType indexOfObject:[NSNumber numberWithInt:[delegate keyboardType]>12?0:[delegate keyboardType]]];
            if (index != NSNotFound){
                NSUInteger idx = index + 1;
                if (index < [self.kbType count] - 1 ){
                    if ([delegate keyboardType] < 0){
                        idx = idx + 1;
                    }
                    actionName = self.kbTypeLabel[idx];
                    
                }else{
                    actionName = self.kbTypeLabel[0];
                }
            }else{
                actionName = LOCALIZED(@"TOAST_KEYBOARD_TYPE_DEFAULT");
            }
            //if (preferencesInt(kDisplayTypekey, 0) == 1){
            //tw = tw + 15;
            //}
        }else if ([selname isEqualToString:@"keyboardTypeActionLP:"]){
            NSUInteger index = [self.kbType indexOfObject:[NSNumber numberWithInt:self.trueKBType]];
            if (index != NSNotFound){
                actionName = self.kbTypeLabel[index];
            }else{
                actionName = LOCALIZED(@"TOAST_KEYBOARD_TYPE_DEFAULT");
            }
            //if (preferencesInt(kDisplayTypekey, 0) == 1){
            //tw = tw + 15;
            //}
            selname = @"keyboardTypeAction:";
        }else if ([selname containsString:@"runCommandAction"]){
            actionName = self.commandTitle;
            //if (preferencesInt(kDisplayTypekey, 0) == 1){
            //tw = tw + 15;
            //}
            selname = @"runCommandAction:";
        }else if ([selname isEqualToString:@"autoCorrectionAction:"]){
            actionName = !self.autoCorrectionEnabled?LOCALIZED(@"TOAST_ON"):LOCALIZED(@"TOAST_OFF");
        }else if ([selname isEqualToString:@"autoCapitalizationAction:"]){
            actionName = !self.autoCapitalizationEnabled?LOCALIZED(@"TOAST_ON"):LOCALIZED(@"TOAST_OFF");
        }
        /*
         else if ([selname isEqualToString:@"insertTextAction:"]){
         actionName = @"Insert";
         }else if ([selname isEqualToString:@"deleteForwardAction:"]){
         actionName = @"Delete";
         }else{
         actionName = [selname stringByReplacingOccurrencesOfString:@"Action:" withString:@""];
         
         if ([selname isEqualToString:@"translomaticAction:"]){
         if (preferencesInt(kDisplayTypekey, 0) == 1){
         tw = tw + 10;
         }
         }
         
         if ([selname isEqualToString:@"moveCursorPreviousWordAction:"] || [selname isEqualToString:@"selectSentenceAction:"]){
         if (preferencesInt(kDisplayTypekey, 0) == 1){
         tw = tw + 30;
         }
         }
         
         if ([selname isEqualToString:@"moveCursorStartOfParagraphAction:"] || [selname isEqualToString:@"moveCursorEndOfParagraphAction:"] || [selname isEqualToString:@"moveCursorStartOfSentenceAction:"] || [selname isEqualToString:@"moveCursorEndOfSentenceAction:"] || [selname isEqualToString:@"selectParagraphAction:"]){
         if (preferencesInt(kDisplayTypekey, 0) == 1){
         tw = tw + 60;
         }
         }
         
         actionName = [actionName stringByReplacingOccurrencesOfString:@"Keyboard" withString:@""];
         actionName = [actionName stringByReplacingOccurrencesOfString:@"moveCursor" withString:@""];
         actionName = [actionName stringByReplacingOccurrencesOfString:@"autoCorrection" withString:!self.autoCorrectionEnabled?@"On":@"Off"];
         actionName = [actionName stringByReplacingOccurrencesOfString:@"autoCapitalization" withString:!self.autoCapitalizationEnabled?@"On":@"Off"];
         NSRegularExpression *regexp = [NSRegularExpression
         regularExpressionWithPattern:@"([a-z])([A-Z])"
         options:0
         error:NULL];
         actionName = [regexp
         stringByReplacingMatchesInString:actionName
         options:0
         range:NSMakeRange(0, actionName.length)
         withTemplate:@"$1 $2"];
         actionName = [actionName capitalizedString];
         }
         */
        
        if (preferencesInt(kDisplayTypekey, 0) == 1){
            tw = (int)([self widthOfString:actionName withFont:[UIFont systemFontOfSize:18]] + 0.5f) + 25;
            //tw = 10*[actionName length] - 20;
        }
        float normalizedToastY = preferencesFloat(kToastPy, toastPosition);
        normalizedToastY = normalizedToastY > 0.95 ? 0.95 : normalizedToastY ;
        normalizedToastY = normalizedToastY < 0.05 ? 0.05 : normalizedToastY;
        [self sendShowToastRequestWithMessage:actionName imagePath:[self getImageNameForActionName:selname] imageTint:toastTintColor width:tw+woffset height:th+hoffset position:normalizedToastY duration:preferencesFloat(kToastDurationkey, toastDuration) alpha:toastAlpha radius:toastRadius textColor:toastTextColor backgroundColor:toastBackgroundTintColor displayType:preferencesInt(kDisplayTypekey, 0)];
    }
    [self shakeButton:sender];
}

-(void)beginUpdateDelegate{
    kbImpl = [%c(UIKeyboardImpl) activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
}

-(void)beginImpactAnimationAndUpdateDelegate:(SEL)action sender:(UIButton *)sender toastWidthOffset:(int)toastWidthOffset toastHeightOffset:(int)toastHeightOffset{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(action) toastWidthOffset:toastWidthOffset toastHeightOffset:toastHeightOffset];
    [self beginUpdateDelegate];
}

#pragma mark actions
-(void)selectAllAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    
    if ([delegate respondsToSelector:@selector(selectAll:)]) {
        [delegate selectAll:nil];
    }else if ([delegate respondsToSelector:@selector(selectAll)]) {
        [delegate selectAll];
        
        [kbImpl clearTransientState];
        [kbImpl clearAnimations];
        [kbImpl setCaretBlinks:YES];
    }
    [self autoPaginationControl];
}

-(void)selectLineAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    
    [delegate _moveToStartOfLine:NO withHistory:nil];
    [delegate _moveToEndOfLine:YES withHistory:nil];
    [self autoPaginationControl];
}

-(void)selectParagraphAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    
    [delegate _moveToStartOfParagraph:NO withHistory:nil];
    [delegate _moveToEndOfParagraph:YES withHistory:nil];;
    [self autoPaginationControl];
}

-(void)selectSentenceAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput, UITextInputTokenizer> *)delegate;
    
    UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.start;
    UITextPosition *startPositionSentence = ((UITextRange * )[tempDelegate _rangeOfSentenceEnclosingPosition:startPositionTemp]).start;
    UITextPosition *endPositionSentence = ((UITextRange * )[tempDelegate _rangeOfSentenceEnclosingPosition:startPositionTemp]).end;
    
    BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
    
    if (isWKContentView){
        
    }else{
        UITextRange *textRange = [tempDelegate textRangeFromPosition:startPositionSentence toPosition:endPositionSentence];
        [tempDelegate setSelectedTextRange:textRange];
    }
    [self autoPaginationControl];
}


-(void)copyAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    
    if ([delegate respondsToSelector:@selector(copy:)]) {
        [delegate copy:nil]; //UIResponderStandardEditActions.h
    }else{
        if ([delegate respondsToSelector:@selector(selectedTextRange)]) {
            UITextRange *range = [delegate selectedTextRange];
            NSString *textRange = [delegate textInRange:range];
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            
            [pasteboard setString:textRange];
            
            [kbImpl clearTransientState];
            [kbImpl clearAnimations];
            [kbImpl setCaretBlinks:YES];
        }
    }
    [self autoPaginationControl];
}

-(BOOL)isValidURL:(NSString *)urlString{
    NSURL *url = [NSURL URLWithString:urlString];
    BOOL isUrl = NO;
    if (url && url.scheme && url.host) isUrl = YES;
    return isUrl;
}

-(void)pasteAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    
    BOOL isUnifiedField = [delegate isKindOfClass:objc_getClass("UnifiedField")];
    int pasteAndGoType = preferencesInt(kPasteAndGoEnabledkey, 2);
    if (pasteAndGoType > 0 && isSafari && isUnifiedField){
        if (pasteAndGoType == 1 && [self isValidURL:[[UIPasteboard generalPasteboard] string]]){
            if ([((UnifiedField *)delegate).delegate respondsToSelector:@selector(unifiedFieldShouldPasteAndNavigate:)]){
                [((UnifiedField *)delegate).delegate unifiedFieldShouldPasteAndNavigate:nil];
                return;
            }
        }else if (pasteAndGoType == 2){
            if ([((UnifiedField *)delegate).delegate respondsToSelector:@selector(unifiedFieldShouldPasteAndNavigate:)]){
                [((UnifiedField *)delegate).delegate unifiedFieldShouldPasteAndNavigate:nil];
                return;
            }
        }
    }
    
    if ([delegate respondsToSelector:@selector(paste:)]) {
        [delegate paste:nil]; //UIResponderStandardEditActions.h
    }else{
        if ([delegate respondsToSelector:@selector(selectedTextRange)]) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            
            NSString *copiedtext = [pasteboard string];
            
            if (copiedtext) {
                [kbImpl insertText:copiedtext];
            }
            
            [kbImpl clearTransientState];
            [kbImpl clearAnimations];
            [kbImpl setCaretBlinks:YES];
            
        }
    }
    [self autoPaginationControl];
}

-(void)cutAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:10  toastHeightOffset:0];
    
    if ([delegate respondsToSelector:@selector(cut:)]) {
        [delegate cut:nil]; //UIResponderStandardEditActions.h
    }else if ([delegate respondsToSelector:@selector(selectedTextRange)]) {
        UITextRange *range = [delegate selectedTextRange];
        NSString *textRange = [delegate textInRange:range];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        
        [pasteboard setString:textRange];
        
        [kbImpl deleteFromInput];
        [kbImpl clearTransientState];
        [kbImpl clearAnimations];
        [kbImpl setCaretBlinks:YES];
    }
    [self autoPaginationControl];
}

-(void)undoAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    if ([[delegate undoManager] canUndo]) {
        [[delegate undoManager] undo];
        
        [kbImpl clearTransientState];
        [kbImpl clearAnimations];
        [kbImpl setCaretBlinks:YES];
    }
    [self autoPaginationControl];
}

-(void)redoAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    if ([[delegate undoManager] canRedo]) {
        [[delegate undoManager] redo];
        
        [kbImpl clearTransientState];
        [kbImpl clearAnimations];
        [kbImpl setCaretBlinks:YES];
    }
    [self autoPaginationControl];
}

-(void)selectAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    
    if ([delegate respondsToSelector:@selector(select:)]) {
        [delegate select:nil]; //UIResponderStandardEditActions.h
    }else{
        if (![kbImpl isUsingDictationLayout]){
            NSString *selectedString = [delegate textInRange:[delegate selectedTextRange]];
            if (!selectedString.length) {
                UITextRange *textRange = [self selectedWordTextRangeWithDelegate:delegate];
                
                if (!textRange)
                    return;
                UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
                if (![((UITextField *)tempDelegate).text isEqualToString:@"\uFFFC"]){
                    tempDelegate.selectedTextRange = textRange;
                }
                [kbImpl clearTransientState];
                [kbImpl clearAnimations];
                [kbImpl setCaretBlinks:YES];
            }
        }
    }
    [self autoPaginationControl];
}

-(void)beginningAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        [(WKContentView *)tempDelegate executeEditCommandWithCallback:@"moveToBeginningOfDocument"];
    }else{
        tempDelegate.selectedTextRange = [tempDelegate textRangeFromPosition:tempDelegate.beginningOfDocument toPosition:tempDelegate.beginningOfDocument];
    }
    [kbImpl clearTransientState];
    [kbImpl clearAnimations];
    [kbImpl setCaretBlinks:YES];
    [self autoPaginationControl];
}

-(void)endingAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        [(WKContentView *)tempDelegate executeEditCommandWithCallback:@"moveToEndOfDocument"];
    }else{
        tempDelegate.selectedTextRange = [tempDelegate textRangeFromPosition:tempDelegate.endOfDocument toPosition:tempDelegate.endOfDocument];
    }
    
    [kbImpl clearTransientState];
    [kbImpl clearAnimations];
    [kbImpl setCaretBlinks:YES];
    [self autoPaginationControl];
}

-(void)capitalizeAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:10  toastHeightOffset:0];
    NSString *selectedString = [delegate textInRange:[delegate selectedTextRange]];
    if (!selectedString.length) {
        UITextRange *textRange = [self selectedWordTextRangeWithDelegate:delegate];
        
        if (!textRange)
            return;
        UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
        tempDelegate.selectedTextRange = textRange;
        
        NSString *capitalizedStrings = [[delegate textInRange:textRange] capitalizedString];
        [kbImpl insertText:capitalizedStrings];
        
    }else{
        NSString *capitalizedStrings = [selectedString capitalizedString];
        [kbImpl insertText:capitalizedStrings];
    }
    [kbImpl clearTransientState];
    [kbImpl clearAnimations];
    [kbImpl setCaretBlinks:YES];
    [self autoPaginationControl];
}

-(void)lowercaseAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:10  toastHeightOffset:-5];
    NSString *selectedString = [delegate textInRange:[delegate selectedTextRange]];
    if (!selectedString.length) {
        UITextRange *textRange = [self selectedWordTextRangeWithDelegate:delegate];
        
        if (!textRange)
            return;
        UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
        tempDelegate.selectedTextRange = textRange;
        
        NSString *lowercaseStrings = [[delegate textInRange:textRange] lowercaseString];
        [kbImpl insertText:lowercaseStrings];
    }else{
        NSString *lowercaseStrings = [selectedString lowercaseString];
        [kbImpl insertText:lowercaseStrings];
    }
    [kbImpl clearTransientState];
    [kbImpl clearAnimations];
    [kbImpl setCaretBlinks:YES];
    [self autoPaginationControl];
}

-(void)uppercaseAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    NSString *selectedString = [delegate textInRange:[delegate selectedTextRange]];
    if (!selectedString.length) {
        UITextRange *textRange = [self selectedWordTextRangeWithDelegate:delegate];
        
        if (!textRange) return;
        UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
        tempDelegate.selectedTextRange = textRange;
        
        NSString *uppercaseStrings = [[delegate textInRange:textRange] uppercaseString];
        [kbImpl insertText:uppercaseStrings];
    }else{
        NSString *uppercaseStrings = [selectedString uppercaseString];
        [kbImpl insertText:uppercaseStrings];
    }
    [kbImpl clearTransientState];
    [kbImpl clearAnimations];
    [kbImpl setCaretBlinks:YES];
    [self autoPaginationControl];
}

-(void)deleteAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:10  toastHeightOffset:0];
    NSString *selectedString = [delegate textInRange:[delegate selectedTextRange]];
    BOOL smartDelete = preferencesBool(kEnabledSmartDeletekey, NO);
    if (!selectedString.length) {
        UITextRange *textRange = [self selectedWordTextRangeWithDelegate:delegate direction:UITextStorageDirectionBackward];
        
        if (!textRange) return;
        
        UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
        
        tempDelegate.selectedTextRange = textRange;
        //[kbImpl deleteFromInput];
        [kbImpl deleteFromInput];
        if (smartDelete) [kbImpl insertText:@" "];
        //[tempDelegate  _moveRight:NO withHistory:nil];
        
        [kbImpl clearTransientState];
        [kbImpl clearAnimations];
        [kbImpl setCaretBlinks:YES];
        
    }else{
        [kbImpl deleteBackward];
        if (smartDelete) [kbImpl insertText:@" "];
        [kbImpl clearTransientState];
        [kbImpl clearAnimations];
        [kbImpl setCaretBlinks:YES];
    }
    [self autoPaginationControl];
    
}

-(void)deleteForwardAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:10  toastHeightOffset:0];
    NSString *selectedString = [delegate textInRange:[delegate selectedTextRange]];
    BOOL smartDelete = preferencesBool(kEnabledSmartDeleteForwardkey, NO);
    if (!selectedString.length) {
        UITextRange *textRange = [self selectedWordTextRangeWithDelegate:delegate direction:UITextStorageDirectionForward];
        
        if (!textRange) return;
        
        UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
        
        tempDelegate.selectedTextRange = textRange;
        //[kbImpl deleteFromInput];
        [kbImpl deleteFromInput];
        if (smartDelete) [kbImpl insertText:@" "];
        //[tempDelegate  _moveRight:NO withHistory:nil];
        
        [kbImpl clearTransientState];
        [kbImpl clearAnimations];
        [kbImpl setCaretBlinks:YES];
        
    }else{
        [kbImpl deleteForwardAndNotify:YES];
        if (smartDelete) [kbImpl insertText:@" "];
        [kbImpl clearTransientState];
        [kbImpl clearAnimations];
        [kbImpl setCaretBlinks:YES];
    }
    [self autoPaginationControl];
    
}

-(void)deleteAllAction:(UIButton*)sender{
    [self autoPaginationControl];
    self.hapticType = 0;
    [self selectAllAction:nil];
    self.hapticType = 2;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secondActionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self triggerImpactAndAnimationWithButton:sender selectorName:@"deleteAction:" toastWidthOffset:10 toastHeightOffset:0];
        [self beginUpdateDelegate];
        [kbImpl deleteFromInput];
        [kbImpl clearTransientState];
        [kbImpl clearAnimations];
        [kbImpl setCaretBlinks:YES];
        [self autoPaginationControl];
    });
}

/*
 -(void)boldAction:(UIButton*)sender{
 [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
 kbImpl = [%c(UIKeyboardImpl) activeInstance];
 delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
 UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
 
 BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
 if (isWKContentView){
 [(WKContentView *)tempDelegate executeEditCommandWithCallback:@"toggleBold"];
 }else{
 HBLogDebug(@"tempDelegate: %@", tempDelegate);
 BOOL isUITextView = [tempDelegate respondsToSelector:@selector(allowsEditingTextAttributes)];
 HBLogDebug(@"isUITextView: %d",  isUITextView?1:0);
 
 //BOOL isUITextView = [[tempDelegate superclass] isKindOfClass:objc_getClass("UITextView")];
 if (isUITextView){
 UITextView *textViewDelegate = (UITextView *)delegate;
 HBLogDebug(@"allowsEditingTextAttributes: %d",  textViewDelegate.allowsEditingTextAttributes?1:0);
 if (textViewDelegate.allowsEditingTextAttributes){
 [textViewDelegate toggleBoldface:nil];
 }else{
 
 UITextRange *textRange = [self selectedWordTextRangeWithDelegate:delegate];
 
 UITextPosition *beginning = textViewDelegate.beginningOfDocument;
 UITextPosition* selectionStart = textRange.start;
 UITextPosition* selectionEnd = textRange.end;
 
 const NSInteger location = [textViewDelegate offsetFromPosition:beginning toPosition:selectionStart];
 const NSInteger length = [textViewDelegate offsetFromPosition:selectionStart toPosition:selectionEnd];
 
 NSRange range = NSMakeRange(location, length);
 NSMutableDictionary *attrDict = [(NSMutableDictionary *)[textViewDelegate.textStorage attributesAtIndex:0 effectiveRange:&range] mutableCopy];
 UIFont *font = [attrDict objectForKey:NSFontAttributeName];
 UIFontDescriptor *fontD = [font.fontDescriptor
 fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
 UIFont *newFont = [UIFont fontWithDescriptor:fontD size:0];
 [attrDict setObject:newFont forKey:NSFontAttributeName ];
 [textViewDelegate.textStorage setAttributes:attrDict range:range];
 
 }
 }
 }
 
 }
 */

-(void)boldAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        [(WKContentView *)tempDelegate executeEditCommandWithCallback:@"toggleBold"];
    }else{
        [tempDelegate toggleBoldface:nil];
    }
    [self autoPaginationControl];
}

-(void)italicAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        [(WKContentView *)tempDelegate executeEditCommandWithCallback:@"toggleItalic"];
    }else{
        [tempDelegate toggleItalics:nil];
    }
    [self autoPaginationControl];
}

-(void)underlineAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        [(WKContentView *)tempDelegate executeEditCommandWithCallback:@"toggleUnderline"];
    }else{
        [tempDelegate toggleUnderline:nil];
    }
    [self autoPaginationControl];
}

-(void)dismissKeyboardAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:10 toastHeightOffset:0];
    kbImpl = [%c(UIKeyboardImpl) activeInstance];
    [kbImpl dismissKeyboard];
    [self autoPaginationControl];
}

-(void)moveCursorLeftAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    
    BOOL isWKContentView = [delegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        BOOL isRTL  = [self isRTLForDelegate:delegate];
        if (isRTL){
            [(WKContentView *)delegate executeEditCommandWithCallback:@"moveRight"];
        }else{
            [(WKContentView *)delegate executeEditCommandWithCallback:@"moveLeft"];
        }
    }else{
        [self moveCursorWithDelegate:delegate offset:-1];
    }
    [self autoPaginationControl];
}

-(void)moveCursorRightAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    
    BOOL isWKContentView = [delegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        BOOL isRTL  = [self isRTLForDelegate:delegate];
        if (isRTL){
            [(WKContentView *)delegate executeEditCommandWithCallback:@"moveLeft"];
        }else{
            [(WKContentView *)delegate executeEditCommandWithCallback:@"moveRight"];
        }
    }else{
        [self moveCursorWithDelegate:delegate offset:1];
    }
    [self autoPaginationControl];
}

-(void)moveCursorPreviousWordAction:(UIButton*)sender{
    [self autoPaginationControl];
    if (sender || self.isWordSender){
        [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    }
    [self beginUpdateDelegate];
    
    BOOL isWKContentView = [delegate isKindOfClass:objc_getClass("WKContentView")];
    BOOL isRTL  = [self isRTLForDelegate:delegate];
    if (isWKContentView){
        if (isRTL){
            [(WKContentView *)delegate _moveToEndOfWord:self.moveCursorWithSelect withHistory:nil];
        }else{
            [(WKContentView *)delegate _moveToStartOfWord:self.moveCursorWithSelect withHistory:nil];
        }
    }else{
        if ([delegate respondsToSelector:@selector(_moveToStartOfWord:withHistory:)]){
            //if (isRTL){
            //[delegate _moveToEndOfWord:NO withHistory:nil];
            //}else{
            [delegate _moveToStartOfWord:self.moveCursorWithSelect withHistory:nil];
            //}
        }else{
            [self moveCursorSingleWordWithDelegate:delegate direction:UITextStorageDirectionBackward];
        }
    }
    self.moveCursorWithSelect = NO;
    self.isWordSender = NO;
    [self autoPaginationControl];
}

-(void)moveCursorNextWordAction:(UIButton*)sender{
    [self autoPaginationControl];
    if (sender || self.isWordSender){
        [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    }
    [self beginUpdateDelegate];
    
    BOOL isWKContentView = [delegate isKindOfClass:objc_getClass("WKContentView")];
    BOOL isRTL  = [self isRTLForDelegate:delegate];
    if (isWKContentView){
        if (isRTL){
            [(WKContentView *)delegate _moveToStartOfWord:self.moveCursorWithSelect withHistory:nil];
        }else{
            [(WKContentView *)delegate _moveToEndOfWord:self.moveCursorWithSelect withHistory:nil];
        }
    }else{
        if ([delegate respondsToSelector:@selector(_moveToEndOfWord:withHistory:)]){
            //if (isRTL){
            //[delegate _moveToStartOfWord:NO withHistory:nil];
            //}else{
            [delegate _moveToEndOfWord:self.moveCursorWithSelect withHistory:nil];
            //}
        }else{
            [self moveCursorSingleWordWithDelegate:delegate direction:UITextStorageDirectionForward];
        }
    }
    self.moveCursorWithSelect = NO;
    self.isWordSender = NO;
    [self autoPaginationControl];
}

-(void)moveCursorStartOfLineAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.start;
    self.moveCursorWithSelect = NO;
    [self moveCursorPreviousWordAction:nil];
    UITextPosition *startPositionMovedTemp = tempDelegate.selectedTextRange.start;
    if (((UITextRange * )[delegate _rangeOfLineEnclosingPosition:startPositionMovedTemp]).start == ((UITextRange * )[delegate _rangeOfLineEnclosingPosition:startPositionTemp]).start){
        [delegate _moveToStartOfLine:NO withHistory:nil];
        
        //[self moveCursorPreviousWordAction:nil];
        
    }
    
    BOOL isWKContentView = [delegate isKindOfClass:objc_getClass("WKContentView")];
    BOOL isRTL  = [self isRTLForDelegate:delegate];
    
    if (isWKContentView){
        if (isRTL){
            [(WKContentView *)delegate _moveToEndOfLine:self.moveCursorWithSelect withHistory:nil];
        }else{
            [(WKContentView *)delegate _moveToStartOfLine:self.moveCursorWithSelect withHistory:nil];
        }
    }else{
        if ([delegate respondsToSelector:@selector(_moveToStartOfLine:withHistory:)]){
            //if (isRTL){
            //[delegate _moveToEndOfLine:NO withHistory:nil];
            //}else{
            [delegate _moveToStartOfLine:self.moveCursorWithSelect withHistory:nil];
            //}
        }else{
            [self moveCursorToLineExtremityWithDelegate:delegate direction:UITextLayoutDirectionLeft];
        }
    }
    self.moveCursorWithSelect = NO;
    [self autoPaginationControl];
}

-(void)moveCursorEndOfLineAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.end;
    self.moveCursorWithSelect = NO;
    
    [self moveCursorNextWordAction:nil];
    UITextPosition *startPositionMovedTemp = tempDelegate.selectedTextRange.end;
    if (((UITextRange * )[delegate _rangeOfLineEnclosingPosition:startPositionMovedTemp]).end == ((UITextRange * )[delegate _rangeOfLineEnclosingPosition:startPositionTemp]).end){
        [self moveCursorNextWordAction:nil];
        
        [delegate _moveToEndOfLine:NO withHistory:nil];
        
    }
    
    BOOL isWKContentView = [delegate isKindOfClass:objc_getClass("WKContentView")];
    BOOL isRTL  = [self isRTLForDelegate:delegate];
    
    if (isWKContentView){
        if (isRTL){
            [(WKContentView *)delegate _moveToStartOfLine:self.moveCursorWithSelect withHistory:nil];
        }else{
            [(WKContentView *)delegate _moveToEndOfLine:self.moveCursorWithSelect withHistory:nil];
        }
    }else{
        if ([delegate respondsToSelector:@selector(_moveToEndOfLine:withHistory:)]){
            //if (isRTL){
            //[delegate _moveToStartOfLine:NO withHistory:nil];
            //}else{
            [delegate _moveToEndOfLine:self.moveCursorWithSelect withHistory:nil];
            //}
        }else{
            [self moveCursorToLineExtremityWithDelegate:delegate direction:UITextLayoutDirectionRight];
        }
    }
    self.moveCursorWithSelect = NO;
    [self autoPaginationControl];
}

-(void)moveCursorStartOfParagraphAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.start;
    if (startPositionTemp == ((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:startPositionTemp]).start){
        self.moveCursorWithSelect = NO;
        [self moveCursorPreviousWordAction:nil];
    }
    
    BOOL isWKContentView = [delegate isKindOfClass:objc_getClass("WKContentView")];
    BOOL isRTL  = [self isRTLForDelegate:delegate];
    
    if (isWKContentView){
        if (isRTL){
            [(WKContentView *)delegate _moveToEndOfParagraph:self.moveCursorWithSelect withHistory:nil];
        }else{
            [(WKContentView *)delegate _moveToStartOfParagraph:self.moveCursorWithSelect withHistory:nil];
        }
    }else{
        if ([delegate respondsToSelector:@selector(_moveToStartOfParagraph:withHistory:)]){
            //if (isRTL){
            //[delegate _moveToStartOfLine:NO withHistory:nil];
            //}else{
            [delegate _moveToStartOfParagraph:self.moveCursorWithSelect withHistory:nil];
            //}
        }
    }
    self.moveCursorWithSelect = NO;
    [self autoPaginationControl];
}

-(void)moveCursorEndOfParagraphAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    UITextPosition *endPositionTemp = tempDelegate.selectedTextRange.end;
    if (endPositionTemp == ((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:endPositionTemp]).end){
        self.moveCursorWithSelect = NO;
        [self moveCursorNextWordAction:nil];
    }
    BOOL isWKContentView = [delegate isKindOfClass:objc_getClass("WKContentView")];
    BOOL isRTL  = [self isRTLForDelegate:delegate];
    
    if (isWKContentView){
        if (isRTL){
            [(WKContentView *)delegate _moveToStartOfParagraph:self.moveCursorWithSelect withHistory:nil];
        }else{
            [(WKContentView *)delegate _moveToEndOfParagraph:self.moveCursorWithSelect withHistory:nil];
        }
    }else{
        if ([delegate respondsToSelector:@selector(_moveToEndOfParagraph:withHistory:)]){
            //if (isRTL){
            //[delegate _moveToStartOfLine:NO withHistory:nil];
            //}else{
            [delegate _moveToEndOfParagraph:self.moveCursorWithSelect withHistory:nil];
            //}
        }
    }
    self.moveCursorWithSelect = NO;
    [self autoPaginationControl];
}

-(void)moveCursorStartOfSentenceAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.start;
    self.moveCursorWithSelect = NO;
    [self moveCursorPreviousWordAction:nil];
    UITextPosition *startPositionMovedTemp = tempDelegate.selectedTextRange.start;
    if (((UITextRange * )[delegate _rangeOfSentenceEnclosingPosition:startPositionMovedTemp]).start == ((UITextRange * )[delegate _rangeOfSentenceEnclosingPosition:startPositionTemp]).start){
        //[delegate _moveToStartOfLine:NO withHistory:nil];
        
        [self moveCursorPreviousWordAction:nil];
        
    }
    
    [delegate _setSelectionToPosition:((UITextRange * )[delegate _rangeOfSentenceEnclosingPosition:startPositionMovedTemp]).start];
    [self autoPaginationControl];
    
}

-(void)moveCursorEndOfSentenceAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.end;
    self.moveCursorWithSelect = NO;
    
    [self moveCursorNextWordAction:nil];
    UITextPosition *startPositionMovedTemp = tempDelegate.selectedTextRange.end;
    if (((UITextRange * )[delegate _rangeOfSentenceEnclosingPosition:startPositionMovedTemp]).end == ((UITextRange * )[delegate _rangeOfSentenceEnclosingPosition:startPositionTemp]).end){
        [self moveCursorNextWordAction:nil];
        
        //[delegate _moveToEndOfLine:NO withHistory:nil];
        
    }
    [delegate _setSelectionToPosition:((UITextRange * )[delegate _rangeOfSentenceEnclosingPosition:startPositionMovedTemp]).end];
    [self autoPaginationControl];
    
}

-(void)moveCursorUpAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    
    BOOL isWKContentView = [delegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        [(WKContentView *)delegate executeEditCommandWithCallback:@"moveUp"];
    }else{
        [self moveCursorVerticalWithDelegate:delegate direction:UITextLayoutDirectionUp];
    }
    [self autoPaginationControl];
}

-(void)moveCursorDownAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    
    BOOL isWKContentView = [delegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        [(WKContentView *)delegate executeEditCommandWithCallback:@"moveDown"];
    }else{
        [self moveCursorVerticalWithDelegate:delegate direction:UITextLayoutDirectionDown];
    }
    [self autoPaginationControl];
}

-(void)moveCursorContinuoslyWithDelegate:(id <UITextInput, UITextInputTokenizer>)delegate offset:(int)offset{
    [self moveCursorWithDelegate:delegate offset:offset];
}

-(CPDistributedMessagingCenter *)IPCCenterNamed:(NSString *)centerName{
    CPDistributedMessagingCenter *c = [CPDistributedMessagingCenter centerNamed:centerName];
    rocketbootstrap_distributedmessagingcenter_apply(c);
    return c;
}

-(BOOL)isAutoCorrectionEnabled{
    BOOL enabled = NO;
    if (!isSpringBoard){
        if (!self.dockxCenter) self.dockxCenter = [self IPCCenterNamed:kIPCCenterDockX];
        NSDictionary *result = [self.dockxCenter sendMessageAndReceiveReplyName:@"getAutoCorrectionValue" userInfo:nil];
        enabled = [result[@"value"] boolValue];
    }else{
        [[%c(UIKeyboardPreferencesController) sharedPreferencesController] synchronizePreferences];
        enabled = [[%c(UIKeyboardPreferencesController) sharedPreferencesController] boolForKey:7];
    }
    return enabled;
}

-(void)setAutoCorrection:(BOOL)enabled{
    if (!isSpringBoard){
        if (!self.dockxCenter) self.dockxCenter = [self IPCCenterNamed:kIPCCenterDockX];
        [self.dockxCenter sendMessageAndReceiveReplyName:@"setAutoCorrectionValue" userInfo:@{@"value":[NSNumber numberWithBool:enabled]}];
    }else{
        [[%c(UIKeyboardPreferencesController) sharedPreferencesController] setValue:[NSNumber numberWithBool:enabled] forKey:7];
        [[%c(UIKeyboardPreferencesController) sharedPreferencesController] synchronizePreferences];
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("AppleKeyboardsSettingsChangedNotification"), NULL, NULL, YES);
    }
}

-(void)updateAutoCorrection:(NSNotification*)notification{
    if (!self.isSameProcess && !self.autoCorrectionCell.hidden){
        if (!self.asyncUpdated) self.autoCorrectionEnabled = [self isAutoCorrectionEnabled];
        NSMutableAttributedString *imageOfName = [[NSMutableAttributedString alloc] initWithString:@""];
        
        UIImage *image;
        
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[DockXHelper localizedStringForActionNamed:@"autoCorrectionAction:" shortName:YES bundle:tweakBundle]];
        NSMutableAttributedString *strikedAttributeString = [attributeString mutableCopy];
        [strikedAttributeString addAttribute:NSStrikethroughStyleAttributeName value:@2 range:NSMakeRange(0, [attributeString length])];
        
        if (@available(iOS 13.0, *)){
            if (useShortenedLabel){
                imageOfName = self.autoCorrectionEnabled?attributeString:strikedAttributeString;
            }else{
                image = [UIImage systemImageNamed:self.autoCorrectionEnabled?@"checkmark.circle.fill":@"checkmark.circle"];
            }
        }else{
            if (@available(iOS 13.0, *)){
                if (useShortenedLabel){
                    imageOfName = self.autoCorrectionEnabled?attributeString:strikedAttributeString;
                }else{
                    image = [UIImage imageNamed:self.autoCorrectionEnabled?@"UIAccessoryButtonCheckmark":@"UIAccessoryButtonX" inBundle:[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/UIKitCore.framework/Artwork.bundle"] compatibleWithTraitCollection:NULL];
                }
            }
        }
        if (useShortenedLabel){
            [self.autoCorrectionCell.btn setImage:nil forState:UIControlStateNormal];
            [self.autoCorrectionCell.btn setAttributedTitle:imageOfName forState:UIControlStateNormal];
        }else{
            [self.autoCorrectionCell.btn setAttributedTitle:nil forState:UIControlStateNormal];
            [self.autoCorrectionCell.btn setImage:image forState:UIControlStateNormal];
        }
    }
    self.asyncUpdated = NO;
    self.isSameProcess = NO;
}

-(void)autoCorrectionAction:(UIButton*)sender{
    [self autoPaginationControl];
    self.autoCorrectionEnabled = [self isAutoCorrectionEnabled];
    [self setAutoCorrection:!self.autoCorrectionEnabled];
    self.isSameProcess = YES;
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    
    
    //sender.highlighted = !autoCorrectionEnabled;
    //sender.selected = !autoCorrectionEnabled;
    NSMutableAttributedString *imageOfName = [[NSMutableAttributedString alloc] initWithString:@""];
    
    UIImage *image;
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[DockXHelper localizedStringForActionNamed:@"autoCorrectionAction:" shortName:YES bundle:tweakBundle]];
    NSMutableAttributedString *strikedAttributeString = [attributeString mutableCopy];
    [strikedAttributeString addAttribute:NSStrikethroughStyleAttributeName value:@2 range:NSMakeRange(0, [attributeString length])];
    
    if (@available(iOS 13.0, *)){
        if (useShortenedLabel){
            imageOfName = !self.autoCorrectionEnabled?attributeString:strikedAttributeString;
        }else{
            image = [UIImage systemImageNamed:(!self.autoCorrectionEnabled)?@"checkmark.circle.fill":@"checkmark.circle"];
        }
    }else{
        if (useShortenedLabel){
            imageOfName = !self.autoCorrectionEnabled?attributeString:strikedAttributeString;
        }else{
            image = [UIImage imageNamed:(!self.autoCorrectionEnabled)?@"UIAccessoryButtonCheckmark":@"UIAccessoryButtonX" inBundle:[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/UIKitCore.framework/Artwork.bundle"] compatibleWithTraitCollection:NULL];
        }
    }
    if (useShortenedLabel){
        [sender setImage:nil forState:UIControlStateNormal];
        [sender setAttributedTitle:imageOfName forState:UIControlStateNormal];
    }else{
        [sender setAttributedTitle:nil forState:UIControlStateNormal];
        [sender setImage:image forState:UIControlStateNormal];
    }
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)kAutoCorrectionChangedIdentifier, NULL, NULL, YES);
    [self autoPaginationControl];
}

-(BOOL)isAutoCapitalizationEnabled{
    BOOL enabled = NO;
    if (!isSpringBoard){
        if (!self.dockxCenter) self.dockxCenter = [self IPCCenterNamed:kIPCCenterDockX];
        NSDictionary *result = [self.dockxCenter sendMessageAndReceiveReplyName:@"getAutoCapitalizationValue" userInfo:nil];
        enabled = [result[@"value"] boolValue];
    }else{
        [[%c(UIKeyboardPreferencesController) sharedPreferencesController] synchronizePreferences];
        enabled = [[%c(UIKeyboardPreferencesController) sharedPreferencesController] boolForKey:8];
    }
    return enabled;
}

-(void)setAutoCapitalization:(BOOL)enabled{
    if (!isSpringBoard){
        if (!self.dockxCenter) self.dockxCenter = [self IPCCenterNamed:kIPCCenterDockX];
        [self.dockxCenter sendMessageAndReceiveReplyName:@"setAutoCapitalizationValue" userInfo:@{@"value":[NSNumber numberWithBool:enabled]}];
    }else{
        if (!kbController){
            
            dlopen("/System/Library/PreferenceBundles/KeyboardSettings.bundle/KeyboardSettings", RTLD_LAZY);
            PSRootController *rootController = [[PSRootController alloc] initWithTitle:@"Preferences" identifier:@"com.apple.Preferences"];
            kbController = [[NSClassFromString(@"KeyboardController") alloc] init];
            if ([kbController respondsToSelector:@selector(setRootController:)]){
                [kbController setRootController:rootController];
            }
            if ([kbController respondsToSelector:@selector(setParentController:)]){
                [kbController setParentController:rootController];
            }
            //if ([kbController respondsToSelector:@selector(specifiersWithSpecifier:)])
            //[kbController specifiersWithSpecifier:nil];
        }
        NSArray *specifiers = [kbController loadAllKeyboardPreferences];
        PSSpecifier *autoCapsSpecifier;
        for (PSSpecifier *sp in specifiers){
            if ([sp.identifier isEqualToString:@"KeyboardAutocapitalization"]){
                autoCapsSpecifier = sp;
                break;
            }
        }
        if (autoCapsSpecifier){
            [kbController setKeyboardPreferenceValue:[NSNumber numberWithBool:enabled] forSpecifier:autoCapsSpecifier];
        }
        
        //[[%c(UIKeyboardPreferencesController) sharedPreferencesController] setValue:[NSNumber numberWithBool:enabled] forKey:8];
        //[[%c(UIKeyboardPreferencesController) sharedPreferencesController] synchronizePreferences];
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("AppleKeyboardsSettingsChangedNotification"), NULL, NULL, YES);
    }
}

-(void)updateAutoCapitalization:(NSNotification*)notification{
    if (!self.isSameProcess && !self.autoCapitalizationCell.hidden){
        if (!self.asyncUpdated) self.autoCapitalizationEnabled = [self isAutoCapitalizationEnabled];
        
        NSMutableAttributedString *imageOfName = [[NSMutableAttributedString alloc] initWithString:@""];
        
        UIImage *image;
        
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[DockXHelper localizedStringForActionNamed:@"autoCapitalizationAction:" shortName:YES bundle:tweakBundle]];
        NSMutableAttributedString *strikedAttributeString = [attributeString mutableCopy];
        [strikedAttributeString addAttribute:NSStrikethroughStyleAttributeName value:@2 range:NSMakeRange(0, [attributeString length])];
        
        if (@available(iOS 13.0, *)){
            if (useShortenedLabel){
                imageOfName = self.autoCapitalizationEnabled?attributeString:strikedAttributeString;
            }else{
                image = [UIImage systemImageNamed:self.autoCapitalizationEnabled?@"shift.fill":@"shift"];
            }
        }else{
            if (useShortenedLabel){
                imageOfName = self.autoCapitalizationEnabled?attributeString:strikedAttributeString;
            }else{
                image = [UIImage imageNamed:self.autoCapitalizationEnabled?@"shift_on_portrait":@"shift_portrait" inBundle:[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/UIKitCore.framework/Artwork.bundle"] compatibleWithTraitCollection:NULL];
            }
        }
        if (useShortenedLabel){
            [self.autoCapitalizationCell.btn setImage:nil forState:UIControlStateNormal];
            [self.autoCapitalizationCell.btn setAttributedTitle:imageOfName forState:UIControlStateNormal];
        }else{
            [self.autoCapitalizationCell.btn setAttributedTitle:nil forState:UIControlStateNormal];
            [self.autoCapitalizationCell.btn setImage:image forState:UIControlStateNormal];
        }
    }
    self.asyncUpdated = NO;
    self.isSameProcess = NO;
}

-(void)autoCapitalizationAction:(UIButton*)sender{
    [self autoPaginationControl];
    self.autoCapitalizationEnabled = [self isAutoCapitalizationEnabled];
    [self setAutoCapitalization:!self.autoCapitalizationEnabled];
    self.isSameProcess = YES;
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    
    
    //sender.highlighted = !autoCorrectionEnabled;
    //sender.selected = !autoCorrectionEnabled;
    NSMutableAttributedString *imageOfName = [[NSMutableAttributedString alloc] initWithString:@""];
    
    UIImage *image;
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[DockXHelper localizedStringForActionNamed:@"autoCapitalizationAction:" shortName:YES bundle:tweakBundle]];
    NSMutableAttributedString *strikedAttributeString = [attributeString mutableCopy];
    [strikedAttributeString addAttribute:NSStrikethroughStyleAttributeName value:@2 range:NSMakeRange(0, [attributeString length])];
    
    if (@available(iOS 13.0, *)){
        if (useShortenedLabel){
            imageOfName = !self.autoCapitalizationEnabled?attributeString:strikedAttributeString;
        }else{
            image = [UIImage systemImageNamed:(!self.autoCapitalizationEnabled)?@"shift.fill":@"shift"];
        }
    }else{
        if (useShortenedLabel){
            imageOfName = !self.autoCapitalizationEnabled?attributeString:strikedAttributeString;
        }else{
            image = [UIImage imageNamed:(!self.autoCapitalizationEnabled)?@"shift_on_portrait":@"shift_portrait" inBundle:[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/UIKitCore.framework/Artwork.bundle"] compatibleWithTraitCollection:NULL];
        }
    }
    if (useShortenedLabel){
        [sender setImage:nil forState:UIControlStateNormal];
        [sender setAttributedTitle:imageOfName forState:UIControlStateNormal];
    }else{
        [sender setAttributedTitle:nil forState:UIControlStateNormal];
        [sender setImage:image forState:UIControlStateNormal];
    }
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)kAutoCapitalizationChangedIdentifier, NULL, NULL, YES);
    [self autoPaginationControl];
}

-(void)keyboardTypeAction:(UIButton*)sender{
    [self autoPaginationControl];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    if ([delegate respondsToSelector:@selector(keyboardType)]){
        //HBLogDebug(@"keyboardTypeAction: %ld", [delegate keyboardType]);
        [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
        [self beginUpdateDelegate];
        
        NSUInteger index = [self.kbType indexOfObject:[NSNumber numberWithInt:[delegate keyboardType]>12?0:[delegate keyboardType]]];
        //HBLogDebug(@"kbtype current index: %ld, count: %lu", index, [self.kbType count]);
        if (index < [self.kbType count] - 1 ){
            int kbTypeInt = [self.kbType[index+1] intValue];
            //HBLogDebug(@"XXXXXX===== kbTypeInt: %d, keyboardType: %@", kbTypeInt, [NSNumber numberWithInt:[delegate keyboardType]]);
            if ([delegate keyboardType] < 0 || kbTypeInt == -1 ){
                kbTypeInt = [self.kbType[index+2] intValue];
            }
            if (kbTypeInt >= 0){
                [delegate setKeyboardType:kbTypeInt];
            }else{
                [delegate setKeyboardType:self.trueKBType];
            }
        }else{
            //HBLogDebug(@"ELSEEEEEE");
            int kbTypeInt = [self.kbType[0] intValue];
            int i = 1;
            while (kbTypeInt == (int)[delegate keyboardType]){
                kbTypeInt = [self.kbType[i] intValue];
                i = i + 1;
            }
            [delegate setKeyboardType:kbTypeInt];
        }
        [delegate reloadInputViews];
    }
    [self autoPaginationControl];
}

-(void)updateKeyboardType:(NSNotification*)notification{
    //HBLogDebug(@"updateKeyboardType");
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    NSMutableAttributedString *imageOfName = [[NSMutableAttributedString alloc] initWithString:@""];
    
    UIImage *image;
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:@"Input"];
    NSMutableAttributedString *strikedAttributeString = [attributeString mutableCopy];
    [strikedAttributeString addAttribute:NSStrikethroughStyleAttributeName value:@2 range:NSMakeRange(0, [attributeString length])];
    
    if (@available(iOS 13.0, *)){
        if (useShortenedLabel){
            imageOfName = [delegate respondsToSelector:@selector(keyboardType)]?attributeString:strikedAttributeString;
        }else{
            image = [UIImage systemImageNamed:[delegate respondsToSelector:@selector(keyboardType)]?@"number.circle.fill":@"number.circle"];
        }
    }else{
        if (useShortenedLabel){
            imageOfName = [delegate respondsToSelector:@selector(keyboardType)]?attributeString:strikedAttributeString;
        }else{
            image = [UIImage imageNamed:[delegate respondsToSelector:@selector(keyboardType)]?@"reachable_full":@"dictation_keyboard_dark" inBundle:[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/UIKitCore.framework/Artwork.bundle"] compatibleWithTraitCollection:NULL];
        }
    }
    
    if (useShortenedLabel){
        [self.keyboardInputTypeCell.btn setImage:nil forState:UIControlStateNormal];
        [self.keyboardInputTypeCell.btn setAttributedTitle:imageOfName forState:UIControlStateNormal];
    }else{
        [self.keyboardInputTypeCell.btn setAttributedTitle:nil forState:UIControlStateNormal];
        [self.keyboardInputTypeCell.btn setImage:image forState:UIControlStateNormal];
    }
}

-(void)defineAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        NSString *selectedString = [(WKContentView *)tempDelegate selectedText];
        [(WKContentView *)tempDelegate select:nil];
        if ([selectedString length] == 0) return;
        if ([tempDelegate respondsToSelector:@selector(_define:)]){
            //[(WKContentView *)tempDelegate selectWordBackward];
            [(WKContentView *)tempDelegate _define:selectedString];
        }
    }else{
        NSString *selectedString = [tempDelegate textInRange:[tempDelegate selectedTextRange]];
        
        if (!selectedString.length) {
            UITextRange *textRange = [self autoDirectionWordSelectedTextRangeWithDelegate:tempDelegate];
            if (!textRange) return;
            tempDelegate.selectedTextRange = textRange;
            selectedString = [tempDelegate textInRange:textRange];
        }
        if ([tempDelegate respondsToSelector:@selector(_define:)]){
            [tempDelegate _define:selectedString];
        }
    }
    [self autoPaginationControl];
}

-(NSDictionary *)getItemWithID:(NSString *)snippetID forKey:(NSString *)keyName identifierKey:(NSString *)identifier{
    NSArray *arrayWithEventID = [prefs[keyName] valueForKey:identifier];
    NSUInteger index = [arrayWithEventID indexOfObject:snippetID];
    NSDictionary *snippet = index != NSNotFound ? prefs[keyName][index] : nil;
    return snippet;
}

-(void)runCommand:(NSString *)cmd{
    if ([cmd length] != 0){
        if (!isSpringBoard){
            if (!self.dockxCenter) self.dockxCenter = [self IPCCenterNamed:kIPCCenterDockX];
            [self.dockxCenter sendMessageAndReceiveReplyName:@"runCommand" userInfo:@{@"value":cmd}];
        }else{
            NSMutableArray *taskArgs = [[NSMutableArray alloc] init];
            taskArgs = [NSMutableArray arrayWithObjects:@"-c", cmd, nil];
            //taskArgs = [NSMutableArray arrayWithObjects:@"-c", @"stb -m $(date +'%T')", nil];
            NSTask * task = [[NSTask alloc] init];
            [task setLaunchPath:@"/bin/bash"];
            //[task setCurrentDirectoryPath:@"/"];
            [task setArguments:taskArgs];
            [task launch];
            
        }
    }
}

-(void)runCommandAction:(UIButton*)sender{
    [self autoPaginationControl];
    NSDictionary *snippet = [self getItemWithID:NSStringFromSelector(_cmd) forKey:@"snippets" identifierKey:@"entryID"];
    self.commandTitle = snippet[@"title"] ? : @"Command";
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    if (snippet[@"command"]){
        [self runCommand:snippet[@"command"]];
    }
    [self autoPaginationControl];
}

-(void)insertTextAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    
    if ([delegate respondsToSelector:@selector(insertText:)]) {
        NSDictionary *snippet = [self getItemWithID:NSStringFromSelector(_cmd) forKey:@"inserts" identifierKey:@"entryID"];
        
        
        int insertType;
        if (self.insertTextActionType == 0){
            insertType = snippet[@"type"] ? [snippet[@"type"] intValue] : 0;
        }else{
            insertType = snippet[@"typeLP"] ? [snippet[@"typeLP"] intValue] : 0;
        }
        //NSLocale* currentLocale = [NSLocale currentLocale];
        NSDate *now = [NSDate date];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        NSString *insertStrings = @"";
        
        switch (insertType) {
            case 0:
                if (self.insertTextActionType == 0){
                    insertStrings = snippet[@"text"];
                }else{
                    insertStrings = snippet[@"textLP"];
                }
                if ([insertStrings length] == 0){
                    insertStrings = [LoremIpsum getQuote];
                }
                [kbImpl insertText:insertStrings];
                break;
            case 1: //“11/23/37” or “3:30 PM”
                [df setDateStyle:NSDateFormatterShortStyle];
                [kbImpl insertText:[df stringFromDate:now]];
                //[kbImpl insertText:[[NSDate date] descriptionWithLocale:currentLocale]];
                break;
            case 2: //“Nov 23, 1937” or “3:30:32 PM”
                [df setDateStyle:NSDateFormatterMediumStyle];
                [kbImpl insertText:[df stringFromDate:now]];
                break;
            case 3: //“11/23/37” or “3:30 PM”
                [df setTimeStyle:NSDateFormatterShortStyle];
                [kbImpl insertText:[df stringFromDate:now]];
                break;
            case 4: //“Nov 23, 1937” or “3:30:32 PM”
                [df setTimeStyle:NSDateFormatterMediumStyle];
                [kbImpl insertText:[df stringFromDate:now]];
                break;
            case 5: //“Nov 23, 1937” or “3:30:32 PM”
                [df setDateStyle:NSDateFormatterMediumStyle];
                [df setTimeStyle:NSDateFormatterMediumStyle];
                [kbImpl insertText:[df stringFromDate:now]];
                break;
            default:
                break;
        }
        
        [kbImpl clearTransientState];
        [kbImpl clearAnimations];
        [kbImpl setCaretBlinks:YES];
        self.insertTextActionType = 0;
        
    }
    [self autoPaginationControl];
}

-(void)copyLogAction:(UIButton*)sender{
    [self autoPaginationControl];
    if (!self.shortcutsGenerator.copyLogDylibExist){
        [self autoPaginationControl];
        return;
    }
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)kCopyLogOpenVewIdentifier, NULL, NULL, YES);
    [self autoPaginationControl];
}

-(void)translomaticAction:(UIButton *)sender{
    [self autoPaginationControl];
    if (!self.shortcutsGenerator.translomaticDylibExist){
        [self autoPaginationControl];
        return;
    }
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:0  toastHeightOffset:0];
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    NSString *selectedString = @"";
    BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        selectedString = [(WKContentView *)tempDelegate selectedText];
        [(WKContentView *)tempDelegate select:nil];
        if ([selectedString length] == 0) return;
    }else{
        selectedString = [tempDelegate textInRange:[tempDelegate selectedTextRange]];
        
        if (!selectedString.length) {
            UITextRange *textRange = [self autoDirectionWordSelectedTextRangeWithDelegate:tempDelegate];
            if (!textRange) return;
            tempDelegate.selectedTextRange = textRange;
            selectedString = [tempDelegate textInRange:textRange];
        }
        if ([selectedString length] == 0) return;
        
    }
    
    [(objc_getClass("TLCHelper")) fetchTranslation:selectedString vc:[self keyWindow].rootViewController];
    [self autoPaginationControl];
}

-(void)wasabiAction:(UIButton *)sender{
    [self autoPaginationControl];
    if (!self.shortcutsGenerator.wasabiDylibExist){
        [self autoPaginationControl];
        return;
    }
    UIKeyboardInputModeController *inputModeController = [objc_getClass("UIKeyboardInputModeController") sharedInputModeController];
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF.identifier contains[cd] %@",
                                    @"wasabi"];
    [inputModeController setCurrentInputMode:[[inputModeController.keyboardInputModes filteredArrayUsingPredicate:resultPredicate] firstObject]];
    [self autoPaginationControl];
}

-(void)pasitheaAction:(UIButton*)sender{
    [self autoPaginationControl];
    if (!self.shortcutsGenerator.pasitheaDylibExist){
        [self autoPaginationControl];
        return;
    }
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)kPasitheaOpenVewIdentifier, NULL, NULL, YES);
    [self autoPaginationControl];
}

-(void)globeAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    UIKeyboardInputModeController *kbController = [objc_getClass("UIKeyboardInputModeController") sharedInputModeController];
    UIKeyboardInputMode *currentInputMode = [kbController currentInputMode];
    NSMutableArray* activeInputs = [kbController activeInputModes];
    NSUInteger indexOfCurrentInputMode = [activeInputs indexOfObject:currentInputMode];
    if (preferencesBool(kEnabledSkipEmojikey, YES)){
        NSPredicate *emojiInputArray = [NSPredicate predicateWithFormat:@"SELF.normalizedIdentifier contains[cd] %@", @"emoji"];
        UIKeyboardInputMode *emojiInputmode = [[activeInputs filteredArrayUsingPredicate:emojiInputArray] firstObject];
        if (emojiInputmode) [activeInputs removeObject:emojiInputmode];
    }
    NSUInteger nextInputModeIndex = indexOfCurrentInputMode + 1;
    nextInputModeIndex = nextInputModeIndex >= [activeInputs count] ? 0 : nextInputModeIndex;
    [kbController setCurrentInputMode:activeInputs[nextInputModeIndex]];
    [self autoPaginationControl];
}

-(void)dictationAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    [[objc_getClass("UIDictationController") sharedInstance] switchToDictationInputModeWithTouch:nil];
    [self autoPaginationControl];
}

-(void)spongebobAction:(UIButton*)sender{
    [self autoPaginationControl];
    [self beginImpactAnimationAndUpdateDelegate:_cmd sender:sender toastWidthOffset:10  toastHeightOffset:0];
    NSString *selectedString = [delegate textInRange:[delegate selectedTextRange]];
    if (!selectedString.length) {
        
        UITextRange *textRange;
        UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput, UITextInputTokenizer> *)delegate;
        
        UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.start;
        UITextPosition *startPositionSentence = ((UITextRange * )[tempDelegate _rangeOfSentenceEnclosingPosition:startPositionTemp]).start;
        UITextPosition *endPositionSentence = ((UITextRange * )[tempDelegate _rangeOfSentenceEnclosingPosition:startPositionTemp]).end;
        
        BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
        
        if (isWKContentView){
            
        }else{
            textRange = [tempDelegate textRangeFromPosition:startPositionSentence toPosition:endPositionSentence];
            [tempDelegate setSelectedTextRange:textRange];
        }
        
        if (!textRange) return;
        selectedString = [delegate textInRange:[delegate selectedTextRange]];
        
        float upperCaseProbability = 0.5;
        NSMutableString *result = [@"" mutableCopy];
        NSString *lowercaseStrings = [selectedString lowercaseString];
        
        for (int i = 0; i < [selectedString length]; i++) {
            NSString *chString = [lowercaseStrings substringWithRange:NSMakeRange(i, 1)];
            BOOL toUppercase = arc4random_uniform(1000) / 1000.0 < upperCaseProbability;
            
            if (toUppercase) {
                chString = [chString uppercaseString];
            }
            [result appendString:chString];
        }
        [kbImpl insertText:result];
        
    }else{
        float upperCaseProbability = 0.5;
        NSMutableString *result = [@"" mutableCopy];
        NSString *lowercaseStrings = [selectedString lowercaseString];
        
        for (int i = 0; i < [selectedString length]; i++) {
            NSString *chString = [lowercaseStrings substringWithRange:NSMakeRange(i, 1)];
            BOOL toUppercase = arc4random_uniform(1000) / 1000.0 < upperCaseProbability;
            
            if (toUppercase) {
                chString = [chString uppercaseString];
            }
            [result appendString:chString];
        }
        [kbImpl insertText:result];
    }
    [kbImpl clearTransientState];
    [kbImpl clearAnimations];
    [kbImpl setCaretBlinks:YES];
    [self autoPaginationControl];
}

#pragma mark longpress actions
-(void)selectAllActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 2;
        [self selectAction:nil];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)selectLineActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 2;
        [self selectAllAction:nil];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)selectParagraphActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 2;
        [self selectAllAction:nil];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}


-(void)selectSentenceActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 2;
        [self selectAllAction:nil];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)copyActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 0;
        [self selectAllAction:nil];
        self.hapticType = 2;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secondActionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self copyAction:nil];
        });
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)pasteActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 0;
        [self selectAllAction:nil];
        self.hapticType = 2;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secondActionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self pasteAction:nil];
        });
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)cutActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 2;
        [self deleteAction:nil];
        
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)undoActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 2;
        [self beginningAction:nil];
        
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)redoActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 2;
        [self endingAction:nil];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
    
}

-(void)selectActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 2;
        [self selectAllAction:nil];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)beginningActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 2;
        [self undoAction:nil];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}



-(void)endingActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 2;
        [self redoAction:nil];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)capitalizeActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 2;
        [self uppercaseAction:nil];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)lowercaseActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 2;
        [self uppercaseAction:nil];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)uppercaseActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 2;
        [self lowercaseAction:nil];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)deleteActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 2;
        [self deleteAllAction:nil];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)deleteForwardActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 2;
        [self deleteAllAction:nil];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)boldActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 0;
        [self selectAction:nil];
        self.hapticType = 2;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secondActionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self boldAction:nil];
        });
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)italicActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 0;
        [self selectAction:nil];
        self.hapticType = 2;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secondActionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self italicAction:nil];
        });
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)underlineActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 0;
        [self selectAction:nil];
        self.hapticType = 2;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secondActionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self underlineAction:nil];
        });
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)dismissKeyboardActionLP:(UILongPressGestureRecognizer *)recognizer{
    /*
     if (recognizer.state == UIGestureRecognizerStateBegan) {
     self.hapticType = 0;
     [self selectAction:nil];
     self.hapticType = 2;
     [self underlineAction:nil];
     }else if (recognizer.state == UIGestureRecognizerStateEnded){
     [self shakeView:recognizer.view];
     }
     */
}

-(void)retestGestureStatusForMovingCursor:(NSTimer *)timer{
    UILongPressGestureRecognizer *recognizer = [[timer userInfo] objectForKey:@"recognizer"];
    if (recognizer.state == UIGestureRecognizerStatePossible || recognizer.state == UIGestureRecognizerStateEnded){
        
        if (!self.retestDispatchBlock){
            //HBLogDebug(@"cursorTimerRetest: %ld, dispatch: %@", recognizer.state, self.retestDispatchBlock);
            self.retestDispatchBlock = dispatch_block_create(0, ^{
                if (recognizer.state == UIGestureRecognizerStatePossible || recognizer.state == UIGestureRecognizerStateEnded){
                    [self.cursorTimer invalidate];
                    self.cursorTimer = nil;
                    self.cursorTimerSpeed = 0.0;
                    self.cursorMovingFactor = 0;
                    self.t = 0.0;
                    [self.cursorTimerRetest invalidate];
                    self.cursorTimerRetest = nil;
                }
                self.retestDispatchBlock = nil;
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), self.retestDispatchBlock);
        }
    }
    
}

-(void)moveCursorTimer{
    //if (labs(self.cursorMovingFactor) < 300){
    //self.cursorMovingFactor = 2* self.cursorMovingFactor;
    //}
    //if (self.cursorTimerSpeed > 0){
    self.t = self.t + 0.01;
    self.cursorTimerSpeed = 0.2*exp(-5.0*self.t);
    //self.cursorTimerSpeed = self.cursorTimerSpeed - 0.01;
    //}
    NSString *actionName;
    switch (self.cursorMovingFactor) {
        case -1:
            actionName = @"moveCursorLeftAction:";
            break;
        case 1:
            actionName = @"moveCursorRightAction:";
            break;
        case 2:
            actionName = @"moveCursorUpAction:";
            break;
        case 3:
            actionName = @"moveCursorDownAction:";
            break;
        default:
            break;
    }
    //HBLogDebug(@"%f", (float)(self.cursorTimerSpeed));
    if (self.hapticType == 2){
        [self triggerImpactAndAnimationWithButton:nil selectorName:actionName toastWidthOffset:0 toastHeightOffset:0];
    }
    if (self.cursorMovingFactor < 2){
        [self moveCursorContinuoslyWithDelegate:delegate offset:self.cursorMovingFactor];
    }else{
        if (self.cursorMovingFactor == 2){
            [self moveCursorVerticalWithDelegate:delegate direction:UITextLayoutDirectionUp];
        }else if (self.cursorMovingFactor == 3){
            [self moveCursorVerticalWithDelegate:delegate direction:UITextLayoutDirectionDown];
        }
    }
    //self.cursorTimer = nil;
    self.cursorTimer = [NSTimer scheduledTimerWithTimeInterval:self.cursorTimerSpeed target:self selector:@selector(moveCursorTimer) userInfo:nil repeats:NO];
}

-(void)moveCursorLeftActionLP:(UILongPressGestureRecognizer*)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 0;
        [self moveCursorLeftAction:nil];
        self.cursorMovingFactor = -1;
        self.hapticType = 2;
        self.cursorTimerSpeed = 0.2;
        self.t =0.0;
        self.cursorTimer = [NSTimer scheduledTimerWithTimeInterval:self.cursorTimerSpeed target:self selector:@selector(moveCursorTimer) userInfo:nil repeats:NO];
        self.cursorTimerRetest = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(retestGestureStatusForMovingCursor:) userInfo:@{@"recognizer":recognizer} repeats:YES];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self.cursorTimer invalidate];
        self.cursorTimer = nil;
        self.cursorTimerSpeed = 0.0;
        self.cursorMovingFactor = 0;
        self.t = 0.0;
        [self.cursorTimer invalidate];
        self.cursorTimer = nil;
        self.retestDispatchBlock = nil;
        [self shakeView:recognizer.view];
    }
}

-(void)moveCursorRightActionLP:(UILongPressGestureRecognizer*)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 0;
        [self moveCursorRightAction:nil];
        self.cursorMovingFactor = 1;
        self.hapticType = 2;
        self.cursorTimerSpeed = 0.2;
        self.t =0.0;
        self.cursorTimer = [NSTimer scheduledTimerWithTimeInterval:self.cursorTimerSpeed target:self selector:@selector(moveCursorTimer) userInfo:nil repeats:NO];
        self.cursorTimerRetest = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(retestGestureStatusForMovingCursor:) userInfo:@{@"recognizer":recognizer} repeats:YES];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self.cursorTimer invalidate];
        self.cursorTimer = nil;
        self.cursorTimerSpeed = 0.0;
        self.cursorMovingFactor = 0;
        self.t =0.0;
        [self.cursorTimer invalidate];
        self.cursorTimer = nil;
        self.retestDispatchBlock = nil;
        [self shakeView:recognizer.view];
    }
}

-(void)moveCursorPreviousWordActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSDictionary *snippet = [self getItemWithID:@"moveCursorPreviousWordAction:" forKey:@"cursormoevandselect" identifierKey:@"entryID"];
        int selectionType = snippet[@"type"] ? [snippet[@"type"] intValue] : 0;
        if (selectionType > 0){
            self.hapticType = 2;
            self.moveCursorWithSelect = YES;
            self.isWordSender = YES;
            [self moveCursorPreviousWordAction:nil];
        }else{
            self.hapticType = 0;
            self.isWordSender = YES;
            [self moveCursorPreviousWordAction:nil];
            self.hapticType = 2;
            [self selectAction:nil];
        }
        [self triggerImpactAndAnimationWithButton:nil selectorName:@"selectAction:" toastWidthOffset:0 toastHeightOffset:0];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)moveCursorNextWordActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSDictionary *snippet = [self getItemWithID:@"moveCursorNextWordAction:" forKey:@"cursormoevandselect" identifierKey:@"entryID"];
        int selectionType = snippet[@"type"] ? [snippet[@"type"] intValue] : 0;
        if (selectionType > 0){
            self.hapticType = 2;
            self.moveCursorWithSelect = YES;
            self.isWordSender = YES;
            [self moveCursorNextWordAction:nil];
        }else{
            self.hapticType = 0;
            self.isWordSender = YES;
            [self moveCursorNextWordAction:nil];
            self.hapticType = 2;
            [self selectAction:nil];
        }
        [self triggerImpactAndAnimationWithButton:nil selectorName:@"selectAction:" toastWidthOffset:0 toastHeightOffset:0];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)moveCursorStartOfLineActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSDictionary *snippet = [self getItemWithID:@"moveCursorStartOfLineAction:" forKey:@"cursormoevandselect" identifierKey:@"entryID"];
        int selectionType = snippet[@"type"] ? [snippet[@"type"] intValue] : 0;
        if (selectionType > 0){
            self.hapticType = 0;
            self.moveCursorWithSelect = YES;
            [self moveCursorStartOfLineAction:nil];
        }else{
            kbImpl = [%c(UIKeyboardImpl) activeInstance];
            delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
            UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
            self.hapticType = 0;
            [self triggerImpactAndAnimationWithButton:nil selectorName:@"moveCursorStartOfLineAction:" toastWidthOffset:0 toastHeightOffset:0];
            /*
             UITextPosition *startPosition = tempDelegate.selectedTextRange.start;
             [self moveCursorStartOfLineAction:nil];
             UITextPosition *endPosition = tempDelegate.selectedTextRange.start;
             UITextRange *textRange = [delegate textRangeFromPosition:startPosition toPosition:endPosition];
             [delegate setSelectedTextRange:textRange];
             */
            UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.start;
            self.moveCursorWithSelect = NO;
            [self moveCursorPreviousWordAction:nil];
            UITextPosition *startPositionMovedTemp = tempDelegate.selectedTextRange.start;
            if (((UITextRange * )[delegate _rangeOfLineEnclosingPosition:startPositionMovedTemp]).start == ((UITextRange * )[delegate _rangeOfLineEnclosingPosition:startPositionTemp]).start){
                [self moveCursorPreviousWordAction:nil];
                
                //[delegate _moveToStartOfLine:NO withHistory:nil];
                
                
            }
            [delegate _moveToEndOfLine:NO withHistory:nil];
            [delegate _moveToStartOfLine:YES withHistory:nil];
        }
        self.hapticType = 2;
        [self triggerImpactAndAnimationWithButton:nil selectorName:@"selectAction:" toastWidthOffset:0 toastHeightOffset:0];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)moveCursorEndOfLineActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSDictionary *snippet = [self getItemWithID:@"moveCursorEndOfLineAction:" forKey:@"cursormoevandselect" identifierKey:@"entryID"];
        int selectionType = snippet[@"type"] ? [snippet[@"type"] intValue] : 0;
        if (selectionType > 0){
            self.hapticType = 0;
            self.moveCursorWithSelect = YES;
            [self moveCursorEndOfLineAction:nil];
        }else{
            kbImpl = [%c(UIKeyboardImpl) activeInstance];
            delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
            UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
            self.hapticType = 0;
            [self triggerImpactAndAnimationWithButton:nil selectorName:@"moveCursorEndOfLineAction:" toastWidthOffset:0 toastHeightOffset:0];
            /*
             UITextPosition *startPosition = tempDelegate.selectedTextRange.start;
             [self moveCursorEndOfLineAction:nil];
             UITextPosition *endPosition = tempDelegate.selectedTextRange.start;
             UITextRange *textRange = [delegate textRangeFromPosition:startPosition toPosition:endPosition];
             [delegate setSelectedTextRange:textRange];
             */
            UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.end;
            self.moveCursorWithSelect = NO;
            [self moveCursorNextWordAction:nil];
            UITextPosition *startPositionMovedTemp = tempDelegate.selectedTextRange.end;
            if (((UITextRange * )[delegate _rangeOfLineEnclosingPosition:startPositionMovedTemp]).end == ((UITextRange * )[delegate _rangeOfLineEnclosingPosition:startPositionTemp]).end){
                [self moveCursorNextWordAction:nil];
                
                [delegate _moveToEndOfLine:NO withHistory:nil];
                
            }
            [delegate _moveToStartOfLine:NO withHistory:nil];
            [delegate _moveToEndOfLine:YES withHistory:nil];
        }
        self.hapticType = 2;
        [self triggerImpactAndAnimationWithButton:nil selectorName:@"selectAction:" toastWidthOffset:0 toastHeightOffset:0];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)moveCursorStartOfParagraphActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSDictionary *snippet = [self getItemWithID:@"moveCursorStartOfParagraphAction:" forKey:@"cursormoevandselect" identifierKey:@"entryID"];
        int selectionType = snippet[@"type"] ? [snippet[@"type"] intValue] : 0;
        if (selectionType > 0){
            self.hapticType = 0;
            self.moveCursorWithSelect = YES;
            [self moveCursorStartOfParagraphAction:nil];
        }else{
            kbImpl = [%c(UIKeyboardImpl) activeInstance];
            delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
            UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
            self.hapticType = 0;
            [self triggerImpactAndAnimationWithButton:nil selectorName:@"moveCursorStartOfParagraphAction:" toastWidthOffset:0 toastHeightOffset:0];
            /*
             self.hapticType = 0;
             UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.start;
             if (startPositionTemp == ((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:startPositionTemp]).start){
             self.moveCursorWithSelect = NO;
             self.triggerImpact = YES;
             [self moveCursorPreviousWordAction:nil];
             startPositionTemp = tempDelegate.selectedTextRange.start;
             }
             UITextPosition *paragraphStartPosition = ((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:startPositionTemp]).start;
             UITextPosition *paragraphEndPosition = ((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:startPositionTemp]).end;
             UITextRange *textRange = [delegate textRangeFromPosition:paragraphStartPosition toPosition:paragraphEndPosition];
             BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
             if (isWKContentView){
             */
            UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.start;
            self.moveCursorWithSelect = NO;
            [self moveCursorPreviousWordAction:nil];
            UITextPosition *startPositionMovedTemp = tempDelegate.selectedTextRange.start;
            if (((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:startPositionMovedTemp]).start == ((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:startPositionTemp]).start){
                [delegate _moveToStartOfParagraph:NO withHistory:nil];
                
                //[self moveCursorPreviousWordAction:nil];
                
            }
            [delegate _moveToEndOfParagraph:NO withHistory:nil];
            [delegate _moveToStartOfParagraph:YES withHistory:nil];
            /*
             }else{
             [delegate setSelectedTextRange:textRange];
             }
             */
        }
        self.hapticType = 2;
        [self triggerImpactAndAnimationWithButton:nil selectorName:@"selectAction:" toastWidthOffset:0 toastHeightOffset:0];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)moveCursorEndOfParagraphActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSDictionary *snippet = [self getItemWithID:@"moveCursorEndOfParagraphAction:" forKey:@"cursormoevandselect" identifierKey:@"entryID"];
        int selectionType = snippet[@"type"] ? [snippet[@"type"] intValue] : 0;
        if (selectionType > 0){
            self.hapticType = 0;
            self.moveCursorWithSelect = YES;
            [self moveCursorEndOfParagraphAction:nil];
        }else{
            kbImpl = [%c(UIKeyboardImpl) activeInstance];
            delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
            UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
            self.hapticType = 0;
            [self triggerImpactAndAnimationWithButton:nil selectorName:@"moveCursorEndOfParagraphAction:" toastWidthOffset:0 toastHeightOffset:0];
            
            /*
             UITextPosition *endPositionTemp = tempDelegate.selectedTextRange.end;
             if (endPositionTemp == ((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:endPositionTemp]).end){
             self.moveCursorWithSelect = NO;
             self.triggerImpact = YES;
             [self moveCursorNextWordAction:nil];
             endPositionTemp = tempDelegate.selectedTextRange.end;
             }
             UITextPosition *paragraphStartPosition = ((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:endPositionTemp]).start;
             UITextPosition *paragraphEndPosition = ((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:endPositionTemp]).end;
             UITextRange *textRange = [delegate textRangeFromPosition:paragraphStartPosition toPosition:paragraphEndPosition];
             [delegate setSelectedTextRange:textRange];
             */
            UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.end;
            self.moveCursorWithSelect = NO;
            [self moveCursorNextWordAction:nil];
            UITextPosition *startPositionMovedTemp = tempDelegate.selectedTextRange.end;
            if (((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:startPositionMovedTemp]).end == ((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:startPositionTemp]).end){
                [self moveCursorNextWordAction:nil];
                
                [delegate _moveToEndOfParagraph:NO withHistory:nil];
                
            }
            [delegate _moveToStartOfParagraph:NO withHistory:nil];
            [delegate _moveToEndOfParagraph:YES withHistory:nil];
        }
        self.hapticType = 2;
        [self triggerImpactAndAnimationWithButton:nil selectorName:@"selectAction:" toastWidthOffset:0 toastHeightOffset:0];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)moveCursorStartOfSentenceActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSDictionary *snippet = [self getItemWithID:@"moveCursorStartOfSentenceAction:" forKey:@"cursormoevandselect" identifierKey:@"entryID"];
        int selectionType = snippet[@"type"] ? [snippet[@"type"] intValue] : 0;
        
        [self beginUpdateDelegate];
        UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput, UITextInputTokenizer> *)delegate;
        
        BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
        self.hapticType = 0;
        
        UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.start;
        //HBLogDebug(@"startPositionTemp: %@", startPositionTemp);
        UITextPosition *startPositionSentence = ((UITextRange * )[tempDelegate _rangeOfSentenceEnclosingPosition:startPositionTemp]).start;
        //HBLogDebug(@"startPositionSentence: %@", startPositionSentence);
        UITextPosition *endPositionSentence = ((UITextRange * )[tempDelegate _rangeOfSentenceEnclosingPosition:startPositionTemp]).end;
        //HBLogDebug(@"endPositionSentence: %@", endPositionSentence);
        
        if (selectionType > 0){
            
            if (isWKContentView){
                self.hapticType = 2;
                [self selectAllAction:nil];
                return;
                /*
                 NSString *js = [NSString stringWithFormat:@"document.activeElement.selectionStart = %ld", [tempDelegate offsetFromPosition:tempDelegate.beginningOfDocument toPosition:startPositionSentence]];
                 //HBLogDebug(@"-----------js: %@", js);
                 //NSString *js = @"var textarea = document.getElementsByTagName('textarea')[0]; textarea.focus(); textarea.selectionStart = 0";
                 
                 WKWebView *webView = [tempDelegate webView];
                 
                 [webView evaluateJavaScript:js completionHandler:^(id result, NSError *error) {
                 //HBLogDebug(@"XXXXX-result: %@", result);
                 //HBLogDebug(@"XXXXX-error: %@", error);
                 
                 
                 }];
                 */
            }else{
                
                UITextRange *textRange = [tempDelegate textRangeFromPosition:startPositionTemp toPosition:startPositionSentence];
                [tempDelegate setSelectedTextRange:textRange];
            }
        }else{
            if (isWKContentView){
                self.hapticType = 2;
                [self selectAllAction:nil];
                return;
            }else{
                UITextRange *textRange = [tempDelegate textRangeFromPosition:startPositionSentence toPosition:endPositionSentence];
                [tempDelegate setSelectedTextRange:textRange];
            }
        }
        [self triggerImpactAndAnimationWithButton:nil selectorName:@"moveCursorStartOfSentenceAction:" toastWidthOffset:0 toastHeightOffset:0];
        self.hapticType = 2;
        [self triggerImpactAndAnimationWithButton:nil selectorName:@"selectAction:" toastWidthOffset:0 toastHeightOffset:0];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)moveCursorEndOfSentenceActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSDictionary *snippet = [self getItemWithID:@"moveCursorEndOfSentenceAction:" forKey:@"cursormoevandselect" identifierKey:@"entryID"];
        int selectionType = snippet[@"type"] ? [snippet[@"type"] intValue] : 0;
        
        [self beginUpdateDelegate];
        UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput, UITextInputTokenizer> *)delegate;
        
        BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
        self.hapticType = 0;
        
        UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.start;
        //HBLogDebug(@"startPositionTemp: %@", startPositionTemp);
        UITextPosition *startPositionSentence = ((UITextRange * )[tempDelegate _rangeOfSentenceEnclosingPosition:startPositionTemp]).start;
        //HBLogDebug(@"startPositionSentence: %@", startPositionSentence);
        UITextPosition *endPositionSentence = ((UITextRange * )[tempDelegate _rangeOfSentenceEnclosingPosition:startPositionTemp]).end;
        //HBLogDebug(@"endPositionSentence: %@", endPositionSentence);
        
        if (selectionType > 0){
            
            if (isWKContentView){
                self.hapticType = 2;
                [self selectAllAction:nil];
                return;
                /*
                 NSString *js = [NSString stringWithFormat:@"document.activeElement.selectionStart = %ld", [tempDelegate offsetFromPosition:tempDelegate.beginningOfDocument toPosition:startPositionSentence]];
                 //HBLogDebug(@"-----------js: %@", js);
                 //NSString *js = @"var textarea = document.getElementsByTagName('textarea')[0]; textarea.focus(); textarea.selectionStart = 0";
                 
                 WKWebView *webView = [tempDelegate webView];
                 
                 [webView evaluateJavaScript:js completionHandler:^(id result, NSError *error) {
                 //HBLogDebug(@"XXXXX-result: %@", result);
                 //HBLogDebug(@"XXXXX-error: %@", error);
                 
                 
                 }];
                 */
            }else{
                
                UITextRange *textRange = [tempDelegate textRangeFromPosition:startPositionTemp toPosition:endPositionSentence];
                [tempDelegate setSelectedTextRange:textRange];
            }
        }else{
            if (isWKContentView){
                self.hapticType = 2;
                [self selectAllAction:nil];
                return;
            }else{
                UITextRange *textRange = [tempDelegate textRangeFromPosition:startPositionSentence toPosition:endPositionSentence];
                [tempDelegate setSelectedTextRange:textRange];
            }
        }
        [self triggerImpactAndAnimationWithButton:nil selectorName:@"moveCursorEndOfSentenceAction:" toastWidthOffset:0 toastHeightOffset:0];
        self.hapticType = 2;
        [self triggerImpactAndAnimationWithButton:nil selectorName:@"selectAction:" toastWidthOffset:0 toastHeightOffset:0];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)moveCursorUpActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 0;
        [self moveCursorUpAction:nil];
        self.cursorMovingFactor = 2;
        self.hapticType = 2;
        self.cursorTimerSpeed = 0.2;
        self.t =0.0;
        self.cursorTimer = [NSTimer scheduledTimerWithTimeInterval:self.cursorTimerSpeed target:self selector:@selector(moveCursorTimer) userInfo:nil repeats:NO];
        self.cursorTimerRetest = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(retestGestureStatusForMovingCursor:) userInfo:@{@"recognizer":recognizer} repeats:YES];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self.cursorTimer invalidate];
        self.cursorTimer = nil;
        self.cursorTimerSpeed = 0.0;
        self.cursorMovingFactor = 0;
        self.t = 0.0;
        [self.cursorTimer invalidate];
        self.cursorTimer = nil;
        self.retestDispatchBlock = nil;
        [self shakeView:recognizer.view];
    }
}

-(void)moveCursorDownActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 0;
        [self moveCursorDownAction:nil];
        self.cursorMovingFactor = 3;
        self.hapticType = 2;
        self.cursorTimerSpeed = 0.2;
        self.t =0.0;
        self.cursorTimer = [NSTimer scheduledTimerWithTimeInterval:self.cursorTimerSpeed target:self selector:@selector(moveCursorTimer) userInfo:nil repeats:NO];
        self.cursorTimerRetest = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(retestGestureStatusForMovingCursor:) userInfo:@{@"recognizer":recognizer} repeats:YES];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self.cursorTimer invalidate];
        self.cursorTimer = nil;
        self.cursorTimerSpeed = 0.0;
        self.cursorMovingFactor = 0;
        self.t = 0.0;
        [self.cursorTimer invalidate];
        self.cursorTimer = nil;
        self.retestDispatchBlock = nil;
        [self shakeView:recognizer.view];
    }
}

-(void)autoCorrectionActionLP:(UILongPressGestureRecognizer *)recognizer{
    /*
     if (recognizer.state == UIGestureRecognizerStateBegan) {
     self.hapticType = 0;
     [self selectAction:nil];
     self.hapticType = 2;
     [self underlineAction:nil];
     }else if (recognizer.state == UIGestureRecognizerStateEnded){
     [self shakeView:recognizer.view];
     }
     */
}

-(void)autoCapitalizationActionLP:(UILongPressGestureRecognizer *)recognizer{
    /*
     if (recognizer.state == UIGestureRecognizerStateBegan) {
     self.hapticType = 0;
     [self selectAction:nil];
     self.hapticType = 2;
     [self underlineAction:nil];
     }else if (recognizer.state == UIGestureRecognizerStateEnded){
     [self shakeView:recognizer.view];
     }
     */
}

-(void)keyboardTypeActionLP:(UILongPressGestureRecognizer *)recognizer{
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
        delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
        if ([delegate respondsToSelector:@selector(keyboardType)]){
            self.hapticType = 2;
            [self triggerImpactAndAnimationWithButton:nil selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
            kbImpl = [%c(UIKeyboardImpl) activeInstance];
            delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
            [delegate setKeyboardType:self.trueKBType];
            [delegate reloadInputViews];
        }
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
        delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
        if ([delegate respondsToSelector:@selector(keyboardType)]){
            [self shakeView:recognizer.view];
        }
    }
    
}

-(void)defineActionLP:(UILongPressGestureRecognizer *)recognizer{
    /*
     if (recognizer.state == UIGestureRecognizerStateBegan) {
     self.hapticType = 0;
     [self selectAction:nil];
     self.hapticType = 2;
     [self underlineAction:nil];
     }else if (recognizer.state == UIGestureRecognizerStateEnded){
     [self shakeView:recognizer.view];
     }
     */
}

-(void)runCommandActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 2;
        NSDictionary *snippet = [self getItemWithID:@"runCommandAction:" forKey:@"snippets" identifierKey:@"entryID"];
        self.commandTitle = snippet[@"titleLP"] ? : @"Command";
        [self triggerImpactAndAnimationWithButton:nil selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
        [self runCommand:snippet[@"commandLP"]];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)insertTextActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 2;
        self.insertTextActionType = 1;
        [self insertTextAction:nil];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(UIWindow*)keyWindow{
    NSPredicate *isKeyWindow = [NSPredicate predicateWithFormat:@"isKeyWindow == YES"];
    return [[[UIApplication sharedApplication] windows] filteredArrayUsingPredicate:isKeyWindow].firstObject;
}

-(void)copyLogActionLP:(UILongPressGestureRecognizer *)recognizer{
    /*
     if (recognizer.state == UIGestureRecognizerStateBegan) {
     self.hapticType = 0;
     [self selectAction:nil];
     self.hapticType = 2;
     [self underlineAction:nil];
     }else if (recognizer.state == UIGestureRecognizerStateEnded){
     [self shakeView:recognizer.view];
     }
     */
}

-(void)translomaticActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 0;
        [self selectParagraphAction:nil];
        self.hapticType = 2;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secondActionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self translomaticAction:nil];
        });
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)wasabiActionLP:(UILongPressGestureRecognizer *)recognizer{
    /*
     if (recognizer.state == UIGestureRecognizerStateBegan) {
     self.hapticType = 0;
     [self selectAction:nil];
     self.hapticType = 2;
     [self underlineAction:nil];
     }else if (recognizer.state == UIGestureRecognizerStateEnded){
     [self shakeView:recognizer.view];
     }
     */
}

-(void)pasitheaActionLP:(UILongPressGestureRecognizer *)recognizer{
    /*
     if (recognizer.state == UIGestureRecognizerStateBegan) {
     self.hapticType = 0;
     [self selectAction:nil];
     self.hapticType = 2;
     [self underlineAction:nil];
     }else if (recognizer.state == UIGestureRecognizerStateEnded){
     [self shakeView:recognizer.view];
     }
     */
}

-(void)globeActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 2;
        [self dictationAction:nil];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
    
}

-(void)spongebobActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hapticType = 0;
        [self selectAllAction:nil];
        self.hapticType = 2;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secondActionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self spongebobAction:nil];
        });
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
    
}
/*
 -(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
 {
 
 return ceil(_buttons.count / 6);
 }
 */

#pragma mark collectionview


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    
    //HBLogDebug(@"NUM SEC: %f", ceil((float)(((NSArray *)_shortcuts[kbuttonsImages12]).count)/(float)preferencesInt(kShortcutsPerSection, maxshortcutpersection)));
    return ceil((float)(((NSArray *)_shortcuts[kbuttonsImages12]).count)/(float)preferencesInt(kShortcutsPerSection, maxshortcutpersection));
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    UIKeyboardPreferencesController *kbPrefsController = [%c(UIKeyboardPreferencesController) sharedPreferencesController];
    if (kbPrefsController){
        long long currentHandBias = kbPrefsController.handBias;
        //HBLogDebug(@"currentHandBias: %lld",currentHandBias);
        if (currentHandBias > 0){
            //self.pagingEnabled = YES;
            //HBLogDebug(@"numberOfItemsInSection: %lu", ((NSArray *)_shortcuts[kbuttonsImages12]).count>5?5:((NSArray *)_shortcuts[kbuttonsImages12]).count);
            //return ((NSArray *)_shortcuts[kbuttonsImages12]).count>5?5:((NSArray *)_shortcuts[kbuttonsImages12]).count;
            //if (([self numberOfSectionsInCollectionView:collectionView] -1) == section){
            if (([self numberOfSectionsInCollectionView:collectionView] -1) == section){
                return ((NSArray *)_shortcuts[kbuttonsImages12]).count-preferencesInt(kShortcutsPerSection, maxshortcutpersection)*(section);
            }else{
                return ((NSArray *)_shortcuts[kbuttonsImages12]).count>preferencesInt(kShortcutsPerSection, maxshortcutpersection)?preferencesInt(kShortcutsPerSection, maxshortcutpersection):((NSArray *)_shortcuts[kbuttonsImages12]).count;
            }
        }else{
            //if (section == ceil((float)(((NSArray *)_shortcuts[kbuttonsImages12]).count)/6.0f)){
            //return ((NSArray *)_shortcuts[kbuttonsImages12]).count - 6*(section);
            //}else{
            //self.pagingEnabled = NO;
            //return ((NSArray *)_shortcuts[kbuttonsImages12]).count>6?6:((NSArray *)_shortcuts[kbuttonsImages12]).count-6*(section);
            if (([self numberOfSectionsInCollectionView:collectionView] -1) == section){
                //HBLogDebug(@"NUM: %ld, SECTION: %ld", ((NSArray *)_shortcuts[kbuttonsImages12]).count-preferencesInt(kShortcutsPerSection, maxshortcutpersection)*(section), section );
                return ((NSArray *)_shortcuts[kbuttonsImages12]).count-preferencesInt(kShortcutsPerSection, maxshortcutpersection)*(section);
            }else{
                //HBLogDebug(@"NUM: %ld, SECTION: %ld", ((NSArray *)_shortcuts[kbuttonsImages12]).count>preferencesInt(kShortcutsPerSection, maxshortcutpersection)?preferencesInt(kShortcutsPerSection, maxshortcutpersection):((NSArray *)_shortcuts[kbuttonsImages12]).count, section );
                
                return ((NSArray *)_shortcuts[kbuttonsImages12]).count>preferencesInt(kShortcutsPerSection, maxshortcutpersection)?preferencesInt(kShortcutsPerSection, maxshortcutpersection):((NSArray *)_shortcuts[kbuttonsImages12]).count;
            }
            //return ((NSArray *)_shortcuts[kbuttonsImages12]).count-6*(section);
            //}
            //return ((NSArray *)_shortcuts[kbuttonsImages12]).count;
            //HBLogDebug(@"numberOfItemsInSection: %lu", ((NSArray *)_shortcuts[kbuttonsImages12]).count);
            
        }}
    //HBLogDebug(@"ITEMS: %ld",((NSArray *)_shortcuts[kbuttonsImages12]).count>preferencesInt(kShortcutsPerSection, maxshortcutpersection)?preferencesInt(kShortcutsPerSection, maxshortcutpersection):((NSArray *)_shortcuts[kbuttonsImages12]).count-preferencesInt(kShortcutsPerSection, maxshortcutpersection)*(section) );
    //return ((NSArray *)_shortcuts[kbuttonsImages12]).count>6?6:((NSArray *)_shortcuts[kbuttonsImages12]).count-6*(section);
    //HBLogDebug(@"XXXX");
    
    if (([self numberOfSectionsInCollectionView:collectionView] -1 )== section){
        return ((NSArray *)_shortcuts[kbuttonsImages12]).count-preferencesInt(kShortcutsPerSection, maxshortcutpersection)*(section);
    }else{
        return ((NSArray *)_shortcuts[kbuttonsImages12]).count>preferencesInt(kShortcutsPerSection, maxshortcutpersection)?preferencesInt(kShortcutsPerSection, maxshortcutpersection):((NSArray *)_shortcuts[kbuttonsImages12]).count;
    }
}

- (void)activateDTActions:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        self.isWordSender = YES;
        [self activateLPActions:recognizer];
        [self shakeView:recognizer.view];
        self.isWordSender = NO;
    }
}

- (void)activateShootingStarActions:(UIButton *)sender {
    self.isWordSender = YES;
    [self activateLPActions:(UIGestureRecognizer *)sender];
    self.isWordSender = NO;
    
    //[self shakeButton:sender];
}

-(void)activateLPActions:(UIGestureRecognizer *)recognizer{
    //HBLogDebug(@"recognizer: %@", recognizer);
    BOOL isDoubleTap = [recognizer isKindOfClass:objc_getClass("UITapGestureRecognizer")];
    BOOL isShootingStarSender = [recognizer isKindOfClass:objc_getClass("UIButton")];
    
    if (recognizer.state == UIGestureRecognizerStateBegan || (isDoubleTap && recognizer.state == UIGestureRecognizerStateEnded) || isShootingStarSender) {
        [self autoPaginationControl];
        //HBLogDebug(@"########## REG: %@", NSStringFromCGPoint([recognizer locationInView:recognizer.view.window]));
        
        //HBLogDebug(@"recognizer: %@", recognizer);
        UIButton *btn;
        if (isShootingStarSender){
            btn = (UIButton*)recognizer;
        }else{
            btn = (UIButton*)(recognizer.view);
        }
        BOOL doubleTapEnabled = preferencesBool(kEnabledDoubleTapkey, NO);
        NSArray *targetsForLongPressUsingGesture;
        
        if (doubleTapEnabled){
            NSArray *gestures = btn.gestureRecognizers;
            NSPredicate *resultPredicate = [NSPredicate
                                            predicateWithFormat:@"SELF.numberOfTapsRequired == %@",
                                            @1];
            targetsForLongPressUsingGesture = [([[gestures filteredArrayUsingPredicate:resultPredicate] firstObject]) valueForKey:@"_targets"];
        }
        
        id sets;
        if (doubleTapEnabled){
            sets = targetsForLongPressUsingGesture;
        }else{
            sets = btn.allTargets;
        }
        
        for (id target in sets) {
            NSArray *actions;
            HBLogDebug(@"00000000000000000000000000");
            if ((doubleTapEnabled  && isShootingStarSender) || (doubleTapEnabled  && !isShootingStarSender)){
                actions = @[NSStringFromSelector([(UIGestureRecognizerTarget *)target action])];
            }else{
                actions = [btn actionsForTarget:target forControlEvent:UIControlEventTouchUpInside];
            }
            for (NSString *action in actions) {
                HBLogDebug(@"######## action: %@", action);
                int gestureType = 0;
                if (isDoubleTap) gestureType = 1;
                if (isShootingStarSender) gestureType = 2;
                NSString *selectorName1 = preferencesSelectorForIdentifier(action, 1, gestureType, @"");
                NSString *selectorName2 = preferencesSelectorForIdentifier(action, 2, gestureType, @"");
                HBLogDebug(@"selectorName1: %@", selectorName1);
                HBLogDebug(@"selectorName2: %@", selectorName2);
                
                SEL action1 = NSSelectorFromString(selectorName1);
                SEL action2 = NSSelectorFromString(selectorName2);
                
                if ( ([selectorName1 length] > 0) && ([selectorName2 length] > 0) ){
                    //https://github.com/th-in-gs/THObserversAndBinders/blob/master/THObserversAndBinders/THObserver.m
                    self.hapticType = 0;
                    ((void(*)(id, SEL, id))objc_msgSend)(self, action1, nil);
                    //[self performSelector:action1];
                    self.hapticType = 2;
                    //[self performSelector:action2];
                    //((void(*)(id, SEL, id))objc_msgSend)(self, action2, nil);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secondActionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        ((void(*)(id, SEL, id))objc_msgSend)(self, action2, nil);
                    });
                }else if ([selectorName1 length] > 0){
                    self.hapticType = 2;
                    ((void(*)(id, SEL, id))objc_msgSend)(self, action1, nil);
                }else if ([selectorName2 length] > 0){
                    self.hapticType = 2;
                    ((void(*)(id, SEL, id))objc_msgSend)(self, action2, nil);
                }else{
                    NSString *originalSelectorName;
                    BOOL isLP = NO;
                    if (isDoubleTap){
                        originalSelectorName = [action stringByReplacingOccurrencesOfString:@"Action:" withString:@"ActionDT:"];
                    }else if (isShootingStarSender){
                        originalSelectorName = [action stringByReplacingOccurrencesOfString:@"Action:" withString:@"ActionST:"];
                    }else{
                        [self autoPaginationControl];
                        isLP = YES;
                        originalSelectorName = [action stringByReplacingOccurrencesOfString:@"Action:" withString:@"ActionLP:"];
                    }
                    
                    SEL originalAction = NSSelectorFromString(originalSelectorName);
                    //HBLogDebug(@"###### SEL %@", originalSelectorName);
                    if ([self respondsToSelector:originalAction]){
                        ((void(*)(id, SEL, id))objc_msgSend)(self, originalAction, recognizer);
                        if (isLP) [self autoPaginationControl];
                    }
                }
            }
        }
        
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DockXCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kDockXCellID" forIndexPath:indexPath];
    //HBLogDebug(@"SECTION %ld, ROW: %ld", indexPath.section, indexPath.row);
    //cell.transform = CGAffineTransformMakeScale(-1, 1);
    int cellIndex = preferencesInt(kShortcutsPerSection, maxshortcutpersection)*indexPath.section + indexPath.row;
    //HBLogDebug(@"cellINDEX: %d", cellIndex);
    //[cell.btn setTitle:_buttons[indexPath.row] forState:UIControlStateNormal];
    NSString* selectorName = ((NSArray *)_shortcuts[kselectors])[cellIndex];
    
    UIImage* image;
    NSMutableAttributedString *imageOfName = [[NSMutableAttributedString alloc] initWithString:@""];
    
    
    if ([selectorName isEqualToString:@"autoCorrectionAction:"]){
        self.autoCorrectionCell = cell;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.autoCorrectionEnabled = [self isAutoCorrectionEnabled];
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.isSameProcess = NO;
                self.asyncUpdated = YES;
                [self updateAutoCorrection:nil];
            });
        });
        
        
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[DockXHelper localizedStringForActionNamed:selectorName shortName:YES bundle:tweakBundle]];
        NSMutableAttributedString *strikedAttributeString = [attributeString mutableCopy];
        [strikedAttributeString addAttribute:NSStrikethroughStyleAttributeName value:@2 range:NSMakeRange(0, [attributeString length])];
        
        if (@available(iOS 13.0, *)){
            imageOfName = useShortenedLabel ? self.autoCorrectionEnabled?attributeString:strikedAttributeString : self.autoCorrectionEnabled?[@"checkmark.circle.fill" attributedString]:[@"checkmark.circle" attributedString];
        }else{
            imageOfName = useShortenedLabel ? self.autoCorrectionEnabled?attributeString:strikedAttributeString : self.autoCorrectionEnabled?[@"UIAccessoryButtonCheckmark" attributedString]:[@"UIAccessoryButtonX" attributedString];
        }
        if (!useShortenedLabel) image = [DockXHelper imageForName:imageOfName.string  withSystemColor:NO completion:nil];
    }else if ([selectorName isEqualToString:@"autoCapitalizationAction:"]){
        self.autoCapitalizationCell = cell;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.autoCapitalizationEnabled = [self isAutoCapitalizationEnabled];
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.isSameProcess = NO;
                self.asyncUpdated = YES;
                [self updateAutoCapitalization:nil];
            });
        });
        
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[DockXHelper localizedStringForActionNamed:selectorName shortName:YES bundle:tweakBundle]];
        NSMutableAttributedString *strikedAttributeString = [attributeString mutableCopy];
        [strikedAttributeString addAttribute:NSStrikethroughStyleAttributeName value:@2 range:NSMakeRange(0, [attributeString length])];
        
        if (@available(iOS 13.0, *)){
            imageOfName = useShortenedLabel ? self.autoCapitalizationEnabled?attributeString:strikedAttributeString : self.autoCapitalizationEnabled?[@"shift.fill" attributedString]:[@"shift" attributedString];
        }else{
            imageOfName = useShortenedLabel ? self.autoCapitalizationEnabled?attributeString:strikedAttributeString : self.autoCapitalizationEnabled?[@"shift_on_portrait" attributedString]:[@"shift_portrait" attributedString];
        }
        if (!useShortenedLabel) image = [DockXHelper imageForName:imageOfName.string  withSystemColor:NO completion:nil];
    }else if ([selectorName isEqualToString:@"keyboardTypeAction:"]){
        self.keyboardInputTypeCell = cell;
        self.keyboardInputTypeCellIndexPath = indexPath;
        
        [self beginUpdateDelegate];
        BOOL keyboardTypeChangable = [delegate respondsToSelector:@selector(keyboardType)];
        
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[DockXHelper localizedStringForActionNamed:selectorName shortName:YES bundle:tweakBundle]];
        NSMutableAttributedString *strikedAttributeString = [attributeString mutableCopy];
        [strikedAttributeString addAttribute:NSStrikethroughStyleAttributeName value:@2 range:NSMakeRange(0, [attributeString length])];
        
        if (@available(iOS 13.0, *)){
            imageOfName = useShortenedLabel ? keyboardTypeChangable?attributeString:strikedAttributeString : keyboardTypeChangable?[@"number.circle.fill" attributedString]:[@"number.circle" attributedString];
        }else{
            imageOfName = useShortenedLabel ? keyboardTypeChangable?attributeString:strikedAttributeString : keyboardTypeChangable?[@"reachable_full" attributedString]:[@"dictation_keyboard_dark" attributedString];
        }
        if (!useShortenedLabel) image = [DockXHelper imageForName:imageOfName.string  withSystemColor:NO completion:nil];
    }else{
        
        if (@available(iOS 13.0, *)){
            
            imageOfName = useShortenedLabel ? [[DockXHelper localizedStringForActionNamed:selectorName shortName:YES bundle:tweakBundle] attributedString] : [((NSArray *)_shortcuts[kbuttonsImages13])[cellIndex] attributedString];
            //imageOfName = useShortenedLabel ? [((NSArray *)_shortcuts[kshortLabel])[cellIndex] attributedString] : [((NSArray *)_shortcuts[kbuttonsImages13])[cellIndex] attributedString];
        }else{
            imageOfName = useShortenedLabel ? [[DockXHelper localizedStringForActionNamed:selectorName shortName:YES bundle:tweakBundle] attributedString]: [((NSArray *)_shortcuts[kbuttonsImages12])[cellIndex] attributedString];
        }
        if (!useShortenedLabel) image = [DockXHelper imageForName:imageOfName.string  withSystemColor:NO completion:nil];
    }
    
    
    if (useShortenedLabel){
        [cell.btn setImage:nil forState:UIControlStateNormal];
        [cell.btn setAttributedTitle:imageOfName forState:UIControlStateNormal];
    }else{
        [cell.btn setAttributedTitle:nil forState:UIControlStateNormal];
        [cell.btn setImage:image forState:UIControlStateNormal];
    }
    SEL selector = NSSelectorFromString(selectorName);
    [cell.btn removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(activateLPActions:)];
    longPress.minimumPressDuration = 0.5;
    
    BOOL doubleTapEnabled = preferencesBool(kEnabledDoubleTapkey, NO);
    BOOL shootingStarEnabled = preferencesBool(kEnabledShootingStarkey, NO);
    
    UIShortTapGestureRecognizer *singleTap;
    UIShortTapGestureRecognizer *doubleTap;
    if (doubleTapEnabled){
        singleTap = [[UIShortTapGestureRecognizer alloc] initWithTarget:self action:selector];
        singleTap.numberOfTapsRequired = 1;
        doubleTap = [[UIShortTapGestureRecognizer alloc] initWithTarget:self action:@selector(activateDTActions:)];
        doubleTap.numberOfTapsRequired = 2;
        [singleTap requireGestureRecognizerToFail:doubleTap];
        cell.btn.gestureRecognizers = @[longPress, doubleTap, singleTap];
        //[tapGesture setCancelsTouchesInView:NO];
    }else{
        [cell.btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        cell.btn.gestureRecognizers = @[longPress];
    }
    
    if (shootingStarEnabled){
        [[NSNotificationCenter defaultCenter] removeObserver:cell];
        [[NSNotificationCenter defaultCenter] addObserver:cell selector:@selector(shakeCell:) name:[NSString stringWithFormat:@"shakeCell-%@", selectorName] object:nil];
    }
    //SEL selectorLP = NSSelectorFromString(((NSArray *)_shortcuts[kselectorsLP])[cellIndex]);
    
    
    
    /*
     UILongPressGestureRecognizer *longPress;
     
     NSString *selectorName1 = preferencesSelectorForIdentifier(selectorName, 1, @"");
     NSString *selectorName2 = preferencesSelectorForIdentifier(selectorName, 2, @"");
     
     if ( ([selectorName1 length] > 0) && ([selectorName2 length] > 0) ){
     
     //SEL selectorLP = NSSelectorFromString();
     longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(activateDoubleActions:)];
     longPress.minimumPressDuration = 0.5;
     }else{
     SEL selectorLP = NSSelectorFromString(((NSArray *)_shortcuts[kselectorsLP])[cellIndex]);
     longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:selectorLP];
     longPress.minimumPressDuration = 0.5;
     }
     */
    
    //cell.btn.gestureRecognizers?.removeAll();
    
    //while (cell.btn.gestureRecognizers.count) {
    //[cell.btn removeGestureRecognizer:[cell.btn.gestureRecognizers objectAtIndex:0]];
    //}
    
    //[cell.btn addGestureRecognizer:longPress];
    //[cell.btn setContentMode:UIViewContentModeScaleAspectFit];
    //if (useShortenedLabel){
    //MKInfoCardThemeManager *kbTheme = [(UIKeyboardLayoutStar *)[[%c(UIKeyboardImpl) activeInstance] valueForKey:@"m_layout"] mk_theme];
    //cell.btn.backgroundColor = kbTheme.tertiaryTextColor;
    //cell.btn.layer.cornerRadius = 5; // this value vary as per your desire
    //cell.btn.clipsToBounds = YES;
    //}else{
    //cell.btn.backgroundColor = [UIColor clearColor];
    //cell.btn.layer.cornerRadius = 0; // this value vary as per your desire
    //cell.btn.clipsToBounds = NO;
    //}
    //self.layer.masksToBounds = NO;
    
    if (useShortenedLabel) cell.btn.clipsToBounds = YES; else cell.btn.clipsToBounds = NO;
    if (currentBackgroundTintColor)  cell.btn.layer.cornerRadius = 5;
    cell.btn.backgroundColor = currentBackgroundTintColor ? : [UIColor clearColor];
    cell.btn.tintColor = currentTintColor;
    [cell.btn setTitleColor:currentTintColor forState:UIControlStateNormal];
    cell.btn.hidden = isLandscape||isDictating?YES:NO;
    //cell.btn.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.7];
    //HBLogDebug(@"ITEMS: %@", ((NSArray *)_shortcuts[kselectors])[cellIndex]);
    //HBLogDebug(@"INDEX PATH: %@", indexPath);
    //HBLogDebug(@"");
    return cell;
    
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //CGFloat useableWidth = collectionView.frame.size.width / ((NSArray *)_shortcuts[kbuttonsImages12]).count;
    //CGFloat useableWidth = collectionView.frame.size.width / ([self numberOfItemsInSection:indexPath.section] <= preferencesInt(kShortcutsPerSection, maxshortcutpersection) ? (((NSArray *)_shortcuts[kbuttonsImages12]).count <=preferencesInt(kShortcutsPerSection, maxshortcutpersection) ? ((NSArray *)_shortcuts[kbuttonsImages12]).count : preferencesInt(kShortcutsPerSection, maxshortcutpersection)) :  [self numberOfItemsInSection:indexPath.section]);
    UIKeyboardPreferencesController *kbPrefsController = [%c(UIKeyboardPreferencesController) sharedPreferencesController];
    if (kbPrefsController){
        long long currentHandBias = kbPrefsController.handBias;
        //HBLogDebug(@"currentHandBias: %lld",currentHandBias);
        if (currentHandBias > 0){
            int shortcutsPerSectionOneHanded = (preferencesInt(kShortcutsPerSection, maxshortcutpersection_onehanded) > maxshortcutpersection_onehanded) ? maxshortcutpersection_onehanded : preferencesInt(kShortcutsPerSection, maxshortcutpersection_onehanded);
            CGFloat useableWidth = ((currentBackgroundTintColor && collectionView.frame.size.width-4*buttonSpacing >0) ? collectionView.frame.size.width - 4*buttonSpacing : collectionView.frame.size.width) / ([self numberOfItemsInSection:indexPath.section] <= maxshortcutpersection_onehanded ? (((NSArray *)_shortcuts[kbuttonsImages12]).count <= maxshortcutpersection_onehanded ? ((NSArray *)_shortcuts[kbuttonsImages12]).count : shortcutsPerSectionOneHanded) :  shortcutsPerSectionOneHanded);
            return CGSizeMake(useableWidth, buttonHeight);
            
        }
    }
    
    CGFloat useableWidth = ((currentBackgroundTintColor && collectionView.frame.size.width-4*buttonSpacing >0) ? collectionView.frame.size.width - 4*buttonSpacing : collectionView.frame.size.width) / ([self numberOfItemsInSection:indexPath.section] <= preferencesInt(kShortcutsPerSection, maxshortcutpersection) ? (((NSArray *)_shortcuts[kbuttonsImages12]).count <=preferencesInt(kShortcutsPerSection, maxshortcutpersection) ? ((NSArray *)_shortcuts[kbuttonsImages12]).count : preferencesInt(kShortcutsPerSection, maxshortcutpersection)) :  [self numberOfItemsInSection:indexPath.section]);
    
    return CGSizeMake(useableWidth, buttonHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (currentBackgroundTintColor){
        if (section == 0){
            return UIEdgeInsetsMake(topInset, leftInset+2*buttonSpacing, bottomInset, rightInset);
            
        }
        return UIEdgeInsetsMake(topInset, leftInset+buttonSpacing, bottomInset, rightInset);
        
    }
    return UIEdgeInsetsMake(topInset, leftInset, bottomInset, rightInset);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return currentBackgroundTintColor?buttonSpacing:0;
}

@end


#pragma mark hook
%group DockX
%hook UIKeyboardDockView
//%property (retain, nonatomic) UIKeyboardDockItemButton *leftDockButton;
//%property (retain, nonatomic) UIKeyboardDockItemButton *rightDockButton;
%property (retain, nonatomic) DockXCollectionView *dockx;

- (instancetype)initWithFrame:(CGRect)frame {
    dockView = %orig;
    if (preferencesBool(kEnabledkey,YES) && dockView) {
        self.dockx = [[DockXCollectionView alloc] init];
        
        //self.dockx = [[DockXCollectionView alloc] init];
        
        self.dockx.translatesAutoresizingMaskIntoConstraints = NO;
        //self.dockx.transform = CGAffineTransformMakeScale(-1, 1);
        
        [dockView addSubview:self.dockx];
        
        float leading = leadingOffset;
        float trailing = trailingOffset;
        
        HBLogDebug(@"BEFORE leading: %f, trailing: %f",leading, trailing );
        
        switch (preferencesInt(kDockModekey, 0)){
            case 1:
                if (fabs(leading - leadingOffsetDefault) > 0.5f) break;
                leading = 5.0f;
                break;
            case 2:
                if (fabs(trailing - trailingOffsetDefault) > 0.5f) break;
                trailing = -5.0f;
                break;
            case 3:
                if (fabs(leading - leadingOffsetDefault) > 0.5f){
                }else{
                    leading = 5.0f;
                }
                if (fabs(trailing - trailingOffsetDefault) > 0.5f){
                }else{
                    trailing = -5.0f;
                }
                break;
        }
        
        
        HBLogDebug(@"AFTER leading: %f, trailing: %f",leading, trailing );
        
        NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:self.dockx attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:dockView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:leading];
        leadingConstraint.identifier = @"DockX";
        [dockView addConstraint:leadingConstraint];
        
        NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:self.dockx attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:dockView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:trailing];
        trailingConstraint.identifier = @"DockX";
        [dockView addConstraint:trailingConstraint];
        
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.dockx attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:heightOffset];
        heightConstraint.identifier = @"DockX";
        [dockView addConstraint:heightConstraint];
        
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.dockx attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:dockView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:bottomOffset];
        bottomConstraint.identifier = @"DockX";
        [dockView addConstraint:bottomConstraint];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
            delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
            if ([delegate respondsToSelector:@selector(keyboardType)]){
                if (shouldUpdateTrueKBType){
                    self.dockx.trueKBType = [[NSNumber numberWithInt:[delegate keyboardType]] intValue];
                    shouldUpdateTrueKBType = NO;
                }
                NSUInteger index = [self.dockx.kbType indexOfObject:[NSNumber numberWithInt:[delegate keyboardType]]];
                //HBLogDebug(@"indexXXXXX: %lu", index);
                if (index == NSNotFound){
                    //HBLogDebug(@"INDEXOF: %@", [NSNumber numberWithInt:[delegate keyboardType]]);
                    NSMutableArray *kbTypeMutable = [NSMutableArray array];
                    NSMutableArray *kbTypeLabelMutable = [NSMutableArray array];
                    
                    NSUInteger indexInArray = [self.dockx.keyboardTypeDataFull indexOfObject:[NSNumber numberWithInt:[delegate keyboardType]]];
                    if (index == NSNotFound){
                        if ([delegate keyboardType] > 12){
                            self.dockx.trueKBType = 0;
                            shouldUpdateTrueKBType = NO;
                        }else{
                            [kbTypeMutable insertObject:[NSNumber numberWithInt:[delegate keyboardType]] atIndex:0];
                            if (indexInArray != NSNotFound){
                                [kbTypeLabelMutable insertObject:self.dockx.keyboardTypeLabelFull[indexInArray] atIndex:0];
                            }else{
                                [kbTypeLabelMutable insertObject:LOCALIZED(@"TOAST_KEYBOARD_TYPE_GENERIC") atIndex:0];
                            }
                        }
                    }else{
                        [kbTypeMutable insertObject:self.dockx.keyboardTypeDataFull[indexInArray] atIndex:0];
                        [kbTypeLabelMutable insertObject:self.dockx.keyboardTypeLabelFull[indexInArray] atIndex:0];
                    }
                    self.dockx.kbTypeLabel = kbTypeLabelMutable;
                    self.dockx.kbType = kbTypeMutable;
                    
                }else{
                    self.dockx.trueKBType = 0;
                    shouldUpdateTrueKBType = NO;
                }
            }else{
                UIImage *image;
                NSMutableAttributedString *imageOfName = [[NSMutableAttributedString alloc] initWithString:@""];
                
                NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:@"Input"];
                NSMutableAttributedString *strikedAttributeString = [attributeString mutableCopy];
                [strikedAttributeString addAttribute:NSStrikethroughStyleAttributeName value:@2 range:NSMakeRange(0, [attributeString length])];
                
                if (@available(iOS 13.0, *)){
                    imageOfName = useShortenedLabel ? [delegate respondsToSelector:@selector(keyboardType)]?attributeString:strikedAttributeString : [delegate respondsToSelector:@selector(keyboardType)]?[@"number.circle.fill" attributedString]:[@"number.circle" attributedString];
                    if (!useShortenedLabel) image = [DockXHelper imageForName:imageOfName.string  withSystemColor:NO completion:nil];
                }else{
                    imageOfName =  useShortenedLabel ? [delegate respondsToSelector:@selector(keyboardType)]?attributeString:strikedAttributeString : [delegate respondsToSelector:@selector(keyboardType)]?[@"reachable_full" attributedString]:[@"dictation_keyboard_dark" attributedString];
                    if (!useShortenedLabel) image = [DockXHelper imageForName:imageOfName.string  withSystemColor:NO completion:nil];
                }
                if (useShortenedLabel){
                    [self.dockx.keyboardInputTypeCell.btn setImage:nil forState:UIControlStateNormal];
                    [self.dockx.keyboardInputTypeCell.btn setAttributedTitle:imageOfName forState:UIControlStateNormal];
                }else{
                    [self.dockx.keyboardInputTypeCell.btn setAttributedTitle:nil forState:UIControlStateNormal];
                    [self.dockx.keyboardInputTypeCell.btn setImage:image forState:UIControlStateNormal];
                }
            }
            
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handBiasChanged) name:@"handBiasChanged" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleDockX:) name:@"toggleDockX" object:nil];
            
            [self handBiasChanged];
        });
        
    }
    if (![self respondsToSelector:@selector(barmoji)]){
        self.dockx.hidden = YES;
        toggledOn = YES;
    }else{
        if (toggledOn){
            self.dockx.hidden = NO;
        }else{
            self.dockx.hidden = YES;
        }
    }
    
    
    return dockV = dockView;
}

%new
- (void)performDockXToggling:(UILongPressGestureRecognizer*)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"toggleDockX" object:nil];
    }
}

%new
- (void)performDockXTogglingTap:(UITapGestureRecognizer*)gesture{
    //if (gesture.state == UIGestureRecognizerStateBegan){
    [[NSNotificationCenter defaultCenter] postNotificationName:@"toggleDockX" object:nil];
    //}
}


- (void)setLeftDockItem:(UIKeyboardDockItem *)dockItem {
    if (preferencesBool(kEnabledkey,YES)){
        if (!preferencesBool(kColorEnabledkey,NO) || (preferencesBool(kColorEnabledkey,NO)  && !preferencesBool(kShortcutsTintEnabled,YES))){
            currentTintColor = dockItem.button.tintColor;
        }
        if (preferencesInt(kDockModekey, 0) == 1 || preferencesInt(kDockModekey, 0) == 3) return;
        if (preferencesInt(kDedicatedGestureButtonkey, 0) == 1 || preferencesInt(kDedicatedGestureButtonkey, 0) == 3){
            %orig;
            if ([dockView respondsToSelector:@selector(barmoji)]){
                if (preferencesInt(kGestureTypekey,0) == 1){
                    singleTapGlobeEnabled = NO;
                    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(performDockXToggling:)];
                    longPress.minimumPressDuration = 0.3;
                    [dockItem.button addGestureRecognizer:longPress];
                }else{
                    singleTapGlobeEnabled = YES;
                    [dockItem.button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performDockXTogglingTap:)];
                    singleTap.numberOfTapsRequired = 1;
                    [dockItem.button addGestureRecognizer:singleTap];
                }
            }
            return;
        }
    }
    %orig;
    //self.leftDockButton = dockItem.button;
    /*
     UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(performOriginalLeftDockAction:)];
     longPress.minimumPressDuration = 0.5;
     
     //UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performDockXToggling:)];
     //singleTap.numberOfTapsRequired = 1;
     
     [dockItem.button addGestureRecognizer:longPress];
     //[dockItem.button addGestureRecognizer:singleTap];
     %orig;
     [dockItem.button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
     [dockItem.button addTarget:self action:@selector(performDockXToggling:) forControlEvents:UIControlEventTouchUpInside];
     */
}
- (void)setRightDockItem:(UIKeyboardDockItem *)dockItem {
    if (preferencesBool(kEnabledkey,YES)){
        if (!preferencesBool(kColorEnabledkey,NO) || (preferencesBool(kColorEnabledkey,NO)  && !preferencesBool(kShortcutsTintEnabled,YES))){
            currentTintColor = dockItem.button.tintColor;
        }
        if (preferencesInt(kDockModekey, 0) == 2 || preferencesInt(kDockModekey, 0) == 3) return;
        if (preferencesInt(kDedicatedGestureButtonkey, 0) == 2 || preferencesInt(kDedicatedGestureButtonkey, 0) == 3){
            %orig;
            if ([dockView respondsToSelector:@selector(barmoji)]){
                if (preferencesInt(kGestureTypekey,0) == 1){
                    singleTapDictationEnabled = NO;
                    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(performDockXToggling:)];
                    longPress.minimumPressDuration = 0.3;
                    [dockItem.button addGestureRecognizer:longPress];
                }else{
                    singleTapDictationEnabled = YES;
                    [dockItem.button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performDockXTogglingTap:)];
                    singleTap.numberOfTapsRequired = 1;
                    [dockItem.button addGestureRecognizer:singleTap];
                }
            }
            return;
        }
    }
    %orig;
    /*
     NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject: dockItem.button];
     self.rightDockButton = [NSKeyedUnarchiver unarchiveObjectWithData: archivedData];
     
     UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(performOriginalRightDockAction:)];
     longPress.minimumPressDuration = 0.5;
     
     UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performDockXToggling:)];
     singleTap.numberOfTapsRequired = 1;
     
     [dockItem.button addGestureRecognizer:longPress];
     [dockItem.button addGestureRecognizer:singleTap];
     %orig;
     
     [dockItem.button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
     */
}

%new
-(void)toggleDockX:(NSNotification*)notification{
    if (preferencesBool(kEnabledHaptickey,YES)){
        [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight] impactOccurred];
    }
    //self.barmoji.hidden = !self.dockx.hidden;
    toggledOn = self.dockx.hidden;
    [[PrefsManager sharedInstance] setValue:[NSNumber numberWithBool:toggledOn] forKey:kToggledOnkey fromSandbox:!isSpringBoard];
    //dockView.barmoji.hidden = !self.hidden;
    /*
     if (isApplication){
     [[PrefsManager sharedInstance] setValue:[NSNumber numberWithBool:toggledOn] forKey:kToggledOnkey fromSandbox:isApplication];
     CPDistributedMessagingCenter *c = [CPDistributedMessagingCenter centerNamed:@"com.udevs.dockx.server"];
     rocketbootstrap_distributedmessagingcenter_apply(c);
     [c sendMessageAndReceiveReplyName:@"dockXSaveValue" userInfo:@{@"key":kToggledOnkey, @"value":[NSNumber numberWithBool:toggledOn]}];
     }else{
     CFPreferencesSetAppValue((CFStringRef)kToggledOnkey, (CFPropertyListRef)[NSNumber numberWithBool:toggledOn], (CFStringRef)kIdentifier);
     CFPreferencesAppSynchronize((CFStringRef)kIdentifier);
     }
     */
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)kPrefsChangedIdentifier, NULL, NULL, YES);
    
    if (self.dockx.hidden){
        self.barmoji.hidden = YES;
        self.dockx.hidden = NO;
        
        if (@available(iOS 14.0, *)){
            self.dockx.alpha = 0.0f;
            [UIView animateWithDuration:0.3f animations:^{
                self.dockx.alpha = 1.0f;
            } completion:^(BOOL finished) {
            }];
        }else{
            self.dockx.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
            [UIView animateWithDuration:0.3/4 animations:^{
                self.dockx.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/4 animations:^{
                    self.dockx.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3/4 animations:^{
                        self.dockx.transform = CGAffineTransformIdentity;
                    }];
                }];
            }];
        }
    }else{
        self.dockx.hidden = YES;
        self.barmoji.hidden = NO;
        
        if (@available(iOS 14.0, *)){
            self.barmoji.alpha = 0.0f;
            [UIView animateWithDuration:0.3f animations:^{
                self.barmoji.alpha = 1.0f;
            } completion:^(BOOL finished) {
            }];
        }else{
            self.barmoji.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
            [UIView animateWithDuration:0.3/4 animations:^{
                self.barmoji.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/4 animations:^{
                    self.barmoji.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3/4 animations:^{
                        self.barmoji.transform = CGAffineTransformIdentity;
                    }];
                }];
            }];
        }
    }
    [self layoutSubviews];
    
}

%new
-(void)handBiasChanged{
    UIKeyboardPreferencesController *kbPrefsController = [%c(UIKeyboardPreferencesController) sharedPreferencesController];
    if (kbPrefsController){
        int constraintsAdjust = 0;
        long long currentHandBias = kbPrefsController.handBias;
        
        float leading = leadingOffset;
        float trailing = trailingOffset;
        HBLogDebug(@"HANDBIAS BEFORE leading: %f, trailing: %f",leading, trailing );
        HBLogDebug(@"fabs(leading - leadingOffsetDefault): %f", fabs(leading - leadingOffsetDefault));
        HBLogDebug(@"fabs(trailing - trailingOffsetDefault): %f", fabs(trailing - trailingOffsetDefault));
        if (currentHandBias == 0){
            switch (preferencesInt(kDockModekey, 0)){
                case 1:
                    if (fabs(leading - leadingOffsetDefault) > 0.5f) break;
                    leading = 5.0f;
                    break;
                case 2:
                    if (fabs(trailing - trailingOffsetDefault) > 0.5f) break;
                    trailing = -5.0f;
                    break;
                case 3:
                    if (fabs(leading - leadingOffsetDefault) > 0.5f){
                    }else{
                        leading = 5.0f;
                    }
                    if (fabs(trailing - trailingOffsetDefault) > 0.5f){
                    }else{
                        trailing = -5.0f;
                    }
                    break;
            }
        }else if (currentHandBias == 1){
            leading = leadingHBRightOffset;
            trailing = trailingHBRightOffset;
            switch (preferencesInt(kDockModekey, 0)){
                case 1:
                    leading = 50;
                    break;
                case 2:
                    trailing = -5;
                    break;
                case 3:
                    leading = 50;
                    trailing = -5;
                    break;
            }
        }else if (currentHandBias == 2){
            leading = leadingHBLeftOffset;
            trailing = trailingHBLeftOffset;
            switch (preferencesInt(kDockModekey, 0)){
                case 1:
                    leading = 5;
                    break;
                case 2:
                    trailing = -45;
                    break;
                case 3:
                    leading = 5;
                    trailing = -45;
                    break;
            }
        }
        HBLogDebug(@"HANDBIAS AFTER leading: %f, trailing: %f",leading, trailing );
        
        //HBLogDebug(@"received handbiaschangednotification: %lld", currentHandBias);
        //if (currentHandBias == 0){
        for (NSLayoutConstraint *constraint in self.constraints) {
            if (constraint.firstAttribute == NSLayoutAttributeLeading && [constraint.identifier isEqualToString:@"DockX"]) {
                [self removeConstraint:constraint];
                
                NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:self.dockx attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:leading];
                leadingConstraint.identifier = @"DockX";
                [self addConstraint:leadingConstraint];
                constraintsAdjust = constraintsAdjust +1;
            }else if (constraint.firstAttribute == NSLayoutAttributeTrailing && [constraint.identifier isEqualToString:@"DockX"]) {
                [self removeConstraint:constraint];
                NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:self.dockx attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:trailing];
                trailingConstraint.identifier = @"DockX";
                [self addConstraint:trailingConstraint];
                constraintsAdjust = constraintsAdjust +1;
            }
            if (constraintsAdjust == 2){
                break;
            }
            //self.dockx.pagingEnabled = YES;
        }
        /*
         }else if (currentHandBias == 1 ){
         for (NSLayoutConstraint *constraint in self.constraints) {
         if (constraint.firstAttribute == NSLayoutAttributeLeading && [constraint.identifier isEqualToString:@"DockX"]) {
         [self removeConstraint:constraint];
         [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dockx attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:leading]];
         constraintsAdjust = constraintsAdjust +1;
         }else if (constraint.firstAttribute == NSLayoutAttributeTrailing && [constraint.identifier isEqualToString:@"DockX"]) {
         [self removeConstraint:constraint];
         //[self addConstraint:[NSLayoutConstraint constraintWithItem:self.dockx attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:((NSArray *)self.dockx.shortcuts[kbuttonsImages12]).count>5?-19:-60]];
         [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dockx attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:trailing]];
         
         constraintsAdjust = constraintsAdjust +1;
         }
         if (constraintsAdjust == 2){
         break;
         }
         }}else if (currentHandBias == 2 ){
         for (NSLayoutConstraint *constraint in self.constraints) {
         if (constraint.firstAttribute == NSLayoutAttributeLeading && [constraint.identifier isEqualToString:@"DockX"]) {
         [self removeConstraint:constraint];
         [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dockx attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:leading]];
         constraintsAdjust = constraintsAdjust +1;
         }else if (constraint.firstAttribute == NSLayoutAttributeTrailing && [constraint.identifier isEqualToString:@"DockX"]) {
         [self removeConstraint:constraint];
         //[self addConstraint:[NSLayoutConstraint constraintWithItem:self.dockx attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:((NSArray *)self.dockx.shortcuts[kbuttonsImages12]).count>5?-60:-95]];
         [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dockx attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:trailing]];
         
         constraintsAdjust = constraintsAdjust +1;
         }
         if (constraintsAdjust == 2){
         break;
         }
         }}
         */
        
    }else{
        //self.pagingEnabled = NO;
        //return _buttons.count;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dockXLayoutChanged" object:nil userInfo:@{@"fullreload":@YES}];
    //NSNotification * note = [NSNotification notificationWithName:@"dockXLayoutChanged" object:nil userInfo:@{@"fullreload":@YES}];
    //[[NSNotificationQueue defaultQueue] enqueueNotification:note postingStyle:NSPostASAP coalesceMask:NSNotificationCoalescingOnName forModes:nil];
    
    
}

/*
 %new
 -(void)updateDockXTint{
 if (self.leftDockItem.button){
 currentTintColor = self.leftDockItem.button.tintColor;
 }else if (self.rightDockItem.button){
 currentTintColor = self.rightDockItem.button.tintColor;
 }else{
 if (@available(iOS 13.0, *)){
 if ([UITraitCollection currentTraitCollection].userInterfaceStyle == UIUserInterfaceStyleDark) {
 currentTintColor = [UIColor whiteColor];
 }else{
 currentTintColor = [UIColor blackColor];
 }
 }else{
 
 }
 }
 }
 */

- (void)layoutSubviews{
    %orig;
    //HBLogDebug(@"isDictating %d, isLandscape: %d", isDictating?1:0, isLandscape?1:0);
    if (preferencesBool(kEnabledkey,YES)){
        //HBLogDebug(@"toggledOn %d", toggledOn?1:0);
        if (toggledOn){
            if ([self respondsToSelector:@selector(barmoji)]) self.barmoji.hidden = YES;
            
            //NSTimeInterval timeInterval = fabs([lastReloadDate timeIntervalSinceNow]);
            //if (lastReloadDate && timeInterval < 0.5f ) lastReloadDate = [NSDate date]; return;
            //if (!self.dockx) return;
            if (isDictating || isLandscape){
                //HBLogDebug(@"Should Hide");
                self.dockx.hidden = YES;
                return;
                
                //if (!preferencesBool(kColorEnabledkey,NO)){
                //[self updateDockXTint];
                //}
                //NSNotification * note = [NSNotification notificationWithName:@"dockXLayoutChanged" object:nil];
                //[[NSNotificationQueue defaultQueue] enqueueNotification:note postingStyle:NSPostASAP coalesceMask:NSNotificationCoalescingOnName forModes:nil];
            }else{
                //HBLogDebug(@"Shouldn't Hide");
                
                self.dockx.hidden = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"dockXLayoutChanged" object:nil];
                
            }
            //lastReloadDate = [NSDate date];
        }else{
            self.dockx.hidden = YES;
            self.barmoji.hidden = NO;
        }
        
        
        if (self.dockx.keyboardInputTypeCell){
            //dispatch_async(dispatch_get_main_queue(), ^{
            
            //if (![[self.dockx visibleCells] containsObject:self.dockx.keyboardInputTypeCell]) return;
            
            kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
            delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
            
            UIImage *image;
            NSMutableAttributedString *imageOfName = [[NSMutableAttributedString alloc] initWithString:@""];
            
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:@"Input"];
            NSMutableAttributedString *strikedAttributeString = [attributeString mutableCopy];
            [strikedAttributeString addAttribute:NSStrikethroughStyleAttributeName value:@2 range:NSMakeRange(0, [attributeString length])];
            
            if (@available(iOS 13.0, *)){
                imageOfName = useShortenedLabel ? ([delegate respondsToSelector:@selector(keyboardType)]?attributeString:strikedAttributeString) : ([delegate respondsToSelector:@selector(keyboardType)]?[@"number.circle.fill" attributedString]:[@"number.circle" attributedString]);
                if (!useShortenedLabel) image = [DockXHelper imageForName:imageOfName.string  withSystemColor:NO completion:nil];
            }else{
                imageOfName = useShortenedLabel ? ([delegate respondsToSelector:@selector(keyboardType)]?attributeString:strikedAttributeString) : ([delegate respondsToSelector:@selector(keyboardType)]?[@"reachable_full" attributedString]:[@"dictation_keyboard_dark" attributedString]);
                if (!useShortenedLabel) image = [DockXHelper imageForName:imageOfName.string  withSystemColor:NO completion:nil];
            }
            
            if (useShortenedLabel){
                [self.dockx.keyboardInputTypeCell.btn setImage:nil forState:UIControlStateNormal];
                [self.dockx.keyboardInputTypeCell.btn setAttributedTitle:imageOfName forState:UIControlStateNormal];
            }else{
                [self.dockx.keyboardInputTypeCell.btn setAttributedTitle:nil forState:UIControlStateNormal];
                [self.dockx.keyboardInputTypeCell.btn setImage:image forState:UIControlStateNormal];
                
            }
            
            //});
        }
        
    }
}
/*
 %new
 -(void)shouldUpdateLayoutWithDelay:(float)delay{
 
 double delayInSeconds = delay;
 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
 shouldUpdateLayout = YES;
 
 });
 }
 */
//-(void)setLeftDockItem:(UIKeyboardDockItem *)leftDock{
//%orig;
//currentTintColor = leftDock.button.tintColor;
//[[NSNotificationCenter defaultCenter] postNotificationName:@"dockXLayoutChanged" object:nil];
//}
/*
 - (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
 %orig;
 if (preferencesBool(kEnabledkey,YES) && self.dockx.cursorTimer){
 [self.dockx.cursorTimer invalidate];
 self.dockx.cursorTimer = nil;
 }
 }
 */
%end

%hook UIKeyboardDockItem
//iOS 13+
-(void)setImageName:(NSString *)imageName{
    //HBLogDebug(@"singleTapDictationEnabled: %d, singleTapGlobeEnabled: %d", singleTapDictationEnabled?1:0, singleTapGlobeEnabled?1:0);
    if (([imageName isEqualToString:@"mic"] && singleTapDictationEnabled) || ([imageName isEqualToString:@"globe"] && singleTapGlobeEnabled)){
        %orig(@"circle");
        return;
    }
    %orig;
}

//iOS 12
-(id)initWithImageName:(id)imageName identifier:(id)identifier{
    //HBLogDebug(@"imageName: %@, identifier: %@", imageName, identifier);
    if (@available(iOS 13.0, *)){
    }else{
        if ([identifier isEqualToString:@"dictation"] && singleTapDictationEnabled){
            return %orig(@"UIDownloadProgressBorderThick", identifier);
        }else if ([identifier isEqualToString:@"globe"] && singleTapGlobeEnabled){
            return %orig(@"UIDownloadProgressBorderThick", identifier);
        }
    }
    return %orig;
}
%end

%hook UIDictationController
-(void)switchToDictationInputMode{
    %orig;
    isDictating = YES;
    //HBLogDebug(@"switchToDictationInputMode");
}

-(void)switchToDictationInputModeWithTouch:(id)arg1{
    %orig;
    isDictating = YES;
    //HBLogDebug(@"switchToDictationInputModeWithTouch");
    
}

-(void)stopDictation:(BOOL)arg1{
    %orig;
    if (arg1){
        isDictating = NO;
    }
    //HBLogDebug(@"stopDictation: %@", arg1?@"YES":@"NO");
    
}


%end

%hook UIKeyboardPreferencesController
-(void)setHandBias:(long long)arg1{ //0 -normal,2-left, 1-right
    %orig;
    if (preferencesBool(kEnabledkey,YES)){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"handBiasChanged" object:nil];
    }
    
}

%end

//sstatic BOOL forceHidden = NO;


%hook _UIKeyboardTextSelectionInteraction
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer{
    //HBLogDebug(@"GESTURE: %@", recognizer);
    if (preferencesBool(kEnabledkey,YES) && [NSStringFromClass([recognizer.view class]) isEqualToString:@"UIKeyboardDockView"]){
        return NO;
    }
    return %orig;
}
%end

%hook UIKeyboardLayoutStar

-(BOOL)isHandwritingPlane{
    BOOL isHWR = %orig;
    if (preferencesBool(kEnabledkey,YES) && preferencesBool(kSpaceBarScrollingBOOL,YES)){
        UISwipeGestureRecognizer *leftRecognizer = [self valueForKey:@"_leftSwipeRecognizer"];
        UISwipeGestureRecognizer *rightRecognizer = [self valueForKey:@"_rightSwipeRecognizer"];
        if (isHWR){
            leftRecognizer.enabled = NO;
            rightRecognizer.enabled = NO;
        }else{
            leftRecognizer.enabled = YES;
            rightRecognizer.enabled = YES;
        }
    }
    return isHWR;
}

-(id)initWithFrame:(CGRect)arg1{
    self = %orig;
    
    if (preferencesBool(kEnabledkey,YES) && preferencesBool(kSpaceBarScrollingBOOL,YES)){
        UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeHandle:)];
        leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [leftRecognizer setNumberOfTouchesRequired:1];
        [self setValue:leftRecognizer forKey:@"_leftSwipeRecognizer"];
        [self addGestureRecognizer:leftRecognizer];
        
        UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeHandle:)];
        rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [rightRecognizer setNumberOfTouchesRequired:1];
        [self setValue:rightRecognizer forKey:@"_rightSwipeRecognizer"];
        [self addGestureRecognizer:rightRecognizer];
        
        //UISwipeGestureRecognizer *upRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(upSwipeHandle:)];
        //upRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        //[upRecognizer setNumberOfTouchesRequired:1];
        //[self setValue:upRecognizer forKey:@"_upSwipeRecognizer"];
        //[self addGestureRecognizer:upRecognizer];
        
    }
    return self;
}

%new
- (void)leftSwipeHandle:(UISwipeGestureRecognizer*)recognizer
{
    //HBLogDebug(@"leftSwipeHandle");
    //if (recognizer.state == UIGestureRecognizerStateBegan) {
    //NSString *key = [[[self keyHitTest:[recognizer locationInView:recognizer.view]] representedString] lowercaseString];
    //if ([key isEqualToString:@" "]){
    if (!dockView.dockx.hidden){
        kbImpl = [%c(UIKeyboardImpl) activeInstance];
        delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
        [kbImpl clearInputWithCandidatesCleared:YES];
        if ([self respondsToSelector:@selector(clearContinuousPathView)]){
            [self clearContinuousPathView];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollForward" object:nil];
    }
    //}
    //}else if (recognizer.state == UIGestureRecognizerStateEnded){
    //}
}

%new
- (void)rightSwipeHandle:(UISwipeGestureRecognizer*)recognizer
{
    //HBLogDebug(@"rightSwipeHandle");
    //if (recognizer.state == UIGestureRecognizerStateBegan) {
    //NSString *key = [[[self keyHitTest:[recognizer locationInView:recognizer.view]] representedString] lowercaseString];
    //if ([key isEqualToString:@" "]){
    if (!dockView.dockx.hidden){
        kbImpl = [%c(UIKeyboardImpl) activeInstance];
        delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
        [kbImpl clearInputWithCandidatesCleared:YES];
        if ([self respondsToSelector:@selector(clearContinuousPathView)]){
            [self clearContinuousPathView];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollBackward" object:nil];
    }
    //}
    //}else if (recognizer.state == UIGestureRecognizerStateEnded){
    //}
}

/*
 %new
 - (void)upSwipeHandle:(UISwipeGestureRecognizer*)recognizer
 {
 HBLogDebug(@"upSwipeHandle");
 //if (recognizer.state == UIGestureRecognizerStateBegan) {
 //NSString *key = [[[self keyHitTest:[recognizer locationInView:recognizer.view]] representedString] lowercaseString];
 //if ([key isEqualToString:@" "]){
 dockView.dockx.hidden = !dockView.dockx.hidden;
 
 //}
 //}else if (recognizer.state == UIGestureRecognizerStateEnded){
 //}
 }
 */


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (preferencesBool(kEnabledkey,YES) && (preferencesInt(kSwipeSpaceBarTogglekey,0) < 1)){
        prevTime = [NSDate date] ;
        UITouch *touch = [[touches allObjects] firstObject];
        startPosition = [touch locationInView:touch.view];
        key = [[[self keyHitTest:[touch locationInView:touch.view]] representedString] lowercaseString];
        //HBLogDebug(@"touchesBegan EVENT: %ld", event.type);
        //NSString *key = [[[self hitTest:[touch locationInView:touch.view] withEvent:event] representedString] lowercaseString];
        //if ([key isEqualToString:@" "]){
        // return;
        //}
    }
    %orig;
    
}

%new
-(direction)computeDirectionFromTouches {
    NSInteger xDisplacement = endPosition.x-startPosition.x;
    NSInteger yDisplacement = endPosition.y-startPosition.y;
    
    float angle = atan2(xDisplacement, yDisplacement);
    int octant = (int)(round(8 * angle / (2 * M_PI) + 8)) % 8;
    
    return (direction) octant;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    %orig;
    //HBLogDebug(@"isTrackPad: %d", [self isTrackpadMode]?1:0);
    if (preferencesBool(kEnabledkey,YES)){
        if ((preferencesInt(kSwipeSpaceBarTogglekey,0) < 1)){
            isTrackPadMode = [self isTrackpadMode];
            UITouch *touch =  [[touches allObjects] lastObject];
            endPosition = [touch locationInView:touch.view];
            int dragDirection = [self computeDirectionFromTouches];
            //HBLogDebug(@"Direction: %ld", [self computeDirectionFromTouches]);
            if ([key isEqualToString:@" "] && (dragDirection == 3 || dragDirection == 4 || dragDirection == 5)){
                isDraggedGesture = YES;
            }else if (dragDirection == 0 || dragDirection == 1 || dragDirection == 7){
                isPossibleDraggingForShootingStar = YES;
            }else{
                isPossibleDraggingForShootingStar = NO;
                isDraggedGesture = NO;
            }
        }
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event  {
    //HBLogDebug(@"touchesEnded count: %lu",touches.count);
    UITouch *touch = [[touches allObjects] firstObject];
    //UIView *endedKey = [self hitTest:[touch locationInView:touch.view] withEvent:event];
    //CGPoint pt =[dv convertPoint:[touch locationInView:self.window] fromView:self];
    // NSIndexPath *cidx = [dv.dockx indexPathForItemAtPoint:[touch locationInView:touch.window]];
    
    if (preferencesBool(kEnabledkey,YES) && (preferencesBool(kEnabledShootingStarkey, NO))  && !isTrackPadMode && isPossibleDraggingForShootingStar && !UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
        isPossibleDraggingForShootingStar = NO;
        //isDraggedGesture = NO;
        
        CGPoint p = [self.window convertPoint:[touch locationInView:touch.window] toView:dockV.dockx];
        NSIndexPath *idxPath = [dockV.dockx indexPathForItemAtPoint:p];
        if (idxPath){
            //HBLogDebug(@"..................INDEXPATH: %@", idxPath);
            DockXCell *cell = (DockXCell *)[dockV.dockx cellForItemAtIndexPath:idxPath];
            
            HBLogDebug(@"dockV.dockx: %@", dockV.dockx);
            HBLogDebug(@"cell.btn: %@", cell.btn);
            NSString *cellIdentifier;
            BOOL doubleTapEnabled = preferencesBool(kEnabledDoubleTapkey, NO);
            if (doubleTapEnabled){
                NSArray *gestures = cell.btn.gestureRecognizers;
                NSPredicate *resultPredicate = [NSPredicate
                                                predicateWithFormat:@"SELF.numberOfTapsRequired == %@",
                                                @1];
                NSArray *targetsForLongPressUsingGesture = [([[gestures filteredArrayUsingPredicate:resultPredicate] firstObject]) valueForKey:@"_targets"];
                for (id target in targetsForLongPressUsingGesture){
                    NSArray *actions = @[NSStringFromSelector([(UIGestureRecognizerTarget *)target action])];
                    for (NSString *action in actions) {
                        cellIdentifier = action;
                    }
                }
            }else{
                for (id target in cell.btn.allTargets){
                    NSArray *actions = [cell.btn actionsForTarget:target forControlEvent:UIControlEventTouchUpInside];
                    for (NSString *action in actions) {
                        cellIdentifier = action;
                    }
                }
            }
            
            
            HBLogDebug(@"cellIdentifier: %@", cellIdentifier);
            //[dockV.dockx shakeButton:cell.btn];
            kbImpl = [%c(UIKeyboardImpl) activeInstance];
            delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
            [kbImpl clearInputWithCandidatesCleared:YES];
            
            [dockV.dockx activateShootingStarActions:cell.btn];
            [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"shakeCell-%@", cellIdentifier] object:nil];
            
            if ([self respondsToSelector:@selector(clearContinuousPathView)]){
                [self clearContinuousPathView];
            }
            
            
            
            [self touchesCancelled:touches withEvent:event];
            isDraggedGesture = NO;
            return;
        }
        
        
    }
    
    if (preferencesBool(kEnabledkey,YES) && (preferencesInt(kSwipeSpaceBarTogglekey,0) < 1) && [key isEqualToString:@" "] && isDraggedGesture && [dockView respondsToSelector:@selector(barmoji)] && !isTrackPadMode){
        NSTimeInterval elapsedTime = -1.0 * [prevTime timeIntervalSinceNow];
        isDraggedGesture = NO;
        //if (startPosition.y > (endPosition.y + 15)){
        //if (dockView){
        //[dockView.dockx removeFromSuperview];
        //[dockView layoutSubviews];
        kbImpl = [%c(UIKeyboardImpl) activeInstance];
        delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
        [kbImpl clearInputWithCandidatesCleared:YES];
        
        if (elapsedTime > 0.2){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"toggleDockX" object:nil];
        }
        
        
        
        //[dockView.barmoji setNeedsLayout];
        //dockView.barmoji.layer.zPosition = 1;
        //[dockView.dockx removeFromSuperview];
        //[dockView.barmoji removeFromSuperview];
        //[dockView addSubview:dockView.barmoji];
        
        if ([self respondsToSelector:@selector(clearContinuousPathView)]){
            [self clearContinuousPathView];
        }
        [self touchesCancelled:touches withEvent:event];
        isPossibleDraggingForShootingStar = NO;
        return;
    }
    isDraggedGesture = NO;
    isPossibleDraggingForShootingStar = NO;
    %orig;
}

%end

%hook UIKeyboardMenuView
-(void)show{
    //HBLogDebug(@"UIKeyboardMenuView: %@", [self inputView ].currentImage.description);
    //if (preferencesBool(kEnabledkey,YES) && !(preferencesInt(kDedicatedGestureButtonkey, 0) < 1)){
    // return;
    //}
    if (preferencesBool(kEnabledkey,YES) && preferencesInt(kDockModekey, 0) < 3){
        if ((preferencesInt(kDedicatedGestureButtonkey, 0) == 1 || preferencesInt(kDedicatedGestureButtonkey, 0) == 3) && [[self inputView].currentImage.description containsString:@"globe"]){
            return;
        }
        if ((preferencesInt(kDedicatedGestureButtonkey, 0) == 2 || preferencesInt(kDedicatedGestureButtonkey, 0) == 3) && [[self inputView].currentImage.description containsString:@"mic"]){
            return;
        }
    }
    
    %orig;
}


%end


%hook UISystemKeyboardDockController

-(void)updateDockItemsVisibility{
    %orig;
    if (preferencesBool(kEnabledkey,YES)){
        self.dockView.dockx.hidden = self.dockView.centerDockItem ? !self.dockView.centerDockItem.view.hidden : NO;
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if (UIInterfaceOrientationIsLandscape(orientation)){
            self.dockView.dockx.hidden = YES;
        }
    }
}

%end

%end


static void updateAutoCorrection() {
    //HBLogDebug(@"received: %@", dockView.dockx);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateAutoCorrection" object:nil];
}

static void updateAutoCapitalization() {
    //HBLogDebug(@"received: %@", dockView.dockx);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateAutoCapitalization" object:nil];
}

static void reloadPrefs() {
    prefs = [[[PrefsManager sharedInstance] readPrefsFromSandbox:!isSpringBoard] mutableCopy];
    
    if (!firstInit){
        [[PrefsManager sharedInstance] removeKey:kCachekey fromSandbox:!isSpringBoard];
    }else{
        if (isSpringBoard){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                ShortcutsGenerator *shortcutsGenerator = [ShortcutsGenerator sharedInstance];
                HBLogDebug(@"cache: %d ** actual: %d", ([prefs[kCachekey][@"copyLogDylibExist"] intValue] + [prefs[kCachekey][@"translomaticDylibExist"] intValue] + [prefs[kCachekey][@"wasabiDylibExist"] intValue] + [prefs[kCachekey][@"pasitheaDylibExist"] intValue]), ([@(shortcutsGenerator.copyLogDylibExist) intValue] + [@(shortcutsGenerator.translomaticDylibExist) intValue] + [@(shortcutsGenerator.wasabiDylibExist) intValue] + [@(shortcutsGenerator.pasitheaDylibExist) intValue]));
                if (prefs[kCachekey] && (([prefs[kCachekey][@"copyLogDylibExist"] intValue] + [prefs[kCachekey][@"translomaticDylibExist"] intValue] + [prefs[kCachekey][@"wasabiDylibExist"] intValue] + [prefs[kCachekey][@"pasitheaDylibExist"] intValue]) != ([@(shortcutsGenerator.copyLogDylibExist) intValue] + [@(shortcutsGenerator.translomaticDylibExist) intValue] + [@(shortcutsGenerator.wasabiDylibExist) intValue] + [@(shortcutsGenerator.pasitheaDylibExist) intValue]))){
                    [[PrefsManager sharedInstance] removeKey:kCachekey fromSandbox:!isSpringBoard];
                    HBLogDebug(@"cache deleted");
                }
            });
        }
        firstInit = NO;
    }
    toastTintColor = toastImageTintColor;
    toastBackgroundTintColor = toastBackgroundColor;
    
    
    
    //prefs = [[[PrefsManager sharedInstance] readPrefs] mutableCopy];
    
    //isSandboxed = ![NSHomeDirectory() isEqualToString:@"/var/mobile"];
    //CFPreferencesAppSynchronize((CFStringRef)kIdentifier);
    
    /*
     if ([NSHomeDirectory() isEqualToString:@"/var/mobile"]) {
     isSandboxed = NO;
     prefs = [[[PrefsManager sharedInstance] readPrefs] mutableCopy];
     } else {
     isSandboxed = YES;
     CPDistributedMessagingCenter *c = [CPDistributedMessagingCenter centerNamed:@"com.udevs.dockx.server"];
     rocketbootstrap_distributedmessagingcenter_apply(c);
     prefs = [[c sendMessageAndReceiveReplyName:@"dockXFetchPrefs" userInfo:nil] mutableCopy];
     
     }
     */
    //prefs = [NSMutableDictionary dictionary];
    //[prefs addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:kPrefsPath]];
    
    
    //HBLogDebug(@"reloadPrefs: %@", prefs);
    //HBLogDebug(@"kShortcutsPerSection: %@", prefs[kShortcutsPerSection]);
    currentBackgroundTintColor = nil;
    //currentTintColor = nil;
    if (preferencesBool(kColorEnabledkey,NO)){
        
        if (preferencesBool(kShortcutsTintEnabled,YES)) currentTintColor = [SparkColourPickerUtils colourWithString:prefs[@"shortcutstint"]  withFallback:@"#ff0000"];
        if (preferencesBool(kToastTintEnabled,YES)) toastTintColor = [SparkColourPickerUtils colourWithString:prefs[@"toasttint"]  withFallback:@"#ff0000"];
        if (preferencesBool(kToastBackgroundTintEnabled,YES)) toastBackgroundTintColor = [SparkColourPickerUtils colourWithString:prefs[@"toastbackgroundtint"]  withFallback:@"#000000"];
        if (preferencesBool(kToastBackgroundTintEnabled,YES)) toastBackgroundTintColor = [SparkColourPickerUtils colourWithString:prefs[@"shortcutsbackgroundtint"]  withFallback:@"#5B5B5B"];
    }
    
    toggledOn = preferencesBool(kToggledOnkey,YES);
    singleTapGlobeEnabled = (((preferencesInt(kDockModekey, 0) == 0 || preferencesInt(kDockModekey, 0) == 2)) && (preferencesInt(kDedicatedGestureButtonkey,0) == 1 || preferencesInt(kDedicatedGestureButtonkey,0) == 3) && (preferencesInt(kGestureTypekey,0) == 0)) ? YES : NO;
    singleTapDictationEnabled = (((preferencesInt(kDockModekey, 0) == 0 || preferencesInt(kDockModekey, 0) == 1)) && (preferencesInt(kDedicatedGestureButtonkey,0) == 2 || preferencesInt(kDedicatedGestureButtonkey,0) == 3) && (preferencesInt(kGestureTypekey,0) == 0)) ? YES : NO;
    
    useShortenedLabel = preferencesBool(kShortLabelEnabledKey, NO);
    
    
    topInset = preferencesFloat(kTopInsetkey, topInsetDefault);
    bottomInset = preferencesFloat(kBottomInsetkey, bottomInsetDefault);
    leftInset = preferencesFloat(kLeftInsetkey, leftInsetDefault);
    rightInset = preferencesFloat(kRightInsetkey, rightInsetDefault);
    
    leadingOffset = preferencesFloat(kLeadinfOffsetkey,leadingOffsetDefault);
    leadingOffset = currentBackgroundTintColor ? leadingOffset-9.0f : leadingOffset;
    trailingOffset = preferencesFloat(kTrailingOffsetkey, trailingOffsetDefault);
    heightOffset = preferencesFloat(kHeightOffsetkey, heightOffsetDefault);
    bottomOffset = preferencesFloat(kBottomOffsetkey, bottomOffsetDefault);
    
    buttonHeight = preferencesFloat(kCellHeightkey, currentBackgroundTintColor?cellsHeightDefault+5:cellsHeightDefault);
    buttonRadius = preferencesFloat(kCellRadiuskey, currentBackgroundTintColor?cellsRadiusDefault+10:cellsRadiusDefault);
    buttonSpacing = preferencesFloat(kCellSpacingkey, spacingBetweenCellsDefault);
    
    //attemptOneHandedOffsetAdjust = preferencesBool(kAttemptOffsetAutoAdjustInOneHandedkey, YES);
    
    isPagingEnabled =  preferencesBool(kPagingkey, YES);
    shouldPerformBatchUpdate = NO;
    /*
     if (dockView){
     [UIView performWithoutAnimation:^{
     [dockView.dockx performBatchUpdates:^{
     [dockView.dockx reloadData];
     [dockView.dockx.collectionViewLayout invalidateLayout];
     } completion:^(BOOL finished) {}];
     
     }];
     }
     */
    /*
     if (dockV){
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     [[PrefsManager sharedInstance] setValue:[NSKeyedArchiver archivedDataWithRootObject:dockV.dockx] forKey:@"prevState" fromSandbox:!isSpringBoard];
     });
     }
     */
    
    
}

%ctor {
    
    @autoreleasepool {
        // check if process is springboard or an application
        // this prevents our tweak from running in non-application (with UI)
        // processes and also prevents bad behaving tweaks to invoke our tweak
        
        NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
        
        if (args.count != 0) {
            NSString *executablePath = args[0];
            HBLogDebug(@"executablePath: %@", executablePath);
            if (executablePath) {
                NSString *processName = [executablePath lastPathComponent];
                //HBLogDebug(@"INIT: %@", processName);
                isSpringBoard = [processName isEqualToString:@"SpringBoard"];
                isApplication = [executablePath rangeOfString:@"/Application"].location != NSNotFound;
                isApplication = [processName isEqualToString:@"MarkupPhotoExtension"] ?: isApplication;
                isSafari = [processName isEqualToString:@"MobileSafari"];
                
                if (isSpringBoard || isApplication) {
                    tweakBundle = [NSBundle bundleWithPath:bundlePath];
                    [tweakBundle load];
                    firstInit = YES;
                    reloadPrefs();
                    shouldUpdateTrueKBType = YES;
                    shouldPerformBatchUpdate = YES;
                    %init(DockX);
                    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadPrefs, (CFStringRef)kPrefsChangedIdentifier, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
                    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updateAutoCorrection, (CFStringRef)kAutoCorrectionChangedIdentifier, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
                    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updateAutoCapitalization, (CFStringRef)kAutoCapitalizationChangedIdentifier, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
                }
                
            }
        }
    }
}
