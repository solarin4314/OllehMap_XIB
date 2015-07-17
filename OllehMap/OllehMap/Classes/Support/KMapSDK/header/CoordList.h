/*
 *  CoordList.h
 *  KMapSDK
 *  Created by Song Hyun Seob on 10. 07. 19.
 *  Copyright 2010 hssong. All rights reserved.
 *
 */
#import <UIKit/UIKit.h>
#import "KGeometry.h"

/**
 * CoordList: Coord list Class.
 */
@interface CoordList : NSObject
{
@private
	void* _data;
    
    Coord leanFirstCoord;//KML layer
    Coord leanSecondCoord;//KML layer
}

/**
 * Coord를 추가한다.
 * @param x :x 좌표
 * @param y :y 좌표
 */
-(void)addPointX:(double)x Y:(double)y; 

/**
 * Coord를 추가한다.
 * @param coord :coord
 */
-(void)addCoord:(Coord)coord; 

/**
 * Coords를 추가한다.
 * @param coords :coord array
 * @param count :courds count
 */
-(void)addCoords:(Coord*)coords Count:(int)count; 

/**
 * CoordList를 추가한다.
 * @param coordList :CoordList 객체
 * @param count :courds count
 */
-(void)addCoordList:(CoordList*)coordList; 


/**
 * Coords를 반환한다.
 * @return courds array pointer.
 */
-(Coord*)coords; 

/**
 * Coords를 count를 반환한다.
 * @return coords count.
 */
-(int)count; 

/**
 * Coords로 이루어진 polyline이 hit되는지 체크한다.
 * @param coord :coord 정보 
 * @param tolerance :tolerance 
 * @return hitting 여부.
 */
-(Coord)hitPolylineTest:(Coord)coord Tolerance:(double)tolerance; 

-(Coord)_checkPolylineCoord:(Coord)coord Tolerance:(double)tolerance;//KML layer
/**
 * Coords로 이루어진 polygon이 hit되는지 체크한다.
 * @param coord :coord 정보 
 * @return hitting 여부.
 */
-(BOOL)hitPolygonTest:(Coord)coord; 

/**
 * Coord 정보를 반환한다.
 * @param index :반환할 index 
 * @return Coord 정보.
 */
-(Coord)getCoord:(int)index; 

/**
 * Coord 정보들의 bound를 반환한다.
 * @return Coords bound.
 */
-(KBounds) getBounds;

/**
 * Coords로 이루어진 polyline의 거리를 반환한다.
 * @return distance.
 */
-(double ) getDistance;

/**
 * Coords로 이루어진 polygon의 면적을 반환한다.
 * @return area.
 */
-(double ) getArea;

@end
