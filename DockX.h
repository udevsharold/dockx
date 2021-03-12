#import <RocketBootstrap/rocketbootstrap.h>
#include "DockXCollectionView.h"
#include "TextOperation.h"

#ifdef __cplusplus
extern "C" {
#endif

void showCopypastaWithNotification() __attribute__((weak));

#ifdef __cplusplus
}
#endif

@interface UIKeyboardImpl : UIView
+ (UIKeyboardImpl*)activeInstance;
+(BOOL)isFloating;
- (BOOL)isLongPress;
- (void)handleDelete;
- (void)insertText:(id)text;
- (void)clearAnimations;
- (void)clearTransientState;
- (void)setCaretBlinks:(BOOL)arg1;
- (void)deleteFromInput;
- (void)dismissKeyboard;
-(void)pasteOperation;
-(void)cutOperation;
-(void)copyOperation;
-(void)deleteFromInput;
-(BOOL)caretVisible;
-(BOOL)caretBlinks;
-(BOOL)isUsingDictationLayout;
-(void)clearSelection;
-(void)flushDelayedTasks;
-(void)dismissKeyboard;
-(void)deleteBackward;
-(BOOL)isTrackpadMode;
-(id)delegateAsResponder;
-(void)clearInputWithCandidatesCleared:(BOOL)arg1 ;
-(void)setShowsCandidateBar:(BOOL)arg1 ;
-(void)setDisableSmartInsertDelete:(BOOL)arg1 ;
-(void)deleteBackwardAndNotify:(BOOL)arg1 ;
-(BOOL)deleteForwardAndNotify:(BOOL)arg1 ;
@property (readonly, assign, nonatomic) UIResponder <UITextInputPrivate> *privateInputDelegate;
@property (readonly, assign, nonatomic) UIResponder <UITextInput> *inputDelegate;
@property (nonatomic,readonly) UIResponder <UITextInput> *selectableInputDelegate;
@end

@interface UIKBRenderConfig : NSObject
+(id)configForAppearance:(long long)arg1 inputMode:(id)arg2 ;
+(id)darkConfig;
+(id)defaultConfig;
+(id)defaultEmojiConfig;
+(id)lowQualityDarkConfig;
@property (assign,nonatomic) BOOL lightKeyboard;
@end

@interface UIKeyboardDockItemButton : UIButton
@property(nonatomic, strong) UIColor *tintColor;
@end

@interface UIKeyboardDockItem : NSObject
@property (nonatomic,retain) UIKeyboardDockItemButton * button;
@property (nonatomic,readonly) UIKeyboardDockItemButton * view;
@property (nonatomic,retain) UILongPressGestureRecognizer * longPressGestureRecognizer;
@end

@interface BarmojiCollectionView : UICollectionView
- (instancetype)initForPredictiveBar:(BOOL)forPredictive;
@end

@interface UIKeyboardDockView : UIView
@property (nonatomic,retain) UIKeyboardDockItem * leftDockItem;
@property (nonatomic,retain) UIKeyboardDockItem * rightDockItem;
@property (nonatomic,retain) UIKeyboardDockItem * centerDockItem;
//@property (retain, nonatomic) UIKeyboardDockItemButton *leftDockButton;
//@property (retain, nonatomic) UIKeyboardDockItemButton *rightDockButton;
@property (nonatomic, retain) DockXCollectionView *dockx;
@property (retain, nonatomic) BarmojiCollectionView *barmoji;

-(void)shouldUpdateLayoutWithDelay:(float)delay;
- (id)_keyboardLayoutView;
-(void)handBiasChanged;
-(void)toggleDockX:(NSNotification*)notification;
-(void)_dockItemButtonWasTapped:(id)arg1 withEvent:(id)arg2;
-(void)updateDockXTint;
@end


@interface UISystemKeyboardDockController : UIViewController{
    UIKeyboardDockItem* _globeDockItem;
    UIKeyboardDockItem* _dictationDockItem;
    UIKeyboardDockItem* _keyboardDockItem;
}
@property (nonatomic,retain) UIKeyboardDockView * dockView;
-(void)dictationItemButtonWasPressed:(id)arg1 withEvent:(id)arg2 ;
-(void)globeItemButtonWasPressed:(id)arg1 withEvent:(id)arg2 ;
@end

@interface UIDictationController : NSObject
-(void)switchToDictationInputMode;
-(void)switchToDictationInputModeWithTouch:(id)arg1 ;
-(void)cancelDictation;
-(void)switchToDictationInputModeWithTouch:(id)arg1 withKeyboardInputMode:(id)arg2 ;
-(void)setDictationInputMode:(id)arg1 ;
-(void)stopDictation:(BOOL)arg1;
@end

@interface _UITextKitTextRange : NSObject
+(id)rangeWithRange:(NSRange)arg1 ;
+(id)rangeWithRange:(NSRange)arg1 affinity:(long long)arg2 ;
+(id)rangeWithStart:(id)arg1 end:(id)arg2 ;
+(id)defaultRange;
-(id)init;
-(BOOL)isEmpty;
@end

@interface UITextField (DockX)
@property (nonatomic,copy) NSString * text;
-(void)setAttributes:(id)arg1 range:(NSRange)arg2 ;
@end

@interface UIKBShape : NSObject
@end

@interface UIKBKey : UIKBShape
@property(copy) NSString * representedString;
@end

@interface UIKBTree : NSObject
-(NSString *)name;
@end

@interface UIKeyboardMenuView : UIView
@property (assign,nonatomic) UIKBTree * referenceKey;
@property (assign,nonatomic) long long mode;
-(UIKeyboardDockItemButton *)inputView;
@end

@interface MKInfoCardThemeManager : NSObject
@property (assign,nonatomic) BOOL useSmallFont;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (copy,readonly) NSString * description;
@property (copy,readonly) NSString * debugDescription;
@property (nonatomic,readonly) unsigned long long themeType;
@property (nonatomic,readonly) NSString * javaScriptName;
@property (nonatomic,readonly) BOOL isDarkTheme;
@property (nonatomic,readonly) UIColor * textColor;
@property (nonatomic,readonly) UIColor * lightTextColor;
@property (nonatomic,readonly) UIColor * tertiaryTextColor;
@property (nonatomic,readonly) UIColor * tintColor;
@property (nonatomic,readonly) UIColor * highlightedTintColor;
@property (nonatomic,readonly) UIColor * separatorLineColor;
@property (nonatomic,readonly) UIColor * rowColor;
@property (nonatomic,readonly) UIColor * selectedRowColor;
@property (nonatomic,readonly) UIColor * highlightedActionRowTextColor;
@property (nonatomic,readonly) UIColor * disabledActionRowTextColor;
@property (nonatomic,readonly) UIColor * disabledActionRowBackgroundColor;
@property (nonatomic,readonly) UIColor * normalActionRowBackgroundColor;
@property (nonatomic,readonly) UIColor * normalActionRowBackgroundPressedColor;
@property (nonatomic,readonly) UIColor * headerPrimaryButtonNormalColor;
@property (nonatomic,readonly) UIColor * headerPrimaryButtonHighlightedColor;
@property (nonatomic,readonly) UIColor * transitOntimeTextColor;
@property (nonatomic,readonly) UIColor * transitDelayedTextColor;
@property (nonatomic,readonly) UIColor * transitChevronBackgroundColor;
@property (nonatomic,readonly) UIColor * normalBackgroundColor;
@property (nonatomic,readonly) UIColor * buttonNormalColor;
@property (nonatomic,readonly) UIColor * buttonHighlightedColor;
@end

@interface UIKeyboardLayoutStar : UIView{
        BOOL _isContinuousPathUnderway;
}
@property (nonatomic,readonly) NSString * localizedInputMode;
-(MKInfoCardThemeManager *)mk_theme;
-(UIKBKey *)keyHitTest:(CGPoint)arg1 ;
-(UIView *)hitTest:(CGPoint)arg1 withEvent:(id)arg2 ;
-(double)lastTouchDownTimestamp;
-(void)touchDownWithKey:(id)arg1 atPoint:(CGPoint)arg2 executionContext:(id)arg3 ;
-(void)touchUp:(id)arg1 executionContext:(id)arg2 ;
-(void)touchDragged:(id)arg1 ;
-(void)touchUp:(id)arg1 executionContext:(id)arg2 ;
- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)swipeDetected:(id)arg1 ;
-(direction)computeDirectionFromTouches;
-(BOOL)isTrackpadMode;
-(BOOL)isHandwritingPlane;
-(void)_didChangeKeyplaneWithContext:(id)arg1 ;
-(void)updateKeyboardForKeyplane:(id)arg1 ;
-(void)clearContinuousPathView;
-(void)clearUnusedObjects:(BOOL)arg1 ;
-(void)touchCancelled:(id)arg1 executionContext:(id)arg2 ;
-(void)didEndIndirectSelectionGesture;
-(void)clearAllTouchInfo;
-(id)infoForTouch:(id)arg1 ;
-(id)simulateTouch:(CGPoint)arg1 ;
-(void)finishContinuousPathView;
-(id)candidateList;
-(void)clearTransientState;
-(void)didClearInput;
-(void)clearKeyAnnotationsIfNecessary;
-(void)setDisableInteraction:(BOOL)arg1 ;
-(void)deactivateActiveKeys;
-(void)deactivateActiveKeysClearingTouchInfo:(BOOL)arg1 clearingDimming:(BOOL)arg2 ;
-(void)uninstallGestureRecognizers;
-(void)reloadCurrentKeyplane;
-(void)multitapInterrupted;
-(void)refreshDualStringKeys;
-(void)refreshGhostKeyState;
-(void)finishSliderBehaviorFeedback;
-(void)didBeginContinuousPath;
-(BOOL)hasActiveContinuousPathInput;
-(BOOL)supportsContinuousPath;
-(void)_transitionToContinuousPathState:(long long)arg1 forTouchInfo:(id)arg2 ;
-(void)transitionToModalContinuousPathKeyplane;
-(void)cleanupPreviousKeyboardWithNewInputTraits:(id)arg1 ;
-(void)addContinuousPathPoint:(CGPoint)arg1 withTimestamp:(double)arg2 ;
-(void)showMenu:(id)arg1 forKey:(id)arg2 ;
@end


@interface UIControlTargetAction : NSObject {

    id _target;
    SEL _action;
    unsigned long long _eventMask;
    BOOL _cancelled;
}
@property (assign,nonatomic) BOOL cancelled;              //@synthesize cancelled=_cancelled - In the implementation block
-(BOOL)cancelled;
-(void)setCancelled:(BOOL)arg1 ;
@end

@interface UIInputSwitcher : NSObject
+(id)sharedInstance;
+(id)activeInstance;
@end


@interface PSRootController : UIViewController
- (instancetype)initWithTitle:(NSString *)title identifier:(NSString *)identifier;
@end

@interface PSListController : UIViewController
- (instancetype)initForContentSize:(CGSize)contentSize;
@property (nonatomic, retain) PSRootController *rootController;
@property (nonatomic, retain) UIViewController *parentController;
@end

typedef enum PSCellType {
    PSGroupCell,
    PSLinkCell,
    PSLinkListCell,
    PSListItemCell,
    PSTitleValueCell,
    PSSliderCell,
    PSSwitchCell,
    PSStaticTextCell,
    PSEditTextCell,
    PSSegmentCell,
    PSGiantIconCell,
    PSGiantCell,
    PSSecureEditTextCell,
    PSButtonCell,
    PSEditTextViewCell,
} PSCellType;

@interface PSSpecifier : NSObject
@property (nonatomic, retain) NSString *identifier;
+ (instancetype)preferenceSpecifierNamed:(NSString *)name target:(id)target set:(SEL)setter get:(SEL)getter detail:(Class)detailClass cell:(PSCellType)cellType edit:(Class)editClass;
@end

@interface KeyboardController : PSListController
-(id)init;
-(id)specifierByName:(id)arg1 ;
-(NSArray *)loadAllKeyboardPreferences;
-(void)setKeyboardPreferenceValue:(id)arg1 forSpecifier:(id)arg2 ;
@end

@interface WKContentView : NSObject
-(void)executeEditCommandWithCallback:(id)arg1;
-(void)_defineForWebView:(id)arg1 ;
-(void)_showDictionary:(id)arg1 ;
-(void)selectWordBackward;
-(void)_define:(id)arg1 ;
-(void)_selectionChanged;
-(void)_updateChangedSelection:(BOOL)arg1 ;
-(id)selectedText;
-(void)select:(id)arg1 ;
-(id)_moveToStartOfWord:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToEndOfWord:(BOOL)arg1 withHistory:(id)arg2 ;
-(void)moveBackward:(unsigned)arg1 ;
-(id)_moveLeft:(BOOL)arg1 withHistory:(id)arg2 ;
-(void)moveForward:(unsigned)arg1 ;
-(id)_moveRight:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveDown:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveUp:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToStartOfLine:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToEndOfLine:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToStartOfParagraph:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToEndOfParagraph:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToStartOfDocument:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToEndOfDocument:(BOOL)arg1 withHistory:(id)arg2 ;
- (void)clearSelection;
-(void)setSelectedTextRange:(UITextRange *)arg1 ;
- (void)endSelectionChange;
- (void)beginSelectionChange;
@end

@protocol UnifiedFieldDelegate <UITextFieldDelegate>
@required
-(void)unifiedFieldShouldPasteAndNavigate:(id)arg1;
-(void)unifiedField:(id)arg1 didEndEditingWithParsecTopHit:(id)arg2;
-(void)unifiedField:(id)arg1 didEndEditingWithAddress:(id)arg2;
-(void)unifiedField:(id)arg1 didEndEditingWithSearch:(id)arg2;
-(char)unifiedField:(id)arg1 shouldWaitForTopHitForText:(id)arg2;
-(id)unifiedField:(id)arg1 topHitForText:(id)arg2;
-(void)unifiedFieldReflectedItemDidChange:(id)arg1;
-(void)unifiedField:(id)arg1 registerKeyCommandsUsingBlock:(/*^block*/id)arg2;
-(char)unifiedField:(id)arg1 canPerformAction:(SEL)arg2 withSender:(id)arg3;

@end

@interface UnifiedField : UITextField
@property (assign,nonatomic) id<UnifiedFieldDelegate> delegate;
@end

@interface TLCHelper : NSObject
+(void)fetchTranslation:(NSString *)text vc:(UIViewController *)vc;
@end

@interface UIKeyboardInputMode : UITextInputMode
-(NSString *)identifier;
-(NSString *)normalizedIdentifier;
@end

@interface UIKeyboardInputModeController : NSObject
@property (retain) UIKeyboardInputMode * currentInputMode;
@property (retain) NSArray * keyboardInputModes;
+(id)sharedInputModeController;
-(id)activeInputModes;
-(void)setCurrentInputMode:(UIKeyboardInputMode *)arg1;

@end


@interface WKWebView : UIWebView
-(void)evaluateJavaScript:(id)arg1 completionHandler:(/*^block*/id)arg2;
@end

@interface UIGestureRecognizerTarget : NSObject
-(SEL)action;
@end

@interface NSString (AttributedStringCreation)
   - (NSMutableAttributedString *)attributedString;
@end

@implementation NSString (AttributedStringCreation)
- (NSMutableAttributedString *)attributedString {
   return [[NSMutableAttributedString alloc] initWithString:self];
}
@end


