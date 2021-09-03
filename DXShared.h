#import "common.h"
#import "DockX.h"

extern id delegate;
extern UIKeyboardImpl *kbImpl;
extern UIColor *currentTintColor;
extern UIColor *toastTintColor;
extern UIColor *toastBackgroundTintColor;
extern UIColor *currentBackgroundTintColor;
extern BOOL isLandscape;
extern NSMutableDictionary *prefs;
extern BOOL isDictating;
extern BOOL toggledOn;
extern UIKeyboardDockView *dockView;
//extern BOOL isSandboxed;
extern CGPoint startPosition;
extern CGPoint endPosition;
extern NSDate *prevTime;
extern BOOL singleTapDictationEnabled;
extern BOOL singleTapGlobeEnabled;
extern BOOL isTrackPadMode;
extern BOOL isSpringBoard;
extern BOOL isApplication;
extern BOOL isSafari;
extern KeyboardController *kbController;
extern BOOL shouldUpdateTrueKBType;
extern BOOL shouldPerformBatchUpdate;
//extern BOOL shouldSendScrollExecution;
extern NSString *key;
extern BOOL isDraggedGesture;
extern UIKeyboardDockView *dockV;
extern BOOL isPossibleDraggingForShootingStar;
extern BOOL isPagingEnabled;
extern BOOL useShortenedLabel;
extern NSBundle *tweakBundle;
extern BOOL firstInit;
extern DXStudlyCapsType spongebobEntropy;

extern float topInset;
extern float bottomInset;
extern float leftInset;
extern float rightInset;

extern float buttonRadius;
extern float buttonHeight;
extern float buttonSpacing;

extern CGFloat leadingOffset;
extern CGFloat trailingOffset;
extern CGFloat heightOffset;
extern CGFloat bottomOffset;

extern CGFloat leadingHBRightOffset;
extern CGFloat trailingHBRightOffset;

extern CGFloat leadingHBLeftOffset;
extern CGFloat trailingHBLeftOffset;

#ifdef __cplusplus
extern "C" {
#endif

BOOL preferencesBool(NSString* key, BOOL fallback);
float preferencesFloat(NSString* key, float fallback);
int preferencesInt(NSString* key, int fallback);
NSString *preferencesSelectorForIdentifier(NSString* identifier, int selectorNum, int gestureType, NSString *fallback);


void showCopypastaWithNotification() __attribute__((weak));
void flipLoupeEnableSwitch(BOOL enable) __attribute__((weak));
BOOL loupeSwitchState() __attribute__((weak));

#ifdef __cplusplus
}
#endif
