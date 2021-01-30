@interface UIKeyboardExtensionInputMode : NSObject
-(BOOL)isDefaultRightToLeft;
@end

@interface UIResponder(Private)
@property (nonatomic,readonly) UIKeyboardExtensionInputMode * textInputMode;
@property (nonatomic,readonly) NSArray * keyCommands;
@property (nonatomic,readonly) UIResponder * _editingDelegate;
@property (nonatomic,readonly) UIResponder * _responderForEditing;
@property (nonatomic,readonly) UIResponder * nextResponder;
- (void)_define:(NSString *)text;
-(id)targetForAction:(SEL)arg1 withSender:(id)arg2 ;
-(id)_moveToStartOfLine:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToEndOfLine:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToStartOfParagraph:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToEndOfParagraph:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToStartOfWord:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToEndOfWord:(BOOL)arg1 withHistory:(id)arg2 ;
- (void)clearSelection;
-(id)_rangeOfParagraphEnclosingPosition:(id)arg1 ;
-(id)_rangeOfLineEnclosingPosition:(id)arg1 ;
-(id)_rangeOfSentenceEnclosingPosition:(id)arg1 ;
- (void)_setSelectionToPosition:(UITextPosition *)arg1;
-(void)_setSelectedTextRange:(id)arg1 withAffinityDownstream:(BOOL)arg2 ;
-(id)_setSelectionRangeWithHistory:(id)arg1 ;
-(void)_updateSelectionWithTextRange:(id)arg1 withAffinityDownstream:(BOOL)arg2 ;
-(id)textRangeFromPosition:(id)arg1 toPosition:(id)arg2 ;
-(void)moveByOffset:(long long)arg1 ;
- (void)beginSelectionInDirection:(long long)arg1 atPoint:(CGPoint)arg2 completionHandler:(id)arg2;
-(CGPoint)lastInteractionLocation;
-(void)selectWordBackward;
-(void)_becomeFirstResponderWithSelectionMovingForward:(BOOL)arg1 completionHandler:(/*^block*/id)arg2 ;
-(BOOL)becomeFirstResponder;
-(BOOL)becomeFirstResponderForWebView;
-(UITextInteractionAssistant *)interactionAssistant;
-(id)webView;
-(void)_deleteByWord;
-(id)_moveLeft:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveRight:(BOOL)arg1 withHistory:(id)arg2 ;
-(void)_deleteBackwardAndNotify:(BOOL)arg1 ;
-(void)_deleteForwardAndNotify:(BOOL)arg1 ;
@end


@protocol UITextInputTraits_Private <NSObject,UITextInputTraits>
@property (assign,nonatomic) CFCharacterSetRef textTrimmingSet;
@property (assign,nonatomic) unsigned long long insertionPointWidth;
@property (assign,nonatomic) int textLoupeVisibility;
@property (assign,nonatomic) int textSelectionBehavior;
@property (assign,nonatomic) id textSuggestionDelegate;
@property (assign,nonatomic) BOOL isSingleLineDocument;
@property (assign,nonatomic) BOOL contentsIsSingleValue;
@property (assign,nonatomic) BOOL acceptsEmoji;
@property (assign,nonatomic) BOOL forceEnableDictation;
@property (assign,nonatomic) int emptyContentReturnKeyType;
@property (assign,nonatomic) BOOL returnKeyGoesToNextResponder;
@property (assign,nonatomic) BOOL acceptsFloatingKeyboard;
@property (assign,nonatomic) BOOL acceptsSplitKeyboard;
@property (assign,nonatomic) BOOL displaySecureTextUsingPlainText;
@property (assign,nonatomic) BOOL learnsCorrections;
@property (assign,nonatomic) int shortcutConversionType;
@property (assign,nonatomic) BOOL suppressReturnKeyStyling;
@property (assign,nonatomic) BOOL useInterfaceLanguageForLocalization;
@property (assign,nonatomic) BOOL deferBecomingResponder;
@property (assign,nonatomic) BOOL enablesReturnKeyOnNonWhiteSpaceContent;
@property (assign,nonatomic) BOOL disablePrediction;
@optional
-(int)textSelectionBehavior;
-(BOOL)displaySecureTextUsingPlainText;
-(CFCharacterSetRef)textTrimmingSet;
-(BOOL)acceptsSplitKeyboard;
-(int)shortcutConversionType;
-(BOOL)acceptsFloatingKeyboard;
-(BOOL)disablePrediction;
-(BOOL)learnsCorrections;
-(void)setLearnsCorrections:(BOOL)arg1;
-(void)setTextTrimmingSet:(CFCharacterSetRef)arg1;
-(unsigned long long)insertionPointWidth;
-(void)setInsertionPointWidth:(unsigned long long)arg1;
-(int)textLoupeVisibility;
-(void)setTextLoupeVisibility:(int)arg1;
-(void)setTextSelectionBehavior:(int)arg1;
-(id)textSuggestionDelegate;
-(void)setTextSuggestionDelegate:(id)arg1;
-(BOOL)isSingleLineDocument;
-(void)setIsSingleLineDocument:(BOOL)arg1;
-(BOOL)contentsIsSingleValue;
-(void)setContentsIsSingleValue:(BOOL)arg1;
-(BOOL)acceptsEmoji;
-(void)setAcceptsEmoji:(BOOL)arg1;
-(BOOL)forceEnableDictation;
-(void)setForceEnableDictation:(BOOL)arg1;
-(int)emptyContentReturnKeyType;
-(void)setEmptyContentReturnKeyType:(int)arg1;
-(BOOL)returnKeyGoesToNextResponder;
-(void)setReturnKeyGoesToNextResponder:(BOOL)arg1;
-(void)setAcceptsFloatingKeyboard:(BOOL)arg1;
-(void)setAcceptsSplitKeyboard:(BOOL)arg1;
-(void)setDisplaySecureTextUsingPlainText:(BOOL)arg1;
-(void)setShortcutConversionType:(int)arg1;
-(BOOL)suppressReturnKeyStyling;
-(void)setSuppressReturnKeyStyling:(BOOL)arg1;
-(BOOL)useInterfaceLanguageForLocalization;
-(void)setUseInterfaceLanguageForLocalization:(BOOL)arg1;
-(BOOL)deferBecomingResponder;
-(void)setDeferBecomingResponder:(BOOL)arg1;
-(BOOL)enablesReturnKeyOnNonWhiteSpaceContent;
-(void)setEnablesReturnKeyOnNonWhiteSpaceContent:(BOOL)arg1;
-(void)setDisablePrediction:(BOOL)arg1;

@required
-(void)takeTraitsFrom:(id)arg1;

@end

@protocol UITextInputPrivate <UITextInput,UITextInputTokenizer,UITextInputTraits_Private>
@property (nonatomic,readonly) UITextInteractionAssistant * interactionAssistant;
@property (assign,nonatomic) long long selectionGranularity;
@optional
-(void)replaceRangeWithTextWithoutClosingTyping:(id)arg1 replacementText:(id)arg2;
-(void)insertDictationResult:(id)arg1 withCorrectionIdentifier:(id)arg2;
-(id)rangeWithTextAlternatives:(id*)arg1 atPosition:(id)arg2;
-(id)metadataDictionariesForDictationResults;
-(id)textColorForCaretSelection;
-(long long)selectionGranularity;
-(void)setSelectionGranularity:(long long)arg1;
-(id)automaticallySelectedOverlay;
-(void)setBottomBufferHeight:(double)arg1;
-(BOOL)requiresKeyEvents;
-(void)handleKeyWebEvent:(id)arg1;
-(void)streamingDictationDidBegin;
-(void)streamingDictationDidEnd;
-(void)acceptedAutoFillWord:(id)arg1;
-(BOOL)isAutoFillMode;
-(double)_delayUntilRepeatInsertText:(id)arg1;
-(BOOL)_shouldRepeatInsertText:(id)arg1;
-(id)fontForCaretSelection;
-(void)_insertAttributedTextWithoutClosingTyping:(id)arg1;

@required
-(UITextInteractionAssistant *)interactionAssistant;
-(id)textInputTraits;
-(void)selectAll;
-(NSRange*)selectionRange;
-(BOOL)hasSelection;
-(BOOL)hasContent;

@end

@interface UITextInteractionAssistant : NSObject
-(void)willBeginSelectionInteraction;
-(void)willBeginFloatingCursor:(BOOL)arg1 ;
@end
