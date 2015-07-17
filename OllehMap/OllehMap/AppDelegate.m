//
//  AppDelegate.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 4. 17..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MKDirectionsRequest.h>

#import "AppDelegate.h"
#import "GANTracker.h"
#import "DbHelper.h"
#import "URLParser.h"

#import "MapContainer.h"
#import "SearchRouteResultMapViewController.h"
#import "SearchRouteDialogViewController.h"
#import "OMNavigationController.h"
#import "OMToast.h"

#import "ServerConnector.h"
#import "SearchRouteExecuter.h"

#import "CCTVViewController.h"
#ifdef DEBUG
#define USE_DEBUG_MEMORY_X
#endif
#ifdef USE_DEBUG_MEMORY
#import <mach/mach.h>
#import <mach/mach_host.h>
#endif

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [[GANTracker sharedTracker] stopTracker];
    
    [_lblDebugMemoryChecker release];
    [_winDebugMemoryChecker release];
    
    [SearchRouteExecuter closeSearchRouteExecuter];
    [ServerConnector releaseSharedServerConnection];
    [OllehMapStatus closeOllehMapStatus];
    
    [_vcMainMap release];
    [OMNavigationController closeNavigationController];
    [_window release];
    
    [super dealloc];
}
- (id) init
{
    self = [super init];
    if ( self )
    {
        _vcMainMap = nil;
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //OllehMapStatus *oms = [OllehMapStatus  sharedOllehMapStatus];
    
    /*
     //아이폰 사용가능 폰트 리스트
     NSArray *fontListArray = [UIFont familyNames];
     for (NSString *fontName in fontListArray) NSLog(@"%@", fontName);
     */
    
    // 기존 앱에서 오류 발생시 경고메세지 (일단 디버깅용으로 활용해보자)
#ifdef USE_EXCEPTION_CALLBACK
    NSString *lastError = [[NSUserDefaults standardUserDefaults] objectForKeyGC:@"AppLastError"];
    
    if (lastError)
    {
        NSLog(@"[비정상 종료 오류메세지] : \n%@", lastError);
        [OMMessageBox showAlertMessage:@"[비정상 종료 오류메세지]" :lastError];
        
        @try
        {
            if (lastError.length <= 2000)
                [[ServerConnector sharedServerConnection] requestExceptionLogging:nil action:nil exceptionMessage:lastError];
            else
            {
                NSRange range;
                range.length = 1500;
                range.location = 0;
                int max = lastError.length/1500;
                if (lastError.length%1500 >0) max++;
                NSString *guid = [[OllehMapStatus sharedOllehMapStatus] generateUuidString];
                
                for (int i=0; i<max; i++)
                {
                    range.location = i*range.length;
                    if (i==max-1) range.length = lastError.length-range.location;
                    [[ServerConnector sharedServerConnection] requestExceptionLogging:nil action:nil exceptionMessage:[NSString stringWithFormat:@"[SplitLog(%@) %d/%d] %@", guid, i+1, max, [lastError substringWithRange:range]]];
                }
            }
        }
        @catch (NSException *exception)  {  }
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AppLastError"];
    }
#endif
    
    // ㄱㅜㄱㅡㄹ 통계 초기화
#ifdef DEBUG
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-33033628-1" dispatchPeriod:1 delegate:nil];
#else
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-32576408-1" dispatchPeriod:1 delegate:nil];
#endif
    
    
    // 슬립모드 방지
    NSString *strIdleTimerDisabled = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKeyGC:@"IdleTimerDisabled"]];
    // NO일경우 슬립모드 유지
    if ([strIdleTimerDisabled isEqualToString:@"NO"])
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    // NO가 아닐경우 슬립모드 방지
    else
    {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        // NO 가 아닌데, YES 도 아닌 경우 기본값 YES 설정
        if ([strIdleTimerDisabled isEqualToString:@"YES"] == NO)
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"IdleTimerDisabled"];
        }
    }
    
    // 설정 기록 (오류메세지 && 앱실행여부)
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"IsStartup"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // StatusBar 효과
    //[application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    [application setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    
    // 어플 윈도우 생성
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    // 메인맵 생성
    _vcMainMap = [[MainMapViewController alloc] initWithNibName:@"MainMapViewController" bundle:nil];
    [self.window addSubview:[OMNavigationController setNavigationController:_vcMainMap].view];
    
    // 네트워크 연결 상태 체크
    if ([[OllehMapStatus sharedOllehMapStatus] getNetworkStatus] == OMReachabilityStatus_disconnected )
    {
        [OMMessageBox showAlertMessage:@"네트워크" :@"네트워크에 접속할수없습니다. 3G 또는 WiFi 상태를 확인바랍니다."];
        return NO;
    }
    
#ifdef USE_DEBUG_MEMORY
    
    UIControl *vwTmp = [[[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, 18)] autorelease];
    [vwTmp setBackgroundColor:[UIColor clearColor]];
    [vwTmp addTarget:self action:@selector(showDebugMessage) forControlEvents:UIControlEventTouchUpInside];
    
    _lblDebugMemoryChecker = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 18)] autorelease];
    [_lblDebugMemoryChecker setBackgroundColor:convertHexToDecimalRGBA(@"FF", @"99", @"00", 0.7)];
    [_lblDebugMemoryChecker setFont:[UIFont fontWithName:@"Helvetica" size:11.0f]];
    [_lblDebugMemoryChecker setTextAlignment:NSTextAlignmentCenter];
    [_lblDebugMemoryChecker setText:@"Memory Test"];
    
    _winDebugMemoryChecker = [[UIWindow alloc] initWithFrame:CGRectMake(0, 1, 320, 18)];
    [_winDebugMemoryChecker setWindowLevel:UIWindowLevelStatusBar + 1.0f];
    [_winDebugMemoryChecker setHidden:NO];
    [_winDebugMemoryChecker addSubview:vwTmp];
    [_winDebugMemoryChecker addSubview:_lblDebugMemoryChecker];
    [_winDebugMemoryChecker makeKeyAndVisible];
    
    [self doWorkMemoryCheck];
#endif
    
    // 화면 처리
    [self.window makeKeyAndVisible];
    
    /*
     dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
     dispatch_group_t group = dispatch_group_create();
     
     // Add a task to the group
     dispatch_group_async(group, queue, ^{
     // Some asynchronous work
     });
     
     // Do some other work while the tasks execute.
     
     // When you cannot make any more forward progress,
     // wait on the group to block the current thread.
     dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
     
     // Release the group when it is no longer needed.
     dispatch_release(group);
     */
    
    return YES;
}

// URL 받는다(mmv 등 외부 앱에서)
- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    // 메인화면 정상로딩될때까지 조금만 기다려주자
    for (int cnt=0, maxcnt=3; cnt < maxcnt; cnt++)
    {
        [NSThread sleepForTimeInterval:1.0];
        if ( _vcMainMap && _vcMainMap.isViewLoaded ) break;
    }
    
    // 길찾기 요청이 들어온 경우 처리
    if ( [MKDirectionsRequest isDirectionsRequestURL:url] )
    {
        
        MKDirectionsRequest* directionsInfo = [[MKDirectionsRequest alloc] initWithContentsOfURL:url];
        MKMapItem *source = directionsInfo.source;
        MKMapItem *destination = directionsInfo.destination;
        [directionsInfo release];
        
        // 메인맵으로 초기화
        [[OMNavigationController sharedNavigationController] popToRootViewControllerAnimated:NO];
        
        [self openURLRoute:source:destination];
        
                return YES;
    }
    // 기타 요청 처리(위치공유 접근)
    else
    {
        
        [self openURLShare:url];
                
    }
    
    return YES;
}

- (void) applicationDidChangeStatusBarFrame
{
}


#ifdef USE_DEBUG_MEMORY
- (void) showDebugMessage
{
    [OMMessageBox showAlertMessage:@"" :[NSString stringWithFormat:@"%@", [[OllehMapStatus sharedOllehMapStatus] debuggingString]]];
}
- (void) doWorkMemoryCheck
{
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(doWorkMemoryCheck) userInfo:nil repeats:NO];
    
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
        [_lblDebugMemoryChecker setText: [NSString stringWithFormat:@"Failed to fetch vm statistics"]];
    
    /* Stats in bytes */
    natural_t mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * pagesize;
    natural_t mem_free = vm_stat.free_count * pagesize;
    natural_t mem_total = mem_used + mem_free;
    [_lblDebugMemoryChecker setTag:_lblDebugMemoryChecker.tag+1];
    [_lblDebugMemoryChecker setText: [NSString stringWithFormat: @"LOG(%d) used: %.1fmb free: %.1fmb total: %.1fmb",_lblDebugMemoryChecker.tag, mem_used/1024/1024.0, mem_free/1024/1024.0, mem_total/1024/1024.0]];
}
#endif


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //NSLog(@"applicationWillTerminate");
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
}

- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
{
    // iOS6 이상에서 StatusBarFrame 이벤트관련 AutoResizeMask 처리규칙이 바뀐듯. 보정작업해주기로함.
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
    {
        /*-----------------------------------------------------------------------------------
         BOOL isNormal = oldStatusBarFrame.size.height > 20;
         
         OMNavigationController *nav = [OMNavigationController sharedNavigationController];
         
         if ( isNormal )
         {
         [nav.view setFrame:CGRectMake(0, 20,
         [[UIScreen mainScreen] bounds].size.width,
         [[UIScreen mainScreen] bounds].size.height - 20)];
         
         UIViewController *vc = [nav.viewControllers lastObject];
         [vc.view setFrame:CGRectMake(0, 0,
         [[UIScreen mainScreen] bounds].size.width,
         [[UIScreen mainScreen] bounds].size.height - 20)];
         }
         else
         {
         [nav.view setFrame:CGRectMake(0, 40, 320, 440)];
         
         UIViewController *vc = [nav.viewControllers lastObject];
         [vc.view setFrame:CGRectMake(0, 0, 320, 440)];
         }
         -------------------------------------------------------------------------------------*/
        
        // 위 주석처리된 코드를 아래 코드로 대체
        float statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        
        OMNavigationController *nav = [OMNavigationController sharedNavigationController];
        
        [nav.view setFrame:CGRectMake(0, statusBarHeight,
                                      [[UIScreen mainScreen] bounds].size.width,
                                      [[UIScreen mainScreen] bounds].size.height - statusBarHeight)];
        
        UIViewController *vc = [nav.viewControllers lastObject];
        [vc.view setFrame:CGRectMake(0, 0,
                                     [[UIScreen mainScreen] bounds].size.width,
                                     [[UIScreen mainScreen] bounds].size.height - statusBarHeight)];
    }
}

- (BOOL) openURLRoute:(MKMapItem *)source :(MKMapItem *)destination
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 길찾기 결과도 미리 초기화
    [oms.searchRouteData reset];
    
    // 출발지 설정
    NSString *sourceAddress = [NSString stringWithFormat:@"%@ %@ %@"
                               , stringValueOfDictionary(source.placemark.addressDictionary, @"State")
                               , stringValueOfDictionary(source.placemark.addressDictionary, @"SubLocality")
                               , stringValueOfDictionary(source.placemark.addressDictionary, @"Street")
                               ];
    
    [oms.searchResultRouteStart reset];
    [oms.searchResultRouteStart setUsed:YES];
    if ( source.isCurrentLocation)
    {
        [oms.searchResultRouteStart setIsCurrentLocation:YES];
        [oms.searchResultRouteStart setStrLocationName:@"현재 위치"];
        [oms.searchResultRouteStart setCoordLocationPoint:CoordMake(0, 0)];
    }
    // 현재위치 아니면서, 주소가 없을 경우
    else if ( [sourceAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length <= 0 )
    {
        Coord startCoordinateWgs84 = CoordMake(source.placemark.coordinate.longitude, source.placemark.coordinate.latitude);
        Coord startCoordinateUtmk = [[MapContainer sharedMapContainer_Main].kmap convertCoordinate:startCoordinateWgs84 inCoordType:KCoordType_WGS84 outCoordType:KCoordType_UTMK];
        
        [oms.searchResultRouteStart setIsCurrentLocation:NO];
        [oms.searchResultRouteStart setStrLocationName:@""];
        [oms.searchResultRouteStart setCoordLocationPoint:startCoordinateUtmk];
    }
    else
    {
        Coord startCoordinateWgs84 = CoordMake(source.placemark.coordinate.longitude, source.placemark.coordinate.latitude);
        Coord startCoordinateUtmk = [[MapContainer sharedMapContainer_Main].kmap convertCoordinate:startCoordinateWgs84 inCoordType:KCoordType_WGS84 outCoordType:KCoordType_UTMK];
        
        [oms.searchResultRouteStart setIsCurrentLocation:NO];
        [oms.searchResultRouteStart setStrLocationName:sourceAddress];
        [oms.searchResultRouteStart setCoordLocationPoint:startCoordinateUtmk];
    }
    
    
    // 경유지 초기화
    [oms.searchResultRouteVisit reset];
    
    // 도착지 초기화
    NSString *destinationAddress = [NSString stringWithFormat:@"%@ %@ %@"
                                    , stringValueOfDictionary(destination.placemark.addressDictionary, @"State")
                                    , stringValueOfDictionary(destination.placemark.addressDictionary, @"SubLocality")
                                    , stringValueOfDictionary(destination.placemark.addressDictionary, @"Street")
                                    ];
    
    [oms.searchResultRouteDest reset];
    [oms.searchResultRouteDest setUsed:YES];
    if (destination.isCurrentLocation)
    {
        [oms.searchResultRouteDest setIsCurrentLocation:YES];
        [oms.searchResultRouteDest setStrLocationName:@"현재 위치"];
        [oms.searchResultRouteDest setCoordLocationPoint:CoordMake(0, 0)];
    }
    // 현재위치 아니면서, 주소가 없을 경우
    else if ( [destinationAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length <= 0 )
    {
        Coord destCoordinateWgs84 = CoordMake(destination.placemark.coordinate.longitude, destination.placemark.coordinate.latitude);
        Coord destCoordinateUtmk = [[MapContainer sharedMapContainer_Main].kmap convertCoordinate:destCoordinateWgs84 inCoordType:KCoordType_WGS84 outCoordType:KCoordType_UTMK];
        
        [oms.searchResultRouteDest setIsCurrentLocation:NO];
        [oms.searchResultRouteDest setStrLocationName:@""];
        [oms.searchResultRouteDest setCoordLocationPoint:destCoordinateUtmk];
    }
    else
    {
        Coord destCoordinateWgs84 = CoordMake(destination.placemark.coordinate.longitude, destination.placemark.coordinate.latitude);
        Coord destCoordinateUtmk = [[MapContainer sharedMapContainer_Main].kmap convertCoordinate:destCoordinateWgs84 inCoordType:KCoordType_WGS84 outCoordType:KCoordType_UTMK];
        
        [oms.searchResultRouteDest setIsCurrentLocation:NO];
        [oms.searchResultRouteDest setStrLocationName:destinationAddress];
        [oms.searchResultRouteDest setCoordLocationPoint:destCoordinateUtmk];
    }
    
    // 길찾기 활성화
    [[SearchRouteDialogViewController sharedSearchRouteDialog] showSearchRouteDialog];
    [[SearchRouteExecuter sharedSearchRouteExecuter] searchRoute_Public];
    
    return YES;
}

- (void) openURLShare:(NSURL *)url
{
    NSLog(@"유알엘 = %@", url);
    
    URLParser *parser = nil;
    
    NSString *platform = [[OllehMapStatus sharedOllehMapStatus] getDeviceModel];
#ifdef DEBUG
    if ( [platform isEqualToString:@"x86_64"] || [platform isEqualToString:@"i386"] )
    {
        // 공유url 테스트부분 시작
        
        NSString *urlTester = @"";
        
        URLParser *testParser = [[URLParser alloc] initWithURLString:url.absoluteString];
        
        int shareType = [[testParser valueForVariable:@"share"] intValue];
        
        switch (shareType)
        {
            case 10:    // 지도 MP
                urlTester = @"ktolleh00047://hub?ptype=m_map&pid=MP1108710675105&detailtype=0&x=964469&y=1945849&name=롯데월드&addr=서울특별시 송파구 잠실동 40-1&tel=123-4567";
                break;
            case 11:    // 지도 MV
                urlTester = @"ktolleh00047://hub?ptype=m_map&pid=MP1108011407912&detailtype=0&x=957360&y=1954907&name=cgv성신여대&addr=&tel=";
                break;
            case 12:    // 지도 OL
                urlTester = @"ktolleh00047://hub?ptype=m_map&pid=MP1302P00769799&detailtype=0&x=957483&y=1954350&name=현대오일뱅크성북주유소&addr=&tel=";
                break;
            case 13:    // 지도 버정
                urlTester = @"ktolleh00047://hub?ptype=m_map&pid=106584&detailtype=1&x=959055&y=1955097&name=숭례초등학교&addr=&tel=";
                break;
            case 14:    // 지도 지하철
                urlTester = @"ktolleh00047://hub?ptype=m_map&pid=640&detailtype=2&x=959026&y=1954658&name=고려대역 (6호선)&addr=&tel=";
                break;
            case 15:    // 지도 CCTV
                urlTester = @"ktolleh00047://hub?ptype=m_map&pid=00050143&detailtype=3";
                break;
            case 16:    // 지도 주소
                urlTester = @"ktolleh00047://hub?ptype=m_map&pid=&detailtype=4&x=959312&y=1954779&name=서울특별시 동대문구 청량리동&addr=서울특별시 동대문구 청량리동 823-26";
                break;
                
                
                
            case 20:    // 결과 강남 장소 정확도순
                urlTester = @"ktolleh00047://hub?ptype=m_search&x=959996&y=1946554&query=%EA%B0%95%EB%82%A8&searchtype=place&order=rank";
                break;
            case 21:    // 결과 강남 장소 거리순
                urlTester = @"ktolleh00047://hub?ptype=m_search&x=959996&y=1946554&query=%EA%B0%95%EB%82%A8&searchtype=place&order=dis";
                break;
            case 22:    // 결과 강남 주소 정확도순
                urlTester = @"ktolleh00047://hub?ptype=m_search&x=959996&y=1946554&query=%EA%B0%95%EB%82%A8&searchtype=address&order=rank";
                break;
            case 23:    // 결과 강남 주소 거리순
                urlTester = @"ktolleh00047://hub?ptype=m_search&x=959996&y=1946554&query=%EA%B0%95%EB%82%A8&searchtype=address&order=dis";
                break;
            case 24:    // 결과 강남 교통
                urlTester = @"ktolleh00047://hub?ptype=m_search&x=959996&y=1946554&query=%EA%B0%95%EB%82%A8&searchtype=traffic&order=";
                break;
                
                
            case 30:    // 상세 MP
                urlTester = @"ktolleh00047://hub?ptype=m_detail&poi_id=MP1108710675105&detailtype=0&stid=MP1108710675105";
                break;
            case 31:    // 상세 MV
                urlTester = @"ktolleh00047://hub?ptype=m_detail&poi_id=MP1108011428428&detailtype=0&stid=T2060";
                break;
            case 32:    // 상세 OL
                urlTester = @"ktolleh00047://hub?ptype=m_detail&poi_id=MP1207P00632592&detailtype=0&stid=50466";
                break;
            case 33:    // 상세 버스정류장
                urlTester = @"ktolleh00047://hub?ptype=m_detail&poi_id=106584&detailtype=1&stid=106584";
                break;
            case 34:    // 상세 지하철
                urlTester = @"ktolleh00047://hub?ptype=m_detail&poi_id=416&detailtype=2&stid=416";
                break;
            case 35:    // 상세 주소
                urlTester = @"ktolleh00047://hub?ptype=m_detail&addr=강원도 춘천시 강남동&detailtype=4";
                break;
            default:
                urlTester = @"알수없음";
                break;
        }
        
        parser = [[URLParser alloc] initWithURLString:urlTester];
        
        // 공유 url 테스트 끝

    }
    else
        parser = [[URLParser alloc] initWithURLString:url.absoluteString];
#else
    parser = [[URLParser alloc] initWithURLString:url.absoluteString];
#endif

    @try
    {
        
        
        
        NSString *srcApp = [parser valueForVariable:@"srcApp"];
        
        NSString *ptype = [parser valueForVariable:@"ptype"];
        //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"mmv" message:(NSString *)parser delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
        //            [alert show];
        //            [alert release];
        // 필수항목 첫번재 // openUrl 타입을 체크한다.
        
        if (([ptype isEqualToString:@""] || !ptype) && [srcApp isEqualToString:@"0"])
        {
            // 인디케이터 활성화
            //[[OMIndicator sharedIndicator] startAnimating];
            //[[OMToast sharedToast] showToastMessagePopup:@"데이터를 분석중입니다." superView:self.window maxBottomPoint:self.window.frame.size.height/2 autoClose:YES];
            
            // type.0 좌표, POI명, POI타입 모든 정보를 입력받아서 렌더링한다.
            // MP1210011453884 / 946392 1943191
            // KTolleh00047://?srcapp=0&NAME=MikSystem&ptype=MP&pid=MP1210011453884&x=946392&y=1943191&id=0&level=9&maptype=
            float x = [[parser valueForVariable:@"X"] floatValue];
            float y = [[parser valueForVariable:@"Y"] floatValue];
            Coord coordinate = CoordMake(x, y);
            NSString *poiName = [parser valueForVariable:@"Name"];
            if (poiName == nil) poiName = @"";
            else poiName = [poiName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *poiId = [parser valueForVariable:@"ID"];
            if ( poiId == nil ) poiId = @"";
            NSString *poiType = [[parser valueForVariable:@"Ptype"] uppercaseString];
            if ( poiType == nil ) poiType = @"";
            NSString *poiDocId = [parser valueForVariable:@"Pid"];
            if ( poiDocId == nil ) poiDocId = @"";
            NSString *mapType = [parser valueForVariable:@"Maptype"];
            if ( mapType == nil ) mapType = @"";
            NSString *level = [parser valueForVariable:@"Level"];
            if ( level == nil ) level = @"9"; // 기본값 9 사용
            
            // 필수값 체크
            //if ( x <= 0 || y <= 0 || !poiName || poiName.length <= 0 )
            if ( x <= 0 || y <= 0 )
                [NSException raise:@"Ollehmap OpenURL InvalidParameter" format:@""];
            
            /*
             NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
             [parameters setObject:[NSNumber numberWithFloat:x] forKey:@"X"];
             [parameters setObject:[NSNumber numberWithFloat:y] forKey:@"Y"];
             [parameters setObject:poiName forKey:@"Name"];
             [parameters setObject:poiId forKey:@"ID"];
             [parameters setObject:poiType forKey:@"Type"];
             [parameters setObject:poiDocId forKey:@"PID"];
             [parameters setObject:mapType forKey:@"MapType"];
             [parameters setObject:[NSNumber numberWithInteger:[level integerValue]] forKey:@"Level"];
             */
            
            // MIK.geun :: 20121019 // 스레드를 통해서 상태체크를 하면, 원인불명 맵이 바보가 됨. 타이머로 비슷한 효과내도록 시도...
            //[NSThread detachNewThreadSelector:@selector(doWorkExternalOpenPOI:) toTarget:self withObject:parser];
            //
            //NSTimer *timer = [NSTimer timerWithTimeInterval:0 target:self selector:@selector(doWorkExternalOpenPOI:) userInfo:parameters repeats:NO];
            //[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
            
            /*
             NSTimeInterval interval = 0.1;
             NSInteger tryCount = 0;
             while (tryCount++ < 10) // 0.5 초 * 10 ==> 5초
             {
             BOOL checkMainMapViewLoaded = NO;
             BOOL checkMapServiceEnabled = NO;
             
             // 네비게이션컨트롤러에 한개 이상의 뷰 존재하는지 체크
             if ( [OMNavigationController sharedNavigationController].viewControllers.count > 0 )
             {
             // 화면 로드완료 판단
             if ( _vcMainMap && _vcMainMap.isViewLoaded )
             {
             OMNavigationController *nav = [OMNavigationController sharedNavigationController];
             // 루트뷰 이외에 다른 뷰가 쌓여있을 경우 전부 클리어, 루트로 이동, 그리고 다시 체크
             if ( nav && nav.viewControllers && nav.viewControllers.count > 0 )
             {
             if (  nav.viewControllers.count > 1 )
             {
             [[OMNavigationController sharedNavigationController] popToRootViewControllerAnimated:NO];
             }
             else
             {
             checkMainMapViewLoaded = YES;
             }
             }
             }
             
             // 지도 서비스 활성화 판단
             checkMapServiceEnabled = [MapContainer sharedMapContainer_Main].kmap.checkStartMapService == 3;
             
             // 두가지 조건 만족할 경우 다음 단계 진행
             if ( checkMainMapViewLoaded && checkMapServiceEnabled && [OllehMapStatus sharedOllehMapStatus].isMainViewDidApear ) break;
             }
             // 쉬엇다가기..
             [NSThread sleepForTimeInterval:interval];
             }
             */
            
            // 인디케이터 비활성화
            //[[OMIndicator sharedIndicator] forceStopAnimation];
            
            MapContainer *mc = [MapContainer sharedMapContainer_Main];
            OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
            OMNavigationController *nav = [OMNavigationController sharedNavigationController];
            
            // POI 정보 입력
            OMSearchResult *searchResult =[OllehMapStatus sharedOllehMapStatus].searchResultOneTouchPOI ;
            [searchResult reset];
            [searchResult setUsed:YES];
            [searchResult setCoordLocationPoint:coordinate];
            [searchResult setStrType:poiType];
            // 영화관(MV), 주유소(OL) 일경우 ID대신 DocID  사용
            //                if ( [poiType isEqualToString:@"MV"] || [poiType isEqualToString:@"OL"] )
            //                    [searchResult setStrID:poiDocId];
            //                else
            //                    [searchResult setStrID:poiId];
            // 20130227 docid없을때는 id가 docid 추가
            if([poiDocId isEqualToString:@""] || poiDocId == nil)
            {
                poiDocId = poiId;
            }
            // 추가끝
            [searchResult setStrID:poiDocId];
            
            [searchResult setStrLocationName:poiName];
            
            //MainMapViewController *mmvc = (MainMapViewController*)[[OMNavigationController sharedNavigationController].viewControllers objectAtIndexGC:0];
            MainMapViewController *mmvc = _vcMainMap;
            
            // 일단 무조건 모든작업 클리어
            if ( nav.viewControllers.count > 1 )
                [nav popToRootViewControllerAnimated:NO];
            [[ThemeCommon sharedThemeCommon] clearThemeSearchResult];
            [mc.kmap removeAllOverlaysWithoutTraffic];
            [[SearchRouteDialogViewController sharedSearchRouteDialog] closeSearchRouteDialog];
            
            // 지도설정 타입 설정
            if ( mapType == nil ) mapType  = @"";
            if ( [mapType.uppercaseString isEqualToString:@"AIR"] )
                [mmvc toggleKMapStyle:KMapTypeHybrid];
            else
                [mmvc toggleKMapStyle:KMapTypeStandard];
            
            // 내위치 비활성화
            oms.calledOpenURL = YES;
            [mmvc toggleMyLocationMode:MapLocationMode_None];
            [mc.kmap setCenterCoordinate:coordinate];
            
            // OneTouchPOI 로 렌더링하기 **최소한 POI명이 존재해야 POI렌더링한다.
            if ( poiName.length > 0 )
                [mmvc pinLongtapPOIOverlay:YES];
            
            // 지도 줌레벨 설정
            [NSThread sleepForTimeInterval:0.5];
            [mc.kmap setAdjustZoomLevel: [level integerValue]];
            
        }
        // 공유 url 검색결과
        else if (ptype && [ptype isEqualToString:@"m_search"])
        {
            
            OMNavigationController *nav = [OMNavigationController sharedNavigationController];
            
            // 일단 무조건 모든작업 클리어
            if ( nav.viewControllers.count > 1 )
                [nav popToRootViewControllerAnimated:NO];
            [[ThemeCommon sharedThemeCommon] clearThemeSearchResult];
            [[MapContainer sharedMapContainer_Main].kmap removeAllOverlaysWithoutTraffic];
            [[SearchRouteDialogViewController sharedSearchRouteDialog] closeSearchRouteDialog];
            
            
            NSString *query = [parser valueForVariable:@"query"];
            NSString *searchType = [parser valueForVariable:@"searchtype"];
            NSString *order = [parser valueForVariable:@"order"];
            
            SearchViewController *svc = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
            
            // 정확도순 검색일땐 order값이 false
            // 거리순 검색일 경우엔 order 값을 true로 준다
            if([order.uppercaseString isEqualToString:@"DIS"])
                svc.order = YES;
            
            // 검색결과에서 장소/주소/교통 먼저 보여주기(장소 : 1, 주소 : 2, 교통: 3) 
            if([searchType.uppercaseString isEqualToString:@"PLACE"])
                svc.resultType = 1;
            else if ([searchType.uppercaseString isEqualToString:@"ADDRESS"])
                svc.resultType = 2;
            else if ([searchType.uppercaseString isEqualToString:@"TRAFFIC"])
                svc.resultType = 3;
            
            [OllehMapStatus sharedOllehMapStatus].keyword = [query stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [svc onSearch];

        }
        // 공유 url 지도
        else if (ptype && [ptype isEqualToString:@"m_map"])
        {
            
            float x = [[parser valueForVariable:@"x"] floatValue];
            float y = [[parser valueForVariable:@"y"] floatValue];
            Coord coordinate = CoordMake(x, y);
            
            NSString *poiId = [parser valueForVariable:@"pid"];
            
            NSString *poiName = [parser valueForVariable:@"name"];
            
            if (poiName == nil)
                poiName = @"";
            else
                poiName = [poiName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSString *mapType = [parser valueForVariable:@"maptype"];
            
            // addr은 필요없음
            // tel도 필요없음
            
            if ( poiId == nil ) poiId = @"";
            NSString *poiType = [parser valueForVariable:@"detailtype"];
            
            if ( poiType == nil ) poiType = @"";

            int type = [poiType intValue];
            
            switch (type) {
                
                case 1:
                    poiType = @"TR_BUS";
                    break;
                case 2:
                    poiType = @"TR";
                    break;
                case 3:
                    poiType = @"CCTV";
                    break;
                case 4:
                    poiType = @"ADDR";
                    break;
                default:
                    poiType = @"MP";
                    break;
            }


            NSString *level = [parser valueForVariable:@"zoom"];
            if ( level == nil ) level = @"9"; // 기본값 9 사용
            
            // 필수값 체크
            //if ( x <= 0 || y <= 0 || !poiName || poiName.length <= 0 )
            if (( x <= 0 || y <= 0) && type != 3)
                [NSException raise:@"Ollehmap OpenURL InvalidParameter" format:@""];

            
            // 인디케이터 비활성화
            //[[OMIndicator sharedIndicator] forceStopAnimation];
            
            MapContainer *mc = [MapContainer sharedMapContainer_Main];
            OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
            OMNavigationController *nav = [OMNavigationController sharedNavigationController];
            
            // POI 정보 입력
            OMSearchResult *searchResult =[OllehMapStatus sharedOllehMapStatus].searchResultOneTouchPOI ;
            [searchResult reset];
            [searchResult setUsed:YES];
            [searchResult setCoordLocationPoint:coordinate];
            [searchResult setStrType:poiType];
            
            // 추가끝
            [searchResult setStrID:poiId];
            
            [searchResult setStrLocationName:poiName];
            
            //MainMapViewController *mmvc = (MainMapViewController*)[[OMNavigationController sharedNavigationController].viewControllers objectAtIndexGC:0];
            MainMapViewController *mmvc = _vcMainMap;
            
            // 일단 무조건 모든작업 클리어
            if ( nav.viewControllers.count > 1 )
                [nav popToRootViewControllerAnimated:NO];
            [[ThemeCommon sharedThemeCommon] clearThemeSearchResult];
            [mc.kmap removeAllOverlaysWithoutTraffic];
            [[SearchRouteDialogViewController sharedSearchRouteDialog] closeSearchRouteDialog];
            
            
            // 지도설정 타입 설정
            if ( mapType == nil ) mapType  = @"";
            if ( [mapType.uppercaseString isEqualToString:@"AIR"] || [mapType.uppercaseString isEqualToString:@"HYBRID"] )
                [mmvc toggleKMapStyle:KMapTypeHybrid];
            else
                [mmvc toggleKMapStyle:KMapTypeStandard];
            
            // 내위치 비활성화
            oms.calledOpenURL = YES;
            [mmvc toggleMyLocationMode:MapLocationMode_None];
            
            
            if(type == 3)
            {
                [[ServerConnector sharedServerConnection] requestTrafficOptionCCTVInfo:self action:@selector(finishTrafficOptionCCTVInfo:) cctvid:poiId cctvCoordinate:CoordMake(0, 0)];
            }
            else
            {
            // OneTouchPOI 로 렌더링하기 **최소한 POI명이 존재해야 POI렌더링한다.
            if ( poiName.length > 0 )
                [mmvc pinLongtapPOIOverlay:YES];
                
                [mc.kmap setCenterCoordinate:coordinate];
            }
            
            
            // 지도 줌레벨 설정
            [NSThread sleepForTimeInterval:0.5];
            [mc.kmap setAdjustZoomLevel: [level integerValue]];
            
            
        }
        // 공유url 상세
        else if (ptype && [ptype isEqualToString:@"m_detail"])
        {
            
            OMNavigationController *nav = [OMNavigationController sharedNavigationController];

            // 일단 무조건 모든작업 클리어
            if ( nav.viewControllers.count > 1 )
                [nav popToRootViewControllerAnimated:NO];
            [[ThemeCommon sharedThemeCommon] clearThemeSearchResult];
            [[MapContainer sharedMapContainer_Main].kmap removeAllOverlaysWithoutTraffic];
            [[SearchRouteDialogViewController sharedSearchRouteDialog] closeSearchRouteDialog];
            
            NSString *detailType = [parser valueForVariable:@"detailtype"];
            NSString *poiId = [parser valueForVariable:@"poi_id"];
            NSString *stid = [parser valueForVariable:@"stid"];
            
            NSString *addr = [parser valueForVariable:@"addr"];
            NSString *cctvId = [parser valueForVariable:@"cctv"];
            NSString *decodeAddr = [addr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            //NSString *info = [NSString stringWithFormat:@"id : %@, type : %@, stid : %@", poiId, detailType, stid];
            //[OMMessageBox showAlertMessage:@"상세정보" :info];
            
            int type = [detailType intValue];
            
            switch (type) {
                case 1:
                    [[ServerConnector sharedServerConnection] requestBusStationInfoStid:self action:@selector(finishRequestBusDetail:) stId:stid];
                    break;
                case 2:
                    [[ServerConnector sharedServerConnection] requestSubStation:self action:@selector(finishRequestSubwayDetail:) stationId:stid];
                    
                    break;
                case 3:
                    [[ServerConnector sharedServerConnection] requestTrafficOptionCCTVInfo:self action:@selector(finishTrafficOptionCCTVInfo:) cctvid:cctvId cctvCoordinate:CoordMake(0, 0)];
                    break;
                case 4:
                {
                    AddressPOIViewController *apc = [[AddressPOIViewController alloc] initWithNibName:@"AddressPOIViewController" bundle:nil];
                    apc.poiAddress = decodeAddr;
                    
                    // 좌표를 0을 주면 지도버튼 disable
                    apc.poiCrd = CoordMake(0, 0);
                    apc.poiSubAddress = @"";
                    apc.oldOrNew = @"Old";
                    [[OMNavigationController sharedNavigationController] pushViewController:apc animated:NO];
                    
                    [apc release];
                }
                    break;
                default:
                    [[ServerConnector sharedServerConnection] requestPoiDetailAtPoiId:self action:@selector(finishRequestPOIDetail:) poiId:poiId];
                    break;
            }
        }            
        else
        {
        }
        
    }
    @catch (NSException *exception)
    {
        [OMMessageBox showAlertMessage:@"" :@"올레 map을 잘못된 방식으로 호출하고 있어 작업을 진행할 수 없습니다." ];
        //[[OMIndicator sharedIndicator] forceStopAnimation];
    }
    @finally
    {
        [parser release];
    }
    
}
- (void) finishTrafficOptionCCTVInfo :(ServerRequester*)request
{
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        NSDictionary *cctvInfo = (NSDictionary*)[request userObject];
        
        NSLog(@"cctvInfo : %@", cctvInfo);
        
        CCTVViewController *cctvVC = [[CCTVViewController alloc] initWithNibName:@"CCTVViewController" bundle:nil];
        [[OMNavigationController sharedNavigationController] pushViewController:cctvVC animated:NO];
        [cctvVC showCCTV:cctvInfo];
        [cctvVC release];
    }
    // 오류발생했을 경우 경고메세지
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}

// 일반상세
-(void)finishRequestPOIDetail:(id)request
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
            
            
            //NSMutableDictionary *obj = (NSMutableDictionary *)[request userObject];

            
            
            NSString *type = [oms.poiDetailDictionary objectForKeyGC:@"ORG_DB_TYPE"];
            
            if([type isEqualToString:@"OL"])
            {
                // POI상세 선택 통계
                [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail"];
                
                OilPOIDetailViewController *opdvc = [[OilPOIDetailViewController alloc] initWithNibName:@"OilPOIDetailViewController" bundle:nil];
                
                [[OMNavigationController sharedNavigationController] pushViewController:opdvc animated:NO];
                [opdvc release];
            }
            else if ([type isEqualToString:@"MV"])
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
            else
            {
            
            GeneralPOIDetailViewController *gpdvc = [[GeneralPOIDetailViewController alloc] initWithNibName:@"GeneralPOIDetailViewController" bundle:nil];
            
            // ver3테스트3번버그(일반상세API에는 상세이름까지 없다...결과에서넘겨줘야됨 ㅡㅡ)
            NSString *name = [oms.searchLocalDictionary objectForKeyGC:@"LastExtendCellName"];
            
            [gpdvc setThemeToDetailName:name];
            
            [[OMNavigationController sharedNavigationController] pushViewController:gpdvc animated:NO];
            [gpdvc release];
            }
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

// =====


@end
