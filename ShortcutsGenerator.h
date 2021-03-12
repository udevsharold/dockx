#define copyLogDylib @"/Library/MobileSubstrate/DynamicLibraries/CopyLog.dylib"
#define translomaticDylib @"/Library/MobileSubstrate/DynamicLibraries/Translomatic.dylib"
#define wasabiDylib @"/Library/MobileSubstrate/DynamicLibraries/Wasabi.dylib"
#define pasitheaDylib @"/Library/MobileSubstrate/DynamicLibraries/Pasithea2.dylib"
#define copypastaDylib @"/Library/MobileSubstrate/DynamicLibraries/Copypasta.dylib"

@interface ShortcutsGenerator : NSObject
@property (nonatomic, assign) BOOL copyLogDylibExist;
@property (nonatomic, assign) BOOL translomaticDylibExist;
@property (nonatomic, assign) BOOL wasabiDylibExist;
@property (nonatomic, assign) BOOL pasitheaDylibExist;
@property (nonatomic, assign) BOOL copypastaDylibExist;
+(void)load;
+(instancetype)sharedInstance;
-(instancetype)init;
-(NSArray *)imageNameArrayForiOS:(NSInteger)iosVersion;
-(NSArray *)selectorNameForLongPress:(BOOL)longPress;
-(NSArray *)labelName;
-(NSArray *)shortenedlabelName;
-(BOOL)dylibExist:(NSString *)dylibPath manager:(NSFileManager *)fileManager;
-(NSArray *)thirdPartyImageNameArray:(NSArray *)array foriOS:(NSInteger)iosVersion;
-(NSArray *)thirdPartySelectorNameArray:(NSArray *)array longPress:(BOOL)longPress;
-(NSArray *)thirdPartyLabelNameArray:(NSArray *)array;
-(NSArray *)thirdPartyShortenedLabelNameArray:(NSArray *)array;
-(NSArray *)keyboardTypeLabel;
-(NSArray *)keyboardTypeData;
@end

