
/*
 *  MeasureOverlay.h
 *  KMapSDK
 *
 *  Created by Song Hyun Seob on 10. 07. 19.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>

#import "VectorOverlay.h"
#import "PolylineOverlay.h"
#import "LabelOverlay.h"

/**
 * MeasureOverlay: Measure Overlay class.
 */
@interface MeasureOverlay : VectorOverlay
{
	CoordList*     coordList;
	
	CGColorRef fillColor;
	
	CGColorRef nodeFillColor;
	CGColorRef nodeStrokeColor;
	
	int measureType;
	
	LabelOverlay* labelOverlay;
	
}

/**
 * CoordList class.
 */
@property (nonatomic, retain) CoordList*     coordList;

/**
 * fill color.
 */
@property (nonatomic, assign) CGColorRef fillColor;

/**
 * node fill color.
 */
@property (nonatomic, assign) CGColorRef nodeFillColor;

/**
 * node stroke color.
 */
@property (nonatomic, assign) CGColorRef nodeStrokeColor;

/**
 * MeasureOverlay를 type과 함께 초기화 한다.
 * @param type : type(0:distance, 1: area)
 */
-(id)initWithType:(int)type; 

/**
 * MeasureOverlay를 coord list,type과 함께 초기화 한다.
 * @param coordList :CoordList class
 * @param type :type(0:distance, 1: area)
 */
-(id)initWithCoordList:(CoordList*)coordList Type:(int)type;

/**
 * coord 정보를 추가한다.
 * @param coord :추가할 coord
 */
-(void)addCoord:(Coord)coord; 

/**
 * coord count를 반환한다.
 * @return coord count
 */
-(int)coordCount;

/**
 * coord 정보를  반환한다.
 * @param index :반환받을 index
 * @return coord
 */
-(Coord)getCoord:(int)index; 

/**
 * measure 정보가 올바른지 반환한다.
 * @return measure 정보가 올바른지 여부.
 */
-(BOOL)isValidMeasure;

@end

