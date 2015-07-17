
/*
 *  PolylineOverlay.h
 *  KMapSDK
 *
 *  Created by Song Hyun Seob on 10. 07. 19.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>
#import "VectorOverlay.h"
#import "CoordList.h"

/**
 * PolylineOverlay: Polyline Overlay class.
 */
@interface PolylineOverlay : VectorOverlay
{
	CoordList* coordList;
	BOOL	   rough;
}

/**
 * polyline의 Coord List.
 */
@property (nonatomic, retain) CoordList* coordList;

/**
 * polyline의 경량화.
 */
@property (nonatomic, assign) BOOL rough;

/**
 * PolylineOverlay의 초기화 함수.
 */
-(id)init; 

/**
 * PolylineOverlay를 coord list와 함께 초기화.
 * @param coordList :coord list
 */
-(id)initWithCoordList:(CoordList*)coordList; 

@end

