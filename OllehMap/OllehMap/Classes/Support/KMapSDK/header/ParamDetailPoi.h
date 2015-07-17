//
//  ParamDetailPoi.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 19..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParamBase.h"

//! ParamDetailPoi Class
/*!
 상세 POI 검색메소드의 파라미터를 정의한다.
 DetailPoiInfo
 검색 메소드의 파라미터로 사용된다.
 */
@interface ParamDetailPoi : ParamBase {
	NSString *idpoi;        /**<POI ID*/
}
/**
 idpoi(POI ID) Property (Get/Set 메소드 정의)
 */
@property (nonatomic, retain) NSString *idpoi;

@end
