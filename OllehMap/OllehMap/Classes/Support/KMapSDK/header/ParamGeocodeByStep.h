//
//  ParamGeocodeByStep.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 17..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParamBase.h"

//! ParamGeocodeByStep Class
/*!
 GeocodeByStep 검색메소드의 파라미터를 정의한다.
 GeocodeByStep
 검색 메소드의 파라미터로 사용된다.
 */
@interface ParamGeocodeByStep : ParamBase {
	NSString *addrcd;               /**<주소코드*/
	AddressCodeType addrcdtype;     /**<주소코드 타입 (0 = 법정동, 1 = 행정동)*/
}
/**
 addrcd(주소코드) Property (Get/Set 메소드 정의)
 */
@property (nonatomic, retain) NSString *addrcd;
/**
 addrcdtype(주소코드 타입) Property (Get/Set 메소드 정의)
 */
@property (assign) AddressCodeType addrcdtype;

@end
