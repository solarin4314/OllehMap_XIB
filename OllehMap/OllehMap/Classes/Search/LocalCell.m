//
//  LocalCell.m
//  OllehMap
//
//  Created by 이 제민 on 12. 8. 6..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "LocalCell.h"
#import "MainMapViewController.h"

@implementation LocalCell

@synthesize cellBgView = _cellBgView;
@synthesize localName = _localName;
@synthesize localAddress = _localAddress;
@synthesize localFreeCall = _localFreeCall;
@synthesize localLeftBar = _localLeftBar;
@synthesize localDistance = _localDistance;
@synthesize localRightBar = _localRightBar;
@synthesize localUj = _localUj;
@synthesize localSinglePOI = _localSinglePOI;
@synthesize localStrImg = _localStrImg;
@synthesize localImg = _localImg;
@synthesize localBtnView = _localBtnView;
@synthesize localStart = _localStart;
@synthesize localDest = _localDest;
@synthesize localVisit = _localVisit;
@synthesize localShare = _localShare;
@synthesize localDetail = _localDetail;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc 
{

    [_cellBgView release];
    [_localName release];
    [_localAddress release];
    [_localFreeCall release];
    [_localLeftBar release];
    [_localDistance release];
    [_localRightBar release];
    [_localUj release];
    [_localSinglePOI release];
    [_localBtnView release];
    [_localStart release];
    [_localDest release];
    [_localVisit release];
    [_localShare release];
    [_localDetail release];
    [_localStrImg release];
    [_localImg release];
    [super dealloc];
}

- (IBAction)localStartClick:(id)sender 
{
    // 출발지통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/search_result/start"];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    oms.currentMapLocationMode = MapLocationMode_None;
    
    NSString *place = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellName"];
    double x = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellX"] doubleValue];
    double y = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellY"] doubleValue];
    NSLog(@"%@, %f, %f", place, x, y);
    [oms.searchResultRouteStart reset];
    [oms.searchResultRouteStart setUsed:YES];
    [oms.searchResultRouteStart setIsCurrentLocation:NO];
    [oms.searchResultRouteStart setStrLocationName:place];
    [oms.searchResultRouteStart setCoordLocationPoint:CoordMake(x, y)];
    [[SearchRouteDialogViewController sharedSearchRouteDialog] showSearchRouteDialog];
    [mc.kmap setCenterCoordinate:oms.searchResultRouteStart.coordLocationPoint];
}

- (IBAction)localDestClick:(id)sender 
{
    // 도착지 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/search_result/dest"];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    oms.currentMapLocationMode = MapLocationMode_None;
    NSString *place = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellName"];
    double x = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellX"] doubleValue];
    double y = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellY"] doubleValue];
    NSLog(@"%@, %f, %f", place, x, y);
    [oms.searchResultRouteDest reset];
    [oms.searchResultRouteDest setUsed:YES];
    [oms.searchResultRouteDest setIsCurrentLocation:NO];
    [oms.searchResultRouteDest setStrLocationName:place];
    [oms.searchResultRouteDest setCoordLocationPoint:CoordMake(x, y)];
    [[SearchRouteDialogViewController sharedSearchRouteDialog] showSearchRouteDialog];
    [mc.kmap setCenterCoordinate:oms.searchResultRouteDest.coordLocationPoint];
}

- (IBAction)localVisitClick:(id)sender 
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    oms.currentMapLocationMode = MapLocationMode_None;
    NSString *place = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellName"];
    double x = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellX"] doubleValue];
    double y = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellY"] doubleValue];
    NSLog(@"%@, %f, %f", place, x, y);
    [oms.searchResultRouteVisit reset];
    [oms.searchResultRouteVisit setUsed:YES];
    [oms.searchResultRouteVisit setIsCurrentLocation:NO];
    [oms.searchResultRouteVisit setStrLocationName:place];
    [oms.searchResultRouteVisit setCoordLocationPoint:CoordMake(x, y)];
    [[SearchRouteDialogViewController sharedSearchRouteDialog] showSearchRouteDialog];
    
    [mc.kmap setCenterCoordinate:oms.searchResultRouteVisit.coordLocationPoint];
}

- (IBAction)localShareClick:(id)sender 
{
    // 위치공유 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/search_result/share"];
    
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSString *place = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellName"];
    NSString *poiId = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellDidCode"];
    NSString *orgDbId = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellId"];
    
    double x = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellX"] doubleValue];
    double y = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellY"] doubleValue];
    NSString *Addadd = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellTelAddress"];
    NSString *poiType = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellType"];
    
    NSString *themeCoder = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellTheme"];
    
    if([poiType isEqualToString:@"TR"])
    { 
        if([themeCoder rangeOfString:@"0406"].length > 0)
        {
            poiType = @"TR";
            poiId = orgDbId;
        }
        else if ([themeCoder rangeOfString:@"0407"].length > 0)
        {
            poiType = @"TR_BUS";
            poiId = orgDbId;
        }
        else
            poiType = @"MP";
    }
    
    if(!Addadd)
        Addadd = @"";
    // 새로운 url공유
    NSString *order = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendOrder"];
    [[ServerConnector sharedServerConnection] requestSearchURL:self action:@selector(finishShareBtnClick:) PX:(int)x PY:(int)y Query:oms.keyword SearchType:@"place" order:order];
    
    //[[ServerConnector sharedServerConnection] requestShortenURL:self action:@selector(finishShareBtnClick:) PX:(int)x PY:(int)y Level:mc.kmap.zoomLevel MapType:mc.kmap.mapType Name:place PID:poiId Addr:Addadd Tel:nil Type:poiType ID:orgDbId];
}
// 위치공유버튼클릭
- (void) finishShareBtnClick:(id)request
{
    if([request finishCode] == OMSRFinishCode_Completed)
    {
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        
        NSString *name = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellName"];
        NSString *tel = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellTel"];
        NSString *addr = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellTelAddress"];
        
        if(tel == nil)
            tel = @"";
        
        if(addr == nil)
            addr = @"";
        
        [oms.shareDictionary setObject:name forKey:@"NAME"];
        
        [oms.shareDictionary setObject:addr forKey:@"ADDR"];
        [oms.shareDictionary setObject:tel forKey:@"TEL"];
        
        NSLog(@"단축URL : %@", [oms.shareDictionary objectForKeyGC:@"ShortURL"]);
        
        //[self.view addSubview:[ShareViewController instVC].view];
        
        [ShareViewController sharePopUpView:self.superview.superview];
    }
    else 
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_ShortURL_NotResponse", @"")];
    }
}

- (IBAction)localDetailClick:(id)sender 
{
    
    // 상세 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/search_result/detail"];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    // 마지막클릭한 타입, ID, didCode, 주소
    NSString *type = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellType"];
    NSString *masterID = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellId"];
    NSString *didCode = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellDidCode"];
    NSString *theme = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellTheme"];

    
    NSLog(@"masterID = %@ \n didCode = %@ \n type = %@ \n theme = %@", masterID, didCode, type, theme);
    // 기름
    if([type isEqualToString:@"OL"])
    {
        /**
         @MethodDescription
         GW. POI상세 
         /v1/search/PoiInfo.json?POI_ID=%@
         @MethodParams
         didCode(DID_CODE) [POI_ID]
         @MethodMehotdReturn
         poi상세정보
         */
        
        
        //NSLog(@"DID_CODE : %@ 로 POI상세 API GO", oilID);
        [[ServerConnector sharedServerConnection] requestPoiDetailAtPoiId:self action:@selector(finishRequestoilDetail:) poiId:didCode];
    }
    // 영화
    else if ([type isEqualToString:@"MV"]) 
    {
        /**
         @MethodDescription
         GW. POI상세 
         /v1/search/PoiInfo.json?POI_ID=%@
         @MethodParams
         didCode(DID_CODE) [POI_ID]
         @MethodMehotdReturn
         poi상세정보
         */
        
        [[ServerConnector sharedServerConnection] requestPoiDetailAtPoiId:self action:@selector(finishRequestMovieDetailAtPoiId:) poiId:didCode];
    }
    
    // 지하철
    else if ([type isEqualToString:@"TR"] && [theme rangeOfString:@"0406"].length > 0) 
    {
        
        /**
         @MethodDescription
         GW. 지하철 상세
         /v1/masstransit/TrafficSubStationInfo.json?STID=%@
         @MethodParams
         masterId(ORG_DB_ID) [STID]
         @MethodMehotdReturn
         지하철 상세정보
         */
        
        [[ServerConnector sharedServerConnection] requestSubStation:self action:@selector(finishRequestSubwayDetail:) stationId:masterID];
        
    }
    // 버스(장소에서 버정이 나옴....)
    else if ([type isEqualToString:@"TR"] && [theme rangeOfString:@"0407"].length > 0) 
    {
        
        /**
         @MethodDescription
         GW. 버스정류장 상세
         /v1/masstransit/BusStation.json?STID=%@
         @MethodParams
         masterId(ORG_DB_ID) [STID]
         @MethodMehotdReturn
         버스정류장 상세정보
         */
        
        
        [[ServerConnector sharedServerConnection] requestBusStationInfoStid:self action:@selector(finishRequestBusDetail:) stId:masterID];
    }
    // 버스(강제 타입 고정, 지하철과 버스 구분이 안되기 때문
    else if ([type isEqualToString:@"TR_BUS"]) 
    {
        
        /**
         @MethodDescription
         GW. 버스정류장 상세
         /v1/masstransit/BusStation.json?STID=%@
         @MethodParams
         masterId(ORG_DB_ID) [STID]
         @MethodMehotdReturn
         버스정류장 상세정보
         */
        
        [[ServerConnector sharedServerConnection] requestBusStationInfoStid:self action:@selector(finishRequestBusDetail:) stId:masterID];
        
    }
    // 와이파이(나중에 쓸듯?)
    else if ([type isEqualToString:@"WI"]) 
    {
        [OMMessageBox showAlertMessage:@"상세정보" :@"와이파이 입니다"];
    }
    
    // MP 포함해서 그 외....
    else {
        
        /**
         @MethodDescription
         GW. POI상세 
         /v1/search/PoiInfo.json?POI_ID=%@
         @MethodParams
         masterId(ORG_DB_ID) [POI_ID]
         @MethodMehotdReturn
         poi상세정보
         */
        
        [[ServerConnector sharedServerConnection] requestPoiDetailAtPoiId:self action:@selector(finishRequestPoiDetailAtPoiId:) poiId:masterID];
        
    }

}
// 영화상세 UI콜백
- (void)finishRequestMovieDetailAtPoiId:(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        if([oms.poiDetailDictionary count] <= 0)
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_POI_DetailView_NothingInfo", @"")];
        }
        else 
        {
            // POI상세 선택 통계
            [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail"];
            MoviePOIDetailViewController *mpdvc = [[MoviePOIDetailViewController alloc] initWithNibName:@"MoviePOIDetailViewController" bundle:nil];
            // ver3테스트3번버그(일반상세API에는 상세이름까지 없다...결과에서넘겨줘야됨 ㅡㅡ)
            NSString *name = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellName"];
            
            [mpdvc setThemeToDetailName:name];
            
            [[OMNavigationController sharedNavigationController] pushViewController:mpdvc animated:NO];
            [mpdvc release];
        }
    }
    else 
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
    
}
// 일반상세 UI콜백
-(void)finishRequestPoiDetailAtPoiId:(id)request
{
    
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        if([oms.poiDetailDictionary count] <= 0)
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_POI_DetailView_NothingInfo", @"")];
        }
        else 
        {
            // POI상세 선택 통계
            [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail"];
            
            GeneralPOIDetailViewController *gpdvc = [[GeneralPOIDetailViewController alloc] initWithNibName:@"GeneralPOIDetailViewController" bundle:nil];
            
            // ver3테스트3번버그(일반상세API에는 상세이름까지 없다...결과에서넘겨줘야됨 ㅡㅡ) 
                NSString *name = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellName"];
            
            [gpdvc setThemeToDetailName:name];
            
            [[OMNavigationController sharedNavigationController] pushViewController:gpdvc animated:NO];
            [gpdvc release];
        }
        
    }
    else 
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
    
}
// 유가상세 UI콜백
-(void)finishRequestoilDetail:(id)request
{
    
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        if([oms.poiDetailDictionary count] <= 0)
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_POI_DetailView_NothingInfo", @"")];
        }
        else 
        {
            
            
            // POI상세 선택 통계
            [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail"];
            
            OilPOIDetailViewController *opdvc = [[OilPOIDetailViewController alloc] initWithNibName:@"OilPOIDetailViewController" bundle:nil];
            
            [[OMNavigationController sharedNavigationController] pushViewController:opdvc animated:NO];
            [opdvc release];
        }
    }
    else 
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}

// 버스정류장상세 UI콜백
- (void) finishRequestBusDetail:(id)request
{
    
    if([request finishCode] == OMSRFinishCode_Completed)
    {
        //[OllehMapStatus sharedOllehMapStatus].pushPop = NO;
        // POI상세 선택 통계
        [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail"];
        BusStationDetailViewController *bspdvc = [[BusStationDetailViewController alloc] initWithNibName:@"BusStationDetailViewController" bundle:nil];
        
        [[OMNavigationController sharedNavigationController] pushViewController:bspdvc animated:NO];
        [bspdvc release];
    }
    else 
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
    
}
// 지하철상세 UI콜백
-(void)finishRequestSubwayDetail:(id)request
{
    
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        if([oms.subwayDetailDictionary count] <= 0)
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_POI_DetailView_NothingInfo", @"")];
        }
        else 
        {
            // POI상세 선택 통계
            [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail"];
            SubwayPOIDetailViewController *spdvc = [[SubwayPOIDetailViewController alloc] initWithNibName:@"SubwayPOIDetailViewController" bundle:nil];
            
            
            [[OMNavigationController sharedNavigationController] pushViewController:spdvc animated:NO];
            [spdvc release];
        }
    }
    else 
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}

@end
