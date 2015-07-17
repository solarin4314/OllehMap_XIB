/**
 @section Program 프로그램명
 - 프로그램명 :  OllehMap \n
 - 프로그램 내용 : 맵 정보 서비스 
 @section 개발 업체 정보 
 - 업체정보 :  KTH
 - 작성일 : 2011-12-07
 @file CommonGW.h
 @class CommonGW
 @brief 길찾기 정보 데이터 클래스
 */ 

#import <Foundation/Foundation.h>
#import "RouteSearch.h"




#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]




@interface CommonGW : NSObject 
{

	NSString* _ERRCODE;			// 에러코드(0:정상처리)
	NSString* _ERRMSG;			// 에러 메시지

    
	RouteSearch *_routeSearch;
	RSPTotalArrayList* _rspTotalArrayList;

    int RPTYPE; // RPTYPE : 0 (자동차) , 1 (대중교통)
}

@property (nonatomic, assign) BOOL isError;
@property (nonatomic, retain) NSString* _ERRCODE;
@property (nonatomic, retain) NSString* _ERRMSG;


@property (nonatomic, assign) RouteSearch* _routeSearch;
@property (nonatomic, assign) RSPTotalArrayList* _rspTotalArrayList;

@property (nonatomic, assign) int RPTYPE;

/**
 @brief 초기화
 */
- (id)init;


@end
