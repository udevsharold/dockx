#include "common.h"
#include "DockXHelper.h"

#define UIKitBundleArtwork @"/System/Library/PrivateFrameworks/UIKitCore.framework/Artwork.bundle"

@implementation DockXHelper

+(UIImage *)imageForDockXWithPlaceholder:(BOOL)placeholder{
    if (placeholder){
        return [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/DockXPrefs.bundle/DockX_Placeholder.png"];
    }
    return [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/DockXPrefs.bundle/DockX.png"];
}

+(UIImage *)imageForName:(NSString *)imageName withSystemColor:(BOOL)withSystemColor completion:(void (^)(BOOL isThirteen, BOOL isCustomImagePath))handler{
    UIImage *image;
    NSString *customPrefix = @"CUSTOM_";
    NSString *customImagePath = @"";
    UIColor *systemBlueColor = [UIColor systemBlueColor];
    BOOL isCustomImagePath = [imageName hasPrefix:customPrefix];
    BOOL isThirteen = NO;
    if (isCustomImagePath){
        customImagePath = [imageName substringFromIndex:[customPrefix length]];
    }
    
    if (@available(iOS 13.0, *)){
        isThirteen = YES;
        if (isCustomImagePath){
            if (withSystemColor){
                image = [[UIImage imageWithContentsOfFile:customImagePath] imageWithTintColor:systemBlueColor];
            }else{
                image = [UIImage imageWithContentsOfFile:customImagePath];
            }
        }else{
            image = [UIImage systemImageNamed:imageName];
        }
    }else{
        if (isCustomImagePath){
            //if (withSystemColor){
            //image = [[UIImage imageWithContentsOfFile:customImagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            //}else{
            image = [[UIImage imageWithContentsOfFile:customImagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            //}
        }else{
            image = [UIImage imageNamed:imageName inBundle:[NSBundle bundleWithPath:UIKitBundleArtwork] compatibleWithTraitCollection:NULL];
        }
    }
    if (handler){
        handler(isThirteen, isCustomImagePath);
    }
    return image;
}

+(UIImage *)imageFromArray:(NSArray *)array atIndex:(NSUInteger)index withSystemColor:(BOOL)withSystemColor completion:(void (^)(BOOL isThirteen, BOOL isCustomImagePath))handler{
    UIImage *image;
    __block BOOL isThirteen = NO;
    __block BOOL isCustomImagePath = NO;
    if (@available(iOS 13.0, *)){
        NSArray* imagelistDict = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%@ IN self.@allKeys" , @"images13"]];
        NSArray *imagelist = [imagelistDict valueForKey:@"images13"];
        NSString *imageNameAtIndex = [imagelist objectAtIndex:index];
        
        dispatch_semaphore_t smp = dispatch_semaphore_create(0);
        image = [self imageForName:imageNameAtIndex withSystemColor:withSystemColor completion:^(BOOL thirteen, BOOL customPath){
            isThirteen = thirteen;
            isCustomImagePath = customPath;
            dispatch_semaphore_signal(smp);
        }];
        dispatch_semaphore_wait(smp, DISPATCH_TIME_FOREVER);
        
    }else{
        NSArray* imagelistDict = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%@ IN self.@allKeys" , @"images12"]];
        NSArray *imagelist = [imagelistDict valueForKey:@"images12"];
        NSString *imageNameAtIndex = [imagelist objectAtIndex:index];
        
        dispatch_semaphore_t smp = dispatch_semaphore_create(0);
        image = [self imageForName:imageNameAtIndex withSystemColor:withSystemColor completion:^(BOOL thirteen, BOOL customPath){
            isThirteen = thirteen;
            isCustomImagePath = customPath;
            dispatch_semaphore_signal(smp);
        }];
        dispatch_semaphore_wait(smp, DISPATCH_TIME_FOREVER);
    }
    if (handler){
        handler(isThirteen, isCustomImagePath);
    }
    return image;
}

+(NSString *)labelFromArray:(NSArray *)array atIndex:(NSUInteger)index{
    NSArray* labelTextlistDict = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%@ IN self.@allKeys" , @"label" ]];
    NSArray *labelTextlist = [labelTextlistDict valueForKey:@"label"];
    return [labelTextlist objectAtIndex:index];
}

+(NSString *)actionNameFromArray:(NSArray *)array atIndex:(NSUInteger)index{
    NSArray* labelTextlistDict = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%@ IN self.@allKeys" , @"selector" ]];
    NSArray *labelTextlist = [labelTextlistDict valueForKey:@"selector"];
    return [labelTextlist objectAtIndex:index];
}

+(void)showSearchCountEasterAlertFor:(id)object searchController:(UISearchController *)searchController count:(NSUInteger)count delay:(double)delay{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Fact" message:[NSString stringWithFormat:@"Little did you know you've tapped the search bar %ld times. Have you finally found the look you're looking for? \U0001F92A", count] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [searchController.searchBar becomeFirstResponder];
        }];
        [alert addAction:okAction];
        [object presentViewController:alert animated:YES completion:nil];
    });
}

+(NSString *)localizedStringForActionNamed:(NSString *)actionName shortName:(BOOL)shortName bundle:(NSBundle *)tweakBundle{
    actionName = [actionName stringByReplacingOccurrencesOfString:@"Action:" withString:@""];
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"([a-z])([A-Z])" options:0 error:NULL];
    actionName = [regexp stringByReplacingMatchesInString:actionName options:0 range:NSMakeRange(0, actionName.length) withTemplate:@"$1_$2"];
    if (shortName){
        actionName = [NSString stringWithFormat:@"SHORT_%@", [actionName uppercaseString]];
    }else{
        actionName = [NSString stringWithFormat:@"LONG_%@", [actionName uppercaseString]];
    }
    HBLogDebug(@"localizedStringForActionNamed: %@", actionName);
    return [tweakBundle localizedStringForKey:actionName value:@"" table:nil];
}

+(NSString *)localizedStringOfToastForActionNamed:(NSString *)actionName bundle:(NSBundle *)tweakBundle{
    actionName = [actionName stringByReplacingOccurrencesOfString:@"ActionLP:" withString:@""];
    actionName = [actionName stringByReplacingOccurrencesOfString:@"Action:" withString:@""];
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"([a-z])([A-Z])" options:0 error:NULL];
    actionName = [regexp stringByReplacingMatchesInString:actionName options:0 range:NSMakeRange(0, actionName.length) withTemplate:@"$1_$2"];
    actionName = [NSString stringWithFormat:@"TOAST_%@", [actionName uppercaseString]];
    HBLogDebug(@"localizedStringForActionNamed: %@", actionName);
    return [tweakBundle localizedStringForKey:actionName value:@"" table:nil];
}
@end

