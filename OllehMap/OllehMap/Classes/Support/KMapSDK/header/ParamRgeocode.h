//
//  ParamRgeocode.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 17..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParamBase.h"

//! ParamRgeocode Class
/*!
 Reverse Geocoding 검색의 파라미터를 정의한다.
 Rgeocode
 검색 메소드의 파라미터로 사용된다.
 */
@interface ParamRgeocode : ParamBase {
	double x;                       /**<좌표 X*/
	double y;                       /**<좌표 Y*/
	ReturnPOIType isMPoi;           /**<Main POI반환여부 : (0 = 지번데이터반환, 1 = POI데이터반환)*/
	AddressCodeType addrcdtype;     /**<주소코드 타입 (0 = 법정동, 1 = 행정동)*/
	AddressType newAddr;            /**<새주소반환여부 : (0 = 구조소, 1 = 새주소)*/
	AddressJibunType isJibun;       /**<지번반환여부 : (0 = 행정동까지 반환, 1 = 지번까지반환)*/
}
/**
 isMPoi(Main POI반환여부) Property (Get/Set 메소드 정의)
 */
@property (assign) ReturnPOIType isMPoi;
/**
 addrcdtype(주소코드 타입) Property (Get/Set 메소드 정의)
 */
@property (assign) AddressCodeType addrcdtype;
/**
 newAddr(새주소반환여부) Property (Get/Set 메소드 정의)
 */
@property (assign) AddressType newAddr;
/**
 isJibun(지번반환여부) Property (Get/Set 메소드 정의)
 */
@property (assign) AddressJibunType isJibun;
/**
 x(좌료 X) Property (Get/Set 메소드 정의)
 */
@property (assign) double x;
/**
 y(좌표 Y) Property (Get/Set 메소드 정의)
 */
@property (assign) double y;

@end
