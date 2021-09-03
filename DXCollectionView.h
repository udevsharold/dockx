#import "DXCell.h"
#import "DXShortcutsGenerator.h"
#import <RocketBootstrap/rocketbootstrap.h>

typedef NS_ENUM(NSInteger, direction) {
    Down = 0, DownRight = 1,
    Right = 2, UpRight = 3,
    Up = 4, UpLeft = 5,
    Left = 6, DownLeft = 7
};

@interface DXCollectionView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) NSArray *shortcuts;
@property (strong, nonatomic) NSArray *fullshortcuts;
@property (strong, nonatomic) NSArray *kbType;
@property (strong, nonatomic) NSArray *kbTypeLabel;
@property (nonatomic, assign) NSInteger hapticType;
@property (nonatomic, assign) NSInteger trueKBType;
@property (nonatomic, assign) BOOL isSameProcess;
@property (strong, nonatomic) DXCell *autoCorrectionCell;
@property (strong, nonatomic) DXCell *autoCapitalizationCell;
@property (strong, nonatomic) DXCell *loupeCell;
//@property (strong, nonatomic) UIButton *keyboardInputTypeButton;
@property (strong, nonatomic) __block DXCell *keyboardInputTypeCell;

@property (nonatomic, assign) BOOL refreshView;
@property (nonatomic, assign) BOOL firstCellVisible;
@property (nonatomic, assign) BOOL firstInit;
@property (nonatomic, assign) BOOL autoCorrectionEnabled;
@property (nonatomic, assign) BOOL autoCapitalizationEnabled;
@property (nonatomic, assign) BOOL loupeEnabled;
@property (nonatomic, strong) dispatch_block_t retestDispatchBlock;
@property (nonatomic, strong) dispatch_block_t autoPaginationDispatchBlock;
@property (nonatomic, assign) NSTimer *cursorTimer;
@property (nonatomic, assign) NSTimer *cursorTimerRetest;
@property (nonatomic, assign) NSInteger cursorMovingFactor;
@property (nonatomic, assign) float cursorTimerSpeed;
@property (nonatomic, assign) float t;
@property (strong, nonatomic) NSArray *indexArray;
@property (strong, nonatomic) NSArray *sectionOffsetForwardArray;
@property (strong, nonatomic) NSArray *sectionOffsetBackwardArray;
@property (strong, nonatomic) CPDistributedMessagingCenter *dockxCenter;
@property (strong, nonatomic) CPDistributedMessagingCenter *toastCenter;
@property (strong, nonatomic) NSString *commandTitle;
@property (nonatomic, assign) NSInteger insertTextActionType;

@property (nonatomic, assign) BOOL moveCursorWithSelect;
@property (nonatomic, assign) BOOL isWordSender;
@property (nonatomic, assign) BOOL asyncUpdated;
@property (nonatomic, strong) NSIndexPath *keyboardInputTypeCellIndexPath;
@property (strong, nonatomic) NSArray *keyboardTypeDataFull;
@property (strong, nonatomic) NSArray *keyboardTypeLabelFull;
@property (strong, nonatomic) DXShortcutsGenerator *shortcutsGenerator;

-(void)shakeButton:(UIButton *)sender;
-(void)shakeView:(UIView *)sender;
-(IBAction)selectAllAction:(UIButton*)sender;
-(IBAction)copyAction:(UIButton*)sender;
-(IBAction)pasteAction:(UIButton*)sender;
-(IBAction)cutAction:(UIButton*)sender;
-(IBAction)undoAction:(UIButton*)sender;
-(IBAction)redoAction:(UIButton*)sender;
-(IBAction)selectAction:(UIButton*)sender;
-(IBAction)beginningAction:(UIButton*)sender;
-(IBAction)endingAction:(UIButton*)sender;
-(IBAction)capitalizeAction:(UIButton*)sender;
-(IBAction)lowercaseAction:(UIButton*)sender;
-(IBAction)uppercaseAction:(UIButton*)sender;
-(IBAction)deleteAction:(UIButton*)sender;
-(IBAction)deleteAllAction:(UIButton*)sender;
-(IBAction)boldAction:(UIButton*)sender;
-(IBAction)italicAction:(UIButton*)sender;
-(IBAction)underlineAction:(UIButton*)sender;
-(IBAction)dismissKeyboardAction:(UIButton*)sender;
-(void)moveCursorLeftAction:(UIButton*)sender;
-(void)moveCursorRightAction:(UIButton*)sender;
-(void)moveCursorUpAction:(UIButton*)sender;
-(void)moveCursorDownAction:(UIButton*)sender;
-(void)keyboardTypeAction:(UIButton*)sender;
-(void)defineAction:(UIButton*)sender;
-(void)runCommandAction:(UIButton*)sender;
-(void)insertTextAction:(UIButton*)sender;

-(void)selectLineAction:(UIButton*)sender;
-(void)selectParagraphAction:(UIButton*)sender;
-(void)selectSentenceAction:(UIButton*)sender;
-(void)moveCursorPreviousWordAction:(UIButton*)sender;
-(void)moveCursorNextWordAction:(UIButton*)sender;
-(void)moveCursorStartOfLineAction:(UIButton*)sender;
-(void)moveCursorEndOfLineAction:(UIButton*)sender;
-(void)moveCursorStartOfParagraphAction:(UIButton*)sender;
-(void)moveCursorEndOfParagraphAction:(UIButton*)sender;
-(void)moveCursorStartOfSentenceAction:(UIButton*)sender;
-(void)moveCursorEndOfSentenceAction:(UIButton*)sender;
-(void)copyLogAction:(UIButton*)sender;
-(void)translomaticAction:(UIButton *)sender;
-(void)wasabiAction:(UIButton *)sender;
-(void)pasitheaAction:(UIButton*)sender;
-(void)globeAction:(UIButton*)sender;
-(void)dictationAction:(UIButton*)sender;
-(void)deleteForwardAction:(UIButton*)sender;

-(void)selectAllActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)copyActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)pasteActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)cutActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)undoActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)redoActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)selectActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)beginningActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)endingActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)capitalizeActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)lowercaseActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)uppercaseActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)deleteActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)boldActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)italicActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)underlineActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)dismissKeyboardActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)moveCursorLeftActionLP:(UILongPressGestureRecognizer*)recognizer;
-(void)moveCursorRightActionLP:(UILongPressGestureRecognizer*)recognizer;
-(void)moveCursorUpActionLP:(UILongPressGestureRecognizer*)recognizer;
-(void)moveCursorDownActionLP:(UILongPressGestureRecognizer*)recognizer;
-(void)keyboardTypeActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)defineActionLP:(UILongPressGestureRecognizer*)recognizer;
-(void)runCommandActionLP:(UILongPressGestureRecognizer*)recognizer;
-(void)insertTextActionLP:(UILongPressGestureRecognizer*)recognizer;

-(void)selectLineActionLP:(UILongPressGestureRecognizer*)recognizer;
-(void)selectParagraphActionLP:(UILongPressGestureRecognizer*)recognizer;
-(void)selectSentenceActionLP:(UILongPressGestureRecognizer*)recognizer;
-(void)moveCursorPreviousWordActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)moveCursorNextWordActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)moveCursorStartOfLineActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)moveCursorEndOfLineActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)moveCursorStartOfParagraphActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)moveCursorEndOfParagraphActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)moveCursorStartOfSentenceActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)moveCursorEndOfSentenceActionLP:(UILongPressGestureRecognizer *)recognizer;
-(UIWindow*)keyWindow;
-(void)copyLogActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)translomaticActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)wasabiActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)pasitheaActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)activateLPActions:(UIGestureRecognizer *)recognizer;
-(void)globeActionLP:(UILongPressGestureRecognizer*)recognizer;
-(void)deleteForwardActionLP:(UILongPressGestureRecognizer *)recognizer;

-(void)moveCursorContinuoslyWithDelegate:(id <UITextInput, UITextInputTokenizer>)delegate offset:(int)offset;
-(NSString *)convertColorToString:(UIColor *)colorname;
-(NSString *)getImageNameForActionName:(NSString *)actionname;
-(void)sendShowToastRequestWithMessage:(NSString *)message imagePath:(NSString *)imagepath imageTint:(UIColor *)imagetint width:(int)width height:(int)height position:(float)position duration:(double)duration alpha:(float)alpha radius:(float)radius textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor displayType:(int)displayType;
-(void)triggerImpactAndAnimationWithButton:(UIButton *)sender selectorName:(NSString *)selname toastWidthOffset:(int)woffset toastHeightOffset:(int)hoffset;
-(NSArray *)synthesizeIndexingForIndexOrOffset:(BOOL)offset descendingOffset:(BOOL)reverse numberOfItems:(int)itemsCount;
- (NSInteger)currentCursorPosition:(id <UITextInput, UITextInputTokenizer>)delegate;
-(void)moveCursorWithDelegate:(id <UITextInput, UITextInputTokenizer>)delegate offset:(int)offset;
-(void)moveCursorVerticalWithDelegate:(id<UITextInput>)delegate direction:(UITextLayoutDirection)direction;
-(BOOL)isRTLForDelegate:(id <UITextInput, UITextInputTokenizer>)delegate;
-(UITextRange *)selectedWordTextRangeWithDelegate:(id<UITextInput>)delegate;
-(UITextRange *)selectedWordTextRangeWithDelegate:(id<UITextInput>)delegate direction:(UITextStorageDirection)direction;
-(UITextRange *)autoDirectionWordSelectedTextRangeWithDelegate:(id<UITextInput> )delegate;

-(UITextRange *)singleWordTextRangeWithDelegate:(id<UITextInput>)delegate direction:(UITextStorageDirection)direction;
-(UITextRange *)lineExtremityTextRangeWithDelegate:(id<UITextInput>)delegate direction:(UITextLayoutDirection)direction;
-(void)moveCursorSingleWordWithDelegate:(id <UITextInput, UITextInputTokenizer>)delegate direction:(UITextStorageDirection)direction;
-(void)moveCursorToLineExtremityWithDelegate:(id <UITextInput, UITextInputTokenizer>)delegate direction:(UITextLayoutDirection)direction;

-(CPDistributedMessagingCenter *)IPCCenterNamed:(NSString *)centerName;
-(BOOL)isAutoCorrectionEnabled;
-(void)setAutoCorrection:(BOOL)enabled;
-(void)updateAutoCorrection:(NSNotification*)notification;
-(BOOL)isAutoCapitalizationEnabled;
-(void)setAutoCapitalization:(BOOL)enabled;
-(void)updateAutoCapitalization:(NSNotification*)notification;
-(NSDictionary *)getItemWithID:(NSString *)snippetID forKey:(NSString *)keyName identifierKey:(NSString *)identifier;
-(void)runCommand:(NSString *)cmd;
-(BOOL)isValidURL:(NSString *)urlString;

- (void)activateShootingStarActions:(UIButton *)sender;
@end
