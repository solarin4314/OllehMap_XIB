/*
 *  KGeometry.h
 *  KMapSDK
 *  Created by Song Hyun Seob on 10. 07. 19.
 *  Copyright 2010 hssong. All rights reserved.
 *
 */

#ifndef _GEOMETRY_DEF_H__
#define _GEOMETRY_DEF_H__

/**
 Coord: coordinate 정보.
 */
typedef struct {
	double x; /**< x value. */
	double y; /**< y value. */
} Coord;


/**
 KBounds: bounds 정보.
 */
typedef struct {
	double minX; /**< minX value. */
	double minY; /**< minY value. */
	double maxX; /**< maxX value. */
	double maxY; /**< maxY value. */
} KBounds;

/**
 KRegion: region 정보.
 */
typedef struct {
	Coord center; /**< Coord value. */
	double			scale; /**< Map zoom scale value. */
	int				level; /**< Map tile current level. */
} KRegion;

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */
	
/**
* Coord struct를 생성한다.
* @param x :x 좌표.
* @param y :y 좌표.
* @return coord strcut. 
 */	
extern Coord CoordMake(double x, double y);

/**
 * KBounds struct를 생성한다.
 * @param minX :min x 좌표.
 * @param minY :min y 좌표.
 * @param maxX :max x 좌표.
 * @param maxY :max y 좌표.
 * @return KBounds strcut. 
 */	
extern KBounds BoundsMake(double minX, double minY,double maxX, double maxY);	

/**
 * KBounds 의 중심점을 반환한다.
 * @param bound :KBound struct.
 * @return 중심점 Coord. 
 */		
extern Coord BoundsCenter(KBounds bound);

/**
 * KBounds 의 폭을 반환한다.
 * @param bound :KBound struct.
 * @return Bounds width. 
 */		
extern double BoundsWidth(KBounds bound);

/**
 * KBounds 의 넓이를 반환한다.
 * @param bound :KBound struct.
 * @return Bound height. 
 */		
extern double BoundsHeight(KBounds bound);		

/**
 * 두 Coord 사이의 간격을 반환한다.
 * @param a :Coord struct.
 * @param b :Coord struct.
 * @return 간격. 
 */			
extern double CoordDistance(Coord a,Coord b);	
#ifdef __cplusplus
}
#endif /* __cplusplus */
	
#endif