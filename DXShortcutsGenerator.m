#import "common.h"
#import "DXShortcutsGenerator.h"

static const NSBundle *tweakBundle;

@implementation DXShortcutsGenerator

+(void)load{
    @autoreleasepool {
        NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
        
        if (args.count != 0) {
            NSString *executablePath = args[0];
            
            if (executablePath) {
                NSString *processName = [executablePath lastPathComponent];
                
                BOOL isSpringBoard = [processName isEqualToString:@"SpringBoard"];
                BOOL isApplication = [executablePath rangeOfString:@"/Application"].location != NSNotFound;
                
                if (isSpringBoard || isApplication) {
                    tweakBundle = [NSBundle bundleWithPath:bundlePath];
                    [tweakBundle load];
                    [DXShortcutsGenerator sharedInstance];
                    
                }
            }
        }
    }
}

+(instancetype)sharedInstance{
    static dispatch_once_t predicate;
    static DXShortcutsGenerator *generator;
    dispatch_once(&predicate, ^{ generator = [[self alloc] init]; });
    return generator;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        self.copyLogDylibExist = [self dylibExist:copyLogDylib manager:fileManager];
        self.translomaticDylibExist = [self dylibExist:translomaticDylib manager:fileManager];
        self.wasabiDylibExist = [self dylibExist:wasabiDylib manager:fileManager];
        self.pasitheaDylibExist = [self dylibExist:pasitheaDylib manager:fileManager];
        self.copypastaDylibExist = [self dylibExist:copypastaDylib manager:fileManager];
        self.loupeDylibExist = [self dylibExist:loupeDylib manager:fileManager];
        self.tranzloDylibExist = [self dylibExist:tranzloDylib manager:fileManager];
    }
    return self;
}

-(NSArray *)imageNameArrayForiOS:(NSInteger)iosVersion{
    // 0 = iOS 12
    // 1 = iOS 13+
    NSArray *array;
    if (iosVersion == 0){
        array = @[@"UIButtonBarListIcon",@"UIButtonBarKeyboardCopy",@"UIButtonBarKeyboardPaste",@"UIButtonBarKeyboardCut",@"UIButtonBarKeyboardUndo",@"UIButtonBarKeyboardRedo", @"UIButtonBarKeyboardItalic", @"UIButtonBarArrowLeft", @"UIButtonBarArrowRight", @"shift_portrait_skinny", @"UIButtonBarArrowDown", @"shift_lock_portrait_skinny", @"delete_portrait", @"UIButtonBarKeyboardBold", @"UIButtonBarKeyboardItalic", @"UIButtonBarKeyboardUnderline", @"bold_dismiss_landscape", @"Black_BreadcrumbArrowLeft", @"Black_BreadcrumbArrowRight", @"UIAccessoryButtonCheckmark", @"shift_on_portrait", @"reachable_full", @"KeyGlyph-upArrow-large", @"KeyGlyph-downArrow-large", @"UITabBarSearchTemplate", @"KeyGlyph-command-large", @"messages_writeboard", @"UICalloutBarPreviousArrow", @"UICalloutBarNextArrow", @"KeyGlyph-rtlTab-large", @"KeyGlyph-tab-large", @"KeyGlyph-return-large", @"KeyGlyph-rtlReturn-large", @"UIMovieScrubberEditingGlassLeft", @"UIMovieScrubberEditingGlassRight", @"UIRemoveControlMinusStroke", @"UITableGrabber", @"UIButtonBarListIcon", @"globe_dockitem-portrait", @"dictation_dockitem-portrait", @"delete_portrait", @"bold_emoji_activity"];
    }else{
        array = @[@"doc.text",@"doc.on.doc",@"doc.on.clipboard",@"scissors",@"arrow.uturn.left.circle",@"arrow.uturn.right.circle", @"text.cursor", @"chevron.left.circle", @"chevron.right.circle", @"textformat.alt", @"textformat.abc", @"capslock", @"delete.left", @"bold", @"italic", @"underline", @"keyboard.chevron.compact.down", @"arrowtriangle.left.circle.fill", @"arrowtriangle.right.circle.fill", @"checkmark.circle.fill", @"shift.fill", @"number.circle.fill", @"arrowtriangle.up.circle.fill", @"arrowtriangle.down.circle.fill", @"doc.text.magnifyingglass", @"command", @"text.bubble", @"arrow.left.circle.fill", @"arrow.right.circle.fill", @"arrow.left.to.line", @"arrow.right.to.line", @"text.insert", @"text.append", @"decrease.quotelevel", @"increase.quotelevel", @"line.horizontal.3", @"paragraph", @"list.bullet", @"globe", @"mic", @"delete.right", @"circle.grid.3x3"];
    }
    array = [self thirdPartyImageNameArray:array foriOS:iosVersion];
    return array;
}

-(NSArray *)selectorNameForLongPress:(BOOL)longPress{
    NSArray *array = @[@"selectAllAction:",@"copyAction:",@"pasteAction:",@"cutAction:",@"undoAction:",@"redoAction:", @"selectAction:", @"beginningAction:", @"endingAction:", @"capitalizeAction:", @"lowercaseAction:", @"uppercaseAction:", @"deleteAction:", @"boldAction:", @"italicAction:", @"underlineAction:", @"dismissKeyboardAction:", @"moveCursorLeftAction:", @"moveCursorRightAction:", @"autoCorrectionAction:", @"autoCapitalizationAction:", @"keyboardTypeAction:", @"moveCursorUpAction:", @"moveCursorDownAction:", @"defineAction:", @"runCommandAction:", @"insertTextAction:", @"moveCursorPreviousWordAction:", @"moveCursorNextWordAction:", @"moveCursorStartOfLineAction:", @"moveCursorEndOfLineAction:", @"moveCursorStartOfParagraphAction:", @"moveCursorEndOfParagraphAction:", @"moveCursorStartOfSentenceAction:", @"moveCursorEndOfSentenceAction:", @"selectLineAction:", @"selectParagraphAction:", @"selectSentenceAction:", @"globeAction:", @"dictationAction:", @"deleteForwardAction:", @"spongebobAction:"];
    
    if (longPress){
        NSMutableArray *longPressArray = [[NSMutableArray alloc] init];
        for (NSString *selName in array){
            [longPressArray addObject:[selName stringByReplacingOccurrencesOfString:@":" withString:@"LP:"]];
        }
        array = longPressArray;
    }
    array = [self thirdPartySelectorNameArray:array longPress:longPress];
    return array;
}

-(NSArray *)labelName{
    NSArray *array = @[LOCALIZED(@"LONG_SELECT_ALL"), LOCALIZED(@"LONG_COPY"), LOCALIZED(@"LONG_PASTE"), LOCALIZED(@"LONG_CUT"), LOCALIZED(@"LONG_UNDO"), LOCALIZED(@"LONG_REDO"), LOCALIZED(@"LONG_SELECT"), LOCALIZED(@"LONG_BEGINNING"), LOCALIZED(@"LONG_ENDING"), LOCALIZED(@"LONG_CAPITALIZE"), LOCALIZED(@"LONG_LOWERCASE"), LOCALIZED(@"LONG_UPPERCASE"), LOCALIZED(@"LONG_DELETE"), LOCALIZED(@"LONG_BOLD"), LOCALIZED(@"LONG_ITALIC"), LOCALIZED(@"LONG_UNDERLINE"), LOCALIZED(@"LONG_DISMISS_KEYBOARD"), LOCALIZED(@"LONG_MOVE_CURSOR_LEFT"), LOCALIZED(@"LONG_MOVE_CURSOR_RIGHT"), LOCALIZED(@"LONG_AUTO_CORRECTION"), LOCALIZED(@"LONG_AUTO_CAPITALIZATION"), LOCALIZED(@"LONG_KEYBOARD_TYPE"), LOCALIZED(@"LONG_MOVE_CURSOR_UP"), LOCALIZED(@"LONG_MOVE_CURSOR_DOWN"), LOCALIZED(@"LONG_DEFINE"), LOCALIZED(@"LONG_RUN_COMMAND"), LOCALIZED(@"LONG_INSERT_TEXT"), LOCALIZED(@"LONG_MOVE_CURSOR_PREVIOUS_WORD"), LOCALIZED(@"LONG_MOVE_CURSOR_NEXT_WORD"), LOCALIZED(@"LONG_MOVE_CURSOR_START_OF_LINE"), LOCALIZED(@"LONG_MOVE_CURSOR_END_OF_LINE"), LOCALIZED(@"LONG_MOVE_CURSOR_START_OF_PARAGRAPH"), LOCALIZED(@"LONG_MOVE_CURSOR_END_OF_PARAGRAPH"), LOCALIZED(@"LONG_MOVE_CURSOR_START_OF_SENTENCE"), LOCALIZED(@"LONG_MOVE_CURSOR_END_OF_SENTENCE"), LOCALIZED(@"LONG_SELECT_LINE"), LOCALIZED(@"LONG_SELECT_PARAGRAPH"),LOCALIZED(@"LONG_SELECT_SENTENCE"), LOCALIZED(@"LONG_GLOBE"), LOCALIZED(@"LONG_DICTATION"), LOCALIZED(@"LONG_DELETE_FORWARD"), LOCALIZED(@"LONG_SPONGEBOB")];
    array = [self thirdPartyLabelNameArray:array];
    return array;
}

-(NSArray *)shortenedlabelName{
    NSArray *array = @[LOCALIZED(@"SHORT_SELECT_ALL"), LOCALIZED(@"SHORT_COPY"), LOCALIZED(@"SHORT_PASTE"), LOCALIZED(@"SHORT_CUT"), LOCALIZED(@"SHORT_UNDO"), LOCALIZED(@"SHORT_REDO"), LOCALIZED(@"SHORT_SELECT"), LOCALIZED(@"SHORT_BEGINNING"), LOCALIZED(@"SHORT_ENDING"), LOCALIZED(@"SHORT_CAPITALIZE"), LOCALIZED(@"SHORT_LOWERCASE"), LOCALIZED(@"SHORT_UPPERCASE"), LOCALIZED(@"SHORT_DELETE"), LOCALIZED(@"SHORT_BOLD"), LOCALIZED(@"SHORT_ITALIC"), LOCALIZED(@"SHORT_UNDERLINE"), LOCALIZED(@"SHORT_DISMISS_KEYBOARD"), LOCALIZED(@"SHORT_MOVE_CURSOR_LEFT"), LOCALIZED(@"SHORT_MOVE_CURSOR_RIGHT"), LOCALIZED(@"SHORT_AUTO_CORRECTION"), LOCALIZED(@"SHORT_AUTO_CAPITALIZATION"), LOCALIZED(@"SHORT_KEYBOARD_TYPE"), LOCALIZED(@"SHORT_MOVE_CURSOR_UP"), LOCALIZED(@"SHORT_MOVE_CURSOR_DOWN"), LOCALIZED(@"SHORT_DEFINE"), LOCALIZED(@"SHORT_RUN_COMMAND"), LOCALIZED(@"SHORT_INSERT_TEXT"), LOCALIZED(@"SHORT_MOVE_CURSOR_PREVIOUS_WORD"), LOCALIZED(@"SHORT_MOVE_CURSOR_NEXT_WORD"), LOCALIZED(@"SHORT_MOVE_CURSOR_START_OF_LINE"), LOCALIZED(@"SHORT_MOVE_CURSOR_END_OF_LINE"), LOCALIZED(@"SHORT_MOVE_CURSOR_START_OF_PARAGRAPH"), LOCALIZED(@"SHORT_MOVE_CURSOR_END_OF_PARAGRAPH"), LOCALIZED(@"SHORT_MOVE_CURSOR_START_OF_SENTENCE"), LOCALIZED(@"SHORT_MOVE_CURSOR_END_OF_SENTENCE"), LOCALIZED(@"SHORT_SELECT_LINE"), LOCALIZED(@"SHORT_SELECT_PARAGRAPH"), LOCALIZED(@"SHORT_SELECT_SENTENCE"), LOCALIZED(@"SHORT_GLOBE"), LOCALIZED(@"SHORT_DICTATION"), LOCALIZED(@"SHORT_DELETE_FORWARD"), LOCALIZED(@"SHORT_SPONGEBOB")];
    array = [self thirdPartyShortenedLabelNameArray:array];
    return array;
}

-(BOOL)dylibExist:(NSString *)dylibPath manager:(NSFileManager *)fileManager{
    return [fileManager fileExistsAtPath:dylibPath];
}

-(NSArray *)thirdPartyImageNameArray:(NSArray *)array foriOS:(NSInteger)iosVersion{
    NSMutableArray *thirdPartArray = [array mutableCopy];
    if (self.copyLogDylibExist){
        [thirdPartArray addObject:@"CUSTOM_/Library/Application Support/CopyLog/Ressources.bundle/keyboardlogo.png"];
    }
    if (self.translomaticDylibExist){
        [thirdPartArray addObject:@"CUSTOM_/Library/MobileSubstrate/DynamicLibraries/com.foxfort.translomatic.bundle/trans_24.png"];
    }
    if (self.wasabiDylibExist){
        if (iosVersion == 0){
            [thirdPartArray addObject:@"UIButtonBarCompose"];
        }else{
            [thirdPartArray addObject:@"rectangle.and.paperclip"];
        }
    }
    if (self.pasitheaDylibExist){
        if (iosVersion == 0){
            [thirdPartArray addObject:@"UIButtonBarCompose"];
        }else{
            [thirdPartArray addObject:@"rectangle.and.paperclip"];
        }
    }
    if (self.copypastaDylibExist){
        if (iosVersion == 0){
            [thirdPartArray addObject:@"UIButtonBarCompose"];
        }else{
            [thirdPartArray addObject:@"rectangle.and.paperclip"];
        }
    }
    if (self.loupeDylibExist){
        if (iosVersion == 0){
            [thirdPartArray addObject:@"kb-loupe-hi"];
        }else{
            [thirdPartArray addObject:@"magnifyingglass.circle.fill"];
        }
    }
    if (self.tranzloDylibExist){
        [thirdPartArray addObject:@"CUSTOM_/Library/Shortmoji/Shortcuts/TranzloTranslateShortcut.bundle/icon.png"];
    }
    return thirdPartArray;
}

-(NSArray *)thirdPartySelectorNameArray:(NSArray *)array longPress:(BOOL)longPress{
    NSMutableArray *thirdPartArray = [array mutableCopy];
    if (self.copyLogDylibExist){
        if (longPress){
            [thirdPartArray addObject:@"copyLogActionLP:"];
        }else{
            [thirdPartArray addObject:@"copyLogAction:"];
        }
    }
    if (self.translomaticDylibExist){
        if (longPress){
            [thirdPartArray addObject:@"translomaticActionLP:"];
        }else{
            [thirdPartArray addObject:@"translomaticAction:"];
        }
    }
    if (self.wasabiDylibExist){
        if (longPress){
            [thirdPartArray addObject:@"wasabiActionLP:"];
        }else{
            [thirdPartArray addObject:@"wasabiAction:"];
        }
    }
    if (self.pasitheaDylibExist){
        if (longPress){
            [thirdPartArray addObject:@"pasitheaActionLP:"];
        }else{
            [thirdPartArray addObject:@"pasitheaAction:"];
        }
    }
    if (self.copypastaDylibExist){
        if (longPress){
            [thirdPartArray addObject:@"copypastaActionLP:"];
        }else{
            [thirdPartArray addObject:@"copypastaAction:"];
        }
    }
    if (self.loupeDylibExist){
        if (longPress){
            [thirdPartArray addObject:@"loupeActionLP:"];
        }else{
            [thirdPartArray addObject:@"loupeAction:"];
        }
    }
    if (self.tranzloDylibExist){
        if (longPress){
            [thirdPartArray addObject:@"tranzloActionLP:"];
        }else{
            [thirdPartArray addObject:@"tranzloAction:"];
        }
    }
    return thirdPartArray;
}

-(NSArray *)thirdPartyLabelNameArray:(NSArray *)array{
    NSMutableArray *thirdPartArray = [array mutableCopy];
    if (self.copyLogDylibExist){
        [thirdPartArray addObject:LOCALIZED(@"LONG_COPY_LOG")];
    }
    if (self.translomaticDylibExist){
        [thirdPartArray addObject:LOCALIZED(@"LONG_TRANSLOMATIC")];
    }
    if (self.wasabiDylibExist){
        [thirdPartArray addObject:LOCALIZED(@"LONG_WASABI")];
    }
    if (self.pasitheaDylibExist){
        [thirdPartArray addObject:LOCALIZED(@"LONG_PASITHEA")];
    }
    if (self.copypastaDylibExist){
        [thirdPartArray addObject:LOCALIZED(@"LONG_COPYPASTA")];
    }
    if (self.loupeDylibExist){
        [thirdPartArray addObject:LOCALIZED(@"LONG_LOUPE")];
    }
    if (self.tranzloDylibExist){
        [thirdPartArray addObject:LOCALIZED(@"LONG_TRANZLO")];
    }
    return thirdPartArray;
}

-(NSArray *)thirdPartyShortenedLabelNameArray:(NSArray *)array{
    NSMutableArray *thirdPartArray = [array mutableCopy];
    if (self.copyLogDylibExist){
        [thirdPartArray addObject:LOCALIZED(@"SHORT_COPY_LOG")];
    }
    if (self.translomaticDylibExist){
        [thirdPartArray addObject:LOCALIZED(@"SHORT_TRANSLOMATIC")];
    }
    if (self.wasabiDylibExist){
        [thirdPartArray addObject:LOCALIZED(@"SHORT_WASABI")];
    }
    if (self.pasitheaDylibExist){
        [thirdPartArray addObject:LOCALIZED(@"SHORT_PASITHEA")];
    }
    if (self.copypastaDylibExist){
        [thirdPartArray addObject:LOCALIZED(@"SHORT_COPYPASTA")];
    }
    if (self.loupeDylibExist){
        [thirdPartArray addObject:LOCALIZED(@"SHORT_LOUPE")];
    }
    if (self.tranzloDylibExist){
        [thirdPartArray addObject:LOCALIZED(@"SHORT_TRANZLO")];
    }
    return thirdPartArray;
}

-(NSArray *)keyboardTypeLabel{
    NSArray *array = @[LOCALIZED(@"TOAST_KEYBOARD_TYPE_ORIGINAL"), LOCALIZED(@"TOAST_KEYBOARD_TYPE_DEFAULT"), LOCALIZED(@"TOAST_KEYBOARD_TYPE_DECIMAL_PAD"), LOCALIZED(@"TOAST_KEYBOARD_TYPE_NUMBER_PAD"), LOCALIZED(@"TOAST_KEYBOARD_TYPE_URL"), LOCALIZED(@"TOAST_KEYBOARD_TYPE_EMAIL"), LOCALIZED(@"TOAST_KEYBOARD_TYPE_ASCII"), LOCALIZED(@"TOAST_KEYBOARD_TYPE_NUMBERS_AND_PUNC"), LOCALIZED(@"TOAST_KEYBOARD_TYPE_PHONE_PAD"), LOCALIZED(@"TOAST_KEYBOARD_TYPE_NAME_AND_PHONE_PAD"), LOCALIZED(@"TOAST_KEYBOARD_TYPE_TWITTER"), LOCALIZED(@"TOAST_KEYBOARD_TYPE_WEB_SEARCH"), LOCALIZED(@"TOAST_KEYBOARD_TYPE_NUMBER_PAD_ASCII"), LOCALIZED(@"TOAST_KEYBOARD_TYPE_ALPHABET")];
    return array;
}

-(NSArray *)keyboardTypeData{
    NSArray *array = @[@-1, @0, @8, @4, @3, @7, @1, @2, @5, @6, @9, @10, @11, @12];
    return array;
}
@end

