
/*
 *  ImageOverlay.h
 *  KMapSDK
 *
 *  Created by Song Hyun Seob on 10. 07. 19.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>
#import "KGeometry.h"
#import "Overlay.h"

/**
 * ImageOverlay: Image Overlay class.
 */
@interface ImageOverlay : Overlay
{
    
	CGPoint centerOffset;
	UIImageView* imageView;
	CGSize	imageSize;
}

/**
 * ImageOverlay를 image와 함께 초기화.
 * @param: image :UIImage class
 */
- (id)initWithImage:(UIImage *)image;

/**
 * ImageOverlay의 중심점으로 부터의 offset.
 */
@property (nonatomic) CGPoint centerOffset;

/**
 * ImageOverlay의 UIImageView.
 */
@property (nonatomic,retain) UIImageView* imageView;

/**
 * ImageOverlay의 image size.
 */
@property (nonatomic) CGSize	imageSize;

@end

