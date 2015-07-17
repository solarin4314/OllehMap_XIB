
/*
 *  MarkerOverlay.h
 *  KMapSDK
 *
 *  Created by Song Hyun Seob on 10. 07. 19.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>
#import "KGeometry.h"
#import "ImageOverlay.h"

enum{
	markerType_readPin,
};

/**
 * MarkerOverlay: Marker Overlay class.
 */
@interface MarkerOverlay : ImageOverlay
{
}

/**
 * MarkerOverlay를 marker type과 함께 초기화.
 * @param markerType :marker type (현재 markerType_readPin 만 지원)
 */
- (id)initWithType:(int)markerType;

@end

