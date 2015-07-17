//
//  MapContainer.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 5. 4..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "MapContainer.h"
#import "MyImage.h"

#import "MainMapViewController.h"


#if 0
// 그러니까 이게 앞으로 사용하지 않을 오버레이입니다. 그러니 사용하지마세요. 삭제할예정
@implementation ExpansionImageOverlay
@synthesize index = _index;
@synthesize duplicatePOIIndexList = _duplicatePOIIndexList;

- (id) init
{
    id _self = [super init];
    _duplicatePOIIndexList = [[NSMutableArray alloc] init];
    return _self;
}

- (id) initWithImage:(UIImage *)image
{
    id _self = [super initWithImage:image];
    _duplicatePOIIndexList = [[NSMutableArray alloc] init];
    return _self;
}

- (void) dealloc
{
    [_duplicatePOIIndexList release];
    [super dealloc];
}

-(BOOL) hasIndexNumber :(int)index
{
    for (NSNumber *indexNumber in _duplicatePOIIndexList)
    {
        if ( [indexNumber intValue] == index ) return YES;
    }
    return NO;
}

@end
#endif



// OMKMapView 클래스 구현
@implementation OMKMapView

@synthesize trafficCCTV = _trafficCCTV;
@synthesize trafficBusStation = _trafficBusStation;
@synthesize trafficSubwayStation = _trafficSubwayStation;
@synthesize lastLongTapCoordinate = _lastLongTapCoordinate;
@synthesize lastMapCenterCoordinate = _lastMapCenterCoordinate;
@synthesize lastMapZoomLevel = _lastMapZoomLevel;
@synthesize theme = _theme;

- (id) init
{
    self = [super init];
    if ( self ) [self initComponents];
    return self;
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self ) [self initComponents];
    return self;
}
- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self ) [self initComponents];
    return self;
}
- (void) initComponents
{
    if ( self )
    {
        overlayWorkQueue = dispatch_queue_create("OllehMapOverlays", NULL);
    }
}

// 오버레이 관리메소드 오버라이딩
- (NSArray*) getOverlays
{
    __block NSArray *allOverlays = nil;
    __block BOOL hasException = NO;
    dispatch_sync(overlayWorkQueue, ^{
        @try
        {
            allOverlays = [[[super getOverlays] copy] autorelease];
        }
        @catch (NSException *exception)
        {
            allOverlays = nil;
            hasException = YES;
        }
    });
    if ( hasException )
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithExceptionOverlay", @"")];
    }
    return allOverlays;
}
- (BOOL) addOverlay:(Overlay *)overlay
{
    __block BOOL addOverlayResult = NO;
    __block BOOL hasException = NO;
    dispatch_sync(overlayWorkQueue, ^{
        @try
        {
            addOverlayResult = [super addOverlay:overlay];
        }
        @catch (NSException *exception)
        {
            hasException = YES;
        }
    });
    if (hasException)
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithExceptionOverlay", @"")];
    }
    return addOverlayResult;
}
- (void) removeOverlay:(Overlay *)overlay
{
    __block BOOL hasException = NO;
    dispatch_sync(overlayWorkQueue, ^{
        @try
        {
            [super removeOverlay:overlay];
        }
        @catch (NSException *exception)
        {
            hasException = YES;
        }
    });
    if ( hasException )
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithExceptionOverlay", @"")];
    }
}
- (void) removeAllOverlays
{
    __block BOOL hasException = NO;
    dispatch_sync(overlayWorkQueue, ^{
        @try
        {
            [super removeAllOverlays];
        }
        @catch (NSException *exception)
        {
            hasException = YES;
        }
    });
    if ( hasException )
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithExceptionOverlay", @"")];
    }
}
- (void) removeAllBalloonOverlays
{
    __block BOOL hasException = NO;
    dispatch_sync(overlayWorkQueue, ^{
        @try
        {
            [super removeAllBalloonOverlays];
        }
        @catch (NSException *exception)
        {
            hasException = YES;
        }
    });
    if ( hasException )
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithExceptionOverlay", @"")];
    }
}
- (void) removeAllOverlaysWithDefault:(BOOL)withDefault withNormalPOI:(BOOL)withNormalPOI withTrafficPOI:(BOOL)withTrafficPOI withPolyLinePOI:(BOOL)withPolyLinePOI
{
    [self removeAllOverlaysWithDefault:withDefault withNormalPOI:withNormalPOI withTrafficPOI:withTrafficPOI withRoutingPOI:NO withPolyLinePOI:withPolyLinePOI];
}
// 오버레이 관리메소드 (private)
- (void) removeAllOverlaysWithDefault:(BOOL)withDefault withNormalPOI:(BOOL)withNormalPOI withTrafficPOI:(BOOL)withTrafficPOI withRoutingPOI:(BOOL)withRoutingPOI withPolyLinePOI:(BOOL)withPolyLinePOI
{
    NSMutableArray *deletePOIList = [[NSMutableArray alloc] init];
    // 오버레이 삭제대상을 추려낸다.
    for (Overlay *currentOverlay in self.getOverlays)
    {
        // 커스텀 이미지 오버레이에 대해 먼저 처리
        if ( [currentOverlay isKindOfClass:[OMImageOverlay class]] )
        {
            OMImageOverlay *currentCustomImageOverlay = (OMImageOverlay*)currentOverlay;
            // 교통옵션 처리용 오버레이는 따로 체크한다.
            if ( currentCustomImageOverlay.isTrafficOption )
            {
                // 교통옵션 삭제파라메터가 참일 경우 해당 오버레이도 삭제대상으로 추가한다.
                if ( withTrafficPOI ) [deletePOIList addObject:currentOverlay];
                
            }
            // 길찾기옵션 처리용 오버레이는 따로 체크한다.
            else if( currentCustomImageOverlay.isRouteOption )
            {
                // 길찾기옵션 삭제파라메터가 참일 경우 해당 오버레이도 삭제대상으로 추가한다.
                if ( withRoutingPOI ) [deletePOIList addObject:currentOverlay];
                
            }
            
            // 일반적인 오버레이 삭제여부에 따라 처리한다.
            else
            {
                if (withNormalPOI ) [deletePOIList addObject:currentOverlay];
            }
        }
        else if ([currentOverlay isKindOfClass:[OMPolylineOverlay class]])
        {
            OMPolylineOverlay *currentCustomPolylineOverlay = (OMPolylineOverlay *)currentOverlay;

            
            if(withPolyLinePOI) [deletePOIList addObject:currentCustomPolylineOverlay];
            
        }
        else
        {
            // 나머지 모든 오버레이에 대해서 처리한다.
            if ( withDefault ) [deletePOIList addObject:currentOverlay];
        }
    }
    // 맵에서 삭제대상 오버레이 제거하도록 한다.
    for (Overlay *deleteOverlay in deletePOIList)
    {
        [self removeOverlay:deleteOverlay];
    }
    // 삭제대상 오버레이 리스트 정리한다.
    [deletePOIList removeAllObjects];
    [deletePOIList release];
}

- (void) removeAllOverlaysWithoutTraffic
{
    // 교통옵션을 제외한 모든 오버레이를 제거한다.
    [self removeAllOverlaysWithDefault:YES withNormalPOI:YES withTrafficPOI:NO withPolyLinePOI:YES];
}
// 안쓴다 이메소드
- (void) removeAllOverlaysWithoutLinePoly
{
    // 라인폴리를 제외한 모든 오버레이 제거
    [self removeAllOverlaysWithDefault:YES withNormalPOI:YES withTrafficPOI:YES withPolyLinePOI:NO];
}
- (void) removeAllOverlaysWithoutTrafficWithoutLinePoly
{
    // 라인폴리와 교통 제외한 모든 오버레이를 제거
    [self removeAllOverlaysWithDefault:YES withNormalPOI:YES withTrafficPOI:NO withPolyLinePOI:NO];
}
// 안쓴다 이 메소드
- (void) removeAllOverlaysWithoutTrafficRoute
{
    // 길찾기 제외한 모두 제거
    [self removeAllOverlaysWithDefault:YES withNormalPOI:YES withTrafficPOI:NO withRoutingPOI:NO withPolyLinePOI:YES];
}
- (void) removeAllTrafficOverlayWithoutLinePoly
{
    // 교통 오버레이 제거
    [self removeAllOverlaysWithDefault:NO withNormalPOI:NO withTrafficPOI:YES withPolyLinePOI:NO];
}
- (void) removeAllTrafficOverlay
{
    // 교통옵션 오버레이제거
    [self removeAllOverlaysWithDefault:NO withNormalPOI:NO withTrafficPOI:YES withPolyLinePOI:NO];
    
    // 교통옵션 POI  제거 이후 선택된 오버레이가 없다면 교통옵션 관련 마커오버레이도 제거해버리자..
    BOOL otherSelected = NO;
    for (Overlay *overlay in self.getOverlays)
    {
        if ( [overlay isKindOfClass:[OMImageOverlay class]] && ((OMImageOverlay*)overlay).selected )
        {
            otherSelected = YES;
            break;
        }
    } // end for
    if ( otherSelected == NO )
    {
        [self removeSpecialOverlaysKindOfClass:[OMUserOverlayMarkerOption class]];
    }
}
- (void) removeAllThemeOverlay
{
    // 테마 오버레이 제거
    [self removeSpecialOverlaysKindOfClass:[OMImageOverlayTheme class]];
    
    // 테마 POI  제거 이후 선택된 오버레이가 없다면 테마 관련 마커오버레이도 제거해버리자..
    BOOL otherSelected = NO;
    for (Overlay *overlay in self.getOverlays)
    {
        if ( [overlay isKindOfClass:[OMImageOverlay class]] && ((OMImageOverlay*)overlay).selected )
        {
            otherSelected = YES;
            break;
        }
    } // end for
    if ( otherSelected == NO )
    {
        [self removeSpecialOverlaysKindOfClass:[OMUserOverlayMarkerOption class]];
    }
}

- (void) removeAllRouteOverlay
{
    // 테마 오버레이 제거
    [self removeSpecialOverlaysKindOfClass:[OMImageOverlaySearchRouteStart class]];
    [self removeSpecialOverlaysKindOfClass:[OMImageOverlaySearchRouteVisit class]];
    [self removeSpecialOverlaysKindOfClass:[OMImageOverlaySearchRouteDest class]];
}

- (void) removeSpecialOverlaysKindOfClass:(Class)classKind
{
    NSMutableArray *deletePOIList = [[NSMutableArray alloc] init];
    for (Overlay *currentOverlay in self.getOverlays)
    {
        if ( [currentOverlay isKindOfClass:classKind] ) [deletePOIList addObject:currentOverlay];
    }
    for (Overlay *deleteOverlay in deletePOIList)
    {
        [self removeOverlay:deleteOverlay];
    }
    [deletePOIList removeAllObjects];
    [deletePOIList release];
}
- (void) removeSpecialOverlaysMemberOfClass:(Class)classMember
{
    NSMutableArray *deletePOIList = [[NSMutableArray alloc] init];
    for (Overlay *currentOverlay in self.getOverlays)
    {
        if ( [currentOverlay isMemberOfClass:classMember] ) [deletePOIList addObject:currentOverlay];
    }
    for (Overlay *deleteOverlay in deletePOIList)
    {
        [self removeOverlay:deleteOverlay];
    }
    [deletePOIList removeAllObjects];
    [deletePOIList release];
}
- (void) selectPOIOverlay:(OMImageOverlay *)overlay
{
    // 원터치POI의 경우는 제거해줘야 한다.
    NSMutableArray *deleteList = [[NSMutableArray alloc] init];
    
    // 오버레이 선택처리
    NSArray *allOverlays = self.getOverlays;
    for (Overlay *currentOverlay in allOverlays)
    {
        if ( [currentOverlay isKindOfClass:[OMImageOverlay class]] )
        {
            OMImageOverlay *currentImageOverlay = (OMImageOverlay*)currentOverlay;
            if ( [currentImageOverlay isMemberOfClass:[OMImageOverlayLongtap class]] )
            {
                [deleteList addObject:currentImageOverlay];
            }
            else if ( currentImageOverlay == overlay )
            {
                [currentImageOverlay setSelected:YES];
            }
            else if ([currentImageOverlay isMemberOfClass:[OMImageOverlaySearchRouteStart class]] || [currentImageOverlay isMemberOfClass:[OMImageOverlaySearchRouteDest class]] || [currentImageOverlay isMemberOfClass:[OMImageOverlaySearchRouteVisit class]])
            {
                
            }
            else
            {
                [currentImageOverlay setSelected:NO];
            }
        }
    }
    
    // 삭제대상 제거
    for (Overlay *deleteOverlay in deleteList)
    {
        [self removeOverlay:deleteOverlay];
    }
    [deleteList removeAllObjects];
    [deleteList release];
}
- (int) adjustZoomLevel
{
    if ( self.mapDisplay == KMapDisplayNormalSmallText ) return self.zoomLevel -1;
    else return self.zoomLevel;
}
- (void) setAdjustZoomLevel :(int)level
{
    if ( self.mapDisplay == KMapDisplayNormalSmallText )
        //self.zoomLevel = (level-1);
        [super setZoomLevel:(level-1)];
    else
        //self.zoomLevel = level;
        [super setZoomLevel:level];
}
@end // OMKMapView 클래스 구현 // 끝.

// MapContainer 클래스 구현
@implementation MapContainer
@synthesize kmap = _kmap;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        @try
        {
            // KMap 뷰 생성
            _kmap = [[OMKMapView alloc] initWithFrame:frame];
            [_kmap setDelegate:self];
            
            // KMap 서비스 시작
            //[_kmap startMapService:@"OllehMapAPI0004"];
            [_kmap startMapService:@"OllehMapAPI0004" UserKey:@"vT1S4NqVdi"];
            
            // KMap 설정
            //[self.kmap setCenterCoordinate:OM_DefaultCoord];
            //[self.kmap setTrafficInfo:NO clearCache:YES];
            [self.kmap setMapDisplay:[[OllehMapStatus sharedOllehMapStatus] getDisplayMapResolution]];

            [self.kmap setMapType:KMapTypeStandard];
            [self.kmap setZoomLevel:10];
            
            [self.kmap setUserLocationInfo:[MyImage getCurrentMyImage] CompassImage:[UIImage imageNamed:@"map_circinus.png"]];
            
            [self.kmap setShowUserLocation:UserLocationNorthUp];
            // 지도교통옵션
            [self.kmap setTrafficCCTV:NO];
            [self.kmap setTrafficBusStation:NO];
            [self.kmap setTrafficSubwayStation:NO];
            // 테마
            [self.kmap setTheme:NO];
            // 지도 좌표정보
            [self.kmap setLastLongTapCoordinate:self.kmap.getUserLocation];
            [self.kmap setLastMapCenterCoordinate:self.kmap.getUserLocation];
            [self.kmap setLastMapZoomLevel:self.kmap.zoomLevel];
            
            if ( ![MapContainer CheckLocationServiceWithoutAlert] ) [self.kmap setCenterCoordinate:OM_DefaultCoord];
            
        }
        @catch (NSException *ex)
        {
            NSLog(@"%@", [ex reason]);
        }
        @finally
        {
        }
        
        
        
        /*
         switch ([self.kmap checkStartMapService])
         {
         case 0:
         NSLog(@"0 : 세팅준비");
         break;
         case 1:
         NSLog(@"1 : 세팅실패");
         break;
         case 2:
         NSLog(@"2 : 재시도중");
         break;
         case 3:
         NSLog(@"3 : 정상적으로 세팅 완료");
         break;
         default:
         NSLog(@"X : 알수없는 값 / SDK문서 checkStartMapService 참조");
         break;
         }
         */
    }
    return self;
}

- (void) dealloc
{
    if (_kmap)
    {
        _kmap.delegate =nil;
        [_kmap release];
        _kmap = nil;
    }
    
    [super dealloc];
}


// =======================================
// [ 맵 종류별 공유 메소드 시작 ]
// =======================================

// 메인맵 공유
static MapContainer *_Instance_Main = nil;
+ (MapContainer *) sharedMapContainer_Main
{
    if (_Instance_Main == nil)
    {
        // KMap은 전체화면 (StatusBar 제외) 영역에 렌더링되도록 한다.
        _Instance_Main = [[MapContainer alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    }
    return _Instance_Main;
}

// 길찾기 모드공유
static MapContainer *_Instance_SearchRouteResult = nil;
+ (MapContainer *) sharedMapContainer_SearchRouteResult
{
    if (_Instance_SearchRouteResult == nil)
    {
        // KMap은 전체화면 (StatusBar 제외) 영역에 렌더링되도록 한다.
        _Instance_SearchRouteResult = [[MapContainer alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    }
    return _Instance_SearchRouteResult;
}

// 길찾기 모드의 경우 뷰 새로 시작할때 초기화된 뷰를 넘겨주도록 한다.
+ (MapContainer *)resetMapContainer_SearchRouteResult
{
    if (_Instance_SearchRouteResult)
    {
        [_Instance_SearchRouteResult release];
    }
    _Instance_SearchRouteResult = nil;
    
    _Instance_SearchRouteResult = [self sharedMapContainer_SearchRouteResult];
    return _Instance_SearchRouteResult;
}

+ (void) closeMapContainer_Main
{
    if (_Instance_Main)
    {
        [_Instance_Main release];
    }
    _Instance_Main = nil;
}

+ (void) closeMapContainer_SearchRouteResult
{
    if (_Instance_SearchRouteResult)
    {
        [_Instance_SearchRouteResult release];
    }
    _Instance_SearchRouteResult = nil;
}

// 맵 해상도 한번에 변경하기
+ (void) changeMapDisplayResolution :(int)resolution
{
    [[MapContainer sharedMapContainer_Main].kmap setMapDisplay:resolution];
    //[[MapContainer sharedMapContainer_SearchRouteResult].kmap setMapDisplay:resolution];
}

+ (void) refreshMapLocationImage
{
    [[MapContainer sharedMapContainer_Main].kmap setUserLocationInfo:[MyImage getCurrentMyImage] CompassImage:[UIImage imageNamed:@"map_circinus.png"]];
}

// ***************************************


// =======================================
// [ 맵 디스플레이 메소드 시작 ]
// =======================================

// 해당 뷰위로 맵 디스플레이
- (void) showMapContainer:(UIView *)sView :(id)delegate
{
    // 기존 렌더링된 뷰제거
    //[self removeFromSuperview];
    [self.kmap removeFromSuperview];
    
    //맵영역 슈퍼뷰에 추가
    [_kmap setDelegate:delegate];
    if (sView.frame.size.height != _kmap.frame.size.height)
    {
        CGSize sizeMap = sView.frame.size;
        //sizeMap.height = [[UIScreen mainScreen] bounds].size.height - 20;
        
        //sizeMap.height -= [[UIApplication sharedApplication] statusBarFrame].size.height - 20;
        // 테더링시 상태바 확장
        if ( [[UIApplication sharedApplication] statusBarFrame].size.height > 20 )
        {
            sizeMap.height += 20;
        }
        [_kmap setFrame:CGRectMake(0, 0, sizeMap.width, sizeMap.height)];
    }
    
    // 변경된 해상도 맵이 삽입되도록 처리하자. (특히 길찾기 모드에서 죽지 않기위해서..)
    [self.kmap setMapDisplay:[[OllehMapStatus sharedOllehMapStatus] getDisplayMapResolution]];
    
    [sView insertSubview:_kmap atIndex:0];
}

- (NSInteger) convertToDistanceFromZoomLevel :(int)zoomLevel
{
    NSInteger meter = 102 * 1000;
    for (int i=0; i < zoomLevel; i++)
    {
        meter = meter / 2;
    }
    //  일반지도-작은글씨 지도일 경우 거리를 2배로 다시 곱해준다.
    if (self.kmap.mapDisplay == KMapDisplayNormalSmallText) meter *= 2;
    
    return meter;
}
- (NSInteger) getCurrentMapZoomLevelMeterWithScreen
{
    Coord minCoordinate = [self.kmap convertPoint:CGPointMake(0, 0)];
    Coord maxCoordinate = [self.kmap convertPoint:CGPointMake(self.kmap.frame.size.width, self.kmap.frame.size.height)];
    
    return CoordDistance(minCoordinate, maxCoordinate);
    //return [self convertToDistanceFromZoomLevel:self.kmap.zoomLevel] * 10;
}

// ***************************************



// =======================================
// [ 위치서비스 메소드 시작 ]
// =======================================

+ (BOOL) CheckLocationService
{
    if ([MapContainer CheckLocationServiceWithoutAlert]) return YES;
    else
    {
        [OMMessageBox showAlertMessage:nil :NSLocalizedString(@"Msg_LocationServiceFailed", @"")];
        return NO;
    }
}
+ (BOOL) CheckLocationServiceWithoutAlert
{
    
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if (version > 4.29) // Version 4.3 이상 (authorizationStatus 사용가능)
    {
        // 위치 서비스 관련 설정 값 체크 ( 폰 설정에서 위치서비스 관련 스위치 값 체크 )
        if(!([CLLocationManager locationServicesEnabled]) || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied))
            return NO;
        else
            return YES;
    }
    else // Version 4.3 이전..
    {
        // 위치 서비스 관련 설정 값 체크 ( 폰 설정에서 위치서비스 관련 스위치 값 체크 )
        if(!([CLLocationManager locationServicesEnabled]))
            return NO;
        else
            return YES;
    }
}

- (Coord) getCurrentUserLocation
{
    if (  [MapContainer CheckLocationServiceWithoutAlert] ) return _kmap.getUserLocation;
    else return OM_DefaultCoord;
}

// ***************************************



@end
