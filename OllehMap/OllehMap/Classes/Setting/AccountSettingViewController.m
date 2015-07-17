//
//  AccountSettingViewController.m
//  OllehMap
//
//  Created by 이 제민 on 12. 8. 28..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "AccountSettingViewController.h"

@interface AccountSettingViewController ()

@end

@implementation AccountSettingViewController

@synthesize engine = _engine;
@synthesize delegate    =   _delegate;


#pragma mark -
#pragma mark Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // 트위터 엔진 생성및 키 설정
        self.engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
        self.engine.consumerKey = kOAuthConsumerKey;
        self.engine.consumerSecret = kOAuthConsumerSecret;
        
        // Custom initialization
        _twitLbl = [[UILabel alloc] init];
        _twitView = [[UIView alloc] init];
        _twitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_twitBtn retain];
        _twitBtnLbl = [[UILabel alloc] init];
        
        _faceLbl = [[UILabel alloc] init];
        _faceView = [[UIView alloc] init];
        _faceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_faceBtn retain];
        
        _faceBtnLbl = [[UILabel alloc] init];
    }
    
    return self;
}

- (void) dealloc
{
    [_faceLbl release];
    [_twitLbl release];
    [_facebook release];
    [_faceBtn release];
    [_faceBtnLbl release];
    [_faceView release];
    [_twitView release];
    [_twitBtn release];
    [_twitBtnLbl release];
    [_engine release];
    [super dealloc];
}
- (void)viewDidUnload
{
    [self setEngine:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    if (!_facebook)
    {
        _facebook = [[Facebook alloc] init];
    }
    
    [self twitterNfaceBookCheck];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _twitterState = NO;
    _facebookState = NO;
    
    //NSLog(@"NSUserDefaults 내용 : %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    
    [self checkTwitterLogin];
}


#pragma mark -
#pragma mark AccountSettingViewController
- (void) twitterNfaceBookCheck
{
    [self twitterCheck];
    [self faceBookCheck];
}


-(void) twitterCheck
{
    
    NSUserDefaults *twitterDefault = [NSUserDefaults standardUserDefaults];
    
    NSString *twitterId = [twitterDefault stringForKey:@"TWITTERID"];
    
    // 트위터
    [_twitLbl setFrame:CGRectMake(21,37+ 15, 200, 17)];
    [_twitLbl setText:@"트위터"];
    [_twitLbl setFont:[UIFont boldSystemFontOfSize:17]];
    [_twitLbl setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_twitLbl];
    
    
    // 트윗뷰
    [_twitView setFrame:CGRectMake(10, 37+41, 300, 45)];
    [self.view addSubview:_twitView];
    
    
    [_twitBtn setImage:[UIImage imageNamed:@"setting_box_01.png"] forState:UIControlStateNormal];
    [_twitBtn setFrame:CGRectMake(0, 0, 300, 45)];
    [_twitBtn addTarget:self action:@selector(twitterLogin:) forControlEvents:UIControlEventTouchUpInside];
    [_twitView addSubview:_twitBtn];
    
    NSLog(@"트윗아디 : %@", twitterId);
    
    [_twitBtnLbl setFrame:CGRectMake(143, 0, 130, 45)];
    [_twitBtnLbl setFont:[UIFont boldSystemFontOfSize:14]];
    [_twitBtnLbl setBackgroundColor:[UIColor clearColor]];
    
    if(!twitterId)
    {
        UIImageView *twitterImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setting_twitter.png"]];
        [twitterImg setFrame:CGRectMake(118, 13, 20, 20)];
        [_twitView addSubview:twitterImg];
        [twitterImg release];
        _twitterState = YES;
        
        [_twitBtnLbl setTextAlignment:NSTextAlignmentLeft];
        [_twitBtnLbl setText:@"로그인"];
    }
    else
    {
        [_twitBtnLbl setTextAlignment:NSTextAlignmentRight];
        [_twitBtnLbl setText:@"로그아웃"];
        
        UIImageView *arrowImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setting_arrow_btn.png"]];
        [arrowImg setFrame:CGRectMake(280, 16, 9, 14)];
        [_twitView addSubview:arrowImg];
        [arrowImg release];
        
        UILabel *twittLoginId = [[UILabel alloc] init];
        [twittLoginId setFrame:CGRectMake(11, 15, 150, 15)];
        [twittLoginId setFont:[UIFont boldSystemFontOfSize:15]];
        [twittLoginId setBackgroundColor:[UIColor clearColor]];
        [twittLoginId setTextColor:convertHexToDecimalRGBA(@"19", @"a8", @"c7", 1)];
        [twittLoginId setText:twitterId];
        [_twitView addSubview:twittLoginId];
        [twittLoginId release];
    }
    
    [_twitView addSubview:_twitBtnLbl];
    
}
-(void)faceBookCheck
{
    NSUserDefaults *faceDefaults = [NSUserDefaults standardUserDefaults];
    NSString *facebookId = [faceDefaults stringForKey:@"FACEBOOKID"];
    
    // 페북
    [_faceLbl setFrame:CGRectMake(21,37 + 100, 200, 17)];
    [_faceLbl setText:@"페이스북"];
    [_faceLbl setFont:[UIFont boldSystemFontOfSize:17]];
    [_faceLbl setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_faceLbl];
    
    // 페북뷰
    [_faceView setFrame:CGRectMake(10, 37 + 126, 300, 45)];
    [self.view addSubview:_faceView];
    
    [_faceBtn setImage:[UIImage imageNamed:@"setting_box_01.png"] forState:UIControlStateNormal];
    [_faceBtn setFrame:CGRectMake(0,0, 300, 45)];
    [_faceBtn addTarget:self action:@selector(faceBookLogin:) forControlEvents:UIControlEventTouchUpInside];
    [_faceView addSubview:_faceBtn];
    
    NSLog(@"페북아디 : %@", facebookId);
    
    [_faceBtnLbl setFrame:CGRectMake(143, 0, 130, 45)];
    [_faceBtnLbl setFont:[UIFont boldSystemFontOfSize:14]];
    [_faceBtnLbl setBackgroundColor:[UIColor clearColor]];
    
    if(!facebookId)
    {
        UIImageView *faceBookImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setting_facebook.png"]];
        [faceBookImg setFrame:CGRectMake(118, 13, 20, 20)];
        [_faceView addSubview:faceBookImg];
        [faceBookImg release];
        
        _facebookState = YES;
        
        [_faceBtnLbl setTextAlignment:NSTextAlignmentLeft];
        [_faceBtnLbl setText:@"로그인"];
    }
    else
    {
        [_faceBtnLbl setTextAlignment:NSTextAlignmentRight];
        [_faceBtnLbl setText:@"로그아웃"];
        
        UIImageView *arrowImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setting_arrow_btn.png"]];
        [arrowImg setFrame:CGRectMake(280, 16, 9, 14)];
        [_faceView addSubview:arrowImg];
        [arrowImg release];
        
        UILabel *faceLoginId = [[UILabel alloc] init];
        [faceLoginId setFrame:CGRectMake(11, 15, 150, 15)];
        [faceLoginId setFont:[UIFont boldSystemFontOfSize:15]];
        [faceLoginId setBackgroundColor:[UIColor clearColor]];
        [faceLoginId setTextColor:convertHexToDecimalRGBA(@"19", @"a8", @"c7", 1)];
        [faceLoginId setText:facebookId];
        [_faceView addSubview:faceLoginId];
        [faceLoginId release];
        
    }
    
    [_faceView addSubview:_faceBtnLbl];
    
    
}


#pragma mark -
#pragma mark IBAction
- (IBAction)popBtn:(id)sender
{
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
    
}

- (void)twitterLogin:(id)sender
{
    if(![self checkTwitterLogin] && _twitterState == YES)
    {
        [self loginTwitter];
    }
    else
    {
        if(_engine != nil)
        {
            // 토큰 클린, 라벨 재설정, 로그인 플러그 재설정
            [_engine clearAccessToken];
            
            [self logoutTwitter];
        }
        
    }
    
}
- (void)logoutTwitter
{
    NSUserDefaults *twitterState = [NSUserDefaults standardUserDefaults];
    [twitterState removeObjectForKey:@"TWITTERID"];
    //_engine = nil;
    [twitterState removeObjectForKey:@"authData"];
    [twitterState synchronize];
    //[_engine clearAccessToken];
    
    // 쿠키삭제
    NSHTTPCookieStorage *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *someCookies = [cookies cookiesForURL:[NSURL URLWithString:@"http://twitter.com"]];
    
    for (NSHTTPCookie *cookie in someCookies)
    {
        [cookies deleteCookie:cookie];
    }
    // 쿠키삭제 끝~
    
    _twitterState = NO;
    
    [self twitterCheck];
    
}
- (void)loginTwitter
{
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
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username
{
	NSUserDefaults	*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject:data forKey:@"authData"];
	[defaults synchronize];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username
{
    // 로컬데이터에 데이터가 없을 경우
    if([[[NSUserDefaults standardUserDefaults] objectForKeyGC: @"authData"] isEqualToString:@""])
    {
        return [[NSUserDefaults standardUserDefaults] objectForKeyGC: @"authData"];
    }
    
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    // 로컬데이터를 & 구분자를 사용하여 파싱하여 tempArray 넣어준다.
    NSArray *tempArray = [[[NSUserDefaults standardUserDefaults] objectForKeyGC: @"authData"] componentsSeparatedByString:@"&"];
    
    // 데이터가 들어있을 경우
    if([tempArray count] != 0)
    {
        NSArray *tempItem;
        
        for (NSString *tempString in tempArray)
        {
            // = 를 구분자로 사용하여 데이터를 파싱하여 ret 에 데이터를 넣어준다.
            tempItem = [tempString componentsSeparatedByString:@"="];
            [ret setObject:[tempItem objectAtIndexGC:1] forKey:[tempItem objectAtIndexGC:0]];
        }
        
        // 사용 안함으로 인한 주석처리 20111020
        RequestKey = [ret objectForKeyGC:@"oauth_token"];
        RequestSecret = [ret objectForKeyGC:@"oauth_token_secret"];
        //NSLog(@"RequestKey : %@", RequestKey);
        //NSLog(@"RequestSecret : %@", RequestSecret);
        //NSLog(@"screen_name : %@", [ret objectForKeyGC:@"screen_name"]);
        
        // 공용데이터에 데이터를 넣어준다.
        
        //        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //
        //        [defaults setObject:@"screen_name" forKey:@"TWITTERID"];
        //        [defaults synchronize];
        
    }
    
    // 20120307 릴리즈
    [ret release];
    
	return [[NSUserDefaults standardUserDefaults] objectForKeyGC: @"authData"];
}


#pragma mark -
#pragma mark SA_OAuthTwitterControllerDelegate
- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username {
	
	NSLog(@"Authenticated with user %@", username);
	
    NSUserDefaults *twitterId = [NSUserDefaults standardUserDefaults];
    
    [twitterId setObject:[NSString stringWithFormat:@"%@", username] forKey:@"TWITTERID"];
    [twitterId synchronize];
    
	tweets = [NSMutableArray array];
	//[self updateStream:nil];
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller {
	
	NSLog(@"Authentication Failure");
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller {
	
	NSLog(@"Authentication Canceled");
}


#pragma mark -
#pragma mark MGTwitterEngineDelegate
- (void)requestSucceeded:(NSString *)connectionIdentifier
{
    [OllehMapStatus sharedOllehMapStatus].isPhotosCheck = NO;
    [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_Share_TwitterOk", "")];
	NSLog(@"Request Suceeded: %@", connectionIdentifier);
}
- (void)requestFailed:(NSString *)connectionIdentifier
{
    [OllehMapStatus sharedOllehMapStatus].isPhotosCheck = NO;
    //[[OMIndicator sharedIndicator] forceStopAnimation];
    [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_Share_TwitterFail", "")];
	NSLog(@"Request Suceeded: %@", connectionIdentifier);
}



- (void)receivedObject:(NSDictionary *)dictionary forRequest:(NSString *)connectionIdentifier {
    
	NSLog(@"Recieved Object: %@", dictionary);
}

- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)connectionIdentifier {
    
	NSLog(@"Direct Messages Received: %@", messages);
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier {
	
	NSLog(@"User Info Received: %@", userInfo);
}

- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)connectionIdentifier {
	
	NSLog(@"Misc Info Received: %@", miscInfo);
}


- (void) faceBookLogin:(id)sender
{
    
    NSUserDefaults *faceDefault = [NSUserDefaults standardUserDefaults];
    
    NSString *faceId = [faceDefault stringForKey:@"FACEBOOKID"];
    
    
	if (_facebookState == YES && !faceId)
    {
        // 로그인 시킴
		[self loginFacebook];
	}
    else
    {		// 로그아웃 시킴
		[self logoutFacebook];
        
		
	}
}

- (void)loginFacebook
{
    // 페이스북 앱 아이디
	NSString* kAppId = @"170614009631423";
    
	// 퍼미션 설정 ( 권한설정 )
    NSArray *_permissions = [NSArray arrayWithObjects: @"read_stream", @"publish_stream", @"offline_access", nil];
    
    // 페이스북이 생성이 안되어 있으면 생성
    if (!_facebook)
    {
        _facebook = [[Facebook alloc] init];
    }
    
    // 페이스북 권한 요청하기
    [_facebook authorize:kAppId permissions:_permissions delegate:self];
}

/*
 @brief 페이스북 로그아웃 하기
 */
- (void)logoutFacebook
{
    // 페이스북 로그아웃
	[_facebook logout:self];
    
}

#pragma mark -
#pragma mark 페이스북 델리게이트 함수
/*
 @brief 로그인 되었을 때 호출
 */
- (void)fbDidLogin
{
	//NSLog(@"로그인..");
    // Get user Info
    [_facebook requestWithGraphPath:@"me" andDelegate:self];
    
}

/*
 @brief 데이터를 받을 때 호출 - 페이스북 델리게이트 함수
 @param request [ FBRequest ] FBRequest 정보
 @param result [ id ] request 정보
 */
- (void)request:(FBRequest*)request didLoad:(id)result
{
    
    //NSLog(@"result >> %@", result);
    
    
    // 페이스북 로그인 정보를 확인한다.
    //[self facebookloginInfo];
    
    if ([result isKindOfClass:[NSDictionary class]])
    {
        NSString *name = [result objectForKeyGC:@"name"];
        //NSString *facebookId = [result objectForKeyGC:@"id"];
        //NSString *email = [result objectForKeyGC:@"email"];
        
        // 로그아웃 문자를 라벨에 넣어준다.
        //[_facebookLoginLabel setText:[NSString stringWithFormat:@"%@ 로그아웃", name]];
        
        // 공용데이터에 아이디 및 플러그 값을 설정한다.
        //[DataBox sharedDataBox].facebookID = name;
        
        // 로컬에 페이스북 네임을 저장한다.
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:name forKey:@"FACEBOOKID"];
        [defaults synchronize];
        
        [self faceBookCheck];
    }
}


/*
 @brief 로그인 실패시 호출
 */
- (void)fbDidNotLogin:(BOOL)cancelled
{
	// login failed
    NSLog(@"login failed!!");
}

/*
 @brief 로그아웃 시 호출
 */
-(void)fbDidLogout
{
    // 로컬에 페이스북 로그아웃 되었다고 저장한다.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:@"FACEBOOKID"];
	[defaults synchronize];
	
    _facebookState = NO;
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"facebook"];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    }
    
    [self faceBookCheck];
    // 라벨 로그인으로 변경
    //    [_facebookLoginLabel setText:@"로그인"];
    
    // 공용데이터에 아이디 값및 플러그 설정
    //    [DataBox sharedDataBox].facebookID = @"";
    //    [DataBox sharedDataBox].isFacebookLogin = NO;
    
    // 로그인 정보를 체크한다.
	//[self facebookloginInfo];
}

/*
 @brief 데이터를 받기 전에 호출
 */
- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response;
{
    NSLog(@"response >>> [%@]", response);
}

/*
 @brief 에러가 발생하였을 때 호출
 */
- (void)request:(FBRequest*)request didFailWithError:(NSError*)error;
{
    NSLog(@"error >>> [%@]", error);
}

- (void)sendUpdate:(NSString *)data
{
    // 메시지 보내기
    NSLog(@"데이토 : %@", data);
    [_engine sendUpdate:data];
}

- (void)sendUpdate:(NSString*)_data setImageData:(UIImage*)_uploadimg
{
	ServerRequester *request = [[ServerRequester alloc] init];
	
	[request setURL:[NSURL URLWithString:@"http://api.twitpic.com/1/uploadAndPost.json"]];
    
	[request setHTTPMethod:@"POST"];
	
	[request addFinishTarget:self action:@selector(finishUploadTwitPic:)];
	
	NSString *stringBoundary = @"0xKhTmLbOuNdArY---This_Is_ThE_BoUnDaRyy---pqo";
	
	NSString *headerBoundary = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary];
	[request addValue:headerBoundary forHTTPHeaderField:@"Content-Type"];
	
	NSMutableData *postBody = [NSMutableData data];
	
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Disposition: form-data; name=\"key\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 트위픽 키
	[postBody appendData:[@"ae79add0c06b387d8135c79bf099d478" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Disposition: form-data; name=\"consumer_token\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    // 인증키
	[postBody appendData:[kOAuthConsumerKey dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Disposition: form-data; name=\"consumer_secret\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 인증키
	[postBody appendData:[kOAuthConsumerSecret dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Disposition: form-data; name=\"oauth_token\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 토큰 키
    [postBody appendData:[RequestKey dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Disposition: form-data; name=\"oauth_secret\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 토큰 키
    [postBody appendData:[RequestSecret dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Disposition: form-data; name=\"message\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    // 전송할 데이터
	[postBody appendData:[_data dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	
    
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"media\"; filename=\"%@\"\r\n", @"map.jpg" ] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Type: image/jpg\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    // 전송할 이미지
	[postBody appendData:UIImageJPEGRepresentation(_uploadimg, 0.8) ];
    
	[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    // 바디 설정
	[request setHTTPBody:postBody];
	[request sendRequest];
    
    
}

- (void)finishUploadTwitPic:(id)request
{
	//[MainViewController getMainViewController].isDefaultNavigationBar = NO;
	if ([request finishCode] == OMSRFinishCode_Completed)
	{
        
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
		// 알림창 표시
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_Share_TwitterOk", "")];
        
        if(oms.photoimg != nil){
            
            oms.photoimg = nil;
        }
        
	}
    else
    {
        
        [OMMessageBox showAlertMessage:@"" :@"네트워크 연결에 실패하였습니다"];
        
        
        
        //        NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        //        NSLog(@"sns 로그인 뷰 finishUploadTwitPic");
        //        NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        
    }
	
	[request release];
}

@end
