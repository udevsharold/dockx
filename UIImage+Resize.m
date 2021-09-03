#import "common.h"
#import "UIImage+Resize.h"

@implementation UIImage (Resize)

+(UIImage *)imageWithImage:(UIImage *)image resize:(CGSize)newSize{
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:newSize];
    UIImage *newImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext*_Nonnull myContext) {
        [image drawInRect:(CGRect) {.origin = CGPointZero, .size = newSize}];
    }];
    return [newImage imageWithRenderingMode:image.renderingMode];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize inRect:(CGRect)rect{
    
    //Determine whether the screen is retina
    if ([[UIScreen mainScreen] scale] == 2.0) {
        UIGraphicsBeginImageContextWithOptions(newSize, YES, 2.0);
    }else{
        UIGraphicsBeginImageContext(newSize);
    }
    
    //Draw image in provided rect
    [image drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //Pop this context
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
    return [UIImage imageWithImage:image scaledToSize:newSize inRect:(CGRect) {.origin = CGPointZero, .size = newSize}];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToFitToSize:(CGSize)newSize{
    
    //Only scale images down
    if (image.size.width < newSize.width && image.size.height < newSize.height){
        return [image copy];
    }
    
    //Determine the scale factors
    CGFloat widthScale = newSize.width/image.size.width;
    CGFloat heightScale = newSize.height/image.size.height;
    CGFloat scaleFactor;
    
    //The smaller scale factor will scale more (0 < scaleFactor < 1) leaving the other dimension inside the newSize rect
    
    widthScale < heightScale ? (scaleFactor = widthScale) : (scaleFactor = heightScale);
    CGSize scaledSize = CGSizeMake(image.size.width * scaleFactor, image.size.height * scaleFactor);
    
    //Scale the image
    return [UIImage imageWithImage:image scaledToSize:scaledSize inRect:CGRectMake(0.0, 0.0, scaledSize.width, scaledSize.height)];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillToSize:(CGSize)newSize{
    
    //Only scale images down
    if (image.size.width < newSize.width && image.size.height < newSize.height) {
        return [image copy];
    }
    
    //Determine the scale factors
    CGFloat widthScale = newSize.width/image.size.width;
    CGFloat heightScale = newSize.height/image.size.height;
    CGFloat scaleFactor;
    
    //The larger scale factor will scale less (0 < scaleFactor < 1) leaving the other dimension hanging outside the newSize rect
    widthScale > heightScale ? (scaleFactor = widthScale) : (scaleFactor = heightScale);
    CGSize scaledSize = CGSizeMake(image.size.width * scaleFactor, image.size.height * scaleFactor);
    
    //Create origin point so that the center of the image falls into the drawing context rect (the origin will have negative component).
    CGPoint imageDrawOrigin = CGPointMake(0, 0);
    widthScale > heightScale ?  (imageDrawOrigin.y = (newSize.height - scaledSize.height) * 0.5) :
    (imageDrawOrigin.x = (newSize.width - scaledSize.width) * 0.5);
    
    //Create rect where the image will draw
    CGRect imageDrawRect = CGRectMake(imageDrawOrigin.x, imageDrawOrigin.y, scaledSize.width, scaledSize.height);
    
    //The imageDrawRect is larger than the newSize rect, where the imageDraw origin is located defines what part of
    
    //the image will fall into the newSize rect.
    return [UIImage imageWithImage:image scaledToSize:newSize inRect:imageDrawRect];
}


@end
