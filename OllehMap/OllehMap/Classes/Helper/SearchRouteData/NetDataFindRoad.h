/**
 @section Program 프로그램명
 - 프로그램명 :  OllehMap \n
 - 프로그램 내용 : 맵 정보 서비스 
 @section 개발 업체 정보 
 - 업체정보 :  KTH
 - 작성일 : 2011-12-07
 @file NetDataFindRoad.h
 @class NetDataFindRoad
 @brief 길찾기 검색 결과 데이터 파싱 클래스 
 */ 

#import <Foundation/Foundation.h>
#import "RouteSearch.h"
#import "CommonGW.h"


@interface NetDataFindRoad : NSObject <NSXMLParserDelegate> {
	NSString* themeID;              ///< 테마 ID
	NSString* page;                 ///< 페이지 정보
	NSString* sortType;             ///< 정렬타입
	
	RouteSearch* tmp_RouteSearch;   ///< 경로검색 데이터
	CommonGW* _netResult;           ///< 경로검색 결과 데이터
    
	BOOL isError;                   ///< 데이터 에러 여부
	int isSearchPublic;             ///< RType = 0 : 자동차 길찾기, RType = 1 : 대중교통 길찾기
	BOOL isRecommend;               ///< 대중교통 추천 존재여부
	BOOL isBus;                     ///< 대중교통 버스 존재여부
	BOOL isSubway;                  ///< 대중교통 지하철 존재여부
	BOOL isBoth;                    ///< 대중교통 버스+지하철 존재여부
	NSMutableString* _xmlValue;     ///< xml 값
}

@property (nonatomic, assign) BOOL isError;
@property (nonatomic, assign) int isSearchPublic;
@property (nonatomic, retain) NSString* themeID;
@property (nonatomic, retain) NSString* page;
@property (nonatomic, retain) NSString* sortType;


/**
 @brief 데이터 파싱
 @param aBodyData 파싱할 데이터
 */
- (id) parserData:(NSData *)aBodyData;

@end
