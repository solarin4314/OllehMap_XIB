//
//  ParamConvertCoord.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 17..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParamBase.h"

//! ParamConvertCoord Class
/*!
 좌표체계 변환 검색메소드의 파라미터를 정의한다.
 ConvertCoord
 검색 메소드의 파라미터로 사용된다.
 좌표체계 정의
 enum {
 kCoordType_UTMK = 0,
 kCoordType_TM_WEST,
 kCoordType_TM_MID,
 kCoordType_TM_EAST,
 kCoordType_KATEC,
 kCoordType_UTM52,
 kCoordType_UTM51,
 kCoordType_WGS84, 
 kCoordType_BESSEL,
 kCoordType_NONE
 };
 typedef NSUInteger CoordType;
 */
@interface ParamConvertCoord : ParamBase {
	double x;                   /**<입력 좌표 X*/
	double y;                   /**<입력 좌표 Y*/
	CoordType inCoordType;      /**<입력 좌표체계*/
	CoordType outCoordType;     /**<출력 좌표체계*/
}
/**
 x(입력 좌표 X) Property (Get/Set 메소드 정의)
 */
@property (assign) double x;
/**
 y(입력 좌표 Y) Property (Get/Set 메소드 정의)
 */
@property (assign) double y;
/**
 inCoordType(입력 좌표체계) Property (Get/Set 메소드 정의)
 */
@property (assign) CoordType inCoordType;
/**
 outCoordType(출력 좌표체계) Property (Get/Set 메소드 정의)
 */
@property (assign) CoordType outCoordType;

@end
