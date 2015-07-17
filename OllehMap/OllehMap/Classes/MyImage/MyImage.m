//
//  MyImage.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 9. 26..
//
//

#import "MyImage.h"

#import "OllehMapStatus.h"

@interface MyImage (private)
@end

@implementation MyImage

+ (UIImage*) getCurrentMyImage
{
    // 내이미지 사용여부
    BOOL userMyImage = [[NSUserDefaults standardUserDefaults] boolForKey:@"UseMyImage"];
    
    // 내이미지 사용
    if (userMyImage)
    {
        // 내이미지 인덱스 (0~3 기본, 4는 커스텀)
        NSInteger myImageIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"MyImageIndex"];
        
        switch (myImageIndex)
        {
            case 1:
                return [MyImage merge:[UIImage imageNamed:@"map_location_default_02.png"]];
            case 2:
                return [MyImage merge:[UIImage imageNamed:@"map_location_default_03.png"]];
            case 3:
                return [MyImage merge:[UIImage imageNamed:@"map_location_default_04.png"]];
            case 4:
            {
                // Documents 경로생성
                NSArray *documentsDirecotryPathArray = NSSearchPathForDirectoriesInDomains(
                                                                                           NSDocumentDirectory,
                                                                                           NSUserDomainMask,
                                                                                           YES);
                NSString *documentImageFilePath = [NSString stringWithFormat:@"%@/MyImage.PNG", [documentsDirecotryPathArray objectAtIndexGC:0]];
                return [MyImage merge:[UIImage imageNamed:@"map_location.png"] :[UIImage imageWithContentsOfFile:documentImageFilePath]];
            }
                
            case 0: // 기본이미지 0번
            default: // 또는 해당하는값 없을 경우 기본사용
                return [MyImage merge:[UIImage imageNamed:@"map_location_default_01.png"]];
        }
        
    }
    
    // 내이미지 사용안함 // 기본이미지 // 이단계까지 왔다면 무조건 기본값으로라도 기본 이미지 리턴하자.
    {
        // MIK.geun :: 20120927 // MapSDK 에서 이미지 사이즈가 달라질경우 깨지는 문제 수정하기 위해 기본이미지도 전체프레임 늘려주도록
        //return [UIImage imageNamed:@"map_spot.png"];
        return [MyImage merge:nil];
    }
    
}

/*
 + (UIImage*)merge:(UIImage *)baseImage, ...
 {
 va_list images;
 va_start(images, baseImage);
 for (UIImage *image = baseImage; image != nil; image = va_arg(images, UIImage *))
 {
 
 }
 va_end(images);
 }
 */

+ (UIImage*) merge:(UIImage *)ballon
{
    return [MyImage merge:ballon :nil];
}
+ (UIImage*) merge:(UIImage *)balloon :(UIImage *)custom
{
    // 레티나 여부
    BOOL isRetina = [OllehMapStatus sharedOllehMapStatus].isRetinaDisplay;
    float ratio = isRetina ? 2.0f : 1.0f;
    
    // 병합할 이미지 베이스 생성
    CGSize baseSize = CGSizeMake(64*ratio, 64*2*ratio);
    UIGraphicsBeginImageContext(baseSize);
    
    //CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 스팟 이미지 하단에 삽입
    UIImage *spotImage = [UIImage imageNamed:@"map_spot.png"];
    CGSize spotImageSize = CGSizeMake(spotImage.size.width*ratio, spotImage.size.height*ratio);
    [spotImage drawInRect:CGRectMake((baseSize.width - spotImageSize.width) / 2,
                                     (baseSize.height - spotImageSize.height) / 2,
                                     spotImageSize.width,
                                     spotImageSize.height)];
    
    
    NSLog(@"spot y : %f", (baseSize.height - spotImageSize.height / 2) + 2.5);
    
    // 존재할 경우 커스텀이미지
    if (custom)
    {
        [custom drawInRect:CGRectMake(13*ratio, 6*ratio-3, custom.size.width*ratio, (custom.size.height*ratio)+2)];
    }
    
    // 풍선 이미지
    if (balloon)
    {
        [balloon drawInRect:CGRectMake(0, 0, balloon.size.width*ratio, balloon.size.height*ratio)];
    }
    
    
    
    UIImage *mergedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //레티나 일 경우 스케일 조절
    if ( isRetina )
        mergedImage = [UIImage imageWithCGImage:[mergedImage CGImage] scale:2.0f orientation:UIImageOrientationUp];
    
    // 합쳐진 이미지 돌려주기
    return mergedImage;
}


+ (UIImage*) mask :(UIImage*)image :(UIImage*)maskImage
{
   	CGImageRef imageRef = [image CGImage];
	CGImageRef maskRef = [maskImage CGImage];
    
	CGImageRef mask = CGImageMaskCreate(
                                        CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef),
                                        NULL, false);
    
	CGImageRef masked = CGImageCreateWithMask(imageRef, mask);
	CGImageRelease(mask);
    
	UIImage *maskedImage = [UIImage imageWithCGImage:masked];
	CGImageRelease(masked);
	
	return maskedImage;
}

+(UIImage *)resizeImage:(UIImage *)image width:(float)resizeWidth height:(float)resizeHeight
{
    UIGraphicsBeginImageContext(CGSizeMake(resizeWidth, resizeHeight));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, resizeHeight);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, resizeWidth, resizeHeight), [image CGImage]);
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(currentContext, 0.0, rect.size.height);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    CGRect clippedRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
    CGContextClipToRect( currentContext, clippedRect);
    CGRect drawRect = CGRectMake(rect.origin.x * -1,rect.origin.y * -1,imageToCrop.size.width,imageToCrop.size.height);
    CGContextDrawImage(currentContext, drawRect, imageToCrop.CGImage);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return cropped;
}

static inline double radians (double degrees) {return degrees * M_PI/180;}
+ (UIImage*) rotateWithUp:(UIImage *)src
{
    UIImage *rotateImage = nil;
    CGSize size = src.size;
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 비트맵 컨텍스트를 사이즈/방향 맞추기..
    CGContextTranslateCTM( context, 0.5f * size.width, 0.5f * size.height ) ;
    
    [ src drawInRect:(CGRect){ { -size.width * 0.5f, -size.height * 0.5f }, size } ] ;
    
    rotateImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return rotateImage;
}

@end
