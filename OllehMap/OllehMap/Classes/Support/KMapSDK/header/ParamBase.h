//
//  ParamBase.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 16..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoordList.h"
#import "SearchTypes.h"

//! ParamProtocol Protocol
/*!
 파라메터 관련 클래스의 공통 기능을 정의한다.
 파라메터 중 필수 입력정보의 설정 여부를 검사하는 기능을 정의한다.
 파라메터에 설정된 정보를 바탕으로 조회 URL을 생성하는 기능을 정의한다.
 */
@protocol ParamProtocol

@required
/**
 필수 입력 파라메터의 설정 여부를 검사한다.
 검사결과 필수 입력 파라메커가 입력되지 않으면 NSException을 Throw한다.
 */
-(void)checkParam;
/**
 파라메터에 설정된 정보를 사용하여 조회 URL을 생성한다.
 */
-(NSString *)getRequestURL:(SearchType) type;
@end

//! ParamBase Class
/*!
 파라메터 관련 클래스의 Super Class를 정의한다.
 ParamProtocol을 Implementation하며, 입력 파라메터에 대한 유효성 검사 기능을 정의한다.
 */
@interface ParamBase : NSObject <ParamProtocol> {
}
/**
 KBounds 파라메터의 입력 여부를 검사한다.
 */
- (BOOL)isValidKBounds:(KBounds) data;
/**
 String 파라메터의 입력 여부를 검사한다.
 */
- (BOOL)isValidString:(NSString *) data;
/**
 Integer 파라메터의 입력 여부를 검사한다.
 */
- (BOOL)isValidInteger:(int) data;
/**
 Double 파라메터의 입력 여부를 검사한다.
 */
- (BOOL)isValidDouble:(double) data;
/**
 Coord 파라메터의 입력 여부를 검사한다.
 */
- (BOOL)isValidCoord:(Coord) data;
/**
 CoordList 파라메터의 입력 여부를 검사한다.
 */
- (BOOL)isValidCoordList:(CoordList *) data;
/**
 CoordList의 조회 URL 문자열을 생성한다.
 */
- (NSString *)getCoordListString:(CoordList *) data;
@end
