//
//  ParamAddrToNaddr.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 17..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//
#import <Foundation/Foundation.h>
#import "ParamBase.h"

//! ParamAddr Class
/*!
 구주소를 신주소로 변환하는 검색메소드의 파라미터를 정의한다.
 AddrToNaddr
 검색 메소드의 파라미터로 사용된다.
 */
@interface ParamAddrToNaddr : ParamBase {
	NSString *addr;                 /**<구조소명칭 */
	AddressCodeType addrcdtype;     /**<주소코드 타입 (0 = 법정동, 1 = 행정동)*/
}
/**
 addr(구주소명칭) Property (Get/Set 메소드 정의)
 */
@property (nonatomic, retain) NSString *addr;
/**
 addrcdtype(주소코드 타입) Property (Get/Set 메소드 정의)
 */
@property (assign) AddressCodeType addrcdtype;

@end
