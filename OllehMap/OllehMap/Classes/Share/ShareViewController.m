//
//  ShareViewController.m
//  OllehMap
//
//  Created by 이 제민 on 12. 7. 2..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "ShareViewController.h"
#import "MapContainer.h"
#import "MainMapViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

@synthesize scrollView = _scrollView;
@synthesize poiCoord = _poiCoord;
@synthesize poiName = _poiName;

static ShareViewController *_instVC;


#pragma mark -
#pragma mark Initialization
+ (ShareViewController *)instVC
{
    if(_instVC == nil)
    {
        _instVC = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil];
    }
    return _instVC;
}

+ (void)sharePopUpView:(UIView *)pView
{
    [self instVC];
    
    [pView addSubview:[ShareViewController instVC].view];
}
+ (void) ollehNaviAlertView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"올레 navi로 이동하시겠습니까?" delegate:self cancelButtonTitle:@"아니오" otherButtonTitles:@"예", nil];
    [alert setTag:1];
    [alert show];
    [alert release];
    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        //_poiName = [[NSString alloc] init];
        _poiCoord = CoordMake(0, 0);
        
        _snsAccountView                = [[AccountSettingViewController alloc] initWithNibName:@"AccountSettingViewController" bundle:nil];
        _snsAccountView.delegate       =   self;
        _snsAccountView.view.hidden    = YES;
        
        [self.view setFrame:CGRectMake(0, 0,
                                       [UIScreen mainScreen].bounds.size.width,
                                       [UIScreen mainScreen].bounds.size.height - 20)];
    }
    return self;
}

- (void)dealloc
{
    [_snsSaveString release];
    [_facebook release];
    [_engine release];
    [_tweets release];
    [_poiName release];
    [_scrollView release];
    [super dealloc];
}

- (void)viewDidUnload
{
    
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // ver4 46만큼 높이 줄음(올레톡제거)
    [_scrollView setContentSize:CGSizeMake(228, 230)];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}


#pragma mark -
#pragma mark IBAction
- (IBAction)messageBtnClick:(id)sender
{
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    MFMessageComposeViewController *controller = [[[MFMessageComposeViewController alloc] init] autorelease];
    if([MFMessageComposeViewController canSendText])
    {
        
        NSString *name = [oms.shareDictionary objectForKeyGC:@"NAME"];
        NSString *urlStr = [oms.shareDictionary objectForKeyGC:@"ShortURL"];
        NSString *Addr = [oms.shareDictionary objectForKeyGC:@"ADDR"];
        NSString *tel = [oms.shareDictionary objectForKeyGC:@"TEL"];
        
        if(urlStr == nil || [urlStr isEqualToString:@""])
        {
            urlStr = @"";
        }
        else
        {
            urlStr = [NSString stringWithFormat:@"\n%@", urlStr];
        }
        if(Addr == nil || [Addr isEqualToString:@""])
        {
            Addr = @"";
        }
        else
        {
            
            Addr = [NSString stringWithFormat:@"\n *%@", Addr];
        }
        if(tel == nil || [tel isEqualToString:@""])
        {
            tel = @"";
        }
        else
        {
            tel = [NSString stringWithFormat:@"\n *%@", tel];
        }
        
        
        [[OMNavigationController sharedNavigationController] pushViewController:self animated:NO];
        
        controller.body = [NSString stringWithFormat:@"[올레맵]%@%@%@%@", name,urlStr,Addr,tel];
        controller.messageComposeDelegate = self;
        [self presentModalViewController:controller animated:YES];
        
        
    }
    //    else
    //    {
    //        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_Message_NoAccount", @"")];
    //		return;
    //    }
    
}

- (IBAction)emailBtnClick:(id)sender
{
    
    // 메일계정 미등록 시 알럿뷰
    if(![MFMailComposeViewController canSendMail])
	{
		[OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_Mail_NoAccount", @"")];
		return;
	}
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSString *name = [oms.shareDictionary objectForKeyGC:@"NAME"];
    NSString *urlStr = [oms.shareDictionary objectForKeyGC:@"ShortURL"];
    NSString *Addr = [oms.shareDictionary objectForKeyGC:@"ADDR"];
    NSString *tel = [oms.shareDictionary objectForKeyGC:@"TEL"];
    
    if(urlStr == nil || [urlStr isEqualToString:@""])
    {
        urlStr = @"";
    }
    else
    {
        urlStr = [NSString stringWithFormat:@"\n%@", urlStr];
    }
    if(Addr == nil || [Addr isEqualToString:@""])
    {
        Addr = @"";
    }
    else
    {
        
        Addr = [NSString stringWithFormat:@"\n *%@", Addr];
    }
    if(tel == nil || [tel isEqualToString:@""])
    {
        tel = @"";
    }
    else
    {
        tel = [NSString stringWithFormat:@"\n *%@", tel];
    }
    
    
    MFMailComposeViewController *controller = [[[MFMailComposeViewController alloc] init] autorelease];
    controller.mailComposeDelegate = self;
    [controller setSubject:[NSString stringWithFormat:@"[올레맵]%@", name]];
    [controller setMessageBody:[NSString stringWithFormat:@"[올레맵]%@%@%@%@", name,urlStr,Addr,tel] isHTML:NO];
    
    
    [[OMNavigationController sharedNavigationController]pushViewController:self animated:NO];
    [self presentModalViewController:controller animated:YES];
    
    
}
- (IBAction)kakaoTalkBtnClick:(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSString *name = [oms.shareDictionary objectForKeyGC:@"NAME"];
    NSString *urlStr = [oms.shareDictionary objectForKeyGC:@"ShortURL"];
    NSString *Addr = [oms.shareDictionary objectForKeyGC:@"ADDR"];
    NSString *tel = [oms.shareDictionary objectForKeyGC:@"TEL"];
    
    if(urlStr == nil || [urlStr isEqualToString:@""])
    {
        urlStr = @"";
    }
    else
    {
        urlStr = [NSString stringWithFormat:@"\n%@", urlStr];
    }
    if(Addr == nil || [Addr isEqualToString:@""])
    {
        Addr = @"";
    }
    else
    {
        
        Addr = [NSString stringWithFormat:@"\n *%@", Addr];
    }
    if(tel == nil || [tel isEqualToString:@""])
    {
        tel = @"";
    }
    else
    {
        tel = [NSString stringWithFormat:@"\n *%@", tel];
    }
    
    
    NSMutableString *returnStr = [[NSMutableString alloc] init] ;
    
    [returnStr appendFormat:@"%@%@%@%@", name, urlStr, Addr, tel];
    
    NSString *referenceURLString = [[NSString alloc] initWithString:returnStr];
    
    //NSString *appBundleID = @"com.example.app";
    //NSString *appVersion = @"1.0";
    
    ///
    
    NSString *poiId = stringValueOfDictionary(oms.shareDictionary, @"POI_ID");
    NSString *poiType = stringValueOfDictionary(oms.shareDictionary, @"POI_TYPE");
    int crdX = [stringValueOfDictionary(oms.shareDictionary, @"POI_X") intValue];
    int crdY = [stringValueOfDictionary(oms.shareDictionary, @"POI_Y") intValue];
    
    
    // 카카오톡 호출
    if ([KakaoLinkCenter canOpenKakaoLink])
    {
        [self cancelBtnClick:nil];
        
        NSMutableArray *metaInfoArray = [NSMutableArray array];
        NSDictionary *metaInfoIOS = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"ios", @"os",
                                     @"phone", @"devicetype",
                                     APPSTORE_URL, @"installurl",[NSString stringWithFormat:@"ktolleh00047://?X=%d&Y=%d&Level=5&Name=%@&ID=%@&PType=%@&srcApp=0", crdX, crdY, name, poiId, poiType]
                                     , @"executeurl",
                                     nil];
        [metaInfoArray addObject:metaInfoIOS];

        [KakaoLinkCenter openKakaoLinkWithURL:@"" appVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] appBundleID:[[NSBundle mainBundle] bundleIdentifier] appName:@"올레맵" message:referenceURLString];
        
        // 앱으로 연결하려면...근데 변수가 많음
        // 1. 기차역처럼 타입은 tr인데 일반상세일때
        // 2. 버스와 지하철 구별못함
        //[KakaoLinkCenter openKakaoAppLinkWithMessage:referenceURLString URL:@"" appBundleID:[[NSBundle mainBundle] bundleIdentifier] appVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] appName:@"올레맵" metaInfoArray:metaInfoArray];

    }
    else
    {
        // 카카오톡이 설치되어 있지 않은 경우에 대한 처리
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_NotSetup_kakaoTalk", @"")];
    }
    
    [returnStr release];
    [referenceURLString release];
    
    
}

- (IBAction)twitterBtnClick:(id)sender
{
    [self twitter];
}

- (void) twitter
{
    NSUserDefaults *twitt = [NSUserDefaults standardUserDefaults];
    NSString *twitterId = [twitt stringForKey:@"TWITTERID"];
    
    if(twitterId)
    {
        
        //[self checkTwitterLogin];
        
        [self loginTwitter];
        
        [self showSendMessageView:2];
    }
    else
    {
        if(![self checkTwitterLogin])
        {
            [self loginTwitter];
        }
        else
        {
            
            if(_engine != nil)
            {
                //                // 토큰 클린, 라벨 재설정, 로그인 플러그 재설정
                [_engine clearAccessToken];
                [self loginTwitter];
            }
            
        }
    }
    
    [self cancelBtnClick:nil];
}

- (BOOL)checkTwitterLogin
{
    // 엔진 체크
	if (!_engine)
	{
        // 클래스 생성
		_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
		// 키 설정
		_engine.consumerKey = kOAuthConsumerKey;
		_engine.consumerSecret = kOAuthConsumerSecret;
        
	}
	
	return [_engine isAuthorized];
}
- (void)loginTwitter
{
    UIViewController *controller = nil;
    // 엔진이 생성되어 있으면
	if (_engine)
	{
        // 로그인 컨트롤러 생성
		SA_OAuthTwitterController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];
        
		if (controller)
        {
            NSLog(@"트윗 실패!!");
            [[OMNavigationController sharedNavigationController] presentModalViewController: controller animated: YES];
        }
	}
    else
    {
        _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
        _engine.consumerKey = kOAuthConsumerKey;
        _engine.consumerSecret = kOAuthConsumerSecret;
        
        controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: _engine delegate: self];
    }
    
}

- (void)showSendMessageView:(NSInteger)_type
{
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    // 바디 데이터 설정
    
    NSMutableString *nameData = [NSMutableString string];
    NSMutableString *urlData = [NSMutableString string];
    NSMutableString *strData = [NSMutableString string];
    
    // 페이스북
    if (_type == 1)
    {
        
        // url 정보가 있을 경우
        if (![[oms.shareDictionary objectForKeyGC:@"ShortURL"] isEqualToString:@"(null)"]
            && ![[oms.shareDictionary objectForKeyGC:@"ShortURL"] isEqualToString:@""])
        {
            
            // POI_NAME 정보가 있을 경우
            if (![[oms.shareDictionary objectForKeyGC:@"NAME"] isEqualToString:@"(null)"]
                && ![[oms.shareDictionary objectForKeyGC:@"NAME"] isEqualToString:@""])
            {
                
                // 장소 문구 붙이기
                NSString *nameStr = [NSString stringWithFormat:@"[올레맵] %@", [oms.shareDictionary objectForKeyGC:@"NAME"]];
                //[urlData appendString:nameStr];
                [nameData appendString:nameStr];
            }
            
            // url 문구 붙이기
            NSString *urlStr = [NSString stringWithFormat:@"\n%@\n", [oms.shareDictionary objectForKeyGC:@"ShortURL"]];
            [urlData appendString:urlStr];
        }
        else
        {
            [urlData setString:@""];
            [nameData setString:@""];
            //NSLog(@"데이터가 없다.");
        }
        
        //NSLog(@"urlData >> [%@]", urlData);
        
        // POI_ADDR 정보가 있을 경우
        if (![[oms.shareDictionary objectForKeyGC:@"ADDR"] isEqualToString:@"(null)"]
            && ![[oms.shareDictionary objectForKeyGC:@"ADDR"] isEqualToString:@""])
        {
            
            // 주소 문구 붙이기
            NSString *addrStr = [NSString stringWithFormat:@"%@", [oms.shareDictionary objectForKeyGC:@"ADDR"]];
            [strData appendString:addrStr];
            
            // POI_TEL 정보가 있을 경우
            if (![[oms.shareDictionary objectForKeyGC:@"TEL"] isEqualToString:@"(null)"]
                && ![[oms.shareDictionary objectForKeyGC:@"TEL"] isEqualToString:@""])
            {
                
                // 전화 문구 붙이기
                NSString *telStr = [NSString stringWithFormat:@"\n%@", [oms.shareDictionary objectForKeyGC:@"TEL"]];
                [strData appendString:telStr];
                
                //NSLog(@"strData >> [%@]", strData);
            }
        }
        else
        {
            [strData setString:@""];
            //NSLog(@"데이터가 없다.");
        }

    }
    // 트위터
    else if (_type == 2)
    {
        // url 정보가 있을 경우
        if (![[oms.shareDictionary objectForKeyGC:@"ShortURL"] isEqualToString:@"(null)"]
            && ![[oms.shareDictionary objectForKeyGC:@"ShortURL"] isEqualToString:@""])
            
        {
            
            // POI_NAME 정보가 있을 경우
            if (![[oms.shareDictionary objectForKeyGC:@"NAME"] isEqualToString:@"(null)"]
                && ![[oms.shareDictionary objectForKeyGC:@"NAME"] isEqualToString:@""])
            {
                
                // 장소 문구 붙이기
                NSString *nameStr = [NSString stringWithFormat:@"[올레맵] %@", [oms.shareDictionary objectForKeyGC:@"NAME"]];
                //[urlData appendString:nameStr];
                [nameData appendString:nameStr];
            }
            
            // url 문구 붙이기
            NSString *urlStr = [NSString stringWithFormat:@"\n%@\n", [oms.shareDictionary objectForKeyGC:@"ShortURL"]];
            [urlData appendString:urlStr];
        }
        else
        {
            [urlData setString:@""];
            [nameData setString:@""];
            //NSLog(@"데이터가 없다.");
        }
        
        //NSLog(@"urlData >> [%@]", urlData);
        
        
        
        // POI_ADDR 정보가 있을 경우
        if (![[oms.shareDictionary objectForKeyGC:@"ADDR"] isEqualToString:@"(null)"]
            && ![[oms.shareDictionary objectForKeyGC:@"ADDR"] isEqualToString:@""])
        {
            
            // 주소 문구 붙이기
            NSString *addrStr = [NSString stringWithFormat:@"%@", [oms.shareDictionary objectForKeyGC:@"ADDR"]];
            [strData appendString:addrStr];
            
            // POI_TEL 정보가 있을 경우
            if (![[oms.shareDictionary objectForKeyGC:@"TEL"] isEqualToString:@"(null)"]
                && ![[oms.shareDictionary objectForKeyGC:@"TEL"] isEqualToString:@""])
            {
                
                // 전화 문구 붙이기
                NSString *telStr = [NSString stringWithFormat:@"\n%@", [oms.shareDictionary objectForKeyGC:@"TEL"]];
                [strData appendString:telStr];
                
                //NSLog(@"strData >> [%@]", strData);
            }
            
        }
        else
        {
            [strData setString:@""];
            //NSLog(@"데이터가 없다.");
        }
    }
    
    SNSSendViewController *vc = [[SNSSendViewController alloc] initWithType:_type name:nameData url:urlData strData:strData];
    
    vc.delegate = self;
    
    //UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    
    // 네비게이션 바에 이미지 적용
    
    [self presentModalViewController:vc animated:NO];
    
    // ver4 위치공유 팝업제거
    [self cancelBtnClick:nil];
    
    //[navController release];
    
}

- (IBAction)faceBookBtnClick:(id)sender
{
    
    NSString* kAppId = @"170614009631423";
    
    NSArray *_permissions = [NSArray arrayWithObjects: @"read_stream", @"publish_stream", @"offline_access", @"user_photos",nil];
    
    if (!_facebook)
        _facebook = [[Facebook alloc] init];
    
    [_facebook authorize:kAppId permissions:_permissions delegate:self];
    
    [self cancelBtnClick:nil];
}

- (IBAction)infoCopyBtnClick:(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [NSString stringWithString:[oms.shareDictionary objectForKeyGC:@"ShortURL"]];
    
    [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_Share_Copy", @"")];
    
}

- (IBAction)cancelBtnClick:(id)sender
{
    [self.view removeFromSuperview];
}


#pragma mark -
#pragma mark messageComposeDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result;
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"메시지를 보냈습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
    
    switch (result)
    {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
            break;
        case MessageComposeResultSent:
            [alert show];
            break;
        default:
            break;
    }
    
    [alert autorelease];
    
    [self dismissModalViewControllerAnimated:YES];
    [self becomeFirstResponder];
    
    // ver4 위치공유 팝업제거
    //    OMNavigationController *nc = [OMNavigationController sharedNavigationController];
    //    UIViewController *preVC= [nc.viewControllers objectAtIndexGC:nc.viewControllers.count-2];
    //    [preVC.view addSubview:self.view];
    
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}


#pragma mark -
#pragma mark MailcomposeDelegate
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"메일 전송을 완료하였습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
    
    switch (result)
    {
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
    
    // ver4 위치공유 팝업제거
    //    OMNavigationController *nc = [OMNavigationController sharedNavigationController];
    //    UIViewController *preVC= [nc.viewControllers objectAtIndexGC:nc.viewControllers.count-2];
    //    [preVC.view addSubview:self.view];
    
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
    
}


#pragma mark -
#pragma mark AlertView Delegate
+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 1)
    {
        if(buttonIndex == 1)
        {
            OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
            
            Coord myCrd = [[MapContainer sharedMapContainer_Main].kmap getUserLocation];
            
            Coord poiCrd = CoordMake([[oms.shareDictionary objectForKeyGC:@"X"] doubleValue], [[oms.shareDictionary objectForKeyGC:@"Y"] doubleValue]);
            
            myCrd = [[MapContainer sharedMapContainer_Main].kmap convertCoordinate:myCrd inCoordType:KCoordType_UTMK outCoordType:KCoordType_WGS84];
            poiCrd = [[MapContainer sharedMapContainer_Main].kmap convertCoordinate:poiCrd inCoordType:KCoordType_UTMK outCoordType:KCoordType_WGS84];
            
            double Myx = myCrd.x;
            double Myy = myCrd.y;
            
            double Destx = poiCrd.x;
            double Desty = poiCrd.y;
            
            
            NSLog(@"%f, %f, %f, %f", Myx, Myy, Destx, Desty);
            
            NSString *naviURL = [NSString stringWithFormat:@"ollehnavi://ollehnavi.kt.com/navigation.req?method=routeguide&start=(%f,%f)&end=(%f,%f)&response=ollehmap", Myx, Myy, Destx, Desty];
            
            
            if ([[UIApplication sharedApplication] openURL:[NSURL URLWithString:naviURL]])
            {
                NSLog(@"navi gogo");
            }
            else
            {
                // 알림창 표시
                [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_NotSetup_navi", @"")];
                //[OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_Share_Copy", @"")];
            }
            
        }
    }
}

// 2번 || 로긴후 1번
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username
{
	
	NSUserDefaults	*defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
}
// 1번 4번
- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	
	return [[NSUserDefaults standardUserDefaults] objectForKeyGC: @"authData"];
}

#pragma mark -
#pragma mark SA_OAuthTwitterController Delegate
// 로긴후 2번
- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username
{
	
    NSUserDefaults *twitterId = [NSUserDefaults standardUserDefaults];
    
    [twitterId setObject:[NSString stringWithFormat:@"%@", username] forKey:@"TWITTERID"];
    [twitterId synchronize];
    
	NSLog(@"Authenticated with user %@", username);
	
	_tweets = [[NSMutableArray alloc] init];
    
    
    [self performSelector:@selector(delayTwitterSendMessageView:) withObject:[NSNumber numberWithInt:2] afterDelay:2.0f];
    
    //[self showSendMessageView:2];
    //[OllehMapStatus sharedOllehMapStatus].isTwitterLogin = YES;
	//[self updateStream:nil];
}
-(void)delayTwitterSendMessageView:(NSNumber*)_type
{
    [self showSendMessageView:2];
    
}
// 트윗접속실패
- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller
{
	NSLog(@"Authentication Failure");
}
// 트윗접속취소
- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller
{
	NSLog(@"Authentication Canceled");
}

#pragma mark -
#pragma mark MGTwitterEngineDelegate Methods
// 보내기 성공
- (void)requestSucceeded:(NSString *)connectionIdentifier
{
    
	NSLog(@"Request Suceeded: %@", connectionIdentifier);
}


- (void)receivedObject:(NSDictionary *)dictionary forRequest:(NSString *)connectionIdentifier
{
    
	NSLog(@"Recieved Object: %@", dictionary);
}

- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)connectionIdentifier
{
    
	NSLog(@"Direct Messages Received: %@", messages);
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier
{
	
	NSLog(@"User Info Received: %@", userInfo);
}

- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)connectionIdentifier
{
	
	NSLog(@"Misc Info Received: %@", miscInfo);
}

#pragma mark -
#pragma mark FaceBookDelegate

/*
 @brief 페이스북 로그아웃 하기
 */
- (void)logoutFacebook
{
    // 페이스북 로그아웃
	[_facebook logout:self];
    
}


/*
 @brief 로그인 되었을 때 호출
 */
- (void)fbDidLogin
{
	//NSLog(@"로그인..");
    // Get user Info
    NSUserDefaults *face = [NSUserDefaults standardUserDefaults];
    
    NSString *facebookId = [face objectForKeyGC:@"FACEBOOKID"];
    
    if(!facebookId)
    {
        [OllehMapStatus sharedOllehMapStatus].fbNewContact = YES;
        [_facebook requestWithGraphPath:@"me" andDelegate:self];
    }
    else
    {
        [self showSendMessageView:1];
    }
}

/*
 @brief 데이터를 받을 때 호출
 */
- (void)request:(FBRequest*)request didLoad:(id)result
{
    //NSLog(@"request >>> [%@]", request);
    //NSLog(@"result >>> [%@]", result);
    NSUserDefaults *face = [NSUserDefaults standardUserDefaults];
    
    NSString *facebookId = [face objectForKeyGC:@"FACEBOOKID"];
    
    if ([result isKindOfClass:[NSDictionary class]])
    {
        //.. 로그인 되어있지않을경우
        if(!facebookId)
        {
            
            
            [OllehMapStatus sharedOllehMapStatus].fbNewContact = NO;
            
            //.. 로그인 후 데이터 정보를 단말에 저장합니다.
            NSString *name = [result objectForKeyGC:@"name"];
            
            // 로컬에 페이스북 네임을 저장한다.
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:name forKey:@"FACEBOOKID"];
            [defaults synchronize];
            
            //.. 요청하고자 했던 URL 정보를 입력하는 뷰어를 호출 합니다.
            [self showSendMessageView:1];
            
        }
    }
}

- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response;
{
    
    //NSLog(@"%@", request.params);
    [OllehMapStatus sharedOllehMapStatus].isPhotosCheck = NO;
    if([OllehMapStatus sharedOllehMapStatus].fbNewContact == YES)
        return;
    
	// 알림창 표시
	[OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_Share_FaceBookOk", @"")];
    
    
    
    [[OMIndicator sharedIndicator] stopAnimating];
    
}

/*
 @brief <delegate> 페이스북 오류가 발생했을때
 */
- (void)request:(FBRequest*)request didFailWithError:(NSError*)error;
{
    [[OMIndicator sharedIndicator] stopAnimating];
    
    [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_Share_FaceBookFail", "")];
    
    [OllehMapStatus sharedOllehMapStatus].isPhotosCheck = NO;
}

/*
 @brief 사용자가 로그인하지 않고 대화 상자를 닫습니다 때 호출
 */
- (void)fbDidNotLogin:(BOOL)cancelled;
{
    //[OMMessageBox showAlertMessage:@"" :@"닫아씀"];
}

/*
 @brief SendMessageViewDelegateTextMessage 사용자가 입력한 문구를 가져오는 함수
 */
-(void)SNSSendViewDelegateTextMessage:(NSString *)message type:(int)type
{
    
    
    //NSLog(@"SendMessageViewDelegateTextMessage >>> [%@] type >>> [%d]", message, type);
    if(_snsSaveString == nil)
        _snsSaveString   =   [[NSMutableString alloc] init];
    [_snsSaveString setString:message];
    _snsSaveType =   type;
    //.. 메세지 정보를 SNS 에 전송합니다.
    [self SendMessageViewMessage:_snsSaveString type:_snsSaveType];
}

#pragma mark -
#pragma mark 페이스북, 트위터 사용자 문구 관련
/*
 @brief 메세지를 전송합니다 . 페이스북 , 트위터
 @param message 메세지 정보
 @param type 타입 1 : 페이스북 , 2 : 트위터
 */
-(void)SendMessageViewMessage:(NSString *)message type:(int)type{
    
    NSString *_message = [[[NSString alloc] initWithFormat:@"%@", message] autorelease];
    
    //NSLog(@"_message >>> [%@]", _message);
    
    // 페이스북일 경우
    if (type == 1)
    {
        
#if 1
        NSString *tempStr = [[NSString alloc] initWithFormat:@"%@", _message];
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        // 사진이 첨부 되어 있다면
        if ( oms.isPhotosCheck == TRUE )
        {
            
            NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            _message, @"caption",
                                            oms.photoimg, @"picture",
                                            nil];
            
            [_facebook requestWithGraphPath:@"me/photos"
                                  andParams:params
                              andHttpMethod:@"POST"
                                andDelegate:self];
            
            if(oms.photoimg != nil)
            {
                
                oms.photoimg = nil;
            }
        }
        // 사진이 없을 경우
        else
        {
            
            NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            _message, @"message",
                                            nil];
            
            [_facebook requestWithGraphPath:@"me/feed"
                                  andParams:params
                              andHttpMethod:@"POST"
                                andDelegate:self];
        }
        
        oms.isPhotosCheck = NO;
        //
        //
        //        // 인디케이터 실행
        //        [_indecator startAnimating];
        
        
#else
        
        //NSLog(@"11111111111111111111111111111111111111111");
        
        _snsText.text = [NSString stringWithFormat:@"%@", _message];
        _snsSendView.hidden = NO;
        
        //NSLog(@"11111111111111111111111111111111111111111");
        
#endif
        [tempStr release];
        
        [[OMIndicator sharedIndicator] startAnimating];
        
    }
    // 트위터 일 경우
    else if (type == 2)
    {
        
        NSLog(@"%@", _snsAccountView.engine);
        
        if (!_snsAccountView.engine)
        {
            _snsAccountView.engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:_snsAccountView];
            _snsAccountView.engine.consumerKey = kOAuthConsumerKey;
            _snsAccountView.engine.consumerSecret = kOAuthConsumerSecret;
            
            SA_OAuthTwitterController *vc = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_snsAccountView.engine delegate:self];
            
            if (vc)
            {
                //[MainViewController getMainViewController].isDefaultNavigationBar = YES;
                [self presentModalViewController:vc animated: YES];
                return;
            }
        }
        // 바디 데이터 설정
        
        NSString *tempStr = [[[NSString alloc] initWithFormat:@"%@", _message] autorelease];
        //NSLog(@"트위터 tempStr >> [%@]", tempStr);
        
        // SNS view
        _snsAccountView = [[AccountSettingViewController alloc] initWithNibName:@"AccountSettingViewController" bundle:nil];
        
        _snsAccountView.delegate   =   self;
        _snsAccountView.view.hidden = YES;
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        //        // 사진이 첨부 되어 있다면
        if (oms.isPhotosCheck == TRUE )
        {
            [_snsAccountView sendUpdate:tempStr setImageData:oms.photoimg];
            
        }
        //        // 사진이 없을 경우
        else
        {
            [_snsAccountView sendUpdate:tempStr];
            
            
        }
        
        oms.isPhotosCheck = NO;
        
    }
    
    [OllehMapStatus sharedOllehMapStatus].photoimg = nil;
    
}


@end
