#import <UIKit/UIKit.h>

@interface UIImage (Resize)
+(UIImage *)imageWithImage:(UIImage *)image resize:(CGSize)newSize;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToFitToSize:(CGSize)newSize;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillToSize:(CGSize)newSize;
@end
