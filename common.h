#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include <HBLog.h>

#import "PrefsManager.h"

#define bundlePath @"/Library/PreferenceBundles/DockXPrefs.bundle"
//#define dockxBundlePath @"/Library/Application Support/DockX.bundle"
#define LOCALIZED(str) [tweakBundle localizedStringForKey:str value:@"" table:nil]

#define kIdentifier @"com.udevs.dockx"
#define kIPCCenterPrefsManager @"com.udevs.dockx.prefsmanager"
#define kIPCCenterToast @"com.udevs.dockx.toast"
#define kIPCCenterDockX @"com.udevs.dockx"
#define kPrefsChangedIdentifier @"com.udevs.dockx/prefschanged"
#define kAutoCorrectionChangedIdentifier @"com.udevs.dockx/autocorrectionchanged"
#define kAutoCapitalizationChangedIdentifier @"com.udevs.dockx/autocapitalizationchanged"
#define kLoupeChangedIdentifier @"com.udevs.dockx/loupechanged"
#define kPrefsPath @"/var/mobile/Library/Preferences/com.udevs.dockx.plist"

#define kCopyLogOpenVewIdentifier @"me.tomt000.copylog.showView"
#define kPasitheaOpenVewIdentifier @"com.ichitaso.pasithea-showmenu"

#define kEnabledkey @"enabledBOOL"
#define kEnabledHaptickey @"hapticBOOL"
#define kShakeShortcutkey @"shakeBOOL"
#define kToastkey @"toastBOOL"
#define kToastPy @"toastpy"
#define kShortcutskey @"shortcuts"
#define kToastDurationkey @"toastduration"
#define kColorEnabledkey @"colorBOOL"
#define kSpaceBarScrollingBOOL @"enabledSpaceBarScrollingBOOL"
#define kGranularity @"granularityvalue"
#define kShortcutsPerSection @"shortcutsnum"
#define kToggledOnkey @"toggledOnBOOL"
#define kDockModekey @"dockmode"
#define kDisplayTypekey @"displaytype"
#define kDedicatedGestureButtonkey @"gesturebutton"
#define kGestureTypekey @"gesturetype"
#define kSwipeSpaceBarTogglekey @"swipetoggle"
#define kCustomActionskey @"customactions"
#define kPagingkey @"pagingBOOL"
#define kShortcutsTintEnabled @"shortcutstintBOOL"
#define kShortcutsBackgroundTintEnabled @"shortcutsbackgroundtintBOOL"
#define kToastTintEnabled @"toasttintBOOL"
#define kToastBackgroundTintEnabled @"toastbackgroundtintBOOL"
#define kKeyboardTypekey @"keyboardtype"
#define kPasteAndGoEnabledkey @"pasteandgo"
#define kCustomActionsDTkey @"customactionsdt"
#define kCustomActionsSTkey @"customactionsst"
#define kEnabledDoubleTapkey @"doubletapBOOL"
#define kEnabledShootingStarkey @"shootingstarBOOL"
#define kTopInsetkey @"topinset"
#define kBottomInsetkey @"bottominset"
#define kLeftInsetkey @"leftinset"
#define kRightInsetkey @"rightinset"
#define kLeadinfOffsetkey @"leadingoffset"
#define kTrailingOffsetkey @"trailingoffset"
#define kHeightOffsetkey @"heightoffset"
#define kBottomOffsetkey @"bottomoffset"
#define kAttemptOffsetAutoAdjustInOneHandedkey @"rightinset"
#define kEnabledSmartDeletekey @"smartdeleteBOOL"
#define kEnabledSmartDeleteForwardkey @"smartdeleteforwardBOOL"
#define kEnabledSkipEmojikey @"skipEmojiInputBOOL"
#define kShortLabelEnabledKey @"shortLabelBOOL"
#define kCellHeightkey @"shortcutheight"
#define kCellRadiuskey @"shortcutradius"
#define kCellSpacingkey @"shortcutspacing"
#define kCachekey @"cache"
#define kSpongebobEntropyKey @"spongebobEntropy"

#define toastWidth 50
#define toastHeight 50
#define toastPosition 0.8f
#define toastDuration 0.2
#define toastAlpha 0.95
#define toastRadius 6
#define toastTextColor [UIColor whiteColor]
#define toastBackgroundColor [UIColor blackColor]
#define toastImageTintColor [UIColor whiteColor]

#define kbuttonsImages12 0
#define kbuttonsImages13 1
#define kselectors 2
#define kselectorsLP 3
#define kshortLabel 4

#define tweakVersion @"1.3.1"
#define maxdefaultshortcuts 6
#define maxshortcutpersection 8
#define maxshortcutpersection_onehanded 5
#define granularity 3

#define maxdefaultshortcutskbtype 3

#define topInsetDefault 22.0f
#define bottomInsetDefault 0.0f
#define leftInsetDefault 0.0f
#define rightInsetDefault 0.0f

#define leadingOffsetDefault 69.0f
#define trailingOffsetDefault -60.0f
#define heightOffsetDefault 60.0f
#define bottomOffsetDefault -22.0f

#define leadingOffsetHandBiasRightDefault 100.0f
#define trailingOffsetHandBiasRightDefault -65.0f

#define leadingOffsetHandBiasLeftDefault 69.0f
#define trailingOffsetHandBiasLeftDefault -100.0f

#define searchedCountEaster 100

#define spacingBetweenCellsDefault 3
#define cellsHeightDefault 30
#define cellsRadiusDefault 5

#define secondActionDelay 0.05

typedef NS_ENUM(NSInteger, DXPhonemesType){
    DXPhonemesTypeVowel,
    DXPhonemesTypeConsonent
};

typedef NS_ENUM(NSInteger, DXStudlyCapsType){
    DXStudlyCapsTypeRandom,
    DXStudlyCapsTypeAlternate,
    DXStudlyCapsTypeVowel,
    DXStudlyCapsTypeConsonent
};

@interface CPDistributedMessagingCenter : NSObject
+ (id)centerNamed:(id)arg1;
- (void)runServerOnCurrentThread;
- (void)registerForMessageName:(id)arg1 target:(id)arg2 selector:(SEL)arg3;
- (BOOL)sendMessageName:(id)arg1 userInfo:(id)arg2;
- (NSDictionary *)sendMessageAndReceiveReplyName:(id)arg1 userInfo:(id)arg2;
@end

@interface SpringBoard : NSObject
- (NSDictionary *)showToastRequest:(NSString *)name withUserInfo:(NSDictionary *)userInfo;
@end

@interface UIKeyboardEmojiCollectionInputView : NSObject {
    unsigned long long  _currentSection;
    double  _frameInset;
    bool  _hasShownAnimojiCell;
    bool  _hasShownAnimojiFirstTimeExperience;
    bool  _inputDelegateCanSupportAnimoji;
    bool  _isDraggingInputView;
    bool  _shouldRetryFetchingAnimojiRecents;
    NSIndexPath * _tappedSkinToneEmoji;
    bool  _useWideAnimojiCell;
}
@end

@interface SBSRelaunchAction : NSObject
@property (nonatomic, readonly) unsigned long long options;
@property (nonatomic, readonly, copy) NSString *reason;
@property (nonatomic, readonly, retain) NSURL *targetURL;
+ (id)actionWithReason:(id)arg1 options:(unsigned long long)arg2 targetURL:(id)arg3;
- (id)initWithReason:(id)arg1 options:(unsigned long long)arg2 targetURL:(id)arg3;
- (unsigned long long)options;
- (id)reason;
- (id)targetURL;

@end

@interface FBSSystemService : NSObject
+ (id)sharedService;
- (void)sendActions:(id)arg1 withResult:(/*^block*/id)arg2;
@end

@interface UIKeyboardPreferencesController : NSObject
@property (assign) long long handBias;
+(UIKeyboardPreferencesController *)sharedPreferencesController;
+(id)valueForPreferenceKey:(id)arg1 domain:(id)arg2 ;
-(void)setHandBias:(long long)arg1 ; //0 -normal,2-left, 1-right
-(BOOL)boolForKey:(int)arg1 ;
-(void)setValue:(id)arg1 forKey:(int)arg2 ;
-(void)synchronizePreferences;
@end

