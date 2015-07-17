/**
 @section Program 프로그램명
 - 프로그램명 :  OllehMap \n
 - 프로그램 내용 : 맵 정보 서비스 
 @section 개발 업체 정보 
 - 업체정보 :  KTH
 - 작성일 : 2011-12-07
 @file CommonGW.m
 @class CommonGW
 @brief 길찾기 정보 데이터 클래스
 */ 
#import <UIKit/UIKit.h>
#import "CommonGW.h"

@implementation CommonGW


@synthesize _ERRCODE;
@synthesize _ERRMSG;

@synthesize _routeSearch;
@synthesize _rspTotalArrayList;

@synthesize isError;
@synthesize RPTYPE;

- (id) init 
{
    self = [super init];
	if(self != nil)
    {	
        // init
		_routeSearch = [[RouteSearch alloc] init];
		_rspTotalArrayList = [[RSPTotalArrayList alloc] init];
		
	}
	return self;
}

+ (id) parser 
{
	return [[[[self class] alloc] init] autorelease];
}

@end
