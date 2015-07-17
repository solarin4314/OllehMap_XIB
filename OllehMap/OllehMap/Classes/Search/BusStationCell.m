//
//  BusStationCell.m
//  OllehMap
//
//  Created by 이 제민 on 12. 8. 7..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "BusStationCell.h"
#import "MainMapViewController.h"

@implementation BusStationCell

@synthesize busStationBgView;
@synthesize busStationImg;
@synthesize busStationStrImg;
@synthesize busStationName;
@synthesize busStationUniqueId;
@synthesize busStationDistance;
@synthesize busStationRightBar;
@synthesize busStationDo;
@synthesize busStationGu;
@synthesize busStationDong;
@synthesize busStationSinglePOI;
@synthesize busStationBtnView;
@synthesize busStationStart;
@synthesize busStationDest;
@synthesize busStationVisit;
@synthesize busStationShare;
@synthesize busStationDetail;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [busStationName release];
    [busStationUniqueId release];
    [busStationDistance release];
    [busStationRightBar release];
    [busStationDo release];
    [busStationGu release];
    [busStationDong release];
    [busStationSinglePOI release];
    [busStationBtnView release];
    [busStationStart release];
    [busStationDest release];
    [busStationVisit release];
    [busStationShare release];
    [busStationDetail release];
    [busStationBgView release];
    [busStationImg release];
    [busStationStrImg release];

    [super dealloc];
}
- (IBAction)busStationStartClick:(id)sender 
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

- (IBAction)busStationDestClick:(id)sender 
{
    // 도착지 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/search_result/dest"];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    NSString *place = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellName"];
    oms.currentMapLocationMode = MapLocationMode_None;
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

- (IBAction)busStationVisitClick:(id)sender 
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    NSString *place = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellName"];
    oms.currentMapLocationMode = MapLocationMode_None;
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

- (IBAction)busStationShareClick:(id)sender 
{
    // 위치공유 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/search_result/share"];
    
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSString *place = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellName"];
    NSString *poiId = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellId"];
    double x = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellX"] doubleValue];
    
    double y = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellY"] doubleValue];
    
    NSString *Addadd = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellTelAddress"];
    
    if(!Addadd)
        Addadd = @"";
    
    // 새로운 url공유
    NSString *order = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendOrder"];
    [[ServerConnector sharedServerConnection] requestSearchURL:self action:@selector(finishShareBtnClick:) PX:(int)x PY:(int)y Query:oms.keyword SearchType:@"traffic" order:order];
    
    //[[ServerConnector sharedServerConnection] requestShortenURL:self action:@selector(finishShareBtnClick:) PX:(int)x PY:(int)y Level:mc.kmap.zoomLevel MapType:mc.kmap.mapType Name:place PID:poiId Addr:Addadd Tel:nil Type:@"TR_BUS" ID:poiId];
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

- (IBAction)busStationDetailClick:(id)sender 
{
    
    // 상세 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/search_result/detail"];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    // 마지막클릭한 타입, ID, didCode, 주소
    
    NSString *masterID = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellId"];


        
        /**
         @MethodDescription
         GW. 버스정류장 상세
         /v1/masstransit/BusStation.json?STID=%@
         @MethodParams
         masterId(ORG_DB_ID) [STID]
         @MethodMehotdReturn
         버스정류장 상세정보
         */
        
        //[[ServerConnector sharedServerConnection] requestBusStation:self action:@selector(finishRequestBusDetail:) stationId:masterID];
    [[ServerConnector sharedServerConnection] requestBusStationInfoStid:self action:@selector(finishRequestBusDetail:) stId:masterID];
        
    




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

@end
