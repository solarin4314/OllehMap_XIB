//
//  OllehMapStatus.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 4. 17..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#include <sys/sysctl.h>

// MAC Address 처리용
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if_dl.h>
#if ! defined(IFT_ETHER)
#define IFT_ETHER 0x6 /* Ethernet CSMACD */
#endif


#import "OllehMapStatus.h"
#import "OMReachability.h"
#import "MapContainer.h"


double convertHexToDecimal (NSString *hex)
{
    NSScanner *scanner=[NSScanner scannerWithString:hex];
    unsigned int decimal;
    [scanner scanHexInt:&decimal];
    return decimal / 255.0f;
}
UIColor* convertHexToDecimalRGBA (NSString *r, NSString *g, NSString *b, float a)
{
    return [UIColor colorWithRed:convertHexToDecimal(r) green:convertHexToDecimal(g) blue:convertHexToDecimal(b) alpha:a];
}


NSString* stringValueOfDictionary (NSDictionary *dic, NSString *key)
{
    return tryStringValueOfDictionary(dic, key, @"");
}
NSString* tryStringValueOfDictionary (NSDictionary *dic, NSString *key, NSString *defaultValue)
{
    if ( dic && [[dic allKeys] containsObject:key] )
    {
        NSString *returnString = [NSString stringWithFormat:@"%@", [dic objectForKeyGC:key]];
        if ( [returnString isEqualToString:@"<null>"] )
            return [NSString stringWithString:defaultValue];
        else if ( [returnString isEqualToString:@"(null)"] )
            return [NSString stringWithString:defaultValue];
        else
            return returnString;
    }
    else
    {
        return [NSString stringWithString:defaultValue];
    }
}
NSNumber* numberValueOfDiction (NSDictionary *dic, NSString *key)
{
    if ( [[dic allKeys] containsObject:key] )
        return [dic objectForKeyGC:key];
    else
        return [NSNumber numberWithInt:0];
}

BOOL isCollectionType (id coll)
{
    if ( coll
        && ( [coll isKindOfClass:[NSDictionary class]] || [coll isKindOfClass:[NSMutableDictionary class]] || [coll isKindOfClass:[NSArray class]] || [coll isKindOfClass:[NSMutableArray class]] )
        )
        return YES;
    
    return NO;
}

id objectForKey ( id coll, NSString *key)
{
    return objectForKeyWithDefault(coll, key, nil);
}
id objectForKeyWithDefault ( id coll, NSString *key, NSObject *defaultValue)
{
    if ( isCollectionType(coll) == NO ) return defaultValue;
    
    id object = [coll objectForKeyGC:key];
    
    // 데이터는 존재하지만, NSNull null 객체인경우 디폴트로보정
    if ( object && [object isKindOfClass:[NSNull class]] )
    {
        object = defaultValue;
    }
    // collection에 해당하는 key 가 없거나 nil 인경우 defaultValue 보정
    else if ( object == nil )
    {
        object = defaultValue;
    }
    
    return object;
}

id objectAtIndex ( id coll, NSInteger index)
{
    return objectAtIndexWithDefault(coll, index, nil);
}
id objectAtIndexWithDefault ( id coll, NSInteger index, NSObject *defaultValue)
{
    
    if ( isCollectionType(coll) == NO ) return defaultValue;
    
    id object = [coll objectAtIndexGC:index];
    
    if ( object && [object isKindOfClass:[NSNull class]] )
    {
        object = defaultValue;
    }
    else if ( object == nil )
    {
        object = defaultValue;
    }
    
    return object;
}

@implementation OllehMapStatus

@synthesize soundState = _soundState;
@synthesize fbNewContact = _fbNewContact;
@synthesize isPhotosCheck = _isPhotosCheck;
@synthesize photoimg = _photoimg;

@synthesize pushDataBusNumberArray = _pushDataBusNumberArray;
@synthesize pushDataBusStationArray = _pushDataBusStationArray;
@synthesize currentActionType = _currentActionType;
@synthesize currentTouchesType = _currentTouchesType;
@synthesize currentMapScreenMode = _currentMapScreenMode;
@synthesize currentSearchTargetType = _currentSearchTargetType;
@synthesize currentMapLocationMode = _currentMapLocationMode;

@synthesize debuggingString = _debuggingString;
@synthesize searchResult = _searchResult;
@synthesize searchResultRouteStart = _searchResultRouteStart;
@synthesize searchResultRouteVisit = _searchResultRouteVisit;
@synthesize searchResultRouteDest = _searchResultRouteDest;
@synthesize searchResultOneTouchPOI = _searchResultOneTouchPOI;

@synthesize isMainViewDidApear = _isMainViewDidApper;
@synthesize calledOpenURL = _calledOpenURL;
@synthesize searchAutoMakeArray = _searchAutoMakeArray;
@synthesize searchLocalDictionary = _searchLocalDictionary;
@synthesize searchIndex = _searchIndex;
@synthesize keyword = _keyword;
@synthesize favoriteList = _favoriteList;

@synthesize searchRouteData = _searchRouteData;
@synthesize oneTouchPOIDictionary = _oneTouchPOIDictionary;
@synthesize addressPOIDictionary = _addressPOIDictionary;
@synthesize poiDetailDictionary = _poiDetailDictionary;
@synthesize voiceSearchArray = _voiceSearchArray;
@synthesize oilDetailDictionary = _oilDetailDictionary;
@synthesize subwayDetailDictionary = _subwayDetailDictionary;
@synthesize subwayTimeDictionary = _subwayTimeDictionary;
@synthesize subwayExitDictionary = _subwayExitDictionary;
@synthesize movieDetailDictionary = _movieDetailDictionary;
@synthesize movieListDictionary = _movieListDictionary;
@synthesize subwayExistArr = _subwayExistArr;

@synthesize busStationNewDictionary = _busStationNewDictionary;
@synthesize subwayRefinedExitDictionary = _subwayRefinedExitDictionary;
@synthesize busNumberNewDictionary = _busNumberNewDictionary;
@synthesize laneIdToBisIdDictionary = _laneIdToBisIdDictionary;
@synthesize busLineDrawingDictionary = _busLineDrawingDictionary;
@synthesize shareDictionary = _shareDictionary;
@synthesize noticeListDictionary = _noticeListDictionary;
@synthesize noticeDetailDictionary = _noticeDetailDictionary;
@synthesize noticeCheckArray = _noticeCheckArray;
@synthesize appVersionDictionary = _appVersionDictionary;
@synthesize themeInfoList = _themeInfoList;
@synthesize themeSearchResultList = _themeSearchResultList;
@synthesize deviceDisplayID = _deviceDisplayID;

@synthesize linePolygonDictionary = _linePolygonDictionary;

// ================
// [ 생성자 메소드 ]
// ================

static OllehMapStatus *_Instance = nil;
+ (OllehMapStatus *) sharedOllehMapStatus
{
    if (_Instance == nil)
    {
        _Instance = [[OllehMapStatus alloc] init];
        [_Instance initStatus];
    }
    return _Instance;
}
+ (void) closeOllehMapStatus
{
    [_Instance release];
    _Instance = nil;
}

-(id)init
{
    return [super init];
}
-(void) dealloc
{
    // retain 객체들 해제
    [_photoimg release];
    [_pushDataBusNumberArray release];
    [_pushDataBusStationArray release];
    
    [_searchResult release];
    [_searchResultRouteStart release];
    [_searchResultRouteVisit release];
    [_searchResultRouteDest release];
    [_searchResultOneTouchPOI release];
    
    [_debuggingString release];
    
    [_deviceDisplayID release];
    
    [_searchAutoMakeArray release];
    [_searchLocalDictionary release];
    [_keyword release];
    [_searchRouteData release];
    [_voiceSearchArray release];
    [_favoriteList release];
    [_addressPOIDictionary release];
    
    [_poiDetailDictionary release];
    [_oilDetailDictionary release];
    [_subwayDetailDictionary release];
    [_subwayTimeDictionary release];
    [_subwayExitDictionary release];
    [_movieDetailDictionary release];
    [_movieListDictionary release];
    [_subwayExistArr release];
    [_busStationNewDictionary release];
    
    
    [_subwayRefinedExitDictionary release];



    
    [_busNumberNewDictionary release];
    

    [_laneIdToBisIdDictionary release];


    [_busLineDrawingDictionary release];
    
    [_shareDictionary release];
    [_noticeListDictionary release];
    [_noticeDetailDictionary release];
    [_noticeCheckArray release];
    [_appVersionDictionary release];
    
    
    [_themeInfoList release];
    [_themeSearchResultList release];
    
    
    [_recentSearch release];
    _recentSearch = nil;
    
    [_linePolygonDictionary release];
    
    if (_recommandWordTable) sqlite3_free_table(_recommandWordTable);
    _recommandWordTable = nil;
    
    [super dealloc];
}
-(void) initStatus
{
    _photoimg = [[UIImage alloc] init];
    // 버스-버정 푸쉬데이터
    _pushDataBusNumberArray = [[NSMutableArray alloc] init];
    _pushDataBusStationArray = [[NSMutableArray alloc] init];
    
    // 앱상에서 사용되는 검색결과 공유변수
    _searchResult = [[OMSearchResult alloc] init];
    _searchResultRouteStart = [[OMSearchResult alloc] init];
    _searchResultRouteDest = [[OMSearchResult alloc] init];
    _searchResultRouteVisit = [[OMSearchResult alloc] init];
    _searchResultOneTouchPOI = [[OMSearchResult alloc] init];
    
    _isMainViewDidApper = NO;
    _calledOpenURL = NO;
    
    // 장소/주소/대중교통 검색시 사용되는 변수
    _searchLocalDictionary = [[NSMutableDictionary alloc] init];
    [self resetLocalSearchDictionary:@"Place"];
    [self resetLocalSearchDictionary:@"Address"];
    [self resetLocalSearchDictionary:@"NewAddress"];
    [self resetLocalSearchDictionary:@"PublicBusStation"];
    [self resetLocalSearchDictionary:@"PublicBusNumber"];
    [self resetLocalSearchDictionary:@"PUblicSubwayStation"];
    
    // 디버깅
    _debuggingString = [[NSMutableString alloc] init];
    
    // 단말기정보
    _deviceDisplayID = nil;
    
    // 최근검색어 관리 변수
    _recentSearch = [[NSMutableArray alloc] initWithCapacity:RecentSearch_MaxCount];
    [self initRecentSearchList];
    
    // 음성검색어 초기화
    _voiceSearchArray = [[NSMutableArray alloc] init];
    
    // 즐겨찾기
    _favoriteList = [[NSMutableArray alloc] init];
    
    // 어드 딕
    _addressPOIDictionary = [[NSMutableDictionary alloc] init];
    
    // 추천검색어 초기화
    _recommandWordTable = nil;
    _recommandWordTableRowCount = 0;
    
    // 추천검색어 자동완성 초기화
    _searchAutoMakeArray = [[NSMutableArray alloc] init];
    _keyword = [[NSString alloc] init];
    _searchIndex = 0;
    
    // 길찾기 결과 초기화
    _searchRouteData = [[OMSearchRouteResult alloc] init];
    
    // 롱탭 POI 초기화
    _oneTouchPOIDictionary = [[NSMutableDictionary alloc] init];
    
    // 상세정보 초기화
    _poiDetailDictionary = [[NSMutableDictionary alloc] init];
    
    // 오일정보 초기화
    _oilDetailDictionary = [[NSMutableDictionary alloc] init];
    
    // 지하철상세정보 초기화
    _subwayDetailDictionary = [[NSMutableDictionary alloc] init];
    
    // 지하철시간정보 초기화
    _subwayTimeDictionary = [[NSMutableDictionary alloc] init];
    
    // 지하철출구정보 초기화
    _subwayExitDictionary = [[NSMutableDictionary alloc] init];
    
    // 영화 상세정보 초기화
    
    _movieDetailDictionary = [[NSMutableDictionary alloc] init];
    
    // 영화 리스트정보 초기화
    
    _movieListDictionary = [[NSMutableDictionary alloc] init];
    
    // 환승역 초기화
    _subwayExistArr = [[NSMutableArray alloc] init];
    
    // 새로운API
    _busStationNewDictionary = [[NSMutableDictionary alloc] init];
    _busNumberNewDictionary = [[NSMutableDictionary alloc] init];
    
    // 지하철출구 2 초기화
    _subwayRefinedExitDictionary = [[NSMutableDictionary alloc] init];
    
    // 라인폴리곤 초기화
    _linePolygonDictionary = [[NSMutableDictionary alloc] init];
    
    // laneID -> BisId 초기화
    
    _laneIdToBisIdDictionary = [[NSMutableDictionary alloc] init];

    // 버스노선 그리기 리스트
    _busLineDrawingDictionary = [[NSMutableDictionary alloc] init];
    // 위치공유 초기화
    
    _shareDictionary = [[NSMutableDictionary alloc] init];
    
    // 공지사항 리스트
    _noticeListDictionary = [[NSMutableDictionary alloc] init];
    
    // 공지 상세
    _noticeDetailDictionary = [[NSMutableDictionary alloc] init];
    
    // 공지체크 관리(데이터가 있으면 가져오고 없으면 새로 생성)
    _noticeCheckArray = [[NSUserDefaults standardUserDefaults] objectForKeyGC:@"NoticeCheck"];
    if(_noticeCheckArray == nil)
        _noticeCheckArray = [[NSMutableArray alloc] init];
    
    // 앱버전
    _appVersionDictionary = [[NSMutableDictionary alloc] init];
    
    // 공지
    
    // 테마상세
    _themeSearchResultList = [[NSMutableArray alloc] init];
    
    // 테마검색
    _themeInfoList = [[NSMutableArray alloc] init];
    
    
    // 기본 액션타입을 맵(MAP)으로 설정
    [self setCurrentActionType:ActionType_MAP];
    // 터치 상태는 NOT으로 설정
    [self setCurrentTouchesType:TouchesType_NOT];
    // 스크린모드는 NORMAL로 설정
    [self setCurrentMapScreenMode:MapScreenMode_NORMAL];
    // 검색대상은 없음으로 설정
    [self setCurrentSearchTargetType:SearchTargetType_NONE];
    // 위치정보는 북쪽고정+블루포인트 기본설정
    [self setCurrentMapLocationMode:MapLocationMode_NorthUp];
    
    // 검색결과 변수는 초기화
}
// 공지 관리

- (void) addNoticeCheck :(int)sequenceNo
{
    
    // 기존에 동일한 검색어 존재할 경우 제거
    [self removeNoticeCheckList:sequenceNo];
    
    [_noticeCheckArray insertObject:[NSString stringWithFormat:@"%d", sequenceNo] atIndex:0];
    
    // 해당 내용을 파일에 저장
    [[NSUserDefaults standardUserDefaults] setObject:_noticeCheckArray forKey:@"NoticeCheck"];
}
- (int) getNoticeCheckCount
{
    return [_noticeCheckArray count];
}
- (NSMutableArray *) getNoticeCheckList
{
    return _noticeCheckArray;
}
- (void) removeNoticeCheckList:(int)key
{
    if(_noticeCheckArray.count <= 0)
        return;
    
    for (int i=0;i<_noticeCheckArray.count; i++)
    {
        if ([[_noticeCheckArray objectAtIndexGC:i] isEqualToString:[NSString stringWithFormat:@"%d", key]])
        {
            [_noticeCheckArray removeObjectAtIndex:i];
            
            // 해당 내용을 파일에 저장
            [[NSUserDefaults standardUserDefaults] setObject:_noticeCheckArray forKey:@"NoticeCheck"];
            
            break;
        }
    }
    
}



// ****************


// =========================
// [ 최근검색어 관리 메소드 ]
// =========================

// 최근검ㅁ색어 파일에서 읽어오기
- (void) initRecentSearchList
{
    [_recentSearch removeAllObjects];
    
    NSArray *tempRecentSearchList = [[NSUserDefaults standardUserDefaults] objectForKeyGC:@"RecentSearch"];
    if (tempRecentSearchList)
        for (NSDictionary *tempDic in tempRecentSearchList)
        {
            NSMutableDictionary *remakeTempDic = [[NSMutableDictionary alloc] initWithDictionary:tempDic];
            [_recentSearch addObject:remakeTempDic];
            [remakeTempDic release];
        }
}

// 중복 대상 존재하는지 체크
- (NSMutableDictionary*) getDuplicatedRecentData :(NSMutableDictionary*)compDic
{
    // 비교하려는 데이터의 타입 먼저 가져온다.
    NSString *compType = [NSString stringWithFormat:@"%@", [compDic objectForKeyGC:@"TYPE"]];
    
    for (NSMutableDictionary *targetDic in _recentSearch)
    {
        // 일단 비교하려는 타입과 대상의 타입이 같은 경우에만 비교 진행
        if ( [[targetDic objectForKeyGC:@"TYPE"] isEqualToString:compType] )
        {
            // 경로는 별도로 체크
            if ( [compType isEqualToString:@"ROUTE"])
            {
                // 비교하려는 좌표
                int startX = [[compDic objectForKeyGC:@"START_X"] intValue];
                int startY = [[compDic objectForKeyGC:@"START_Y"] intValue];
                int visitX = [[compDic objectForKeyGC:@"VISIT_X"] intValue];
                int visitY = [[compDic objectForKeyGC:@"VISIT_Y"] intValue];
                int stopX = [[compDic objectForKeyGC:@"STOP_X"] intValue];
                int stopY = [[compDic objectForKeyGC:@"STOP_Y"] intValue];
                // 대상의 좌표
                int tStartX = [[targetDic objectForKeyGC:@"START_X"] intValue];
                int tStartY = [[targetDic objectForKeyGC:@"START_Y"] intValue];
                int tVisitX = [[targetDic objectForKeyGC:@"VISIT_X"] intValue];
                int tVisitY = [[targetDic objectForKeyGC:@"VISIT_Y"] intValue];
                int tStopX = [[targetDic objectForKeyGC:@"STOP_X"] intValue];
                int tStopY = [[targetDic objectForKeyGC:@"STOP_Y"] intValue];
                // 값 비교
                if ( startX == tStartX && startY == tStartY
                    && visitX == tVisitX && visitY == tVisitY
                    && stopX == tStopX && stopY == tStopY )
                {
                    return targetDic;
                }
            }
            // 주소는 이름으로 비교
            else if ( [compType isEqualToString:@"ADDR"])
            {
                NSString *compareA = [compDic objectForKeyGC:@"NAME"];
                NSString *compareB = [targetDic objectForKeyGC:@"NAME"];
                
                if([compareA isEqualToString:compareB])
                {
                    return targetDic;
                }
                
            }
            // 나머지 POI ID값으로 체크
            else
            {
                // 비교하려는 ID
                NSString *compID = [NSString stringWithFormat:@"%@", [compDic objectForKeyGC:@"ID"]];
                // 대상의 ID
                NSString *targetID = [NSString stringWithFormat:@"%@", [targetDic objectForKeyGC:@"ID"]];
                // 값 비교
                if ( [compID isEqualToString:targetID] )
                {
                    return targetDic;
                }
            }
        }
    }
    
    return nil;
}

- (void) addRecentSearch :(NSMutableDictionary *)dicSearch
{
    if (dicSearch != nil)
    {
        // 기존에 동일한 검색어 존재할 경우 제거
        NSMutableDictionary *removeRecent = [self getDuplicatedRecentData:dicSearch];
        if (removeRecent)
        {
            [_recentSearch removeObject:removeRecent];
        }
        
        // 최근검색어 카운트가 최대일 경우 가장오래된 검색어를 제거한다
        if (_recentSearch.count >= RecentSearch_MaxCount)
        {
            [_recentSearch removeObjectAtIndex:RecentSearch_MaxCount-1];
        }
        
        // 최근검색된 데이터 추가
        [_recentSearch insertObject:dicSearch atIndex:0];
        
        // 해당 내용을 파일에 저장
        [[NSUserDefaults standardUserDefaults] setObject:_recentSearch forKey:@"RecentSearch"];
    }
}
- (int) getRecentSearchCount
{
    return [_recentSearch count];
}
- (NSMutableArray *) getRecentSearchList
{
    return _recentSearch;
}

- (void) removeRecentSearchOnCheckDelete
{
    NSMutableArray *deleteTargetList = [NSMutableArray array];
    for (NSMutableDictionary *deleteTarget in _recentSearch)
    {
        // 삭제 체크된 아이들만 제거대상에 등록
        if ( [[deleteTarget objectForKeyGC:@"CheckDelete"] boolValue] )
            [deleteTargetList addObject:deleteTarget];
    }
    
    // 실제로 삭제작업 수행
    for (NSMutableDictionary *deleteTarget in deleteTargetList)
    {
        [_recentSearch removeObject:deleteTarget];
    }
}

- (void) completeRecenSearchEdting :(BOOL)isSave
{
    // 수정 내용 저장
    if (isSave)
    {
        // 모든 최근검색 대상 삭제체크 해제
        for (NSMutableDictionary *recentSearch in _recentSearch)
        {
            [recentSearch setObject:[NSNumber numberWithBool:NO] forKey:@"CheckDelete"];
        }
        
        // 메모리 내용을 이제 파일에 저장
        [[NSUserDefaults standardUserDefaults] setObject:_recentSearch forKey:@"RecentSearch"];
    }
    // 파일에서 원상복구
    else
    {
        // 파일에서 모든 내용 다시 가져오기
        [self initRecentSearchList];
        
        // 모든 최근검색 대상 삭제체크 해제
        for (NSMutableDictionary *recentSearchDic in _recentSearch)
        {
            [recentSearchDic setObject:[NSNumber numberWithBool:NO] forKey:@"CheckDelete"];
        }
        // 해당 내용을 파일에 저장
        [[NSUserDefaults standardUserDefaults] setObject:_recentSearch forKey:@"RecentSearch"];
    }
}

// *************************


- (void) setRecommWord :(char**)table :(int)count
{
    if (_recommandWordTable) sqlite3_free_table(_recommandWordTable);
    _recommandWordTable = table;
    _recommandWordTableRowCount = count;
}
- (int) getRecommWordRowCount
{
    return _recommandWordTableRowCount;
}
- (NSString*) getRecommWord :(int)index
{
    if (index >= _recommandWordTableRowCount) return @"";
    else if (_recommandWordTable == nil) return @"";
    
    NSString *word = [NSString stringWithUTF8String:(char*)_recommandWordTable[index+1]];
    return word;
}

// ==============
// [ 보조 메소드 ]
// ==============

- (void) resetLocalSearchDictionary:(NSString *)s
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    if ([s isEqualToString:@"Place"] || [s isEqualToString:@"Address"]  || [s isEqualToString:@"NewAddress"]
        || [s isEqualToString:@"PublicBusStation"] || [s isEqualToString:@"PublicBusNumber"] || [s isEqualToString:@"PublicSubwayStation"] )
    {
        [oms.searchLocalDictionary setValue:@"-1" forKey:[NSString stringWithFormat:@"TotalCount%@", s]];
        [oms.searchLocalDictionary setValue:@"-1" forKey:[NSString stringWithFormat:@"CurrentCount%@", s]];
        [oms.searchLocalDictionary setValue:@"-1" forKey:[NSString stringWithFormat:@"CurrentPage%@", s]];
        [oms.searchLocalDictionary removeObjectForKey:[NSString stringWithFormat:@"Data%@", s]];
    }
}

// **************


// ==============
// [ 상태 메소드 ]
// ==============
- (BOOL) isNetworkConnected
{
    // 3G or WiFi 연결일 경우 YES 리턴  ( NotReachable, ReachableViaWWAN, ReachableViaWiFi )
    return ([self getNetworkStatus] != OMReachabilityStatus_disconnected);
}
- (OMReachabilityStatus) getNetworkStatus
{
    // 네트워크의 상태를 알아옵니다.
    NetworkStatus netStatus = [[OMReachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    switch (netStatus)
    {
        case ReachableViaWWAN:
            return OMReachabilityStatus_connected_3G;
        case ReachableViaWiFi:
            return OMReachabilityStatus_connected_WiFi;
        case NotReachable:
        default:
            return OMReachabilityStatus_disconnected;
    }
    
}
- (NSString *)getMACAddress:(NSString *)separator
{
	BOOL bSuccess;
	
	struct ifaddrs *addrs;
	const struct ifaddrs *cursor;
	const struct sockaddr_dl *dlAddr;
	const uint8_t *base;
	
	NSString *nsMACAddress = @"";
	
	bSuccess = getifaddrs(&addrs) == 0;
	
	if (bSuccess) {
		cursor = addrs;
		
		while (cursor != NULL) {
			fprintf(stderr, "%s\n", cursor->ifa_name);
			
			if ([[NSString stringWithUTF8String:cursor->ifa_name] isEqualToString:@"en0"]) {
				if ( (cursor->ifa_addr->sa_family == AF_LINK)
					&& (((const struct sockaddr_dl *)cursor->ifa_addr)->sdl_type == IFT_ETHER) ) {
					
					dlAddr = (const struct sockaddr_dl *)cursor->ifa_addr;
					fprintf(stderr, "sdl_nlen = %d\n", dlAddr->sdl_nlen);
					fprintf(stderr, "sdl_alen = %d\n", dlAddr->sdl_alen);
					base = (const uint8_t *)&dlAddr->sdl_data[dlAddr->sdl_nlen];
					fprintf(stderr, " ");
					
					
					
					for (int i=0; i<dlAddr->sdl_alen; i++) {
						if (i != 0) {
							fprintf(stderr, ":");
							nsMACAddress = [ NSString stringWithFormat:@"%@%@", nsMACAddress, separator];
						}
						
						fprintf(stderr, "%02x", base[i]);
						nsMACAddress = [NSString stringWithFormat:@"%@%02X", nsMACAddress, base[i]];
					}
					fprintf(stderr, "\n");
				}
			}
			cursor = cursor->ifa_next;
		}
		
		freeifaddrs(addrs);
	}
	
	//NSLog(@"* MAC Address: %@ ", nsMACAddress);
	return nsMACAddress;
}

- (void) trackPageView:(NSString *)page
{
    NSError *trackerError;
    
    [self trackCustomVariable];
    
    if ( [[GANTracker sharedTracker] trackPageview:page withError:&trackerError] )
    {
        NSLog(@"%@ 페이지 통계처리", page);
    }
    else
    {
        NSLog(@"%@", trackerError);
#ifdef DEBUG
        [OMMessageBox showAlertMessage:@"통계" :[NSString stringWithFormat:@"%@", trackerError]];
#endif
    }
    
}

- (void) trackEvent :(NSString *)event action:(NSString *)action label:(NSString *)label value:(NSInteger)value
{
    NSError *trackerError;
    
    [self trackCustomVariable];
    
    if ( [[GANTracker sharedTracker] trackEvent:event action:action label:label value:value withError:&trackerError] )
    {
        NSLog(@"%@ 이벤트 통계처리", event);
    }
    else
    {
        NSLog(@"%@", trackerError);
    }
}

- (void) trackCustomVariable
{
    
    [[GANTracker sharedTracker] setCustomVariableAtIndex:1 name:@"DeviceType" value:[[OllehMapStatus sharedOllehMapStatus] getDeviceModel] withError:nil];
    [[GANTracker sharedTracker] setCustomVariableAtIndex:2 name:@"IsRetinaDisplay" value:[NSString stringWithFormat:@"%d", [[OllehMapStatus sharedOllehMapStatus] isRetinaDisplay]] withError:nil];
}


//KMapDisplayNormalBigText = 0,   /**< 일반지도(큰 글씨) */
//KMapDisplayNormalSmallText,     /**< 일반지도(작은 글씨) */
//KMapDisplayHD                   /**< HD 지도 */
- (void) setDisplayMapResolution :(int)resolution
{
    // 잘못된 값이 들어오면 디폴트 값 0로 설정
    if (resolution < 0 || resolution > 2) resolution = KMapDisplayNormalBigText;
    
    if (resolution == KMapDisplayHD)
    {
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        NSString *platform = [NSString stringWithUTF8String:machine];
        free(machine);
        // iPhone3GS => iPhone2,1
        if ([platform isEqualToString:@"iPhone2,1"]) resolution = KMapDisplayNormalBigText;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:resolution] forKey:@"DisplayMapResolution"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (int) getDisplayMapResolution
{

    NSNumber *displayResolutionNumber = [[NSUserDefaults standardUserDefaults] objectForKeyGC:@"DisplayMapResolution"];

    // 해상도 값이 없을 경우 기본값 일반-큰글씨 처리한다.
    if (displayResolutionNumber)
    {
        
        
    }
    else
    {
        // MIK.geun :: 20121004 // 레티나 디스플레이일경우 기본값을 고해상도 지도로 처리한다.
        /*
         if ( [self isRetinaDisplay] ) // 레티나 지원일 경우
         displayResolutionNumber = [NSNumber numberWithInt:KMapDisplayHD];
         else // 레티나 미지원일 경우
         displayResolutionNumber = [NSNumber numberWithInt:KMapDisplayNormalBigText];
         */
        // MIK.geun :: 20121004 // 최성군부장님 요청으로 기본값 일반-큰글씨로 유지..
        displayResolutionNumber = [NSNumber numberWithInt:KMapDisplayNormalBigText];
        
        // 기본값 저장
        [self setDisplayMapResolution: [displayResolutionNumber intValue]];
    }
    
    // 저해상도 단말기에서 일반-큰글씨 외의 지도가 호출되지 않도록 처리한다
    if ( [displayResolutionNumber intValue] != KMapDisplayNormalBigText && ![[OllehMapStatus sharedOllehMapStatus] isRetinaDisplay] )
    {
        [self setDisplayMapResolution:KMapDisplayNormalBigText];
        displayResolutionNumber = [NSNumber numberWithInt:KMapDisplayNormalBigText];
    }
    
    return [displayResolutionNumber intValue];
}

- (BOOL) isRetinaDisplay
{
    UIScreen *ms = [UIScreen mainScreen];
    
    if ( [ms respondsToSelector:@selector(displayLinkWithTarget:selector:)]
        && [ms scale] == 1.0f )
    {
        return NO;
    }
    else
    {
        return YES;
    }
    
}
- (BOOL) isLongDisplay
{
    
    return NO;
}
- (NSString*) getDeviceModel
{
    /*
     iPhone1,1 iPhone 1G
     iPhone1,2 iPhone 3G
     iPhone2,1 iPhone 3GS
     iPhone3,1 iPhone 4
     iPhone3,2 Verizon iPhone 4
     iPhone4,1 iPhone 4S
     iPhone5,1 iPhone 5
     iPod1,1   iPod Touch 1G
     iPod2,1   iPod Touch 2G
     iPod3,1   iPod Touch 3G
     iPod4,1   iPod Touch 4G
     iPad1,1   iPad
     iPad2,1   iPad 2 (WiFi)
     iPad2,2   iPad 2 (GSM)
     iPad2,3   iPad 2 (CDMA)
     iPad3,1   iPad 3 (WiFi)
     iPad3,2   iPad 3 (GSM)
     iPad3,3   iPad 3 (CDMA)
     x86_64 Simulator
     i386      Simulator
     */
    
    // machine 정보
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    
    return platform;
}
- (NSString *)generateUuidString
{
    NSString *uuidString = [[NSUserDefaults standardUserDefaults] objectForKeyGC:@"AppUUID"];
    
    // UUID 존재할경우 바로 리턴
    if ( uuidString ) return uuidString;
    // 존재하지 않을 경우 새로 생성/기록뒤 리턴
    else
    {
        // create a new UUID which you own
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        // create a new CFStringRef (toll-free bridged to NSString)
        // that you own
        uuidString = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
        // transfer ownership of the string
        // to the autorelease pool
        [uuidString autorelease];
        // release the UUID
        CFRelease(uuid);
        
        [[NSUserDefaults standardUserDefaults] setObject:uuidString forKey:@"AppUUID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        return uuidString;
    }
    
}
// 이메일 유효성 체크
- (BOOL) emailVaildCheck:(NSString *)emailId
{
    
    NSString *expression = @"^[A-Z0-9._%-]+@[A-Z0-9.-]+.[A-Z]{2,4}$";
    //NSString *expression = @"\\b[A-Z0-9._%-]+@[A-Z0-9.-]+.[A-Z]{2,4}\\b";
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult *match = [regex firstMatchInString:emailId options:0 range:NSMakeRange(0, [emailId length])];
    
    if(match)
        return YES;
    else
        return NO;
    
}
// 숫자5자리 체크
- (BOOL) number5VaildCheck:(NSString *)keyword
{
    
    NSString *expression = @"^[0-9]{5,}$";
    //NSString *expression = @"\\b[A-Z0-9._%-]+@[A-Z0-9.-]+.[A-Z]{2,4}\\b";
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult *match = [regex firstMatchInString:keyword options:0 range:NSMakeRange(0, [keyword length])];
    
    if(match)
        return YES;
    else
        return NO;
    
}

// 고유번호 2자리-3자리 체크
- (BOOL) uniqueVaildCheck:(NSString *)keyword
{
    
    NSString *expression = @"^[0-9]{2}+-[0-9]{3,}$";
    //NSString *expression = @"\\b[A-Z0-9._%-]+@[A-Z0-9.-]+.[A-Z]{2,4}\\b";
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult *match = [regex firstMatchInString:keyword options:0 range:NSMakeRange(0, [keyword length])];
    
    if(match)
        return YES;
    else
        return NO;
    
}

// 버스LAINID로 이미지
- (NSString *) getLaneIdToImgString :(NSString *)laneId
{
    NSString *imgString = nil;
    
    if([laneId isEqualToString:@"1"])
    {
        imgString = [NSString stringWithFormat:@"info_icon_27.png"];
    }
    // 좌석
    else if([laneId isEqualToString:@"2"])
    {
        imgString = [NSString stringWithFormat:@"info_icon_28.png"];
    }
    // 마을
    else if([laneId isEqualToString:@"3"])
    {
        imgString = [NSString stringWithFormat:@"info_icon_29.png"];
    }
    // 직행좌석
    else if([laneId isEqualToString:@"4"])
    {
        imgString = [NSString stringWithFormat:@"info_icon_30.png"];
    }
    // 공항버스
    else if([laneId isEqualToString:@"5"])
    {
        imgString = [NSString stringWithFormat:@"info_icon_31.png"];
    }
    // 간선급행
    else if([laneId isEqualToString:@"6"] || [laneId isEqualToString:@"15"])
    {
        imgString = [NSString stringWithFormat:@"info_icon_32.png"];
    }
    // 외곽
    else if([laneId isEqualToString:@"10"])
    {
        imgString = [NSString stringWithFormat:@"info_icon_33.png"];
    }
    // 간선
    else if ([laneId isEqualToString:@"11"])
    {
        imgString = [NSString stringWithFormat:@"info_icon_34.png"];
    }
    // 지선
    else if([laneId isEqualToString:@"12"])
    {
        imgString = [NSString stringWithFormat:@"info_icon_35.png"];
    }
    // 순환
    else if([laneId isEqualToString:@"13"])
    {
        imgString = [NSString stringWithFormat:@"info_icon_36.png"];
    }
    // 광역
    else if([laneId isEqualToString:@"14"])
    {
        imgString = [NSString stringWithFormat:@"info_icon_37.png"];
    }
    // 급행간선
    else if([laneId isEqualToString:@"26"])
    {
        imgString = [NSString stringWithFormat:@"info_icon_39.png"];
    }
    
    return imgString;
    
}

- (UIImage *) returnCaptureImg:(UIView *)selfView
{
    
    [self isRetinaDisplay] ? UIGraphicsBeginImageContextWithOptions(selfView.frame.size, NO, 2.0f) : UIGraphicsBeginImageContext(selfView.frame.size);
    
    [selfView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *imageCapture = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    //UIImage *returnImg = nil;
    
    return imageCapture;
}
// 업종분류 상위 2개만 표시
- (NSString *) ujNameSegment :(NSString *)omsUjString
{
    NSArray *ujNameArr = [omsUjString componentsSeparatedByString:@">"];
    
    NSString *classification;
    NSString *bigSegment;
    NSString *middleSegment;
    
    if(ujNameArr.count > 0)
    {
        bigSegment = [ujNameArr objectAtIndexGC:0];
        
        
        classification = [NSString stringWithFormat:@"%@", bigSegment];
        
        if(ujNameArr.count > 1)
        {
            middleSegment = [ujNameArr objectAtIndexGC:1];
            
            if([middleSegment isEqualToString:@""])
            {
                classification = [NSString stringWithFormat:@"%@", bigSegment];
            }
            else
                
            {
                classification = [NSString stringWithFormat:@"%@ > %@", bigSegment, middleSegment];
            }
            
        }
        
        
    }
    else {
        classification = @"";
    }
    
    return classification;
    
}

-(NSString *) cityCodeToCityName : (int)Bl_CityCode
{
    NSString *cityname;
    
    if(Bl_CityCode == 1000)
    {
        cityname = @"[서울]";
        
    }
    else if(Bl_CityCode == 1)
    {
        cityname = @"[수도권]";
    }
    else if(Bl_CityCode == 2000)
    {
        cityname = @"[인천]";
    }
    else if(Bl_CityCode == 3000)
    {
        cityname = @"[대전]";
    }
    else if(Bl_CityCode == 4000)
    {
        cityname = @"[대구]";
    }
    else if(Bl_CityCode == 5000)
    {
        cityname = @"[광주]";
    }
    else if(Bl_CityCode == 6000)
    {
        cityname = @"[울산]";
    }
    else if(Bl_CityCode == 7000)
    {
        cityname = @"[부산]";
    }
    else if(Bl_CityCode == 8000)
    {
        cityname = @"[제주도]";
    }
    else if(Bl_CityCode == 3100)
    {
        cityname = @"[충남]";
    }
    else if(Bl_CityCode > 1000 && Bl_CityCode < 1311)
    {
        cityname = @"[경기]";
        
    }
    else
    {
        cityname = @"";
    }
    
    return cityname;
    
}

// url로 이미지 보이기
- (UIImage*)urlGetImage:(NSString *)Url
{
	NSURL *imageURL= [NSURL URLWithString:Url];
	NSData *imageData = nil;
    
	
	if(imageURL != nil)
    {
		imageData = [NSData dataWithContentsOfURL:imageURL];
		UIImage *tempThumeNailImage = [UIImage imageWithData:imageData];
		
		if(imageData != nil)
        {
			return tempThumeNailImage;
		}
	}
    return 0;
}

// URL 유효성 체크
- (NSString *) urlValidCheck:(NSString *)rawUrl
{
    //NSString *url = [oms.poiDetailDictionary objectForKey:@"URL"];
    
    NSString *urlPre = [rawUrl substringToIndex:7];
    
    
    NSLog(@"유알엘앞대가리 : %@", urlPre);
    if(([urlPre compare:@"http://" options:NSCaseInsensitiveSearch] == NSOrderedSame) || ([urlPre compare:@"https:/" options:NSCaseInsensitiveSearch] == NSOrderedSame))
    {
        return rawUrl;
    }
    else
    {
        return [NSString stringWithFormat:@"http://%@", rawUrl];
    }
    
}

// 버스타입으로 이미지숫자
- (int) getBusClassNumber:(int)busClass
{
    int busNumValue = busClass;
    
    // 일반
    if(busNumValue == 1)
    {
        return 27;
    }
    // 좌석
    else if (busNumValue == 2)
    {
        return  28;
    }
    // 마을
    else if (busNumValue == 3)
    {
        return  29;
    }
    // 직행좌석
    else if (busNumValue == 4)
    {
        return  30;
    }
    // 공항
    else if (busNumValue == 5)
    {
        return  31;
    }
    // 간선급행
    else if (busNumValue == 6)
    {
        return  32;
    }
    // 외곽
    else if (busNumValue == 10)
    {
        return  33;
    }
    // 간선
    else if (busNumValue == 11)
    {
        return  34;
    }
    // 지선
    else if (busNumValue == 12)
    {
        return  35;
    }
    //순환
    else if (busNumValue == 13)
    {
        return  36;
    }
    // 광역
    else if (busNumValue == 14)
    {
        return  37;
    }
    // 급행
    else if (busNumValue == 15)
    {
        return  38;
    }
    // 급행간선
    else if (busNumValue == 26)
    {
        return  39;
    }
    else
    {
        return -1;
    }
    
}
// **************

@end
