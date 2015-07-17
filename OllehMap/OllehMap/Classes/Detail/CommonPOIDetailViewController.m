//
//  CommonPOIDetailViewController.m
//  OllehMap
//
//  Created by 이 제민 on 12. 7. 4..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "CommonPOIDetailViewController.h"
#import "MainMapViewController.h"
#import "MapContainer.h"

NSString* convertBISUniqueId (NSString *bisId)
{
    if(bisId)
    {
        if([bisId isEqualToString:@"0"])
        {
            return bisId;
        }
        else if ([bisId length] < 5)
        {
            return [NSString stringWithFormat:@"0%@", bisId];
        }
        else
            return bisId;
    }
    else
        return @"";
}

NSString* refineBISUniqueId (NSString *bisId, BOOL withZero)
{
    if(bisId == nil)
        return bisId;
    
    if(withZero == YES)
    {
        return convertBISUniqueId(bisId);
    }
    else
    {
        NSRange range = [bisId rangeOfString:@"0"];
        
        if(range.location == 0)
        {
            range.length = 1;
            
            NSMutableString *newBisId = [NSMutableString stringWithString:bisId];
            [newBisId deleteCharactersInRange:range];
            
            return [NSString stringWithFormat:@"%@", newBisId];
        }
        else
        {
            return bisId;
        }
    }
}

@interface CommonPOIDetailViewController ()

@end


@implementation CommonPOIDetailViewController

@synthesize displayMapBtn = _displayMapBtn;
@synthesize delegate = _delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _displayMapBtn = YES;
        _isPushBusStationAndLine = NO;
    }
    return self;
}
- (void) dealloc
{
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) typeChecker : (int)type
{
    _dicType = type;
}

- (void) telViewCallBtnClick:(NSString *)telString
{
    TelAlertView *alert = [[TelAlertView alloc] initWithTitle:telString message:@"해당 전화번호로 연결하시겠습니까?" delegate:self cancelButtonTitle:@"아니오" otherButtonTitles:@"예", nil];
    [alert show];
    [alert release];
}
- (void) homeViewURLBtnClick:(NSString *)urlString
{
    HomeAlertView *alert = [[HomeAlertView alloc] initWithTitle:urlString message:@"웹페이지로 이동하시겠습니까?" delegate:self cancelButtonTitle:@"아니오" otherButtonTitles:@"예", nil];
    [alert show];
    [alert release];
}
- (void) btnViewStartBtnClick:(NSDictionary *)dic
{
    NSString *btnStartName = nil;
    
    double btnX = 0;
    double btnY = 0;
    
    switch (_dicType) {
        case ParamType_TR_BUS:
        {
            btnStartName = stringValueOfDictionary(dic, @"BST_NAME");
            btnX = [[dic objectForKeyGC:@"BST_X"] doubleValue];
            btnY = [[dic objectForKeyGC:@"BST_Y"] doubleValue];
        }
            break;
        case ParamType_TR:
        {
            btnStartName = [NSString stringWithFormat:@"%@ (%@)", stringValueOfDictionary(dic, @"SST_NAME"), stringValueOfDictionary(dic, @"SUBWAY_LANENAME")];
            btnX = [[dic objectForKeyGC:@"SST_X"] doubleValue];
            btnY = [[dic objectForKeyGC:@"SST_Y"] doubleValue];
        }
            break;
        case ParamType_MP:
        case ParamType_MV:
        case ParamType_OL:
        case ParamType_ADDR:
        {
            btnStartName = stringValueOfDictionary(dic, @"NAME");
            btnX = [[dic objectForKeyGC:@"X"] doubleValue];
            btnY = [[dic objectForKeyGC:@"Y"] doubleValue];
            
        }
            break;
        default:
            break;
    }
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    oms.currentMapLocationMode = MapLocationMode_None;
    // 출발지 선택 통계
    [oms trackPageView:@"/POI_detail/start"];
    
    [oms.searchResultRouteStart reset];
    [oms.searchResultRouteStart setUsed:YES];
    [oms.searchResultRouteStart setIsCurrentLocation:NO];
    [oms.searchResultRouteStart setStrLocationName:btnStartName];
    [oms.searchResultRouteStart setCoordLocationPoint:CoordMake(btnX, btnY)];
    [[SearchRouteDialogViewController sharedSearchRouteDialog] showSearchRouteDialog];
    [mc.kmap setCenterCoordinate:oms.searchResultRouteStart.coordLocationPoint];
}
- (void) btnViewDestBtnClick:(NSDictionary *)dic
{
    NSString *btnDestName = nil;
    double btnX = 0;
    double btnY = 0;
    
    switch (_dicType) {
        case ParamType_TR_BUS:
        {
            btnDestName = stringValueOfDictionary(dic, @"BST_NAME");
            btnX = [[dic objectForKeyGC:@"BST_X"] doubleValue];
            btnY = [[dic objectForKeyGC:@"BST_Y"] doubleValue];
        }
            break;
        case ParamType_TR:
        {
            btnDestName = [NSString stringWithFormat:@"%@ (%@)", stringValueOfDictionary(dic, @"SST_NAME"), stringValueOfDictionary(dic, @"SUBWAY_LANENAME")];
            btnX = [[dic objectForKeyGC:@"SST_X"] doubleValue];
            btnY = [[dic objectForKeyGC:@"SST_Y"] doubleValue];
        }
            break;
        case ParamType_MP:
        case ParamType_MV:
        case ParamType_OL:
        case ParamType_ADDR:
        {
            btnDestName = stringValueOfDictionary(dic, @"NAME");
            btnX = [[dic objectForKeyGC:@"X"] doubleValue];
            btnY = [[dic objectForKeyGC:@"Y"] doubleValue];
            
        }
            break;
        default:
            break;
    }
    
    // 도착지 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail/dest"];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    oms.currentMapLocationMode = MapLocationMode_None;
    
    [oms.searchResultRouteDest reset];
    [oms.searchResultRouteDest setUsed:YES];
    [oms.searchResultRouteDest setIsCurrentLocation:NO];
    [oms.searchResultRouteDest setStrLocationName:btnDestName];
    [oms.searchResultRouteDest setCoordLocationPoint:CoordMake(btnX, btnY)];
    [[SearchRouteDialogViewController sharedSearchRouteDialog] showSearchRouteDialog];
    [mc.kmap setCenterCoordinate:oms.searchResultRouteDest.coordLocationPoint];
    //[OMMessageBox showAlertMessage:@"도착지로" :@"도착~"];
}
- (void) btnViewShareBtnClick
{
    // 위치공유 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail/share"];
    
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSString *poiName = nil;
    NSString *poiId = nil;
    NSString *org_db_id = nil;
    Coord poiCrd;
    NSString *tel = nil;
    NSString *addr = nil;
    NSString *type = nil;
    
    int newUrlShareType = 0;
    
    switch (_dicType) {
        case ParamType_MP:
        {
            poiName = stringValueOfDictionary(oms.poiDetailDictionary, @"NAME");
            poiId = stringValueOfDictionary(oms.poiDetailDictionary, @"POI_ID");
            tel = stringValueOfDictionary(oms.poiDetailDictionary, @"TEL");
            addr = stringValueOfDictionary(oms.poiDetailDictionary, @"ADDR");
            poiCrd = CoordMake([[oms.poiDetailDictionary objectForKey:@"X"] doubleValue], [[oms.poiDetailDictionary objectForKey:@"Y"] doubleValue]);
            org_db_id = stringValueOfDictionary(oms.poiDetailDictionary, @"POI_ID");
            type = @"MP";
        }
            break;
        case ParamType_MV:
        {
            poiName = stringValueOfDictionary(oms.poiDetailDictionary, @"NAME");
            poiId = stringValueOfDictionary(oms.poiDetailDictionary, @"POI_ID");
            tel = stringValueOfDictionary(oms.poiDetailDictionary, @"TEL");
            addr = stringValueOfDictionary(oms.poiDetailDictionary, @"ADDR");
            poiCrd = CoordMake([[oms.poiDetailDictionary objectForKey:@"X"] doubleValue], [[oms.poiDetailDictionary objectForKey:@"Y"] doubleValue]);
            org_db_id = stringValueOfDictionary(oms.poiDetailDictionary, @"ORG_DB_ID");
            type = @"MV";
        }
            break;
        case ParamType_OL:
        {
            poiName = stringValueOfDictionary(oms.poiDetailDictionary, @"NAME");
            poiId = stringValueOfDictionary(oms.poiDetailDictionary, @"POI_ID");
            tel = stringValueOfDictionary(oms.poiDetailDictionary, @"TEL");
            addr = stringValueOfDictionary(oms.poiDetailDictionary, @"ADDR");
            poiCrd = CoordMake([[oms.poiDetailDictionary objectForKey:@"X"] doubleValue], [[oms.poiDetailDictionary objectForKey:@"Y"] doubleValue]);
            org_db_id = stringValueOfDictionary(oms.poiDetailDictionary, @"ORG_DB_ID");
            type = @"OL";
        }
            break;
        case ParamType_ADDR:
        {
            poiName = stringValueOfDictionary(oms.addressPOIDictionary, @"NAME");
            poiId = @"";
            tel = @"";
            addr = stringValueOfDictionary(oms.addressPOIDictionary, @"NAME");
            poiCrd = CoordMake([[oms.addressPOIDictionary objectForKey:@"X"] doubleValue], [[oms.addressPOIDictionary objectForKey:@"Y"] doubleValue]);
            org_db_id = @"";
            type = @"ADDR";
            newUrlShareType = 4;
        }
            break;
        case ParamType_TR_BUS:
        {
            poiName = stringValueOfDictionary(oms.busStationNewDictionary, @"bst_NAME");
            poiId = @"";
            tel = @"";
            addr = [NSString stringWithFormat:@"%@ %@ %@", stringValueOfDictionary(oms.busStationNewDictionary, @"bst_DO"), stringValueOfDictionary(oms.busStationNewDictionary, @"bst_GU"), stringValueOfDictionary(oms.busStationNewDictionary, @"bst_DONG")];
            
            poiCrd = CoordMake([[oms.busStationNewDictionary objectForKeyGC:@"bst_X"] doubleValue], [[oms.busStationNewDictionary objectForKeyGC:@"bst_Y"] doubleValue]);
            org_db_id = stringValueOfDictionary(oms.busStationNewDictionary, @"stid");
            type = @"TR_BUS";
            newUrlShareType = 1;
        }
            break;
        case ParamType_TR:
        {
            poiName = stringValueOfDictionary(oms.subwayDetailDictionary, @"SST_NAME");
            poiId = @"";
            tel = stringValueOfDictionary(oms.subwayDetailDictionary, @"SST_TEL");
            addr = stringValueOfDictionary(oms.subwayDetailDictionary, @"SST_ADDRESS");
            
            poiCrd = CoordMake([[oms.subwayDetailDictionary objectForKeyGC:@"SST_X"] doubleValue], [[oms.subwayDetailDictionary objectForKeyGC:@"SST_Y"] doubleValue]);
            org_db_id = stringValueOfDictionary(oms.subwayDetailDictionary, @"STID");
            type = @"TR";
            newUrlShareType = 2;
        }
            break;
            
        default:
            break;
    }

    
    [[ServerConnector sharedServerConnection] requestDetailURL:self action:@selector(finishShareBtnClick:) PID:poiId DetailType:newUrlShareType Addr:addr StId:org_db_id];
    
        //[[ServerConnector sharedServerConnection] requestShortenURL:self action:@selector(finishShareBtnClick:) PX:(double)poiCrd.x PY:(double)poiCrd.y Level:mc.kmap.zoomLevel MapType:mc.kmap.mapType Name:poiName PID:poiId Addr:addr Tel:tel Type:type ID:org_db_id];
}
- (void) finishShareBtnClick:(id)request
{
    
    if([request finishCode] == OMSRFinishCode_Completed)
    {
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        NSString *orgId = nil;
        NSString *type = nil;
        NSString *crdX = nil;
        NSString *crdY = nil;
        NSString *name = nil;
        NSString *tel = nil;
        NSString *addr = nil;
        
        switch (_dicType) {
            case ParamType_MP:
            {
                orgId = stringValueOfDictionary(oms.poiDetailDictionary,@"POI_ID");
                type = @"MP";
                crdX = stringValueOfDictionary(oms.poiDetailDictionary,@"X");
                crdY = stringValueOfDictionary(oms.poiDetailDictionary,@"Y");
                name = stringValueOfDictionary(oms.poiDetailDictionary,@"NAME");
                tel = stringValueOfDictionary(oms.poiDetailDictionary,@"TEL");
                addr = stringValueOfDictionary(oms.poiDetailDictionary,@"ADDR");
                
        
            }
                break;
            case ParamType_MV:
            {
                orgId = stringValueOfDictionary(oms.poiDetailDictionary,@"POI_ID");
                type = @"MV";
                crdX = stringValueOfDictionary(oms.poiDetailDictionary,@"X");
                crdY = stringValueOfDictionary(oms.poiDetailDictionary,@"Y");
                name = stringValueOfDictionary(oms.poiDetailDictionary,@"NAME");
                tel = stringValueOfDictionary(oms.poiDetailDictionary,@"TEL");
                addr = stringValueOfDictionary(oms.poiDetailDictionary,@"ADDR");
            }
                break;
            case ParamType_OL:
            {
                orgId = stringValueOfDictionary(oms.poiDetailDictionary,@"POI_ID");
                type = @"OL";
                crdX = stringValueOfDictionary(oms.poiDetailDictionary,@"X");
                crdY = stringValueOfDictionary(oms.poiDetailDictionary,@"Y");
                name = stringValueOfDictionary(oms.poiDetailDictionary,@"NAME");
                tel = stringValueOfDictionary(oms.poiDetailDictionary,@"TEL");
                addr = stringValueOfDictionary(oms.poiDetailDictionary,@"ADDR");
            }
                break;
            case ParamType_ADDR:
            {
                orgId = @"";
                name = stringValueOfDictionary(oms.addressPOIDictionary, @"NAME");
                addr = stringValueOfDictionary(oms.addressPOIDictionary, @"NAME");
                crdX = stringValueOfDictionary(oms.addressPOIDictionary, @"X");
                crdY = stringValueOfDictionary(oms.addressPOIDictionary, @"Y");
                tel = @"";
                type = @"ADDR";
            }
                break;
            case ParamType_TR_BUS:
            {
                name = stringValueOfDictionary(oms.busStationNewDictionary, @"bst_NAME");
                orgId = stringValueOfDictionary(oms.busStationNewDictionary, @"stid");
                tel = @"";
                addr = [NSString stringWithFormat:@"%@ %@ %@", stringValueOfDictionary(oms.busStationNewDictionary, @"bst_DO"), stringValueOfDictionary(oms.busStationNewDictionary, @"bst_GU"), stringValueOfDictionary(oms.busStationNewDictionary, @"bst_DONG")];
                
                crdX = [oms.busStationNewDictionary objectForKeyGC:@"bst_X"];
                crdY = [oms.busStationNewDictionary objectForKeyGC:@"bst_Y"];
                type = @"TR_BUS";
            }
                break;
            case ParamType_TR:
            {
                name = stringValueOfDictionary(oms.subwayDetailDictionary, @"SST_NAME");
                orgId = stringValueOfDictionary(oms.subwayDetailDictionary, @"STID");
                tel = stringValueOfDictionary(oms.subwayDetailDictionary, @"SST_TEL");
                addr = stringValueOfDictionary(oms.subwayDetailDictionary, @"SST_ADDRESS");
                
                crdX = [oms.subwayDetailDictionary objectForKeyGC:@"SST_X"];
                crdY = [oms.subwayDetailDictionary objectForKeyGC:@"SST_Y"];
                type = @"TR";
            }
                break;
            default:
                break;
        }
        
        
        [oms.shareDictionary setObject:name forKey:@"NAME"];
        [oms.shareDictionary setObject:addr forKey:@"ADDR"];
        [oms.shareDictionary setObject:tel forKey:@"TEL"];
        [oms.shareDictionary setObject:orgId forKey:@"POI_ID"];
        [oms.shareDictionary setObject:type forKey:@"POI_TYPE"];
        [oms.shareDictionary setObject:crdX forKey:@"POI_X"];
        [oms.shareDictionary setObject:crdY forKey:@"POI_Y"];
        
        
        [ShareViewController sharePopUpView:self.view];
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_ShortURL_NotResponse", @"")];
    }
}

- (void) btnViewNaviBtnClick:(NSDictionary *)dic
{
    
    double btnX = 0;
    double btnY = 0;
    
    switch (_dicType)
    {
        case ParamType_TR_BUS:
        {
            btnX = [[dic objectForKeyGC:@"BST_X"] doubleValue];
            btnY = [[dic objectForKeyGC:@"BST_Y"] doubleValue];
        }
            break;
        case ParamType_TR:
        {
            btnX = [[dic objectForKeyGC:@"SST_X"] doubleValue];
            btnY = [[dic objectForKeyGC:@"SST_Y"] doubleValue];
        }
            break;
        case ParamType_MP:
        case ParamType_MV:
        case ParamType_OL:
        case ParamType_ADDR:
        {
            btnX = [[dic objectForKeyGC:@"X"] doubleValue];
            btnY = [[dic objectForKeyGC:@"Y"] doubleValue];
            
        }
            break;
        default:
            break;
    }
    // 네비 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail/olleh_navi"];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    [oms.shareDictionary  setObject:[NSString stringWithFormat:@"%f", btnX] forKey:@"X"];
    [oms.shareDictionary  setObject:[NSString stringWithFormat:@"%f", btnY] forKey:@"Y"];
    
    NSLog(@"X좌표 %f, Y좌표 : %f", [[oms.shareDictionary objectForKeyGC:@"X"] doubleValue], [[oms.shareDictionary objectForKeyGC:@"Y"] doubleValue]);
    
    [ShareViewController ollehNaviAlertView];
}
- (void) bottomViewFavorite:(NSDictionary *)dic placeHolder:(NSString *)placeHolderStr
{
    
    FavoAlertView *alert = [[[FavoAlertView alloc] initWithTitle:@"즐겨찾기 이름" message:@"\n" delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil] autorelease];
    [alert setPlace:placeHolderStr];
    [alert show];
    
}
- (void)modalContact:(NSDictionary *)dic
{
    // 주소 넣기
    NSString *contactName = stringValueOfDictionary(dic, @"NAME");
    NSString *contactImage = stringValueOfDictionary(dic, @"IMG_URL");
    NSString *contactAddr = stringValueOfDictionary(dic, @"ADDR");
    NSString *contactHomePage = stringValueOfDictionary(dic, @"URL");
    NSString *contactTel = stringValueOfDictionary(dic, @"TEL");
    
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 저장할 레코드를 생성한다.
	ABRecordRef person = ABPersonCreate();
    
    // 이름넣기
    ABRecordSetValue(person, kABPersonFirstNameProperty, contactName, nil);
    
    if(![contactImage isEqualToString:@""])
    {
        NSData *data1 = UIImagePNGRepresentation([oms urlGetImage:contactImage]);
        ABPersonSetImageData(person, (CFDataRef)data1, NULL);
    }
    
    // 주소넣기
    if(![contactAddr isEqualToString:@""])
    {
        ABMutableMultiValueRef multiAddress = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
        
        NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];
        
        [addressDictionary setObject:contactAddr forKey:(NSString *) kABPersonAddressStreetKey];
        // 레코드에 데이터 저장
        ABMultiValueAddValueAndLabel(multiAddress, addressDictionary, kABWorkLabel, NULL);
        ABRecordSetValue(person, kABPersonAddressProperty, multiAddress,NULL);
        CFRelease(multiAddress);
    }
    
    // 홈피넣기
    
    // 다중 입력을 할수 있게 속성값을 넣어준다.
    ABMutableMultiValueRef homePage = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    if(![contactHomePage isEqualToString:@""])
    {
        ABMultiValueAddValueAndLabel(homePage, contactHomePage, kABPersonHomePageLabel, NULL);
    }
    
    // 레코드에 데이터를 저장한다.
    ABRecordSetValue(person, kABPersonURLProperty, homePage, nil);
    
    if(homePage)
        CFRelease(homePage);
    
    // 전화번호 넣기
    
    // 다중 입력을 할수 있게 속성값을 넣어준다.
	ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
	
    // 레코드 안의 폰 라벨에 전화번호 정보를 설정하여 준다.
    if(![contactTel isEqualToString:@""])
        ABMultiValueAddValueAndLabel(multiPhone, contactTel, kABPersonPhoneMainLabel, NULL);
	
    // 레코드에 데이터를 저장한다.
    ABRecordSetValue(person, kABPersonPhoneProperty, multiPhone, nil);
    
    if(multiPhone)
        CFRelease(multiPhone);
    
    
    // 새로운 Parson 을 추가하기 위한 뷰 컨트로러
    // 생성한 뷰 컨틀로러에 저장한 레코드를 넣어준다.
	ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
	picker.newPersonViewDelegate = self;
	picker.displayedPerson = person;
	
    
	UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:picker];
	[self presentModalViewController:navigation animated:YES];
	
	[picker release];
	[navigation release];
	
	CFRelease(person);
    
}
// Dismisses the new-person view controller.
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void) modalInfoModify:(NSDictionary *)dic
{
    // 메일계정 미등록 시 알럿뷰
    if(![MFMailComposeViewController canSendMail])
	{
		[OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_Mail_NoAccount", @"")];
		return;
	}
    
    NSData *data = UIImagePNGRepresentation([[OllehMapStatus sharedOllehMapStatus] returnCaptureImg:self.view]);
    
    NSArray *toRecipients = [NSArray arrayWithObject:ollehEmail];
    
    NSString *pName = nil;
    NSString *pAdd = nil;
    NSString *pTel = nil;
    
    switch (_dicType) {
        case ParamType_TR_BUSNO:
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[dic objectForKeyGC:@"laneid"]  forKey:@"LANEID"];
            
            [[OllehMapStatus sharedOllehMapStatus].pushDataBusNumberArray addObject:dict];
            
            [dict release];
            
            pName = stringValueOfDictionary(dic, @"bl_BUSNO");
            pAdd = @"";
            pTel = @"";
        }
            break;
        case ParamType_TR_BUS:
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[dic objectForKeyGC:@"stid"]  forKey:@"STID"];
            
            [[OllehMapStatus sharedOllehMapStatus].pushDataBusStationArray addObject:dict];
            
            [dict release];
            
            
            pName = stringValueOfDictionary(dic, @"bst_NAME");
            NSString *pAdd1 = stringValueOfDictionary(dic, @"bst_DO");
            NSString *pAdd2 = stringValueOfDictionary(dic, @"bst_GU");
            NSString *pAdd3 = stringValueOfDictionary(dic, @"bst_DONG");
            
            pAdd = [NSString stringWithFormat:@"%@%@%@", pAdd1, pAdd2, pAdd3];
            pTel = @"";
        }
            break;
        case ParamType_TR:
        {
            pName = stringValueOfDictionary(dic, @"SST_NAME");
            pAdd = stringValueOfDictionary(dic, @"SST_ADDRESS");
            pTel = stringValueOfDictionary(dic, @"SST_TEL");
        }
            break;
        case ParamType_MP:
        case ParamType_MV:
        case ParamType_ADDR:
        case ParamType_OL:
        {
            pName = stringValueOfDictionary(dic, @"NAME");
            pAdd = stringValueOfDictionary(dic, @"ADDR");
            pTel = stringValueOfDictionary(dic, @"TEL");
        }
        default:
            break;
    }
    
    NSString *title = @"[정보수정 요청]";
    NSString *body1 = @"[현재 내용] \n\n 정보명: ";
    NSString *add = @"\n 주소: ";
    NSString *tel = @"\n 전화번호: ";
    NSString *body2 = @"\n\n\n [수정내용] \n 수정이 필요한 내용을 자세하게 적어주세요. \n\n 예시) \n 상호가 [ㅇㅇㅇ]로 변경 되었습니다. \n [예약]을 할 수 없습니다. \n [주류]를 판매합니다.";
    
    if([pTel isEqualToString:@""])
    {
        tel = @"";
    }
    
    if([pAdd isEqualToString:@""])
    {
        add = @"";
    }
    
    MFMailComposeViewController *controller = [[[MFMailComposeViewController alloc] init] autorelease];
    controller.mailComposeDelegate = self;
    [controller setToRecipients:toRecipients];
    [controller setSubject:[NSString stringWithFormat:@"%@%@", title, pName]];
    [controller setMessageBody:[NSString stringWithFormat:@"%@%@%@%@%@%@%@", body1, pName, add, pAdd, tel, pTel, body2] isHTML:NO];
    [controller addAttachmentData:data mimeType:@"image/png" fileName:@"capture"];
    [self presentModalViewController:controller animated:YES];
}
#pragma mark -
#pragma mark MailcomposeDelegate methods

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"정보수정 요청을 완료하였습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
    
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            [alert show];
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    
    [alert autorelease];
    
    [self dismissModalViewControllerAnimated:YES];
    [self becomeFirstResponder];
}

//- (void)modalAddresBook2:(OllehMapAddress*)dic
//{
//    dic.city;
//    dic.tel;
//}
#pragma mark -
#pragma mark AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView isKindOfClass:[TelAlertView class]])
    {

        if(alertView.tag == 5)
        {
            
            if( [_delegate respondsToSelector:@selector(freeCallRemoveFromSuperViewDelegate)])
            {
                [_delegate freeCallRemoveFromSuperViewDelegate];
            }
            
            NSString *telNum = [[OllehMapStatus sharedOllehMapStatus].poiDetailDictionary objectForKeyGC:@"TEL"];
            
            if(buttonIndex == 0)
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel:" stringByAppendingString:telNum]]];
            
        }
        
        else if(buttonIndex == 1)
        {
            switch (_dicType)
            {
                case ParamType_MP:
                case ParamType_OL:
                case ParamType_MV:
                {
                        NSString *telNum = [[OllehMapStatus sharedOllehMapStatus].poiDetailDictionary objectForKeyGC:@"TEL"];
                    
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel:" stringByAppendingString:telNum]]];
                }
                    break;
                case ParamType_TR:
                {
                    NSString *telNum = [[OllehMapStatus sharedOllehMapStatus].poiDetailDictionary objectForKeyGC:@"SST_TEL"];
                    
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel:" stringByAppendingString:telNum]]];
                }
                    break;
                default:
                    break;
            }
            
        }
    }
    else if([alertView isKindOfClass:[HomeAlertView class]])
    {
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        NSString *homeURL = [oms urlValidCheck:[oms.poiDetailDictionary objectForKeyGC:@"URL"]];
        
        if(buttonIndex == 1)
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:homeURL]];
    }
    else if ([alertView isKindOfClass:[FavoAlertView class]])
    {
        if(buttonIndex == 1)
        {
            UITextField  *textfielder = (UITextField*)[alertView viewWithTag:123123];
            
            NSString *refinedText = textfielder.text;
            
            OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
            DbHelper *dh = [[DbHelper alloc] init];
            
            NSMutableDictionary *fdic = nil;
            NSString *ujName = nil;
            
            switch (_dicType)
            {
                case ParamType_MP:
                {
                    ujName = [oms.poiDetailDictionary objectForKey:@"UJ_NAME"];
                    
                    fdic = [OMDatabaseConverter makeFavoriteDictionary:-1 sortOrder:-1 category:Favorite_Category_Local title1:refinedText title2:[oms ujNameSegment:ujName] title3:[NSString stringWithFormat:@"%@", stringValueOfDictionary(oms.searchLocalDictionary, @"LastExtendFreeCall")] iconType:Favorite_IconType_POI coord1x:[[oms.poiDetailDictionary objectForKey:@"X"] doubleValue] coord1y:[[oms.poiDetailDictionary objectForKey:@"Y"] doubleValue] coord2x:0 coord2y:0 coord3x:0 coord3y:0 detailType:@"MP" detailID:[oms.poiDetailDictionary objectForKey:@"POI_ID"] shapeType:stringValueOfDictionary(oms.searchLocalDictionary, @"LastExtendShapeType") fcNm:stringValueOfDictionary(oms.searchLocalDictionary, @"LastExtendFCNM") idBgm:stringValueOfDictionary(oms.searchLocalDictionary, @"LastExtendIDBGM")];
                }
                    break;
                case ParamType_MV:
                {
                    ujName = [oms.poiDetailDictionary objectForKey:@"UJ_NAME"];
                    
                    fdic = [OMDatabaseConverter makeFavoriteDictionary:-1 sortOrder:-1 category:Favorite_Category_Local title1:refinedText title2:[oms ujNameSegment:ujName] title3:@"" iconType:Favorite_IconType_POI coord1x:[[oms.poiDetailDictionary objectForKeyGC:@"X"] doubleValue] coord1y:[[oms.poiDetailDictionary objectForKeyGC:@"Y"] doubleValue] coord2x:0 coord2y:0 coord3x:0 coord3y:0 detailType:@"MV" detailID:[oms.poiDetailDictionary objectForKeyGC:@"POI_ID"] shapeType:@"" fcNm:@"" idBgm:@""];
                }
                    break;
                case ParamType_OL:
                {
                    ujName = [oms.poiDetailDictionary objectForKey:@"UJ_NAME"];
                    
                    fdic = [OMDatabaseConverter makeFavoriteDictionary:-1 sortOrder:-1 category:Favorite_Category_Local title1:refinedText title2:[oms ujNameSegment:ujName] title3:@"" iconType:Favorite_IconType_POI coord1x:[[oms.poiDetailDictionary objectForKeyGC:@"X"] doubleValue] coord1y:[[oms.poiDetailDictionary objectForKeyGC:@"Y"] doubleValue] coord2x:0 coord2y:0 coord3x:0 coord3y:0 detailType:@"OL" detailID:[oms.poiDetailDictionary objectForKeyGC:@"POI_ID"] shapeType:@"" fcNm:@"" idBgm:@""];
                }
                    break;
                    case ParamType_ADDR:
                {
                    
                    fdic = [OMDatabaseConverter makeFavoriteDictionary:-1 sortOrder:-1 category:Favorite_Category_Local title1:refinedText title2:[oms.addressPOIDictionary objectForKeyGC:@"NAME"] title3:@"" iconType:Favorite_IconType_POI coord1x:[[oms.addressPOIDictionary objectForKeyGC:@"X"] doubleValue] coord1y:[[oms.addressPOIDictionary objectForKeyGC:@"Y"] doubleValue] coord2x:0 coord2y:0 coord3x:0 coord3y:0 detailType:@"ADDR" detailID:@"" shapeType:@"" fcNm:@"" idBgm:@""];
                }
                    break;
                case ParamType_TR_BUS:
                {
                    ujName = @"대중교통 > 버스정류장";
                    
                    fdic = [OMDatabaseConverter makeFavoriteDictionary:-1 sortOrder:-1 category:Favorite_Category_Public title1:refinedText title2:ujName title3:@"" iconType:Favorite_IconType_BusStop coord1x:[[oms.busStationNewDictionary objectForKeyGC:@"bst_X"] doubleValue] coord1y:[[oms.busStationNewDictionary objectForKeyGC:@"bst_Y"] doubleValue] coord2x:0 coord2y:0 coord3x:0 coord3y:0 detailType:@"TR_BUS" detailID:[oms.busStationNewDictionary objectForKeyGC:@"stid"] shapeType:@"" fcNm:@"" idBgm:@""];
                }
                    break;
                    case ParamType_TR_BUSNO:
                {
                    
                    ujName = @"대중교통 > 버스노선";
                    
                    fdic = [OMDatabaseConverter makeFavoriteDictionary:-1 sortOrder:-1 category:Favorite_Category_Public title1:refinedText title2:ujName title3:@"" iconType:[oms getBusClassNumber:[[oms.busNumberNewDictionary objectForKeyGC:@"bl_BUSCLASS"] intValue]] coord1x:0 coord1y:0 coord2x:0 coord2y:0 coord3x:0 coord3y:0 detailType:@"TR_BUSNO" detailID:[oms.busNumberNewDictionary objectForKeyGC:@"laneid"] shapeType:@"" fcNm:@"" idBgm:@""];
                }
                    break;
                case ParamType_TR:
                {
                    ujName = @"대중교통 > 지하철";
                    
                    fdic = [OMDatabaseConverter makeFavoriteDictionary:-1 sortOrder:-1 category:Favorite_Category_Public title1:refinedText title2:ujName title3:@"" iconType:Favorite_IconType_Subway coord1x:[[oms.subwayDetailDictionary objectForKeyGC:@"SST_X"] doubleValue] coord1y:[[oms.subwayDetailDictionary objectForKeyGC:@"SST_Y"] doubleValue] coord2x:0 coord2y:0 coord3x:0 coord3y:0 detailType:@"TR" detailID:[oms.subwayDetailDictionary objectForKeyGC:@"STID"] shapeType:@"" fcNm:@"" idBgm:@""];
                }
                    break;
                default:
                    break;
            }

            [dh addFavorite:fdic];
            [dh release];
            
        }
    }
}


@end
