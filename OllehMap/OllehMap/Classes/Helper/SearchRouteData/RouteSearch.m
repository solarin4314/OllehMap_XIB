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
#import "RouteSearch.h"

@implementation RouteSearchCoordItems
@synthesize _vertexX;
@synthesize _vertexY;
@end





/**
@class RouteSearchDirItems
@brief 자동차 길찾기 방향 아이템 클래스
*/ 
//자동차 길찾기
@implementation RouteSearchDirItems
@synthesize _dir_name;	//방면이름
@synthesize _link_idx;	//인덱스
@synthesize _nextdist;	//다음 링크까지 거리
@synthesize _node_name;	//노드 이름
@synthesize _type;		//
@synthesize _x;
@synthesize _y;

@end










//대중교통 길찾기
//NODE
@implementation RouteSearchBusStationItems

@synthesize _name;		// 정류장 명칭
@synthesize _stationtype;		// 정류장의 타입 (1: 버스 정류장, 2: 지하철 정류장)
@synthesize _x;		// 	
@synthesize _y;		// 	

@end











//RG
@implementation RouteSearchBusRGItems

@synthesize _rgtype;			// RG type (참고 : 대중교통 길찾기 RG type 정의)
@synthesize _methodtype;			// 대중 교통 이용 방법 (1: 버스 이용, 2: 지하철 이용, 3: 걸어서 이동)
@synthesize _startname;			// rgtype 에 따른 첫번째 정류장 이름 ex) rgtype이 1인 경우 - 버스를 탑승하는 정류장 이름, rgtype이 3인 경우 - 걸어서 이동하기 시작한 정류장 이름, 
@synthesize _endname;			// rgtype 에 따른 마지막 정류장 이름 ex) rgtype이 1인 경우 - 버스를 하차하는 정류장 이름, rgtype이 3인 경우 - 걸어서 이동하는 목적지 정류장 이름
@synthesize _lanename;			// 이용하는 대중 교통의 노선 이름 주) 걸어서 이동하는 경우 이름 없음 "-1"
@synthesize _distance;			// rgtype 1 단위의 이동 거리
@synthesize _distancetype;			// rgtype 1 단위의 이동 거리 타입 (1: Meter 표시, 2: 정류장 개수 표시) ex) 값이 1인 경우 이후 distance 값은 XXXX 미터값이 2인 경우 이후 distance 값은 XX 정류장 이동
@synthesize _x;			// 경로 가이드 중인 대표 위치 X 좌표(지도 중심점 이동)
@synthesize _y;			// 경로 가이드 중인 대표 위치 Y 좌표(지도 중심점 이동)

@end
 
@implementation RouteSearchSubwayStationItems

@synthesize _name;		// 정류장 명칭
@synthesize _stationtype;		// 정류장의 타입 (1: 버스 정류장, 2: 지하철 정류장)
@synthesize _x;		// 	
@synthesize _y;		// 	

@end

@implementation RouteSearchSubwayRGItems

@synthesize _rgtype;			// RG type (참고 : 대중교통 길찾기 RG type 정의)
@synthesize _methodtype;			// 대중 교통 이용 방법 (1: 버스 이용, 2: 지하철 이용, 3: 걸어서 이동)
@synthesize _startname;			// rgtype 에 따른 첫번째 정류장 이름 ex) rgtype이 1인 경우 - 버스를 탑승하는 정류장 이름, rgtype이 3인 경우 - 걸어서 이동하기 시작한 정류장 이름, 
@synthesize _endname;			// rgtype 에 따른 마지막 정류장 이름 ex) rgtype이 1인 경우 - 버스를 하차하는 정류장 이름, rgtype이 3인 경우 - 걸어서 이동하는 목적지 정류장 이름
@synthesize _lanename;			// 이용하는 대중 교통의 노선 이름 주) 걸어서 이동하는 경우 이름 없음 "-1"
@synthesize _distance;			// rgtype 1 단위의 이동 거리
@synthesize _distancetype;			// rgtype 1 단위의 이동 거리 타입 (1: Meter 표시, 2: 정류장 개수 표시) ex) 값이 1인 경우 이후 distance 값은 XXXX 미터값이 2인 경우 이후 distance 값은 XX 정류장 이동
@synthesize _x;			// 경로 가이드 중인 대표 위치 X 좌표(지도 중심점 이동)
@synthesize _y;			// 경로 가이드 중인 대표 위치 Y 좌표(지도 중심점 이동)

@end













@implementation RouteSearch

@synthesize _rg_count;
@synthesize _total_dist;
@synthesize _total_time;
@synthesize _total_charge;

@synthesize _RouteSearchCoordArray;
@synthesize _RouteSearchDirArray;

@synthesize _RouteSearchBusStationArray;
@synthesize _RouteSearchBusRGArray;
//@synthesize _RouteSearchSubwayStationArray;
//@synthesize _RouteSearchSubwayRGArray;

- (id)init 
{
    self = [super init];
	if(self != nil) 
    {
		_RouteSearchCoordArray          =   [[NSMutableArray alloc] init];
		_RouteSearchDirArray            =   [[NSMutableArray alloc] init];
		_RouteSearchBusStationArray     =   [[NSMutableArray alloc] init];
		_RouteSearchBusRGArray          =   [[NSMutableArray alloc] init];
//		_RouteSearchSubwayStationArray  =   [[NSMutableArray alloc] init];
//		_RouteSearchSubwayRGArray       =   [[NSMutableArray alloc] init];
	}
	return self;
}

@end













@implementation RSPTotalArrayList
@synthesize _BusArray;              
@synthesize _SubwayArray;
@synthesize _BothArray;
@synthesize _RecommendArray;

- (id) init 
{
	if(self = [super init]) 
    {
        // 버스, 지하철, 버스+지하철, 추천 데이터 초기화
		_BusArray       =   [[NSMutableArray alloc] init];
		_SubwayArray    =   [[NSMutableArray alloc] init];
		_BothArray      =   [[NSMutableArray alloc] init];
		_RecommendArray =   [[NSMutableArray alloc] init];
	}
	return self;
}

@end
