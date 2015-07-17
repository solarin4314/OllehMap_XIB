
/*
 *  PolygonOverlay.h
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
 * PolygonOverlay: Polygon Overlay class.
 */
@interface PolygonOverlay : VectorOverlay
{
	CoordList* coordList;
	CGColorRef fillColor;
    
    NSMutableArray *_interiorPolygons;//KML Layer
}

/**
 * polygon의 Coord List.
 */
@property (nonatomic, retain) CoordList* coordList;

/**
 * PolygonOverlay의 fill color.
 */
@property (nonatomic) CGColorRef fillColor;

/**
 * PolygonOverlay 에 내부 polygon 을 그리기 위한 한개 이상의 coordlist들이 포함된 배열.
 */
@property (nonatomic, readonly) NSMutableArray *_interiorPolygons;//KML Layer

/**
 * PolygonOverlay의 초기화 함수.
 */
-(id)init; 

/**
 * PolygonOverlay를 coord list와 함께 초기화.
 * @param coordList :coord list
 */
-(id)initWithCoordList:(CoordList*)coordList;

/**
 * PolygonOverlay 내부에 그릴 coord list들을 초기화.
 * @param interiorPolygons : 하나 이상의 coord list들의 배열
 */
- (void)interiorPolygonWithCoordinates:(NSArray *)CoordLists;//KML Layer

@end

