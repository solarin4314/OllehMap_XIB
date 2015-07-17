//
//  MyImage.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 9. 26..
//
//

#import <Foundation/Foundation.h>

@interface MyImage : NSObject

+ (UIImage*) getCurrentMyImage;

//+ (UIImage*) merge :(UIImage*)baseImage, ... NS_REQUIRES_NIL_TERMINATION;
+ (UIImage*) merge :(UIImage*)ballon;
+ (UIImage*) merge :(UIImage*)balloon :(UIImage*)custom;

+ (UIImage*) mask :(UIImage*)image :(UIImage*)maskImage;
+ (UIImage *) resizeImage:(UIImage *)image width:(float)resizeWidth height:(float)resizeHeight;
+ (UIImage*) imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect;
+ (UIImage*) rotateWithUp :(UIImage*)src;

@end
