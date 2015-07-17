//
//  MyImageCropViewController.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 9. 27..
//
//

#import <UIKit/UIKit.h>
//iPhone5
#import "uiviewcontroller+is4inch.h"

@interface MyImageCropViewController : UIViewController
{
    UIImageView *_cropImageView;
}
- (void) drawImageWithCameraRoll :(NSDictionary*)info;
@end
