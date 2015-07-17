
/*
 *  UserOverlay.h
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
 * UserOverlay: User Overlay class(사용자가 overlay를 직접 구성한다).
 */
@interface UserOverlay : Overlay
{
	CGPoint centerOffset;
	UIView* overlayView;
	CGSize	overlaySize;
}

/**
 * UserOverlay를 size와 함께 초기화.
 * @param size :size
 */
- (id)initWithSize:(CGSize)size;

/**
 * UserOverlay의 center offset.
 */
@property (nonatomic) CGPoint centerOffset;

/**
 * UserOverlay의 UIView class(사용자 overlay는 이 위에 올리면(addsubview) 된다.
 */
@property (nonatomic,readonly,retain) UIView* overlayView;

/**
 * UserOverlay의 size.
 */
@property (nonatomic,readonly) CGSize	overlaySize;

@end

