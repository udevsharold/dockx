#include "DockXItems.h"
#include "CustomActionViewController.h"
#include "KeyboardTypeOptions.h"
#include "SnippetEntryController.h"
#include "InsertTextEntryController.h"
#include "CursorMoveAndSelectEntryController.h"
#include "../ShortcutsGenerator.h"
#include "../DockXHelper.h"
#include "GesturePickerController.h"
#include "DeleteOptions.h"
#include "GlobeOptions.h"
#include "PasteOptions.h"

static BOOL translomaticInstalled = NO;
static UISearchController *searchController;
static NSBundle *tweakBundle;


@implementation DockXItems



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return LOCALIZED(@"ENABLED_SHORTCUTS");
        case 1:
            return LOCALIZED(@"DISABLED_SHORTCUTS");
        default:
            return LOCALIZED(@"EXTRAS");
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self.currentOrder[0] count];
        case 1:
            return [self.currentOrder[1] count];
        case 2:
            return [self.extrasOptions count];
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *footerTextForSectionOne = @"";
    switch (section) {
        case 0:
            return LOCALIZED(@"FOOTER_TEXT_FOR_ENABLED_SHORTCUTS");
        case 1:
            return @"";
        case 2:
            footerTextForSectionOne = LOCALIZED(@"FOOTER_TEXT_FOR_EXTRAS");
            footerTextForSectionOne = [footerTextForSectionOne stringByAppendingString:@"\n\n"];
            footerTextForSectionOne = [footerTextForSectionOne stringByAppendingString:LOCALIZED(@"FOOTER_TEXT_FOR_DEFAULT_LONG_PRESS_GESTURES")];
            if (translomaticInstalled){
                footerTextForSectionOne = [footerTextForSectionOne stringByAppendingString:@"\n"];
                footerTextForSectionOne = [footerTextForSectionOne stringByAppendingString:LOCALIZED(@"FOOTER_TEXT_FOR_DEFAULT_LONG_PRESS_GESTURES_TRANSLOMATIC")];
            }
            return footerTextForSectionOne;
        default:
            return @"";
            
    }
}

-(void)setCompatibiltyWarning{
    CGRect frame = CGRectMake(0,0,self.tableView.bounds.size.width,50);
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:frame];
    [headerLabel setText:@"Due to compatibility issue, please \"Reset\".\nInteraction with table below is temporary disabled."];
    [headerLabel setFont:font];
    [headerLabel setTextColor:[UIColor redColor]];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [headerLabel setContentMode:UIViewContentModeScaleAspectFit];
    [headerLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [headerLabel setNumberOfLines:0];
    [headerLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [headerView addSubview:headerLabel];
    self.tableView.tableHeaderView = headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DockXItemCell" forIndexPath:indexPath];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DockXItemCell"];
    
    UIImage *image;
    NSString *label;
    
    dispatch_semaphore_t smp = dispatch_semaphore_create(0);
    __block BOOL isCustomImagePath = NO;
    __block BOOL isThirteen = NO;
    
    switch(indexPath.section) {
        case 0: {
            if (self.currentOrder[0] == nil || [self.currentOrder[0] count] <= indexPath.row)
                return nil;
            if (indexPath.row >= [self.currentOrder[0] count]){
                [self setCompatibiltyWarning];
                cell.textLabel.text = LOCALIZED(@"INCOMPATIBLE_RESET");
                cell.imageView.image = nil;
                self.tableView.userInteractionEnabled = NO;
                return cell;
            }
            label = [DockXHelper localizedStringForActionNamed:[DockXHelper actionNameFromArray:self.currentOrder[0] atIndex:indexPath.row] shortName:NO bundle:tweakBundle];
            //label = [DockXHelper labelFromArray:self.currentOrder[0] atIndex:indexPath.row];
            image = [DockXHelper imageFromArray:self.currentOrder[0] atIndex:indexPath.row withSystemColor:YES completion:^(BOOL thirteen, BOOL customPath){
                isThirteen = thirteen;
                isCustomImagePath = customPath;
                dispatch_semaphore_signal(smp);
            }];
            dispatch_semaphore_wait(smp, DISPATCH_TIME_FOREVER);
            if (!isThirteen && isCustomImagePath){
                [cell.imageView setTintColor:[UIColor blackColor]];
            }
            break;
        }
        case 1: {
            if (self.currentOrder[1] == nil || [self.currentOrder[1] count] <= indexPath.row)
                return nil;
            if (indexPath.row >= [self.currentOrder[1] count]){
                [self setCompatibiltyWarning];
                cell.textLabel.text = LOCALIZED(@"INCOMPATIBLE_RESET");
                cell.imageView.image = nil;
                self.tableView.userInteractionEnabled = NO;
                return cell;
            }
            label = [DockXHelper localizedStringForActionNamed:[DockXHelper actionNameFromArray:self.currentOrder[1] atIndex:indexPath.row] shortName:NO bundle:tweakBundle];
            
            //label = [DockXHelper labelFromArray:self.currentOrder[1] atIndex:indexPath.row];
            image = [DockXHelper imageFromArray:self.currentOrder[1] atIndex:indexPath.row withSystemColor:YES completion:^(BOOL thirteen, BOOL customPath){
                isThirteen = thirteen;
                isCustomImagePath = customPath;
                dispatch_semaphore_signal(smp);
            }];
            dispatch_semaphore_wait(smp, DISPATCH_TIME_FOREVER);
            if (!isThirteen && isCustomImagePath){
                [cell.imageView setTintColor:[UIColor blackColor]];
            }
            break;
        }
        case 2: {
            if (self.extrasOptions == nil || [self.extrasOptions count] <= indexPath.row)
                return nil;
            if (indexPath.row >= [self.extrasOptions count]){
                [self setCompatibiltyWarning];
                cell.textLabel.text = LOCALIZED(@"INCOMPATIBLE_RESET");
                cell.imageView.image = nil;
                self.tableView.userInteractionEnabled = NO;
                return cell;
            }
            label = [DockXHelper labelFromArray:self.extrasOptions atIndex:indexPath.row];
            image = [DockXHelper imageFromArray:self.extrasOptions atIndex:indexPath.row withSystemColor:YES completion:^(BOOL thirteen, BOOL customPath){
                isThirteen = thirteen;
                isCustomImagePath = customPath;
                dispatch_semaphore_signal(smp);
            }];
            dispatch_semaphore_wait(smp, DISPATCH_TIME_FOREVER);
            if (!isThirteen && isCustomImagePath){
                [cell.imageView setTintColor:[UIColor blackColor]];
            }
            break;
        }
    }
    cell.textLabel.text = label;
    cell.imageView.image = image;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section < 2){
        
        GesturePickerController *gesturePickerController = [[GesturePickerController alloc] init];
        
        gesturePickerController.fullOrder = @[self.firstOrder, self.fullOrder];
        gesturePickerController.identifier = self.currentOrder[indexPath.section][indexPath.row][@"selector"];
        gesturePickerController.title = [DockXHelper localizedStringForActionNamed:self.currentOrder[indexPath.section][indexPath.row][@"selector"] shortName:NO bundle:tweakBundle];
        
        [gesturePickerController setRootController: [self rootController]];
        [gesturePickerController setParentController: [self parentController]];
        [self pushController:gesturePickerController];
        
    }else{
        if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"keyboardType"]){
            KeyboardTypeOptions *kbTypeOptions = [[KeyboardTypeOptions alloc] init];
            [kbTypeOptions setRootController: [self rootController]];
            [kbTypeOptions setParentController: [self parentController]];
            [self pushController:kbTypeOptions];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"shellCommand"]){
            SnippetEntryController *snippetEntryController = [[SnippetEntryController alloc] init];
            snippetEntryController.entryID = @"runCommandAction:";
            [snippetEntryController setRootController: [self rootController]];
            [snippetEntryController setParentController: [self parentController]];
            [self pushController:snippetEntryController];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"insertText"]){
            InsertTextEntryController *insertTextController = [[InsertTextEntryController alloc] init];
            insertTextController.entryID = @"insertTextAction:";
            [insertTextController setRootController: [self rootController]];
            [insertTextController setParentController: [self parentController]];
            [self pushController:insertTextController];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"prevWord"]){
            CursorMoveAndSelectEntryController *cursorMoveAndSelectController = [[CursorMoveAndSelectEntryController alloc] init];
            cursorMoveAndSelectController.entryID = @"moveCursorPreviousWordAction:";
            [cursorMoveAndSelectController setRootController: [self rootController]];
            [cursorMoveAndSelectController setParentController: [self parentController]];
            [self pushController:cursorMoveAndSelectController];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"nextWord"]){
            CursorMoveAndSelectEntryController *cursorMoveAndSelectController = [[CursorMoveAndSelectEntryController alloc] init];
            cursorMoveAndSelectController.entryID = @"moveCursorNextWordAction:";
            [cursorMoveAndSelectController setRootController: [self rootController]];
            [cursorMoveAndSelectController setParentController: [self parentController]];
            [self pushController:cursorMoveAndSelectController];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"lineStart"]){
            CursorMoveAndSelectEntryController *cursorMoveAndSelectController = [[CursorMoveAndSelectEntryController alloc] init];
            cursorMoveAndSelectController.entryID = @"moveCursorStartOfLineAction:";
            [cursorMoveAndSelectController setRootController: [self rootController]];
            [cursorMoveAndSelectController setParentController: [self parentController]];
            [self pushController:cursorMoveAndSelectController];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"lineEnd"]){
            CursorMoveAndSelectEntryController *cursorMoveAndSelectController = [[CursorMoveAndSelectEntryController alloc] init];
            cursorMoveAndSelectController.entryID = @"moveCursorEndOfLineAction:";
            [cursorMoveAndSelectController setRootController: [self rootController]];
            [cursorMoveAndSelectController setParentController: [self parentController]];
            [self pushController:cursorMoveAndSelectController];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"startOfParagraph"]){
            CursorMoveAndSelectEntryController *cursorMoveAndSelectController = [[CursorMoveAndSelectEntryController alloc] init];
            cursorMoveAndSelectController.entryID = @"moveCursorStartOfParagraphAction:";
            [cursorMoveAndSelectController setRootController: [self rootController]];
            [cursorMoveAndSelectController setParentController: [self parentController]];
            [self pushController:cursorMoveAndSelectController];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"endOfParagraph"]){
            CursorMoveAndSelectEntryController *cursorMoveAndSelectController = [[CursorMoveAndSelectEntryController alloc] init];
            cursorMoveAndSelectController.entryID = @"moveCursorEndOfParagraphAction:";
            [cursorMoveAndSelectController setRootController: [self rootController]];
            [cursorMoveAndSelectController setParentController: [self parentController]];
            [self pushController:cursorMoveAndSelectController];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"startOfSentence"]){
            CursorMoveAndSelectEntryController *cursorMoveAndSelectController = [[CursorMoveAndSelectEntryController alloc] init];
            cursorMoveAndSelectController.entryID = @"moveCursorStartOfSentenceAction:";
            [cursorMoveAndSelectController setRootController: [self rootController]];
            [cursorMoveAndSelectController setParentController: [self parentController]];
            [self pushController:cursorMoveAndSelectController];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"endOfSentence"]){
            CursorMoveAndSelectEntryController *cursorMoveAndSelectController = [[CursorMoveAndSelectEntryController alloc] init];
            cursorMoveAndSelectController.entryID = @"moveCursorEndOfSentenceAction:";
            [cursorMoveAndSelectController setRootController: [self rootController]];
            [cursorMoveAndSelectController setParentController: [self parentController]];
            [self pushController:cursorMoveAndSelectController];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"delete"]){
            DeleteOptions *deleteOptions = [[DeleteOptions alloc] init];
            deleteOptions.entryID = @"deleteAction::";
            [deleteOptions setRootController: [self rootController]];
            [deleteOptions setParentController: [self parentController]];
            [self pushController:deleteOptions];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"deleteForward"]){
            DeleteOptions *deleteOptions = [[DeleteOptions alloc] init];
            deleteOptions.entryID = @"deleteForwardAction::";
            [deleteOptions setRootController: [self rootController]];
            [deleteOptions setParentController: [self parentController]];
            [self pushController:deleteOptions];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"globe"]){
            GlobeOptions *globeOptions = [[GlobeOptions alloc] init];
            [globeOptions setRootController: [self rootController]];
            [globeOptions setParentController: [self parentController]];
            [self pushController:globeOptions];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"paste"]){
            PasteOptions *pasteOptions = [[PasteOptions alloc] init];
            [pasteOptions setRootController: [self rootController]];
            [pasteOptions setParentController: [self parentController]];
            [self pushController:pasteOptions];
        }
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (self.tableView == nil)
        return;
    
    if (self.currentOrder[0] == nil)
        [self updateOrder:NO];
    
    NSString *objectToMove = [self.currentOrder[0] objectAtIndex:sourceIndexPath.row];
    [self.currentOrder[0] removeObjectAtIndex:sourceIndexPath.row];
    [self.currentOrder[0] insertObject:objectToMove atIndex:destinationIndexPath.row];
    [self.tableView reloadData];
    [self writeToFile];
    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return [self.currentOrder[0] count] == 1?NO:YES;
        case 1:
            return NO;
        default:
            return NO;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0: {
            return YES;
            break;
        }
        case 1: {
            return YES;
            break;
        }
        default:
            return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            if (editingStyle == UITableViewCellEditingStyleDelete) {
                // Delete the row from the data source
                [tableView beginUpdates];
                [self.currentOrder[1] addObject:self.currentOrder[0][indexPath.row]];
                [self.currentOrder[0] removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                //[tableView endUpdates];
                
                //[tableView beginUpdates];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.currentOrder[1] count] - 1 inSection:1];
                [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                [tableView endUpdates];
                [self writeToFile];
                
            }
        }
            break;
        case 1: {
            if (editingStyle == UITableViewCellEditingStyleInsert) {
                [tableView beginUpdates];
                [self.currentOrder[0] addObject:self.currentOrder[1][indexPath.row]];
                [self.currentOrder[1] removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.currentOrder[0] count] - 1  inSection:0];
                [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                [tableView endUpdates];
                [self writeToFile];
                
                
            }
            
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return [self.currentOrder[0] count] == 1?UITableViewCellEditingStyleNone:UITableViewCellEditingStyleDelete;
        case 1:
            return [self.currentOrder[0] count] == 1?UITableViewCellEditingStyleInsert:UITableViewCellEditingStyleInsert;
            //return [self.currentOrder[0] count] == maxShortcuts?UITableViewCellEditingStyleNone:UITableViewCellEditingStyleInsert;
        default:
            return UITableViewCellEditingStyleNone;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


- (void)writeToFile {
    
    PSSpecifier *defaultOrderSpecifier = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSLinkListCell edit:nil];
    [defaultOrderSpecifier setProperty:self.currentOrder forKey:@"default"];
    [defaultOrderSpecifier setProperty:kIdentifier forKey:@"defaults"];
    [defaultOrderSpecifier setProperty:@"shortcuts" forKey:@"key"];
    [defaultOrderSpecifier setProperty:@"" forKey:@"label"];
    [defaultOrderSpecifier setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
    [self setPreferenceValue:self.currentOrder specifier:defaultOrderSpecifier];
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)kPrefsChangedIdentifier, NULL, NULL, YES);
    
}

- (void)updateOrder:(BOOL)reset{
    NSMutableDictionary *prefs = [[[PrefsManager sharedInstance] readPrefs] mutableCopy] ?: [NSMutableDictionary dictionary];
    
    //BOOL newShortcutsAvailable = ([tweakVersion compare:prefs[@"version"] options:NSNumericSearch] == NSOrderedDescending);
    /*
     if (forceDefault){
     [prefs removeObjectForKey:@"shortcuts"];
     prefs[@"version"] = tweakVersion;
     [prefs writeToFile:kPrefsPath atomically:NO];
     }
     */
    //NSMutableDictionary *currentOrderDefault = [[NSMutableDictionary alloc] init];
    ShortcutsGenerator *shortcutsGenerator = [ShortcutsGenerator sharedInstance];
    NSMutableArray *defaultOrderLabel = [[shortcutsGenerator labelName] mutableCopy];
    NSMutableArray *defaultOrderSelector = [[shortcutsGenerator selectorNameForLongPress:NO] mutableCopy];
    NSMutableArray *defaultOrderSelectorLP = [[shortcutsGenerator selectorNameForLongPress:YES] mutableCopy];
    NSMutableArray *defaultOrder12 = [[shortcutsGenerator imageNameArrayForiOS:0] mutableCopy];
    NSMutableArray *defaultOrder13 = [[shortcutsGenerator imageNameArrayForiOS:1] mutableCopy];
    //NSMutableArray *shortLabel = [[shortcutsGenerator shortenedlabelName] mutableCopy];
    
    translomaticInstalled = shortcutsGenerator.translomaticDylibExist;
    
    //self.fullOrder = @[defaultOrderLabel, defaultOrderSelector, defaultOrderSelectorLP, defaultOrder12, defaultOrder13];
    
    
    NSMutableArray *fullOrderDict = [[NSMutableArray alloc] init];
    NSMutableArray *firstOrderDict = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [defaultOrderLabel count]; i++){
        if ( i == 0 || i == 6 || i == 35 | i == 36 || i == 37){
            [firstOrderDict addObject: @{
                @"label" : defaultOrderLabel[i],
                @"images12" : defaultOrder12[i],
                @"images13" : defaultOrder13[i],
                @"selector" : defaultOrderSelector[i],
                @"selectorlp" : defaultOrderSelectorLP[i]
                //@"slabel" : shortLabel[i]
            }];
        }
        [fullOrderDict addObject: @{
            @"label" : defaultOrderLabel[i],
            @"images12" : defaultOrder12[i],
            @"images13" : defaultOrder13[i],
            @"selector" : defaultOrderSelector[i],
            @"selectorlp" : defaultOrderSelectorLP[i]
            //@"slabel" : shortLabel[i]
        }];
    }
    
    self.firstOrder = firstOrderDict;
    self.fullOrder = fullOrderDict;
    
    
    //reset custom long press actions
    if (reset){
        prefs[kCustomActionskey] = @[];
        prefs[kCustomActionsDTkey] = @[];
        prefs[kCustomActionsSTkey] = @[];
        [prefs removeObjectForKey:kCachekey];
        //[prefs removeObjectForKey:kCustomActionskey];
        [[PrefsManager sharedInstance] writePrefs:prefs];
    }
    
    //NSArray *defaultOrder = @[@"Select All", @"Copy", @"Paste", @"Cut", @"Undo", @"Redo"];
    BOOL newShortcutsAvailable = NO;
    if (prefs[@"shortcuts"] && ([prefs[@"shortcuts"] firstObject] != nil)){
        newShortcutsAvailable = defaultOrderLabel.count > ((NSArray *)prefs[@"shortcuts"][0]).count + ((NSArray *)prefs[@"shortcuts"][1]).count;
    }
    self.currentOrder = [NSMutableArray array];
    self.currentOrder[0] = [NSMutableArray array];
    self.currentOrder[1] = [NSMutableArray array];
    if (prefs[@"shortcuts"][0]  && ([prefs[@"shortcuts"][0] firstObject] != nil) && !reset){
        NSMutableArray *currentOrderDefault = [prefs[@"shortcuts"][0] mutableCopy];
        for (NSInteger i = 0; i < [currentOrderDefault count]; i++){
            if ([[currentOrderDefault objectAtIndex:i][@"selector"] isEqualToString:@"copyLogAction:"] && !shortcutsGenerator.copyLogDylibExist) continue;
            if ([[currentOrderDefault objectAtIndex:i][@"selector"] isEqualToString:@"translomaticAction:"] && !shortcutsGenerator.translomaticDylibExist) continue;
            if ([[currentOrderDefault objectAtIndex:i][@"selector"] isEqualToString:@"wasabiAction:"] && !shortcutsGenerator.wasabiDylibExist) continue;
            if ([[currentOrderDefault objectAtIndex:i][@"selector"] isEqualToString:@"pasitheaAction:"] && !shortcutsGenerator.pasitheaDylibExist) continue;
            [self.currentOrder[0] addObject:[currentOrderDefault objectAtIndex:i]];
        }
    }else{
        self.currentOrder[0] = [NSMutableArray array];
        NSMutableArray *defaultOrderDict = [[NSMutableArray alloc] init];
        
        for (int i = 0 ; i < maxdefaultshortcuts ; i++) {
            if ([defaultOrderSelector[i] isEqualToString:@"copyLogAction:"] && !shortcutsGenerator.copyLogDylibExist) continue;
            if ([defaultOrderSelector[i] isEqualToString:@"translomaticAction:"] && !shortcutsGenerator.translomaticDylibExist) continue;
            if ([defaultOrderSelector[i] isEqualToString:@"wasabiAction:"] && !shortcutsGenerator.wasabiDylibExist) continue;
            if ([defaultOrderSelector[i] isEqualToString:@"pasitheaAction:"] && !shortcutsGenerator.pasitheaDylibExist) continue;
            [defaultOrderDict addObject: @{
                @"label" : defaultOrderLabel[i],
                @"images12" : defaultOrder12[i],
                @"images13" : defaultOrder13[i],
                @"selector" : defaultOrderSelector[i],
                @"selectorlp" : defaultOrderSelectorLP[i]
                //@"slabel" : shortLabel[i]
            }];
        }
        self.currentOrder[0] = defaultOrderDict;
    }
    if (prefs[@"shortcuts"][1]  && ([prefs[@"shortcuts"][1] firstObject] != nil) && !reset){
        NSMutableArray *currentOrderDefault = [prefs[@"shortcuts"][1] mutableCopy];
        for (NSInteger i = 0; i < [currentOrderDefault count]; i++){
            if ([[currentOrderDefault objectAtIndex:i][@"selector"] isEqualToString:@"copyLogAction:"] && !shortcutsGenerator.copyLogDylibExist) continue;
            if ([[currentOrderDefault objectAtIndex:i][@"selector"] isEqualToString:@"translomaticAction:"] && !shortcutsGenerator.translomaticDylibExist) continue;
            if ([[currentOrderDefault objectAtIndex:i][@"selector"] isEqualToString:@"wasabiAction:"] && !shortcutsGenerator.wasabiDylibExist) continue;
            if ([[currentOrderDefault objectAtIndex:i][@"selector"] isEqualToString:@"pasitheaAction:"] && !shortcutsGenerator.pasitheaDylibExist) continue;
            [self.currentOrder[1] addObject:[currentOrderDefault objectAtIndex:i]];
        }
        if (newShortcutsAvailable){
            NSMutableArray *fullOrderDict = [[NSMutableArray alloc] init];
            for (int i = 0 ; i < [defaultOrderLabel count] ; i++) {
                if ([[defaultOrderSelector objectAtIndex:i] isEqualToString:@"copyLogAction:"] && !shortcutsGenerator.copyLogDylibExist) continue;
                if ([[defaultOrderSelector objectAtIndex:i] isEqualToString:@"translomaticAction:"] && !shortcutsGenerator.translomaticDylibExist) continue;
                if ([[defaultOrderSelector objectAtIndex:i] isEqualToString:@"wasabiAction:"] && !shortcutsGenerator.wasabiDylibExist) continue;
                if ([[defaultOrderSelector objectAtIndex:i] isEqualToString:@"pasitheaAction:"] && !shortcutsGenerator.pasitheaDylibExist) continue;
                [fullOrderDict addObject: @{
                    @"label" : defaultOrderLabel[i],
                    @"images12" : defaultOrder12[i],
                    @"images13" : defaultOrder13[i],
                    @"selector" : defaultOrderSelector[i],
                    @"selectorlp" : defaultOrderSelectorLP[i]
                    //@"slabel" : shortLabel[i]
                }];
            }
            NSMutableArray *newShortcuts = [NSMutableArray arrayWithArray:fullOrderDict];
            [newShortcuts removeObjectsInArray:self.currentOrder[0]];
            [newShortcuts removeObjectsInArray:self.currentOrder[1]];
            for (NSInteger i = 0; i < [newShortcuts count]; i++){
                [self.currentOrder[1] addObject:[newShortcuts objectAtIndex:i]];
            }
            [[PrefsManager sharedInstance] writePrefs:prefs];
            
            /*
             //[prefs writeToFile:kPrefsPath atomically:NO];
             if ([NSHomeDirectory() isEqualToString:@"/var/mobile"]) {
             CFPreferencesSetMultiple((__bridge CFDictionaryRef)prefs, nil, (CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
             CFPreferencesSynchronize((CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
             } else {
             [prefs writeToFile:kPrefsPath atomically:NO];
             }
             */
        }
    }else if ([prefs[@"shortcuts"][0] count] != defaultOrderLabel.count || reset){
        self.currentOrder[1] = [NSMutableArray array];
        NSMutableArray *defaultOrderDict = [[NSMutableArray alloc] init];
        
        for (int i = maxdefaultshortcuts ; i < [defaultOrderLabel count] ; i++) {
            if ([defaultOrderSelector[i] isEqualToString:@"copyLogAction:"] && !shortcutsGenerator.copyLogDylibExist) continue;
            if ([defaultOrderSelector[i] isEqualToString:@"translomaticAction:"] && !shortcutsGenerator.translomaticDylibExist) continue;
            if ([defaultOrderSelector[i] isEqualToString:@"wasabiAction:"] && !shortcutsGenerator.wasabiDylibExist) continue;
            if ([defaultOrderSelector[i] isEqualToString:@"pasitheaAction:"] && !shortcutsGenerator.pasitheaDylibExist) continue;
            [defaultOrderDict addObject: @{
                @"label" : defaultOrderLabel[i],
                @"images12" : defaultOrder12[i],
                @"images13" : defaultOrder13[i],
                @"selector" : defaultOrderSelector[i],
                @"selectorlp" : defaultOrderSelectorLP[i]
                //@"slabel" : shortLabel[i]
            }];
        }
        self.currentOrder[1] = defaultOrderDict;
    }
    
    NSArray *extrasOptionsLabel = @[LOCALIZED(@"EXTRAS_KEYBOARD_INPUT_BEHAVIOUR"), LOCALIZED(@"EXTRAS_SHELL_COMMANDS"), LOCALIZED(@"EXTRAS_INSERT_TEXT_CONTENT"), LOCALIZED(@"EXTRAS_PREVIOUS_WORD_BEHAVIOUR"), LOCALIZED(@"EXTRAS_NEXT_WORD_BEHAVIOUR"), LOCALIZED(@"EXTRAS_LINE_START_BEHAVIOUR"), LOCALIZED(@"EXTRAS_LINE_END_BEHAVIOUR"), LOCALIZED(@"EXTRAS_START_OF_PARAGRAPH_BEHAVIOUR"), LOCALIZED(@"EXTRAS_END_OF_PARAGRAPH_BEHAVIOUR"), LOCALIZED(@"EXTRAS_START_OF_SENTENCE_BEHAVIOUR"), LOCALIZED(@"EXTRAS_END_OF_SENTENCE_BEHAVIOUR"), LOCALIZED(@"EXTRAS_DELETE_BEHAVIOUR"), LOCALIZED(@"EXTRAS_DELETE_FORWARD_BEHAVIOUR"), LOCALIZED(@"EXTRAS_GLOBE_BEHAVIOUR"), LOCALIZED(@"EXTRAS_PASTE_BEHAVIOUR")];
    NSArray *extrasOptionsID = @[@"keyboardType", @"shellCommand", @"insertText", @"prevWord", @"nextWord", @"lineStart", @"lineEnd", @"startOfParagraph", @"endOfParagraph", @"startOfSentence", @"endOfSentence", @"delete", @"deleteForward", @"globe", @"paste"];
    NSArray *extrasOptions12 = @[@"reachable_full", @"KeyGlyph-command-large", @"messages_writeboard", @"UICalloutBarPreviousArrow", @"UICalloutBarNextArrow", @"KeyGlyph-rtlTab-larg", @"KeyGlyph-tab-large", @"KeyGlyph-return-large", @"KeyGlyph-rtlReturn-large", @"UIMovieScrubberEditingGlassLeft", @"UIMovieScrubberEditingGlassRight", @"delete_portrait", @"delete_portrait", @"globe_dockitem-portrait", @"UIButtonBarKeyboardPaste"];
    NSArray *extrasOptions13 = @[@"number.circle.fill", @"command", @"text.bubble", @"arrow.left.circle.fill", @"arrow.right.circle.fill", @"arrow.left.to.line", @"arrow.right.to.line", @"text.insert", @"text.append", @"decrease.quotelevel", @"increase.quotelevel", @"delete.left", @"delete.right", @"globe", @"doc.on.clipboard"];
    
    NSMutableArray *extrasOptionsDict = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [extrasOptionsLabel count]; i++){
        [extrasOptionsDict addObject: @{
            @"label" : extrasOptionsLabel[i],
            @"images12" : extrasOptions12[i],
            @"images13" : extrasOptions13[i],
            @"identifier" : extrasOptionsID[i],
        }];
    }
    self.extrasOptions = extrasOptionsDict;
    
}

-(void)reset{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DockX" message:LOCALIZED(@"RESET_MESSAGE") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *resetAction = [UIAlertAction actionWithTitle:LOCALIZED(@"RESET_YES") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self updateOrder:YES];
        [self.tableView.tableHeaderView removeFromSuperview];
        self.tableView.tableHeaderView = nil;
        self.tableView.userInteractionEnabled = YES;
        [self.tableView reloadData];
        [self writeToFile];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LOCALIZED(@"RESET_NO") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:resetAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if( sourceIndexPath.section != proposedDestinationIndexPath.section )
    {
        return sourceIndexPath;
    }
    else
    {
        return proposedDestinationIndexPath;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (@available(iOS 11.0, *)){
    }else{
        CGPoint contentOffset = self.tableView.contentOffset;
        contentOffset.y += CGRectGetHeight(self.tableView.tableHeaderView.frame);
        self.tableView.contentOffset = contentOffset;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateOrder:NO];
}

- (void)viewDidLoad {
    tweakBundle = [NSBundle bundleWithPath:bundlePath];
    [tweakBundle load];
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"DockXItemCell"];
    [self.tableView setEditing:YES];
    [self.tableView setAllowsSelection:NO];
    self.tableView.allowsSelectionDuringEditing=YES;
    
    ((UIViewController *)self).title = LOCALIZED(@"SHORTCUTS");
    self.view = self.tableView;
    
    self.resetBtn = [[UIBarButtonItem alloc] initWithTitle:LOCALIZED(@"RESET") style:UIBarButtonItemStylePlain target:self action:@selector(reset)];
    //self.addSnippetBtn.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = self.resetBtn;
    
    
    searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.definesPresentationContext = YES;
    searchController.hidesNavigationBarDuringPresentation = YES;
    //searchController.searchBar.delegate = self;
    searchController.searchBar.placeholder = LOCALIZED(@"SEARCHBAR_PLACEHOLDER");
    [searchController.searchBar setImage:[DockXHelper imageForDockXWithPlaceholder:YES] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    if (@available(iOS 13.0, *)){
        searchController.dimsBackgroundDuringPresentation = NO;
    } else {
        searchController.obscuresBackgroundDuringPresentation = NO;
    }
    
    if (@available(iOS 11.0, *)){
        self.navigationItem.searchController = searchController;
        self.navigationItem.hidesSearchBarWhenScrolling = YES;
    }
    
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    PrefsManager *prefsManager = [PrefsManager sharedInstance];
    NSUInteger tappedCount = [[prefsManager getValueForKey:@"searchedc"] longValue];
    [prefsManager setValue:@(tappedCount + 1) forKey:@"searchedc"];
    if (tappedCount + 1 == searchedCountEaster){
        [DockXHelper showSearchCountEasterAlertFor:self searchController:searchController count:tappedCount+1 delay:0.5];
    }
    return YES;
}

@end


