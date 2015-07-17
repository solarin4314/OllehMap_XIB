
/*
 *  CircleOverlay.h
 *  KMapSDK
 *
//  Created by Song Hyun Seob on 10. 07. 19.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>
#import "VectorOverlay.h"
#import "CoordList.h"

/**
 * CircleOverlay: Circle Overlay class.
 */
@interface CircleOverlay : VectorOverlay
{
	double radius;
	CGColorRef fillColor;
}

/**
 * CircleOverlay의 radius.
 */
@property (nonatomic) double radius;

/**
 * CircleOverlay의 fill color.
 */
@property (nonatomic) CGColorRef fillColor;

/**
 * CircleOverlay를 초기화.
 */
-(id)init; 

/**
 * CircleOverlay를 coord, radius와 함께 초기화.
 * @param: coord :중심점.
 * @param: radius :radius.
 */
-(id)initWithCoord:(Coord)coord Radius:(double)radius; 

@end

