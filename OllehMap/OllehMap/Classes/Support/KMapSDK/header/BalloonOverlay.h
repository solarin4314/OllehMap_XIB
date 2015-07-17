
/*
 *  BalloonOverlay.h
 *  KMapSDK
 *
 *  Created by Song Hyun Seob on 10. 07. 19.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>
#import "KGeometry.h"
#import "UserOverlay.h"

/**
 * BalloonOverlay: Balloon Overlay class.
 */
@interface BalloonOverlay : UserOverlay
{
	Overlay* ownerOverlay;
    UIImageView *ctntView;
    UIImageView *arrowView;
    UIButton *button;
    UILabel *label;
}

/**
 * BalloonOverlay의 owner overlay.
 */
@property (nonatomic,retain) Overlay* ownerOverlay;

/**
 * BalloonOverlay를 owner overlay와 size로 초기화 한다.
 * @param ownerOverlay : owner overlay
 * @param size : overlay view size.
 */
- (id)initWithOwner:(Overlay*)ownerOverlay Size:(CGSize)size;

/**
 * BalloonOverlay에 인자로 전달된 문자열을 출력한다.
 * @param title : 문자열
 * @param frame : MapView의 frame
 */
- (void)setBalloonTitle:(NSString *)title frame:(CGRect)frame;


@end

