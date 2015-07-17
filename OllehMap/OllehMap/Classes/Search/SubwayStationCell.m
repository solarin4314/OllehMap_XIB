//
//  SubwayStationCell.m
//  OllehMap
//
//  Created by 이 제민 on 12. 8. 7..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "SubwayStationCell.h"
#import "MainMapViewController.h"

@implementation SubwayStationCell

@synthesize subwayStationName;
@synthesize subwayStationLine;
@synthesize subwayStationImg;
@synthesize subwayStationStr;
@synthesize subwayStationDistance;
@synthesize subwayStationRightBar;
@synthesize subwayStationDo;
@synthesize subwayStationGu;
@synthesize subwayStationDong;
@synthesize subwayStationSinglePOI;
@synthesize subwayBgView;
@synthesize subwayStationBtnView;
@synthesize subwayStart;
@synthesize subwayDest;
@synthesize subwayVisit;
@synthesize subwayShare;
@synthesize subwayDetail;

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
    [subwayStationName release];
    [subwayStationImg release];
    [subwayStationStr release];
    [subwayStationDistance release];
    [subwayStationRightBar release];
    [subwayStationDo release];
    [subwayStationGu release];
    [subwayStationDong release];
    [subwayStationSinglePOI release];
    [subwayBgView release];
    [subwayStationBtnView release];
    [subwayStart release];
    [subwayDest release];
    [subwayVisit release];
    [subwayShare release];
    [subwayDetail release];
    [subwayStationLine release];
    [super dealloc];
}
- (IBAction)subwayStartClick:(id)sender 
{
    // 출발지통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/search_result/start"];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    NSString *place = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellName"];
    NSString *laneName = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellLaneName"];
    double x = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellX"] doubleValue];
    oms.currentMapLocationMode = MapLocationMode_None;
    double y = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellY"] doubleValue];
    
    NSLog(@"%@, %f, %f", place, x, y);
    
    [oms.searchResultRouteStart reset];
    [oms.searchResultRouteStart setUsed:YES];
    [oms.searchResultRouteStart setIsCurrentLocation:NO];
    [oms.searchResultRouteStart setStrLocationName:[NSString stringWithFormat:@"%@ (%@)", place, laneName]];
    [oms.searchResultRouteStart setCoordLocationPoint:CoordMake(x, y)];
    [[SearchRouteDialogViewController sharedSearchRouteDialog] showSearchRouteDialog];
    [mc.kmap setCenterCoordinate:oms.searchResultRouteStart.coordLocationPoint];
}

- (IBAction)subwayDestClick:(id)sender 
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

- (IBAction)subwayVisitClick:(id)sender 
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

- (IBAction)subwayShareClick:(id)sender 
{
    // 위치공유 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/search_result/share"];
    
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSString *place = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellName"];
    //NSString *poiId = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellId"];
    double x = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellX"] doubleValue];
    
    double y = [[oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellY"] doubleValue];
    
    NSString *Addadd = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellTelAddress"];
    
    NSString *stId = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellId"];
    
    if(!Addadd)
        Addadd = @"";
    
    // 새로운 url공유
    NSString *order = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendOrder"];
    [[ServerConnector sharedServerConnection] requestSearchURL:self action:@selector(finishShareBtnClick:) PX:(int)x PY:(int)y Query:oms.keyword SearchType:@"traffic" order:order];
    
    //[[ServerConnector sharedServerConnection] requestShortenURL:self action:@selector(finishShareBtnClick:) PX:(int)x PY:(int)y Level:mc.kmap.zoomLevel MapType:mc.kmap.mapType Name:place PID:stId Addr:Addadd Tel:nil Type:@"TR" ID:stId];
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

- (IBAction)subwayDetailClick:(id)sender 
{
    
    // 상세 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/search_result/detail"];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    // 마지막클릭한 타입, ID, didCode, 주소
    NSString *masterID = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellId"];

    
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
