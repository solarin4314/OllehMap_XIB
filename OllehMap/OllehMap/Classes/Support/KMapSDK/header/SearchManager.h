//
//  SearchManager.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 17..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseData.h"
#import "ParamBase.h"
#import "ParamRec.h"
#import "ParamPoly.h"
#import "ParamAddr.h"
#import "ParamRadius.h"
#import "ParamNear.h"
#import "ParamLine.h"
#import "ParamDetailPoi.h"
#import "ParamGeocode.h"
#import "ParamRgeocode.h"
#import "ParamAddrToNaddr.h"
#import "ParamConvertCoord.h"
#import "ParamGeocodeByStep.h"
#import "ParamSearchRoute.h"

//! SearchManager Class
/*!
 
 */
@interface SearchManager : NSObject {
	NSString *userkey;
	NSString *reqip;
	NSString *baseurl;
	
}
@property (nonatomic, retain) NSString *userkey;
@property (nonatomic, retain) NSString *reqip;
@property (nonatomic, retain) NSString *baseurl;

- (id)initWithServerInfo:(NSString *)userkey reqip:(NSString *)reqip baseurl:(NSString *)baseurl;
- (ResponseData *)query:(ParamBase *) param searchType:(SearchType) type;
- (ResponseData *)queryRecByName:(ParamRec *) param;
- (ResponseData *)queryRecByConsonant:(ParamRec *) param;
- (ResponseData *)queryRecByTelNo:(ParamRec *) param;
- (ResponseData *)queryRecByTheme:(ParamRec *) param;
- (ResponseData *)queryPolyByName:(ParamPoly *) param;
- (ResponseData *)queryPolyByConsonant:(ParamPoly *) param;
- (ResponseData *)queryPolyByTelNo:(ParamPoly *) param;
- (ResponseData *)queryPolyByTheme:(ParamPoly *) param;
- (ResponseData *)queryAddrByName:(ParamAddr *) param;
- (ResponseData *)queryAddrByConsonant:(ParamAddr *) param;
- (ResponseData *)queryAddrByTelNo:(ParamAddr *) param;
- (ResponseData *)queryAddrByTheme:(ParamAddr *) param;
- (ResponseData *)queryRadiusByName:(ParamRadius *) param;
- (ResponseData *)queryRadiusByConsonant:(ParamRadius *) param;
- (ResponseData *)queryRadiusByTelNo:(ParamRadius *) param;
- (ResponseData *)queryRadiusByTheme:(ParamRadius *) param;
- (ResponseData *)queryNearByName:(ParamNear *) param;
- (ResponseData *)queryNearByConsonant:(ParamNear *) param;
- (ResponseData *)queryNearByTelNo:(ParamNear *) param;
- (ResponseData *)queryNearByTheme:(ParamNear *) param;
- (ResponseData *)queryLineByName:(ParamLine *) param;
- (ResponseData *)queryLineByConsonant:(ParamLine *) param;
- (ResponseData *)queryLineByTelNo:(ParamLine *) param;
- (ResponseData *)queryLineByTheme:(ParamLine *) param;
- (ResponseData *)themeCodeList;
- (ResponseData *)detailPoiInfo:(ParamDetailPoi *)param;
- (ResponseData *)geocode:(ParamGeocode *)param;
- (ResponseData *)rgeocode:(ParamRgeocode *)param;
- (ResponseData *)addrToNaddr:(ParamAddrToNaddr *)param;
- (ResponseData *)geocodeByStep:(ParamGeocodeByStep *)param;
- (ResponseData *)convertCoord:(ParamConvertCoord *)param;
- (ResponseData *)routeSearch:(ParamSearchRoute *)param;

@end
