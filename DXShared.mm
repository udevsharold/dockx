#import "DXShared.h"

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

