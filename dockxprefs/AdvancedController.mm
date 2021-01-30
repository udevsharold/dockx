#include "AdvancedController.h"
#include "../DockXHelper.h"
#include "../common.h"

static UISearchController *searchController;
static NSMutableDictionary *settings;
static NSBundle *tweakBundle;

@implementation AdvancedController

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    PrefsManager *prefsManager = [PrefsManager sharedInstance];
    NSUInteger tappedCount = [[prefsManager getValueForKey:@"searchedc"] longValue];
    [prefsManager setValue:@(tappedCount + 1) forKey:@"searchedc"];
    if (tappedCount + 1 == searchedCountEaster){
        [DockXHelper showSearchCountEasterAlertFor:self searchController:searchController count:tappedCount+1 delay:0.5];
    }
    return YES;
}

-(void)viewDidLoad{
    tweakBundle = [NSBundle bundleWithPath:bundlePath];
    [tweakBundle load];
    [super viewDidLoad];
    
    self.resetBtn = [[UIBarButtonItem alloc] initWithTitle:LOCALIZED(@"DEFAULT") style:UIBarButtonItemStylePlain target:self action:@selector(reset)];
    self.navigationItem.rightBarButtonItem = self.resetBtn;
    
    searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.definesPresentationContext = YES;
    searchController.hidesNavigationBarDuringPresentation = YES;
    searchController.searchBar.delegate = self;
    searchController.searchBar.placeholder = LOCALIZED(@"SEARCHBAR_PLACEHOLDER");
    [searchController.searchBar setImage:[DockXHelper imageForDockXWithPlaceholder:YES] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    if (@available(iOS 13.0, *)){
        searchController.dimsBackgroundDuringPresentation = NO;
    } else {
        searchController.obscuresBackgroundDuringPresentation = NO;
    }
    
    if (@available(iOS 11.0, *)){
        self.navigationItem.searchController = searchController;
        self.navigationItem.hidesSearchBarWhenScrolling = NO;
    }
}

-(void)reset{
    NSArray *value = @[@spacingBetweenCellsDefault, @cellsHeightDefault, @cellsRadiusDefault, @leadingOffsetDefault, @trailingOffsetDefault, @heightOffsetDefault, @bottomOffsetDefault, @topInsetDefault, @bottomInsetDefault, @leftInsetDefault, @rightInsetDefault];
    NSArray *iden = @[kCellSpacingkey, kCellHeightkey, kCellRadiuskey, kLeadinfOffsetkey, kTrailingOffsetkey, kHeightOffsetkey, kBottomOffsetkey, kTopInsetkey, kBottomInsetkey, kLeftInsetkey, kRightInsetkey];
    for (PSSpecifier *spec in _specifiers){
        NSUInteger idx = [iden indexOfObject:spec.identifier];
        if (idx != NSNotFound){
            [self setPreferenceValue:value[idx] specifier:spec];
        }
    }
    [self reloadSpecifiers];
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *snippetEntrySpecifiers = [[NSMutableArray alloc] init];
        
        // =============OFFSETS======================
        //spacing
        PSSpecifier *spacingSpecGroup = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"SHORTCUTS") target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [spacingSpecGroup setProperty:LOCALIZED(@"FOOTER_SPACING") forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:spacingSpecGroup];
        
        PSSpecifier *spacingSpec = [PSSpecifier preferenceSpecifierNamed:@"Spacing" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSliderCell edit:nil];
        [spacingSpec setProperty:kCellSpacingkey forKey:@"key"];
        [spacingSpec setProperty:@0 forKey:@"min"];
        [spacingSpec setProperty:@100 forKey:@"max"];
        [spacingSpec setProperty:@YES forKey:@"showValue"];
        [spacingSpec setProperty:@YES forKey:@"isSegmented"];
        [spacingSpec setProperty:@100 forKey:@"segmentCount"];
        [spacingSpec setProperty:@spacingBetweenCellsDefault forKey:@"default"];
        [spacingSpec setProperty:kIdentifier forKey:@"defaults"];
        [spacingSpec setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:spacingSpec];
        
        //height
        PSSpecifier *shortcutsHeightSpecGroup = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [shortcutsHeightSpecGroup setProperty:LOCALIZED(@"FOOTER_HEIGHT") forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:shortcutsHeightSpecGroup];
        
        PSSpecifier *shortcutsHeightSpec = [PSSpecifier preferenceSpecifierNamed:@"Height" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSliderCell edit:nil];
        [shortcutsHeightSpec setProperty:kCellHeightkey forKey:@"key"];
        [shortcutsHeightSpec setProperty:@0 forKey:@"min"];
        [shortcutsHeightSpec setProperty:@100 forKey:@"max"];
        [shortcutsHeightSpec setProperty:@YES forKey:@"showValue"];
        [shortcutsHeightSpec setProperty:@YES forKey:@"isSegmented"];
        [shortcutsHeightSpec setProperty:@100 forKey:@"segmentCount"];
        [shortcutsHeightSpec setProperty:@cellsHeightDefault forKey:@"default"];
        [shortcutsHeightSpec setProperty:kIdentifier forKey:@"defaults"];
        [shortcutsHeightSpec setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:shortcutsHeightSpec];
        
        
        //radius
        PSSpecifier *shortcutsRadiusSpecGroup = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [shortcutsRadiusSpecGroup setProperty:LOCALIZED(@"FOOTER_RADIUS") forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:shortcutsRadiusSpecGroup];
        
        PSSpecifier *shortcutsRadiusSpec = [PSSpecifier preferenceSpecifierNamed:@"Radius" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSliderCell edit:nil];
        [shortcutsRadiusSpec setProperty:kCellRadiuskey forKey:@"key"];
        [shortcutsRadiusSpec setProperty:@0 forKey:@"min"];
        [shortcutsRadiusSpec setProperty:@100 forKey:@"max"];
        [shortcutsRadiusSpec setProperty:@YES forKey:@"showValue"];
        [shortcutsRadiusSpec setProperty:@YES forKey:@"isSegmented"];
        [shortcutsRadiusSpec setProperty:@100 forKey:@"segmentCount"];
        [shortcutsRadiusSpec setProperty:@cellsRadiusDefault forKey:@"default"];
        [shortcutsRadiusSpec setProperty:kIdentifier forKey:@"defaults"];
        [shortcutsRadiusSpec setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:shortcutsRadiusSpec];
        
        
        // =============OFFSETS======================
        //leading
        PSSpecifier *leadingOffsetSpecGroup = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"OFFSETS") target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [leadingOffsetSpecGroup setProperty:LOCALIZED(@"FOOTER_OFFSETS_LEADING") forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:leadingOffsetSpecGroup];
        
        
        PSSpecifier *leadingOffsetSpec = [PSSpecifier preferenceSpecifierNamed:@"Leading" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSliderCell edit:nil];
        [leadingOffsetSpec setProperty:kLeadinfOffsetkey forKey:@"key"];
        [leadingOffsetSpec setProperty:@-200 forKey:@"min"];
        [leadingOffsetSpec setProperty:@200 forKey:@"max"];
        [leadingOffsetSpec setProperty:@YES forKey:@"showValue"];
        [leadingOffsetSpec setProperty:@YES forKey:@"isSegmented"];
        [leadingOffsetSpec setProperty:@400 forKey:@"segmentCount"];
        [leadingOffsetSpec setProperty:@leadingOffsetDefault forKey:@"default"];
        [leadingOffsetSpec setProperty:kIdentifier forKey:@"defaults"];
        [leadingOffsetSpec setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:leadingOffsetSpec];
        
        //Trailing
        PSSpecifier *trailingOffsetSpecGroup = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [trailingOffsetSpecGroup setProperty:LOCALIZED(@"FOOTER_OFFSETS_TRAILING") forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:trailingOffsetSpecGroup];
        
        PSSpecifier *trailingOffsetSpec = [PSSpecifier preferenceSpecifierNamed:@"Trailing" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSliderCell edit:nil];
        [trailingOffsetSpec setProperty:kTrailingOffsetkey forKey:@"key"];
        [trailingOffsetSpec setProperty:@-200 forKey:@"min"];
        [trailingOffsetSpec setProperty:@200 forKey:@"max"];
        [trailingOffsetSpec setProperty:@YES forKey:@"showValue"];
        [trailingOffsetSpec setProperty:@YES forKey:@"isSegmented"];
        [trailingOffsetSpec setProperty:@400 forKey:@"segmentCount"];
        [trailingOffsetSpec setProperty:@trailingOffsetDefault forKey:@"default"];
        [trailingOffsetSpec setProperty:kIdentifier forKey:@"defaults"];
        [trailingOffsetSpec setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:trailingOffsetSpec];
        
        //Height
        PSSpecifier *heightOffsetSpecGroup = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [heightOffsetSpecGroup setProperty:LOCALIZED(@"FOOTER_HEIGHT") forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:heightOffsetSpecGroup];
        
        PSSpecifier *heightOffsetSpec = [PSSpecifier preferenceSpecifierNamed:@"Left Offset" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSliderCell edit:nil];
        [heightOffsetSpec setProperty:kHeightOffsetkey forKey:@"key"];
        [heightOffsetSpec setProperty:@-200 forKey:@"min"];
        [heightOffsetSpec setProperty:@200 forKey:@"max"];
        [heightOffsetSpec setProperty:@YES forKey:@"showValue"];
        [heightOffsetSpec setProperty:@YES forKey:@"isSegmented"];
        [heightOffsetSpec setProperty:@400 forKey:@"segmentCount"];
        [heightOffsetSpec setProperty:@heightOffsetDefault forKey:@"default"];
        [heightOffsetSpec setProperty:kIdentifier forKey:@"defaults"];
        [heightOffsetSpec setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:heightOffsetSpec];
        
        //bottom
        PSSpecifier *bottomOffsetSpecGroup = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [bottomOffsetSpecGroup setProperty:LOCALIZED(@"FOOTER_OFFSETS_BOTTOM") forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:bottomOffsetSpecGroup];
        
        PSSpecifier *bottomOffsetSpec = [PSSpecifier preferenceSpecifierNamed:@"Bottom Offset" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSliderCell edit:nil];
        [bottomOffsetSpec setProperty:kBottomOffsetkey forKey:@"key"];
        [bottomOffsetSpec setProperty:@-200 forKey:@"min"];
        [bottomOffsetSpec setProperty:@200 forKey:@"max"];
        [bottomOffsetSpec setProperty:@YES forKey:@"showValue"];
        [bottomOffsetSpec setProperty:@YES forKey:@"isSegmented"];
        [bottomOffsetSpec setProperty:@400 forKey:@"segmentCount"];
        [bottomOffsetSpec setProperty:@bottomOffsetDefault forKey:@"default"];
        [bottomOffsetSpec setProperty:kIdentifier forKey:@"defaults"];
        [bottomOffsetSpec setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:bottomOffsetSpec];
        
        //Notice
        PSSpecifier *noticeSpecGroup = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [noticeSpecGroup setProperty:LOCALIZED(@"FOOTER_OFFSETS_NOTICE") forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:noticeSpecGroup];
        
        //==============EMPTY GROUP=================
        PSSpecifier *emptySpecGroup = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [snippetEntrySpecifiers addObject:emptySpecGroup];
        
        // =============INSETS======================
        //Top
        PSSpecifier *topInsetSpecGroup = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"INSETS") target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [topInsetSpecGroup setProperty:LOCALIZED(@"FOOTER_INSETS_TOP") forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:topInsetSpecGroup];
        
        
        PSSpecifier *topInsetSpec = [PSSpecifier preferenceSpecifierNamed:@"Top Inset" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSliderCell edit:nil];
        [topInsetSpec setProperty:@"topinset" forKey:@"key"];
        [topInsetSpec setProperty:@-200 forKey:@"min"];
        [topInsetSpec setProperty:@200 forKey:@"max"];
        [topInsetSpec setProperty:@YES forKey:@"showValue"];
        [topInsetSpec setProperty:@YES forKey:@"isSegmented"];
        [topInsetSpec setProperty:@400 forKey:@"segmentCount"];
        [topInsetSpec setProperty:@topInsetDefault forKey:@"default"];
        [topInsetSpec setProperty:kIdentifier forKey:@"defaults"];
        [topInsetSpec setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:topInsetSpec];
        
        //Bottom
        PSSpecifier *bottomInsetSpecGroup = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [bottomInsetSpecGroup setProperty:LOCALIZED(@"FOOTER_INSETS_BOTTOM") forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:bottomInsetSpecGroup];
        
        PSSpecifier *bottomInsetSpec = [PSSpecifier preferenceSpecifierNamed:@"Bottom Inset" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSliderCell edit:nil];
        [bottomInsetSpec setProperty:@"bottominset" forKey:@"key"];
        [bottomInsetSpec setProperty:@-200 forKey:@"min"];
        [bottomInsetSpec setProperty:@200 forKey:@"max"];
        [bottomInsetSpec setProperty:@YES forKey:@"showValue"];
        [bottomInsetSpec setProperty:@YES forKey:@"isSegmented"];
        [bottomInsetSpec setProperty:@400 forKey:@"segmentCount"];
        [bottomInsetSpec setProperty:@bottomInsetDefault forKey:@"default"];
        [bottomInsetSpec setProperty:kIdentifier forKey:@"defaults"];
        [bottomInsetSpec setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:bottomInsetSpec];
        
        //Left
        PSSpecifier *leftInsetSpecGroup = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [leftInsetSpecGroup setProperty:LOCALIZED(@"FOOTER_INSETS_LEFT") forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:leftInsetSpecGroup];
        
        PSSpecifier *leftInsetSpec = [PSSpecifier preferenceSpecifierNamed:@"Left Inset" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSliderCell edit:nil];
        [leftInsetSpec setProperty:@"leftinset" forKey:@"key"];
        [leftInsetSpec setProperty:@-200 forKey:@"min"];
        [leftInsetSpec setProperty:@200 forKey:@"max"];
        [leftInsetSpec setProperty:@YES forKey:@"showValue"];
        [leftInsetSpec setProperty:@YES forKey:@"isSegmented"];
        [leftInsetSpec setProperty:@400 forKey:@"segmentCount"];
        [leftInsetSpec setProperty:@leftInsetDefault forKey:@"default"];
        [leftInsetSpec setProperty:kIdentifier forKey:@"defaults"];
        [leftInsetSpec setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:leftInsetSpec];
        
        //Right
        PSSpecifier *rightInsetSpecGroup = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [rightInsetSpecGroup setProperty:LOCALIZED(@"FOOTER_INSETS_RIGHT") forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:rightInsetSpecGroup];
        
        PSSpecifier *rightInsetSpec = [PSSpecifier preferenceSpecifierNamed:@"Right Inset" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSliderCell edit:nil];
        [rightInsetSpec setProperty:@"rightinset" forKey:@"key"];
        [rightInsetSpec setProperty:@-200 forKey:@"min"];
        [rightInsetSpec setProperty:@200 forKey:@"max"];
        [rightInsetSpec setProperty:@YES forKey:@"showValue"];
        [rightInsetSpec setProperty:@YES forKey:@"isSegmented"];
        [rightInsetSpec setProperty:@400 forKey:@"segmentCount"];
        [rightInsetSpec setProperty:@rightInsetDefault forKey:@"default"];
        [rightInsetSpec setProperty:kIdentifier forKey:@"defaults"];
        [rightInsetSpec setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:rightInsetSpec];
        
        
        
        _specifiers = snippetEntrySpecifiers;
        
        
        if (!settings) settings = [[[PrefsManager sharedInstance] readPrefs] mutableCopy];
        
    }
    
    return _specifiers;
}

@end
