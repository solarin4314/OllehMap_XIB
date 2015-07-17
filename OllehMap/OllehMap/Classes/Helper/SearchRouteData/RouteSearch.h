/**
 @section Program 프로그램명
 - 프로그램명 :  OllehMap \n
 - 프로그램 내용 : 맵 정보 서비스 
 @section 개발 업체 정보 
 - 업체정보 :  KTH
 - 작성일 : 2011-12-07
 @file RouteSearch.h
 @class RouteSearchCoordItems
 @brief 길찾기 좌표 아이템 클래스
 */ 
#import <Foundation/Foundation.h>
#import "OMClassCategory.h"


@interface RouteSearchCoordItems : NSObject
{
	NSString* _vertexX;         ///> 보간점 x
	NSString* _vertexY;         ///> 보간점 y
}

@property (nonatomic, retain) NSString* _vertexX;
@property (nonatomic, retain) NSString* _vertexY;

@end






/**
 @section Program 프로그램명
 - 프로그램명 :  OllehMap \n
 - 프로그램 내용 : 맵 정보 서비스 
 @section 개발 업체 정보 
 - 업체정보 :  KTH
 - 작성일 : 2011-12-07
 @file RouteSearch.h
 @class RouteSearchDirItems
 @brief 자동차 길찾기 방향 아이템 클래스
 */ 

@interface RouteSearchDirItems : NSObject
{
	NSString* _dir_name;	//방면이름
	NSString* _link_idx;	//인덱스
	NSString* _nextdist;	//다음 링크까지 거리
	NSString* _node_name;	//노드 이름
	NSString* _type;		//
	NSString* _x;
	NSString* _y;
}

@property (nonatomic, retain) NSString* _dir_name;	//방면이름
@property (nonatomic, retain) NSString* _link_idx;	//인덱스
@property (nonatomic, retain) NSString* _nextdist;	//다음 링크까지 거리
@property (nonatomic, retain) NSString* _node_name;	//노드 이름
@property (nonatomic, retain) NSString* _type;		//
@property (nonatomic, retain) NSString* _x;
@property (nonatomic, retain) NSString* _y;

@end









/**
 @class RouteSearchBusStationItems
 @brief 대중교통 길찾기 - 버스정류장 아이템 클래스
 */
@interface RouteSearchBusStationItems : NSObject
{
	NSString* _name;            // 정류장 명칭
	NSString* _stationtype;		// 정류장의 타입 (1: 버스 정류장, 2: 지하철 정류장)
	NSString* _x;               // 	
	NSString* _y;               // 	
}

@property (nonatomic, retain) NSString* _name;              // 정류장 명칭
@property (nonatomic, retain) NSString* _stationtype;		// 정류장의 타입 (1: 버스 정류장, 2: 지하철 정류장)
@property (nonatomic, retain) NSString* _x;	
@property (nonatomic, retain) NSString* _y;	

@end






/**
 @class RouteSearchBusRGItems
 @brief 대중교통 길찾기 - 버스 방향 아이템 클래스
 */
@interface RouteSearchBusRGItems : NSObject
{
	NSString* _rgtype;			// RG type (참고 : 대중교통 길찾기 RG type 정의)
	NSString* _methodtype;			// 대중 교통 이용 방법 (1: 버스 이용, 2: 지하철 이용, 3: 걸어서 이동)
	NSString* _startname;			// rgtype 에 따른 첫번째 정류장 이름 ex) rgtype이 1인 경우 - 버스를 탑승하는 정류장 이름, rgtype이 3인 경우 - 걸어서 이동하기 시작한 정류장 이름, 
	NSString* _endname;			// rgtype 에 따른 마지막 정류장 이름 ex) rgtype이 1인 경우 - 버스를 하차하는 정류장 이름, rgtype이 3인 경우 - 걸어서 이동하는 목적지 정류장 이름
	NSString* _lanename;			// 이용하는 대중 교통의 노선 이름 주) 걸어서 이동하는 경우 이름 없음 "-1"
	NSString* _distance;			// rgtype 1 단위의 이동 거리
	NSString* _distancetype;			// rgtype 1 단위의 이동 거리 타입 (1: Meter 표시, 2: 정류장 개수 표시) ex) 값이 1인 경우 이후 distance 값은 XXXX 미터값이 2인 경우 이후 distance 값은 XX 정류장 이동
	NSString* _x;			// 경로 가이드 중인 대표 위치 X 좌표(지도 중심점 이동)
	NSString* _y;			// 경로 가이드 중인 대표 위치 Y 좌표(지도 중심점 이동)
}

@property (nonatomic, retain) NSString* _rgtype;			// RG type (참고 : 대중교통 길찾기 RG type 정의)
@property (nonatomic, retain) NSString* _methodtype;			// 대중 교통 이용 방법 (1: 버스 이용, 2: 지하철 이용, 3: 걸어서 이동)
@property (nonatomic, retain) NSString* _startname;			// rgtype 에 따른 첫번째 정류장 이름 ex) rgtype이 1인 경우 - 버스를 탑승하는 정류장 이름, rgtype이 3인 경우 - 걸어서 이동하기 시작한 정류장 이름, 
@property (nonatomic, retain) NSString* _endname;			// rgtype 에 따른 마지막 정류장 이름 ex) rgtype이 1인 경우 - 버스를 하차하는 정류장 이름, rgtype이 3인 경우 - 걸어서 이동하는 목적지 정류장 이름
@property (nonatomic, retain) NSString* _lanename;			// 이용하는 대중 교통의 노선 이름 주) 걸어서 이동하는 경우 이름 없음 "-1"
@property (nonatomic, retain) NSString* _distance;			// rgtype 1 단위의 이동 거리
@property (nonatomic, retain) NSString* _distancetype;			// rgtype 1 단위의 이동 거리 타입 (1: Meter 표시, 2: 정류장 개수 표시) ex) 값이 1인 경우 이후 distance 값은 XXXX 미터값이 2인 경우 이후 distance 값은 XX 정류장 이동
@property (nonatomic, retain) NSString* _x;			// 경로 가이드 중인 대표 위치 X 좌표(지도 중심점 이동)
@property (nonatomic, retain) NSString* _y;			// 경로 가이드 중인 대표 위치 Y 좌표(지도 중심점 이동)

@end








/**
 @class RouteSearchSubwayStationItems
 @brief 대중교통 길찾기 - 지하철역 아이템 클래스
 */
@interface RouteSearchSubwayStationItems : NSObject
{
	NSString* _name;		// 정류장 명칭
	NSString* _stationtype;		// 정류장의 타입 (1: 버스 정류장, 2: 지하철 정류장)
	NSString* _x;		// 	
	NSString* _y;		// 	
}

@property (nonatomic, retain) NSString* _name;		// 정류장 명칭
@property (nonatomic, retain) NSString* _stationtype;		// 정류장의 타입 (1: 버스 정류장, 2: 지하철 정류장)
@property (nonatomic, retain) NSString* _x;	
@property (nonatomic, retain) NSString* _y;	

@end









/**
 @class RouteSearchSubwayRGItems
 @brief 대중교통 길찾기 - 지하철 방향 아이템 클래스
 */
@interface RouteSearchSubwayRGItems : NSObject
{
	NSString* _rgtype;			// RG type (참고 : 대중교통 길찾기 RG type 정의)
	NSString* _methodtype;			// 대중 교통 이용 방법 (1: 버스 이용, 2: 지하철 이용, 3: 걸어서 이동)
	NSString* _startname;			// rgtype 에 따른 첫번째 정류장 이름 ex) rgtype이 1인 경우 - 버스를 탑승하는 정류장 이름, rgtype이 3인 경우 - 걸어서 이동하기 시작한 정류장 이름, 
	NSString* _endname;			// rgtype 에 따른 마지막 정류장 이름 ex) rgtype이 1인 경우 - 버스를 하차하는 정류장 이름, rgtype이 3인 경우 - 걸어서 이동하는 목적지 정류장 이름
	NSString* _lanename;			// 이용하는 대중 교통의 노선 이름 주) 걸어서 이동하는 경우 이름 없음 "-1"
	NSString* _distance;			// rgtype 1 단위의 이동 거리
	NSString* _distancetype;			// rgtype 1 단위의 이동 거리 타입 (1: Meter 표시, 2: 정류장 개수 표시) ex) 값이 1인 경우 이후 distance 값은 XXXX 미터값이 2인 경우 이후 distance 값은 XX 정류장 이동
	NSString* _x;			// 경로 가이드 중인 대표 위치 X 좌표(지도 중심점 이동)
	NSString* _y;			// 경로 가이드 중인 대표 위치 Y 좌표(지도 중심점 이동)
}

@property (nonatomic, retain) NSString* _rgtype;			// RG type (참고 : 대중교통 길찾기 RG type 정의)
@property (nonatomic, retain) NSString* _methodtype;			// 대중 교통 이용 방법 (1: 버스 이용, 2: 지하철 이용, 3: 걸어서 이동)
@property (nonatomic, retain) NSString* _startname;			// rgtype 에 따른 첫번째 정류장 이름 ex) rgtype이 1인 경우 - 버스를 탑승하는 정류장 이름, rgtype이 3인 경우 - 걸어서 이동하기 시작한 정류장 이름, 
@property (nonatomic, retain) NSString* _endname;			// rgtype 에 따른 마지막 정류장 이름 ex) rgtype이 1인 경우 - 버스를 하차하는 정류장 이름, rgtype이 3인 경우 - 걸어서 이동하는 목적지 정류장 이름
@property (nonatomic, retain) NSString* _lanename;			// 이용하는 대중 교통의 노선 이름 주) 걸어서 이동하는 경우 이름 없음 "-1"
@property (nonatomic, retain) NSString* _distance;			// rgtype 1 단위의 이동 거리
@property (nonatomic, retain) NSString* _distancetype;			// rgtype 1 단위의 이동 거리 타입 (1: Meter 표시, 2: 정류장 개수 표시) ex) 값이 1인 경우 이후 distance 값은 XXXX 미터값이 2인 경우 이후 distance 값은 XX 정류장 이동
@property (nonatomic, retain) NSString* _x;			// 경로 가이드 중인 대표 위치 X 좌표(지도 중심점 이동)
@property (nonatomic, retain) NSString* _y;			// 경로 가이드 중인 대표 위치 Y 좌표(지도 중심점 이동)

@end







/**
 @class RouteSearch
 @brief 길찾기 테이터 클래스
 */
@interface RouteSearch : NSObject 
{
	NSMutableArray* _RouteSearchCoordArray;
	NSMutableArray* _RouteSearchDirArray;
	
	NSMutableArray* _RouteSearchBusStationArray;
	NSMutableArray* _RouteSearchBusRGArray;
//	NSMutableArray* _RouteSearchSubwayStationArray;
//	NSMutableArray* _RouteSearchSubwayRGArray;

	
	NSString* _rg_count;
	NSString* _total_dist;
	NSString* _total_time;
	NSString* _total_charge;
}

@property (nonatomic, retain) NSString* _rg_count;
@property (nonatomic, retain) NSString* _total_dist;
@property (nonatomic, retain) NSString* _total_time;
@property (nonatomic, retain) NSString* _total_charge;

@property (nonatomic, retain) NSMutableArray* _RouteSearchCoordArray;
@property (nonatomic, retain) NSMutableArray* _RouteSearchDirArray;

@property (nonatomic, retain) NSMutableArray* _RouteSearchBusStationArray;
@property (nonatomic, retain) NSMutableArray* _RouteSearchBusRGArray;
//@property (nonatomic, retain) NSMutableArray* _RouteSearchSubwayStationArray;
//@property (nonatomic, retain) NSMutableArray* _RouteSearchSubwayRGArray;

@end









/**
 @class RSPTotalArrayList
 @brief 길찾기 전체 데이터 목록 클래스
 */
@interface RSPTotalArrayList: NSObject
{
	NSMutableArray* _BusArray;
	NSMutableArray* _SubwayArray;
	NSMutableArray* _BothArray;
	NSMutableArray* _RecommendArray;
	
}
@property (nonatomic,retain) NSMutableArray* _BusArray;
@property (nonatomic,retain) NSMutableArray* _SubwayArray;
@property (nonatomic,retain) NSMutableArray* _BothArray;
@property (nonatomic,retain) NSMutableArray* _RecommendArray;

@end