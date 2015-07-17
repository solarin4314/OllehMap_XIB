//
//  ParamSearchRoute.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 17..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParamBase.h"

//! ParamSearchRoute Class
/*!
 경로 검색의 파라미터를 정의한다.
 RouteSearch
 검색 메소드의 파라미터로 사용된다.
 */
@interface ParamSearchRoute : ParamBase {
	double startX;                      /**<시작 좌료 X*/
	double startY;                      /**<시작 좌료 Y*/
	double endX;                        /**<종료 좌료 X*/
	double endY;                        /**<종료 좌료 Y*/
	CoordType coordType;                /**<좌표체계*/
	SearchKind searchKind;              /**<경로검색타입 : (0 = 자동차길찾기, 1 = 대중교통길찾기)*/
	RoutePriority r_priority;           /**<대중교통 경로검색의 우선순위 : (0=추천, 1=버스, 2=지하철, 3=버스+지하철)*/
	PublicRoutePriority p_priority;     /**<자동차 경로검색의 우선순위 : (0=최단거리우선, 1=고속도로우선, 2=무료도록우선, 3=최적경로우선, 4=실시간도로우선)*/
	double vx1;                         /**<경유지 1의 X좌표*/
	double vx2;                         /**<경유지 2의 X좌표*/
	double vx3;                         /**<경유지 3의 X좌표*/
	double vy1;                         /**<경유지 1의 Y좌표*/
	double vy2;                         /**<경유지 2의 Y좌표*/
	double vy3;                         /**<경유지 3의 Y좌표*/
}
/**
 startX(시작 좌료 X) Property (Get/Set 메소드 정의)
 */
@property (assign) double startX;
/**
 startY(시작 좌료 Y) Property (Get/Set 메소드 정의)
 */
@property (assign) double startY;
/**
 endX(종료 좌료 Y) Property (Get/Set 메소드 정의)
 */
@property (assign) double endX;
/**
 endY(종료 좌료 Y) Property (Get/Set 메소드 정의)
 */
@property (assign) double endY;
/**
 coordType(좌표체계 타입) Property (Get/Set 메소드 정의)
 */
@property (assign) CoordType coordType;
/**
 searchKind(경로검색타입) Property (Get/Set 메소드 정의)
 */
@property (assign) SearchKind searchKind;
/**
 r_priority(대중교통 경로검색 우선순위) Property (Get/Set 메소드 정의)
 */
@property (assign) RoutePriority r_priority;
/**
 p_priority(자동차 경로검색 우선순위) Property (Get/Set 메소드 정의)
 */
@property (assign) PublicRoutePriority p_priority;
/**
 vx1(경우지 1의 좌표 X) Property (Get/Set 메소드 정의)
 */
@property (assign) double vx1;
/**
 vx2(경우지 2의 좌표 X) Property (Get/Set 메소드 정의)
 */
@property (assign) double vx2;
/**
 vx3(경우지 3의 좌표 X) Property (Get/Set 메소드 정의)
 */
@property (assign) double vx3;
/**
 vy1(경우지 1의 좌표 Y) Property (Get/Set 메소드 정의)
 */
@property (assign) double vy1;
/**
 vy1(경우지 2의 좌표 Y) Property (Get/Set 메소드 정의)
 */
@property (assign) double vy2;
/**
 vy3(경우지 3의 좌표 Y) Property (Get/Set 메소드 정의)
 */
@property (assign) double vy3;

@end
