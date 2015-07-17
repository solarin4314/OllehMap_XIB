//
//  SearchRouteExecuter.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 5. 24..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "SearchRouteExecuter.h"
#import "SearchRouteResultMapViewController.h"

@implementation SearchRouteExecuter

// ================
// [ 싱글턴 메소드 ]
// ================
static SearchRouteExecuter *_Instance = nil;
+ (SearchRouteExecuter *) sharedSearchRouteExecuter
{
    if (_Instance == nil) _Instance = [[SearchRouteExecuter alloc] init];
    return _Instance;
}
+ (void) closeSearchRouteExecuter
{
    [_Instance release];
    _Instance = nil;
}
// ****************

// ================
// [ 길찾기 메소드 ]
// ================

// 경로탐색 (자동차) // searchType : 경로탐색종류 SearchRoute_Car_SearchType
- (void) searchRoute_Car:(int)searchType
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    
    // **************
    // 출발-경유-도착지에 대한 유효성 체크
    // **************
    
    // 출발-도착지 선택여부, 길찾기 최소조건
    if ( oms.searchResultRouteStart.used == NO)
    {
        [OMMessageBox showAlertMessage:@"":@"출발지에 대한 정보가 존재하지 않습니다."];
        return;
    }
    else if ( oms.searchResultRouteDest.used == NO )
    {
        [OMMessageBox showAlertMessage:@"" :@"도착지에 대한 정보가 존재하지 않습니다."];
        return;
    }
    
    // 출발지-도착지 현재위치 중복사용
    else if ( oms.searchResultRouteVisit.used == NO && oms.searchResultRouteStart.isCurrentLocation && oms.searchResultRouteDest.isCurrentLocation )
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchRoute_DuplicatedStartDest", @"출발-도착")];
        return;
    }
    // 출발지-경유지-도착지 현재위치 중복사용
    else if ( oms.searchResultRouteVisit.used && oms.searchResultRouteStart.isCurrentLocation && oms.searchResultRouteVisit.isCurrentLocation && oms.searchResultRouteDest.isCurrentLocation )
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchRoute_DuplicatedStartVisitDest", @"출발-경유-도착")];
        return;
    }
    // 출발지-경유지 현재위치 중복 사용
    else  if ( oms.searchResultRouteVisit.used && oms.searchResultRouteStart.isCurrentLocation && oms.searchResultRouteVisit.isCurrentLocation )
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchRoute_DuplicatedStartVisit", @"출발-경유")];
        return;
    }
    // 경유지-도착지 현재위치 중복 사용
    else  if ( oms.searchResultRouteVisit.used && oms.searchResultRouteVisit.isCurrentLocation && oms.searchResultRouteDest.isCurrentLocation )
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchRoute_DuplicatedVisitDest", @"경유-도착")];
        return;
    }
    
    // 출발지 - 도착지 동일지점 && 경유지가 없을 경우에만
    else if ( CoordDistance(oms.searchResultRouteStart.coordLocationPoint, oms.searchResultRouteDest.coordLocationPoint) <= 0
             && oms.searchResultRouteVisit.used == NO)
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchRoute_DuplicatedStartDest", @"출발-도착")];
        return;
    }
    // 출발지 - 도착지 - 경유지 모두 동일지점
    else if ( CoordDistance(oms.searchResultRouteStart.coordLocationPoint, oms.searchResultRouteDest.coordLocationPoint) <= 0
             && CoordDistance(oms.searchResultRouteVisit.coordLocationPoint, oms.searchResultRouteDest.coordLocationPoint) <= 0
             && oms.searchResultRouteVisit.used)
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchRoute_DuplicatedStartVisitDest", @"출발-경유-도착")];
        return;
    }
    // 출발지 - 경유지 동일좌표 사용
    if (  oms.searchResultRouteVisit.used && CoordDistance(oms.searchResultRouteStart.coordLocationPoint, oms.searchResultRouteVisit.coordLocationPoint) <= 0)
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchRoute_DuplicatedStartVisit", @"출발-경유")];
        return;
    }
    // 도착지 - 경유지 동일지점
    else if ( oms.searchResultRouteVisit.used && CoordDistance(oms.searchResultRouteDest.coordLocationPoint, oms.searchResultRouteVisit.coordLocationPoint) <= 0)
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchRoute_DuplicatedVisitDest", @"경유-도착")];
        return;
    }
    
    // 탐색 지점을  현재위치로 설정했을 경우 현재 실제좌표로 변환
    Coord currentCoordinate = [MapContainer sharedMapContainer_Main].getCurrentUserLocation;
    if (oms.searchResultRouteStart.isCurrentLocation)
    {
        oms.searchResultRouteStart.coordLocationPoint = currentCoordinate;
    }
    if ( oms.searchResultRouteVisit.used && oms.searchResultRouteVisit.isCurrentLocation)
    {
        oms.searchResultRouteVisit.coordLocationPoint = currentCoordinate;
    }
    if (oms.searchResultRouteDest.isCurrentLocation)
    {
        oms.searchResultRouteDest.coordLocationPoint = currentCoordinate;
    }
    // 실제좌표로 변환된 지점에 대해 주소변환 시도
    if (oms.searchResultRouteStart.isCurrentLocation)
    {
        [[ServerConnector sharedServerConnection] requestGeocodingCoordForSearchRoute:self action:@selector(didRefineTargetAddress:) type:1 x:oms.searchResultRouteStart.coordLocationPoint.x y:oms.searchResultRouteStart.coordLocationPoint.y dong:1 searchType:searchType];
    }
    else if ( oms.searchResultRouteVisit.used && oms.searchResultRouteVisit.isCurrentLocation)
    {
        [[ServerConnector sharedServerConnection] requestGeocodingCoordForSearchRoute:self action:@selector(didRefineTargetAddress:) type:2 x:oms.searchResultRouteVisit.coordLocationPoint.x y:oms.searchResultRouteVisit.coordLocationPoint.y dong:1 searchType:searchType];
    }
    else if (oms.searchResultRouteDest.isCurrentLocation)
    {
        [[ServerConnector sharedServerConnection] requestGeocodingCoordForSearchRoute:self action:@selector(didRefineTargetAddress:) type:3 x:oms.searchResultRouteDest.coordLocationPoint.x y:oms.searchResultRouteDest.coordLocationPoint.y dong:1 searchType:searchType];
    }
    // 바로 경로탐색 시작해도 됨.
    else
    {
        [[ServerConnector sharedServerConnection] requestRouteSearch:self action:@selector(didFinish_SearchRoute_Car:) SX:oms.searchResultRouteStart.coordLocationPoint .x SY:oms.searchResultRouteStart.coordLocationPoint .y EX:oms.searchResultRouteDest.coordLocationPoint.x EY:oms.searchResultRouteDest.coordLocationPoint.y RPType:0/*자동차검색*/ CoordType:7 VX1:oms.searchResultRouteVisit.coordLocationPoint.x VY1:oms.searchResultRouteVisit.coordLocationPoint.y Priority:searchType];
    }
}

- (void) didRefineTargetAddress :(ServerRequester*)request
{
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        // 출발지 주소 처리한 경우  경유지or 도착지 처리
        if ( [request userInt] == 1 )
        {
            if ( oms.searchResultRouteVisit.used && oms.searchResultRouteVisit.isCurrentLocation )
            {
                [[ServerConnector sharedServerConnection] requestGeocodingCoordForSearchRoute:self action:@selector(didRefineTargetAddress:) type:2 x:oms.searchResultRouteVisit.coordLocationPoint.x y:oms.searchResultRouteVisit.coordLocationPoint.y dong:1 searchType:[request userInt]];
            }
            else if ( oms.searchResultRouteDest.isCurrentLocation )
            {
                [[ServerConnector sharedServerConnection] requestGeocodingCoordForSearchRoute:self action:@selector(didRefineTargetAddress:) type:3 x:oms.searchResultRouteDest.coordLocationPoint.x y:oms.searchResultRouteDest.coordLocationPoint.y dong:1 searchType:[request userInt]];
            }
            else
            {
                int searchType = [((NSNumber*)[request userObject]) doubleValue];
                [[ServerConnector sharedServerConnection] requestRouteSearch:self action:@selector(didFinish_SearchRoute_Car:) SX:oms.searchResultRouteStart.coordLocationPoint .x SY:oms.searchResultRouteStart.coordLocationPoint .y EX:oms.searchResultRouteDest.coordLocationPoint.x EY:oms.searchResultRouteDest.coordLocationPoint.y RPType:0/*자동차검색*/ CoordType:7 VX1:oms.searchResultRouteVisit.coordLocationPoint.x VY1:oms.searchResultRouteVisit.coordLocationPoint.y Priority:searchType];
            }
        }
        // 경유지 주소 처리한 경우 도착지 처리
        else if ( [request userInt] == 2)
        {
            if ( oms.searchResultRouteDest.isCurrentLocation )
            {
                [[ServerConnector sharedServerConnection] requestGeocodingCoordForSearchRoute:self action:@selector(didRefineTargetAddress:) type:3 x:oms.searchResultRouteDest.coordLocationPoint.x y:oms.searchResultRouteDest.coordLocationPoint.y dong:1 searchType:[request userInt]];
            }
            else
            {
                int searchType = [((NSNumber*)[request userObject]) doubleValue];
                [[ServerConnector sharedServerConnection] requestRouteSearch:self action:@selector(didFinish_SearchRoute_Car:) SX:oms.searchResultRouteStart.coordLocationPoint .x SY:oms.searchResultRouteStart.coordLocationPoint .y EX:oms.searchResultRouteDest.coordLocationPoint.x EY:oms.searchResultRouteDest.coordLocationPoint.y RPType:0/*자동차검색*/ CoordType:7 VX1:oms.searchResultRouteVisit.coordLocationPoint.x VY1:oms.searchResultRouteVisit.coordLocationPoint.y Priority:searchType];
            }
            
        }
        // 도착지 처리한 경우 경로탐색 시작
        else if ( [request userInt] == 3 )
        {
            int searchType = [((NSNumber*)[request userObject]) doubleValue];
            [[ServerConnector sharedServerConnection] requestRouteSearch:self action:@selector(didFinish_SearchRoute_Car:) SX:oms.searchResultRouteStart.coordLocationPoint .x SY:oms.searchResultRouteStart.coordLocationPoint .y EX:oms.searchResultRouteDest.coordLocationPoint.x EY:oms.searchResultRouteDest.coordLocationPoint.y RPType:0/*자동차검색*/ CoordType:7 VX1:oms.searchResultRouteVisit.coordLocationPoint.x VY1:oms.searchResultRouteVisit.coordLocationPoint.y Priority:searchType];
        }
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}

// 길찾기 완료후 동작 코드 (자동차UI)
- (void) didFinish_SearchRoute_Car :(id)request
{
    // 데이터 수신 완료
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        
        // 정상적으로 검색된 경우
        if(oms.searchRouteData.isRouteCar)
        {
            // 길찾기 화면 띄우자
            SearchRouteResultMapViewController *srrmvc = [[SearchRouteResultMapViewController alloc] initWithNibName:@"SearchRouteResultMapViewController" bundle:nil];
            [[OMNavigationController sharedNavigationController] pushViewController:srrmvc animated:NO];
            [srrmvc release];
            
            // 최근검색에 저장하도록하자
            NSMutableDictionary *recentSearchDic = [NSMutableDictionary dictionary];
            // 타입
            [recentSearchDic setObject:@"ROUTE" forKey:@"TYPE"];
            // 출발지 정보
            [recentSearchDic setObject:[NSString stringWithFormat:@"%@", oms.searchResultRouteStart.strLocationName] forKey:@"START_NAME"];
            [recentSearchDic setObject:[NSNumber numberWithDouble:oms.searchResultRouteStart.coordLocationPoint.x] forKey:@"START_X"];
            [recentSearchDic setObject:[NSNumber numberWithDouble:oms.searchResultRouteStart.coordLocationPoint.y] forKey:@"START_Y"];
            // 아이콘타입
            [recentSearchDic setObject:[NSNumber numberWithInt:Favorite_IconType_Course] forKey:@"ICONTYPE"];
            // 경유지 정보
            if (oms.searchResultRouteVisit.used)
            {
                [recentSearchDic setObject:[NSString stringWithFormat:@"%@", oms.searchResultRouteVisit.strLocationName] forKey:@"VISIT_NAME"];
                [recentSearchDic setObject:[NSNumber numberWithDouble:oms.searchResultRouteVisit.coordLocationPoint.x] forKey:@"VISIT_X"];
                [recentSearchDic setObject:[NSNumber numberWithDouble:oms.searchResultRouteVisit.coordLocationPoint.y] forKey:@"VISIT_Y"];
            }
            else
            {
                [recentSearchDic setObject:@"" forKey:@"VISIT_NAME"];
                [recentSearchDic setObject:[NSNumber numberWithDouble:0] forKey:@"VISIT_X"];
                [recentSearchDic setObject:[NSNumber numberWithDouble:0] forKey:@"VISIT_Y"];
            }
            // 도착지 정보
            [recentSearchDic setObject:[NSString stringWithFormat:@"%@", oms.searchResultRouteDest.strLocationName] forKey:@"STOP_NAME"];
            [recentSearchDic setObject:[NSNumber numberWithDouble:oms.searchResultRouteDest.coordLocationPoint.x] forKey:@"STOP_X"];
            [recentSearchDic setObject:[NSNumber numberWithDouble:oms.searchResultRouteDest.coordLocationPoint.y] forKey:@"STOP_Y"];
            // 최근검색 저장
            [oms addRecentSearch:recentSearchDic];
        }
        else
        {
            [OMMessageBox showAlertMessage:@"" : [SearchRouteExecuter getSearchRouteErrorMessage:oms.searchRouteData.routeCarError] ];
        }
    }
    // 길찾기 API  오류난 경우는 Request 에서 메세지 처리함
}

- (void) searchRoute_Public
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // **************
    // 출발-경유-도착지에 대한 유효성 체크
    // **************
    
    // 출발-도착지 선택여부, 길찾기 최소조건
    if ( oms.searchResultRouteStart.used == NO)
    {
        [OMMessageBox showAlertMessage:@"":@"출발지에 대한 정보가 존재하지 않습니다."];
        return;
    }
    else if ( oms.searchResultRouteDest.used == NO )
    {
        [OMMessageBox showAlertMessage:@"" :@"도착지에 대한 정보가 존재하지 않습니다."];
        return;
    }
    
    // 출발지-도착지 현재위치 중복사용 (대중교통은 경유지 무시..)
    else if ( oms.searchResultRouteVisit.used == NO && oms.searchResultRouteStart.isCurrentLocation && oms.searchResultRouteDest.isCurrentLocation )
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchRoute_DuplicatedStartDest", @"출발-도착")];
        return;
    }
    
    // 출발지 - 도착지 동일지점 && 경유지가 없을 경우에만
    else if ( CoordDistance(oms.searchResultRouteStart.coordLocationPoint, oms.searchResultRouteDest.coordLocationPoint) <= 0
             && oms.searchResultRouteVisit.used == NO)
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchRoute_DuplicatedStartDest", @"출발-도착")];
        return;
    }
    
    
    // 탐색 지점을  현재위치로 설정했을 경우 현재 실제좌표로 변환
    [[MapContainer sharedMapContainer_Main].kmap restartUserLocationTracing];
    Coord currentCoordinate = [MapContainer sharedMapContainer_Main].getCurrentUserLocation;
    
    //  KMap 이 현재좌표에 대한 값을 주지 못할때 직접 좌표 구하기..
    if ( currentCoordinate.x == 0 && currentCoordinate.y == 0 )
    {
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        Coord currentCoordWgs84 = CoordMake(locationManager.location.coordinate.longitude, locationManager.location.coordinate.latitude);
        currentCoordinate = [[MapContainer sharedMapContainer_Main].kmap convertCoordinate:currentCoordWgs84 inCoordType:KCoordType_WGS84 outCoordType:KCoordType_UTMK];
        [locationManager release];
    }
    
    // 현재 위치로 설정된 목적지의 경우 좌표값을 넣어줌
    if (oms.searchResultRouteStart.isCurrentLocation)
    {
        oms.searchResultRouteStart.coordLocationPoint = currentCoordinate;
    }
    if (oms.searchResultRouteDest.isCurrentLocation)
    {
        oms.searchResultRouteDest.coordLocationPoint = currentCoordinate;
    }
    
    // 출발지가 실제좌표로 변환된 지점에 대해 주소변환 시도 or 주소값이 없는 경우에도 주소변환 시도
    if (oms.searchResultRouteStart.isCurrentLocation
        || oms.searchResultRouteStart.strLocationName.length <= 0  )
    {
        [[ServerConnector sharedServerConnection] requestGeocodingCoordForSearchRoute:self action:@selector(didRefineTargetAddress_Public:) type:1 x:oms.searchResultRouteStart.coordLocationPoint.x y:oms.searchResultRouteStart.coordLocationPoint.y dong:1 searchType:0];
    }
    // 도착지가 실제좌표로 변환된 지점에 대해 주소변환 시도 or 주소값이 없는 경우에도 주소변환 시도
    else if (oms.searchResultRouteDest.isCurrentLocation
             || oms.searchResultRouteDest.strLocationName.length <= 0)
    {
        [[ServerConnector sharedServerConnection] requestGeocodingCoordForSearchRoute:self action:@selector(didRefineTargetAddress_Public:) type:3 x:oms.searchResultRouteDest.coordLocationPoint.x y:oms.searchResultRouteDest.coordLocationPoint.y dong:1 searchType:0];
    }
    // 탐색 시도
    else
    {
        [[ServerConnector sharedServerConnection] requestRouteSearch:self action:@selector(didFinish_SearchRoute_Public:) SX:oms.searchResultRouteStart.coordLocationPoint .x SY:oms.searchResultRouteStart.coordLocationPoint .y EX:oms.searchResultRouteDest.coordLocationPoint.x EY:oms.searchResultRouteDest.coordLocationPoint.y RPType:1/*자동차검색*/ CoordType:7 VX1:oms.searchResultRouteVisit.coordLocationPoint.x VY1:oms.searchResultRouteVisit.coordLocationPoint.y Priority:0];
    }
    
}
- (void) didRefineTargetAddress_Public :(ServerRequester*)request
{
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        // 출발(1)에 대한 주소변환이 끝난 상태에서 도착(1)에 대한 주소변환 여부 판단한다.
        if ( [request userInt] == 1 &&
            (oms.searchResultRouteDest.isCurrentLocation
             || oms.searchResultRouteDest.strLocationName.length <= 0) )
        {
            [[ServerConnector sharedServerConnection] requestGeocodingCoordForSearchRoute:self action:@selector(didRefineTargetAddress_Public:) type:3 x:oms.searchResultRouteDest.coordLocationPoint.x y:oms.searchResultRouteDest.coordLocationPoint.y dong:1 searchType:0];
        }
        // 바로 길찾기 시도
        //else if ( [request userInt] == 3 )
        else
        {
            [[ServerConnector sharedServerConnection] requestRouteSearch:self action:@selector(didFinish_SearchRoute_Public:) SX:oms.searchResultRouteStart.coordLocationPoint .x SY:oms.searchResultRouteStart.coordLocationPoint .y EX:oms.searchResultRouteDest.coordLocationPoint.x EY:oms.searchResultRouteDest.coordLocationPoint.y RPType:1/*자동차검색*/ CoordType:7 VX1:oms.searchResultRouteVisit.coordLocationPoint.x VY1:oms.searchResultRouteVisit.coordLocationPoint.y Priority:0];
        }
        
        
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}
- (void) didFinish_SearchRoute_Public :(ServerRequester*)request
{
    // 데이터 수신 완료
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        
        // 정상적으로 검색된 경우
        if(oms.searchRouteData.isRoutePublic)
        {
            // 길찾기 화면 띄우자
            SearchRouteResultMapViewController *srrmvc = [[SearchRouteResultMapViewController alloc] initWithNibName:@"SearchRouteResultMapViewController_PublicFirst" bundle:nil];
            [[OMNavigationController sharedNavigationController] pushViewController:srrmvc animated:NO];
            [srrmvc release];
            
            // 최근검색에 저장하도록하자
            NSMutableDictionary *recentSearchDic = [NSMutableDictionary dictionary];
            // 타입
            [recentSearchDic setObject:@"ROUTE" forKey:@"TYPE"];
            // 출발지 정보
            [recentSearchDic setObject:[NSString stringWithFormat:@"%@", oms.searchResultRouteStart.strLocationName] forKey:@"START_NAME"];
            [recentSearchDic setObject:[NSNumber numberWithDouble:oms.searchResultRouteStart.coordLocationPoint.x] forKey:@"START_X"];
            [recentSearchDic setObject:[NSNumber numberWithDouble:oms.searchResultRouteStart.coordLocationPoint.y] forKey:@"START_Y"];
            // 아이콘타입
            [recentSearchDic setObject:[NSNumber numberWithInt:Favorite_IconType_Course] forKey:@"ICONTYPE"];
            // 경유지 정보 ( 사용안함)
            {
                [recentSearchDic setObject:@"" forKey:@"VISIT_NAME"];
                [recentSearchDic setObject:[NSNumber numberWithDouble:0] forKey:@"VISIT_X"];
                [recentSearchDic setObject:[NSNumber numberWithDouble:0] forKey:@"VISIT_Y"];
            }
            // 도착지 정보
            [recentSearchDic setObject:[NSString stringWithFormat:@"%@", oms.searchResultRouteDest.strLocationName] forKey:@"STOP_NAME"];
            [recentSearchDic setObject:[NSNumber numberWithDouble:oms.searchResultRouteDest.coordLocationPoint.x] forKey:@"STOP_X"];
            [recentSearchDic setObject:[NSNumber numberWithDouble:oms.searchResultRouteDest.coordLocationPoint.y] forKey:@"STOP_Y"];
            // 최근검색 저장
            [oms addRecentSearch:recentSearchDic];
        }
        else
        {
            [OMMessageBox showAlertMessage:@"" : [SearchRouteExecuter getSearchRouteErrorMessage:oms.searchRouteData.routePublicError] ];
        }
    }
    // 길찾기 API  오류난 경우는 Request 에서 메세지 처리함
}

// ****************


// ==================
// [ 보조메소드 시작 ]
// ==================

+ (NSString*) getSearchRouteErrorMessage :(NSString*)msg
{
    if ([msg isEqualToString:@""])
        return @"";
    
    // Type A
    else if ([msg isEqualToString:@"ROUTE_START_FAIL"])
        return @"경로탐색에 실패했습니다.\n이용에 불편을 드려 죄송합니다.\n[E-C001]";
    else if ([msg isEqualToString:@"ROUTE_DEST_FAIL"])
        return @"경로탐색에 실패했습니다.\n이용에 불편을 드려 죄송합니다.\n[E-C002]";
    else if ([msg isEqualToString:@"ROUTE_VIA1_FAIL"])
        return @"경로탐색에 실패했습니다.\n이용에 불편을 드려 죄송합니다.\n[E-C003]";
    else if ([msg isEqualToString:@"ROUTE_FAIL"])
        return @"경로탐색에 실패했습니다.\n이용에 불편을 드려 죄송합니다.\n[E-C006]";
    else if ([msg isEqualToString:@"ROUTE_STARTPOS_FAIL"])
        return @"경로탐색에 실패했습니다.\n이용에 불편을 드려 죄송합니다.\n[E-T002]";
    else if ([msg isEqualToString:@"ROUTE_DESTPOS_FAIL"])
        return @"경로탐색에 실패했습니다.\n이용에 불편을 드려 죄송합니다.\n[E-T003]";
    else if ([msg isEqualToString:@"ROUTE_FAIL"])
        return @"경로탐색에 실패했습니다.\n이용에 불편을 드려 죄송합니다.\n[E-T004]";
    else if ([msg isEqualToString:@"ROUTE_FAIL_RG01"])
        return @"경로탐색에 실패했습니다.\n이용에 불편을 드려 죄송합니다.\n[E-R001]";
    else if ([msg isEqualToString:@"ROUTE_FAIL_RP01"])
        return @"경로탐색에 실패했습니다.\n이용에 불편을 드려 죄송합니다.\n[E-R002]";
    else if ([msg isEqualToString:@"ROUTE_FAIL_RP02"])
        return @"경로탐색에 실패했습니다.\n이용에 불편을 드려 죄송합니다.\n[E-R003]";
    else if ([msg isEqualToString:@"ROUTE_FAIL_RP08"])
        return @"경로탐색에 실패했습니다.\n이용에 불편을 드려 죄송합니다.\n[E-R009]";
    else if ([msg isEqualToString:@"ROUTE_FAIL_FM01"])
        return @"경로탐색에 실패했습니다.\n이용에 불편을 드려 죄송합니다.\n[E-R010]";
    
    // Type B
    else if ([msg isEqualToString:@"ROUTE_DISTANCE_FAIL"])
        return @"목적지간 거리가 짧아 경로탐색이 제공되지 않습니다.\n이용에 불편을 드려 죄송합니다.\n[E-C007]";
    else if ([msg isEqualToString:@"ROUTE_CLOSERANGE_FAIL"])
        return @"목적지간 거리가 짧아 경로탐색이 제공되지 않습니다.\n이용에 불편을 드려 죄송합니다.\n[E-T001]";
    
    // Type C
    else if ([msg isEqualToString:@"ROUTE_NOTMOVE_FAIL"])
        return @"해당 지역에서는 경로탐색이 지원되지 않습니다.\n이용에 불편을 드려 죄송합니다.\n[E-C008]";
    else if ([msg isEqualToString:@"ROUTE_PUBLIC_TRANSIT_FAIL"])
        return @"해당 지역에서는 경로탐색이 지원되지 않습니다.\n이용에 불편을 드려 죄송합니다.\n[E-T005]";
    else if ([msg isEqualToString:@"ROUTE_FAIL_RP03"])
        return @"해당 지역에서는 경로탐색이 지원되지 않습니다.\n이용에 불편을 드려 죄송합니다.\n[E-R004]";
    else if ([msg isEqualToString:@"ROUTE_FAIL_RP04"])
        return @"해당 지역에서는 경로탐색이 지원되지 않습니다.\n이용에 불편을 드려 죄송합니다.\n[E-R005]";
    else if ([msg isEqualToString:@"ROUTE_FAIL_RP07"])
        return @"해당 지역에서는 경로탐색이 지원되지 않습니다.\n이용에 불편을 드려 죄송합니다.\n[E-R008]";
    
    // Type D
    else if ([msg isEqualToString:@"ROUTE_FAIL_RP05"])
        return @"설정된 경로옵션에서는 경로탐색이 지원되지 않습니다.\n[E-R006]";
    else if ([msg isEqualToString:@"ROUTE_FAIL_RP06"])
        return @"설정된 경로옵션에서는 경로탐색이 지원되지 않습니다.\n[E-R007]";
    
    // Type unknown
    // else return msg;
    else return NSLocalizedString(@"Msg_SearchFailedWithException", @"");
}
// *******************


@end
