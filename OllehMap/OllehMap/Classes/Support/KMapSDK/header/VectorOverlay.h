
/*
 *  VectorOverlay.h
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
 * kOverlayLineType Vector타입 오버레이 선분 종류 정의
 * kLineType_Solid : 실선
 * kLineType_Dash  : 점선
 */
typedef enum {
    kLineType_Solid = 0,
    kLineType_Dash = 1
}kOverlayLineType;

/**
 * VectorOverlay: Vector Overlay class.
 */
@interface VectorOverlay : Overlay
{
	CGColorRef strokeColor;
	float	   lineWidth;
    kOverlayLineType lineType;
}

/**
 * stroke color.
 */
@property (nonatomic) CGColorRef strokeColor;

/**
 * stroke line width.
 */
@property (nonatomic) float	   lineWidth;

/**
 * stroke line type.
 * kLineType_Solid : 실선 (Default)
 * kLineType_Dash  : 점선
 */
@property (nonatomic) kOverlayLineType lineType;

@end

