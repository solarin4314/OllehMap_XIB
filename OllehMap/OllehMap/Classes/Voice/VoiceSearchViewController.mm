//
//  VoiceSearchViewController.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 6. 26..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "VoiceSearchViewController.h"

#import "VoiceAssistController.h"

#import "avrController.h"


@interface VoiceSearchViewController
(
 )


// ====================
// [ 초기화 - private ]
// ====================
- (void) initComponents;
- (void) initComponents_MainUI;
- (void) initComponents_AnimationThread;
- (void) initComponents_Device;
- (void) initComponents_VoiceRecognizer;
// ********************

// ============================
// [ 네비게이션 메뉴 - private ]
// ============================
- (void) renderNavigation;
- (void) onNavigationLeftButton :(id)sender;
- (void) retryVoiceSearchView;
// ****************************

// ==========================
// [ 디바이스 제어 - private ]
// ==========================
- (void) manageNotification :(BOOL)enable;
- (void) resetDeviceAudioSession;
- (void) resumePreviousPlayer;
- (void) startVoiceRecognizer;
// **************************

// =============================
// [ 알림 콜백 메소드 - private ]
// =============================
-(void)notiConnectCannot:(NSNotification*) event;
-(void)notiReadyOK:(NSNotification*) event;
-(void)notiSessionTimeout:(NSNotification*) event;
-(void)notiStartRecognize:(NSNotification*) event;
-(void)notiFailedRecognize:(NSNotification*) event;
-(void)notiSuccessRecognize:(NSNotification*) event;
-(void)notiFailure:(NSNotification*) event;
-(void)notiDisconnect:(NSNotification*) event;
// *****************************

// ===============================
// [ 스레드 콜백 메소드 - private ]
// ===============================
- (void) doWorkVoiceWaveLevelProcess;
- (void) doWorkVoiceWaveLevelProcessByMainThread;
-(void) doWorkRenderKeyword;
- (void) renderKeywordLabel :(NSString *)keyword;
// *******************************


// ============================
// [ 검색서비스 호출 - private ]
// ============================
- (void) searchVoiceKeyword;
- (void) searchVoiceKeyword :(int)voiceSearchIndex;
- (void) didFinishSearchInit :(id)request;
// ****************************

@end

@implementation VoiceSearchViewController

@synthesize currentSearchTargetType = _currentSearchTargetType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 백그라운드 진입 노티피케이션 등록
    [[NSNotificationCenter  defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [self initComponents];
}

- (void) didEnterBackground :(id)sender
{
    // 백그라운드 진입 노티피케이션 해제
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    // 음성검색창 닫기
    [self closeVoiceSearchView];
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

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 스레드 종료
    [_threadVoiceWaveLevelProcessor cancel];
    [_threadVoiceWaveLevelProcessor release];
    _threadVoiceWaveLevelProcessor = nil;
    [_threadKeywordRenderer cancel];
    [_threadKeywordRenderer release];
    _threadKeywordRenderer = nil;
    
    // 알림 해제
    [self manageNotification:NO];
    
    // 여전히 인디게이터 활성화 되어 있을 경우 강제로 해제
    [[OMIndicator sharedIndicator] forceStopAnimation];
    
    // 기존 사운드 재생 (조건 충족시..)
    [self resumePreviousPlayer];
}

- (void) dealloc
{
    // UI 리소스 해제
    [_imgvwMikeAnimation release]; _imgvwMikeAnimation  = nil;
    [_lblAanimationKeyword release]; _lblAanimationKeyword = nil;
    [_lblEventNoti release]; _lblEventNoti = nil;
    
    // 스레드 리소스 해제 (실제로는 disappear에서 릴리즈되어 온다.) //보험용..
    [_threadVoiceWaveLevelProcessor release]; _threadVoiceWaveLevelProcessor = nil;
    [_threadKeywordRenderer release]; _threadKeywordRenderer = nil;
    
    // 음성파형 리소스 해제
    if (_aqLevelArr) free(_aqLevelArr); _aqLevelArr = nil;
    
    // 이벤트 리소스 해제
    [_arrayAnimationKeyword release]; _arrayAnimationKeyword = nil;
    
    [super dealloc];
}


// ====================
// [ 초기화 - private ]
// ====================

- (void) initComponents
{
    // MainUI 처리
    [self initComponents_MainUI];
    
    // 애니메이션 처리를 위한 스레드 초기화
    [self initComponents_AnimationThread];
    
    // 음성파형을 사용하기 위한 디바이스 오디오 초기화
    [self initComponents_Device];
    
    // 음성인식 컨트롤 초기화
    [self initComponents_VoiceRecognizer];
    
    // 음성인식 시작
    [self startVoiceRecognizer];
}

- (void) initComponents_MainUI
{
    // 네비게이션 렌더링
    [self renderNavigation];
    
    // 배경이미지
    UIImageView *imgvwBack = [[UIImageView alloc] init];
    
    if (IS_4_INCH)  [imgvwBack setImage:[UIImage imageNamed:@"voice_bg-568h.png"]];
    else            [imgvwBack setImage:[UIImage imageNamed:@"voice_bg.png"]];
    
    [imgvwBack setFrame:CGRectMake(0, 37, [UIScreen mainScreen].bounds.size.width,
                                   [UIScreen mainScreen].bounds.size.height - 20 - 37)];
    [self.view addSubview:imgvwBack];
    [imgvwBack release];
    
    // 하단 안내문구
    UILabel *lblAlert = [[UILabel alloc] initWithFrame:CGRectMake(0, 434, 320, 11)];
    [lblAlert setFont:[UIFont systemFontOfSize:11]];
    [lblAlert setBackgroundColor:[UIColor clearColor]];
    [lblAlert setTextColor:[UIColor colorWithRed:139 green:139 blue:139 alpha:1.0f]];
    [lblAlert setTextAlignment:NSTextAlignmentCenter];
    [lblAlert setText:NSLocalizedString(@"Body_VoiceSearch_Alert", @"")];
    [lblAlert setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [self.view addSubview:lblAlert];
    [lblAlert release];
    
    // 중앙 안내 이미지
    UIImageView *imgvwBalloon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voice_layer.png"]];
    [imgvwBalloon setFrame:CGRectMake(18, 37+42, 566/2, 150/2)];
    [self.view addSubview:imgvwBalloon];
    [imgvwBalloon release];
    
    // 중앙 이벤트 안내 라벨
    _lblEventNoti = [[UILabel alloc] initWithFrame:CGRectMake(36/2, 37+42+13, 566/2, 15)];
    [_lblEventNoti setFont:[UIFont systemFontOfSize:15]];
    [_lblEventNoti setTextColor:[UIColor whiteColor]];
    [_lblEventNoti setBackgroundColor:[UIColor clearColor]];
    [_lblEventNoti setTextAlignment:NSTextAlignmentCenter];
    [_lblEventNoti setText:NSLocalizedString(@"Body_VoiceSearch_Request", @"")];
    [self.view addSubview:_lblEventNoti];
    
    // 중앙 마이크 애니메이션 이미지 뷰
    _imgvwMikeAnimation = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voice_ani_01.png"]];
    [_imgvwMikeAnimation setFrame:CGRectMake(55, 37+118, 420/2, 420/2)];
    [self.view addSubview:_imgvwMikeAnimation];
    
    // 키워드 문자열 처리
    _lblAanimationKeyword = [[UILabel alloc] initWithFrame:CGRectMake(0, 380, 320, 20)];
    [_lblAanimationKeyword setFont:[UIFont boldSystemFontOfSize:20]];
    [_lblAanimationKeyword setTextColor:[UIColor whiteColor]];
    [_lblAanimationKeyword setBackgroundColor:[UIColor clearColor]];
    [_lblAanimationKeyword setTextAlignment:NSTextAlignmentCenter];
    [_lblAanimationKeyword setText:@""];
    [self.view addSubview:_lblAanimationKeyword];
}

- (void) initComponents_AnimationThread
{
    // 스레드 초기화
    _threadVoiceWaveLevelProcessor = [[NSThread alloc] initWithTarget:self selector:@selector(doWorkVoiceWaveLevelProcess) object:nil];
    
    // 스레드 시작 (해당 스레드는 화면이 종료될때까지 유지되야 한다)
    [_threadVoiceWaveLevelProcessor start];
    
    
    _arrayAnimationKeyword = [[NSMutableArray alloc] init];
    _threadKeywordRenderer = [[NSThread alloc] initWithTarget:self selector:@selector(doWorkRenderKeyword) object:nil];
    [_threadKeywordRenderer start];
}

- (void) initComponents_Device
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 기존 오디오 플레이어 상태체크
    UInt32 otherAudioIsPlaying;
    UInt32 size = sizeof(otherAudioIsPlaying);
    AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &size, &otherAudioIsPlaying);
    
    if (otherAudioIsPlaying && [[MPMusicPlayerController iPodMusicPlayer] playbackState] == MPMusicPlaybackStatePlaying )
    {
        oms.soundState = 1;
        [[MPMusicPlayerController iPodMusicPlayer] pause];
    }
    else if (otherAudioIsPlaying && [[MPMusicPlayerController applicationMusicPlayer] playbackState] == MPMusicPlaybackStatePlaying )
    {
        oms.soundState = 2;
        [[MPMusicPlayerController applicationMusicPlayer] pause];
    }
    else if (otherAudioIsPlaying)
    {
        oms.soundState = 3;
    }
    else
    {
        oms.soundState = 0;
    }
    
    // 오디오 디바이스 초기화
    [self resetDeviceAudioSession];
}

- (void) initComponents_VoiceRecognizer
{
    // 음성 인식 알림 등록
    [self manageNotification:YES];
    
    // 음성체크 상태
    _audioCheck = AUDIOSEARCH_READY;
    
    // 음성 인식 컨트롤 변수 설정
    NSString *serverip;
    NSInteger serverport;
    struct hostent *h = gethostbyname(SERVER_IP);
    if (h && h->h_addr_list[0] != NULL)
        serverip = [NSString stringWithFormat:@"%s", inet_ntoa(*(struct in_addr*)h->h_addr_list[0])];
    else
        serverip = [NSString stringWithFormat:@"%s", SERVER_IP];
    serverport = SERVER_PORT;
    
    // 음성 인식 컨트롤러에 인자들을 넘긴다.
    [[VoiceAssistController sharedVoiceAssist] Stop:nil];
    [[VoiceAssistController sharedVoiceAssist] setGui_ip:serverip];
    [[VoiceAssistController sharedVoiceAssist] setGui_port:serverport];
    [[VoiceAssistController sharedVoiceAssist] setGui_svc:1];
    [[VoiceAssistController sharedVoiceAssist] setGui_reqcontype:1];
}

// ********************


// ============================
// [ 네비게이션 메뉴 - private ]
// ============================

- (void) renderNavigation
{
    // 네비게이션바 뷰생성
    UIView *vwNavigation = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 37)];
    
    // 네비게이션바 배경
    UIImageView *imgvwBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_bg.png"]];
    [vwNavigation addSubview:imgvwBackground];
    [imgvwBackground release];
    
    // 좌측버튼
    UIButton *btnNavi = [[UIButton alloc] initWithFrame:CGRectMake(7, 4, 94/2, 56/2)];
    [btnNavi setImage:[UIImage imageNamed:@"title_bt_before.png"] forState:UIControlStateNormal];
    [btnNavi addTarget:self action:@selector(onNavigationLeftButton:) forControlEvents:UIControlEventTouchUpInside];
    [vwNavigation addSubview:btnNavi];
    [btnNavi release];
    
    // 타이틀
    CGRect rectTitle = CGRectMake(0, 0, 0, 0);
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:rectTitle];
    [lblTitle setFont:[UIFont systemFontOfSize:20]];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setText:NSLocalizedString(@"Title_OllehMap_VoiceSearch", @"")];
    rectTitle.size = [lblTitle.text sizeWithFont:lblTitle.font constrainedToSize:CGSizeMake(FLT_MAX, FLT_MAX) lineBreakMode:lblTitle.lineBreakMode];
    rectTitle.origin.x = (320-rectTitle.size.width)/2;
    rectTitle.origin.y = (37-rectTitle.size.height)/2;
    [lblTitle setFrame:rectTitle];
    
    // 타이틀 쉐도우
    CGRect rectTitleShadow = rectTitle;
    rectTitle.origin.x += 2;
    UILabel *lblTitleShadow = [[UILabel alloc] initWithFrame:rectTitleShadow];
    [lblTitleShadow setFont:[UIFont systemFontOfSize:20]];
    [lblTitleShadow setBackgroundColor:[UIColor clearColor]];
    [lblTitleShadow setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.75]];
    [lblTitleShadow setText:NSLocalizedString(@"Title_OllehMap_VoiceSearch", @"")];
    
    //타이틀 삽입
    [vwNavigation addSubview:lblTitleShadow];
    [vwNavigation addSubview:lblTitle];
    [lblTitle release];
    [lblTitleShadow release];
    
    // 네비게이션바 삽입
    [self.view addSubview:vwNavigation];
    [vwNavigation release];
}

- (void) onNavigationLeftButton :(id)sender
{
    [self closeVoiceSearchView];
}

// ****************************


// ==========================
// [ 디바이스 제어 - private ]
// ==========================

- (void) manageNotification :(BOOL)enable
{
    // 기존에 등록됏을지 모르는 알림 제거부터 한다
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIVoiceAssistConnectCannotNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIVoiceAssistReadyOKNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIVoiceAssistSessionTimeoutNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIVoiceAssistStartRecognizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIVoiceAssistFailedRecognizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIVoiceAssistSucessRecognizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIVoiceAssistFailureNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIVoiceAssistDisconnectNotification object:nil];
    
    //음성 인식 service controller로 부터 서비스 상태 통지를 받기 위해 감시기를 등록한다.
    if (enable)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiConnectCannot:) name:UIVoiceAssistConnectCannotNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiReadyOK:) name:UIVoiceAssistReadyOKNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiSessionTimeout:) name:UIVoiceAssistSessionTimeoutNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiStartRecognize:) name:UIVoiceAssistStartRecognizeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiFailedRecognize:) name:UIVoiceAssistFailedRecognizeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiSuccessRecognize:) name:UIVoiceAssistSucessRecognizeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiFailure:) name:UIVoiceAssistFailureNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiDisconnect:) name:UIVoiceAssistDisconnectNotification object:nil];
    }
}

- (void) resetDeviceAudioSession
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 오디오 초기화
    AudioSessionInitialize(NULL, NULL, NULL, self);
    
    // 카테고리 설정 - 레코딩
    UInt32 category = kAudioSessionCategory_RecordAudio;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory , sizeof(category), &category);
    
    // 세션공유 설정 - 기존플레이어 유지
    UInt32 mixWithOthers;
    if (oms.soundState == 1 || oms.soundState == 2)
    {
        mixWithOthers = 1;
    }
    else
    {
        mixWithOthers = 0;
    }
    AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers,sizeof (mixWithOthers),&mixWithOthers);
    
    UInt32 otherPlaying = 1;
    AudioSessionSetProperty (kAudioSessionProperty_OtherAudioIsPlaying,sizeof (otherPlaying),&otherPlaying);
    
    // 세션 활성화
    AudioSessionSetActive(YES);
}

- (void) resumePreviousPlayer
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    AudioSessionInitialize(NULL, NULL, NULL, self);
    UInt32 category = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory , sizeof(category), &category);
    AudioSessionSetActive(NO);
    
    // 기존 사운드 재생
    if (oms.soundState == 1)
    {
        [[MPMusicPlayerController iPodMusicPlayer] play];
    }
    else if (oms.soundState == 2)
    {
        [[MPMusicPlayerController applicationMusicPlayer] play];
    }
    else if ( oms.soundState == 3 )
    {
    }
}

- (void) startVoiceRecognizer
{
    // 음성 파형 관련 컨트롤 초기화
    _aqBufRef = NULL;
    _audioCheck = AUDIOSEARCH_READY;
    
    // 음성 인식 컨트롤러 시작
    [[VoiceAssistController sharedVoiceAssist] Start:nil];
}

// **************************

// =============================
// [ 알림 콜백 메소드 - private ]
// =============================

-(void)notiConnectCannot:(NSNotification*) event
{
    //[_lblAanimationKeyword setText:@"서버에 연결할수없음."];
    
    _audioCheck = AUDIO_NETWORK_ERROR;
    
    OMNavigationController *nc = [OMNavigationController sharedNavigationController];
    UIViewController *vc = [nc.viewControllers lastObject];
    // 현재화면이 음성검색 화면이어야 동작
    if ( [vc isKindOfClass:[VoiceSearchViewController class]] )
        [OMMessageBox showAlertMessageTwoButtonsWithTitle:@"" message:NSLocalizedString(@"Msg_VoiceSearch_Controller_ServerConnectCannot", @"") target:self firstAction:@selector(closeVoiceSearchView) secondAction:@selector(retryVoiceSearchView) firstButtonLabel:@"확인" secondButtonLabel:nil];
}

-(void)notiReadyOK:(NSNotification*) event
{
    // 음성인식 상태 변경
    _audioCheck = AUDIOSEARCH_RECORDING;
    
    // 음성 버퍼 초기화
    if (_aqBufRef == NULL)
        _aqBufRef = [[avrController sharedAVRController] Queue];
    if (_aqLevelArr)
    {
        free(_aqLevelArr);
        _aqLevelArr = NULL;
    }
    _aqLevelArr = (AudioQueueLevelMeterState*)malloc(sizeof(AudioQueueLevelMeterState));
    memset(_aqLevelArr, 0x00, sizeof(AudioQueueLevelMeterState));
    
    UInt32 val = 11;
    //OSStatus sts = AudioQueueSetProperty(_aqBufRef, kAudioQueueProperty_EnableLevelMetering, &val, sizeof(UInt32));
    AudioQueueSetProperty(_aqBufRef, kAudioQueueProperty_EnableLevelMetering, &val, sizeof(UInt32));
    CAStreamBasicDescription queueFormat;
    UInt32 data_sz = sizeof(queueFormat);
    //sts = AudioQueueGetProperty(_aqBufRef, kAudioQueueProperty_StreamDescription, &queueFormat, &data_sz);
    AudioQueueGetProperty(_aqBufRef, kAudioQueueProperty_StreamDescription, &queueFormat, &data_sz);
    
    //[_lblAanimationKeyword setText:@"음성검색 준비완료"];
}

-(void)notiSessionTimeout:(NSNotification*) event
{
    //[_lblAanimationKeyword setText:@"세션 타임아웃"];
    
    // 음성인식 상태 변경
    _audioCheck = AUDIOSEARCH_FALSE;
    
    OMNavigationController *nc = [OMNavigationController sharedNavigationController];
    UIViewController *vc = [nc.viewControllers lastObject];
    // 현재화면이 음성검색 화면이어야 동작
    if ( [vc isKindOfClass:[VoiceSearchViewController class]] )
        [OMMessageBox showAlertMessageTwoButtonsWithTitle:@"" message:NSLocalizedString(@"Msg_VoiceSearch_Controller_SessionTimeout", @"") target:self firstAction:@selector(closeVoiceSearchView) secondAction:@selector(retryVoiceSearchView) firstButtonLabel:@"확인" secondButtonLabel:@"다시 시도"];
}

-(void)notiStartRecognize:(NSNotification*) event
{
    //[_lblAanimationKeyword setText:@"음성 분석 시작"];
    
    // 이벤트 라벨 변경
    [_lblEventNoti setText:NSLocalizedString(@"Body_VoiceSearch_Recognizing", @"")];
    
    // 음성인식 상태 변경
    _audioCheck = AUDIOSEARCH_PROC;
}

-(void)notiFailedRecognize:(NSNotification*) event
{
    //[_lblAanimationKeyword setText:@"음성 분석 실패"];
    
    // 음성인식 상태 변경
    _audioCheck = AUDIOSEARCH_FALSE;
    
    OMNavigationController *nc = [OMNavigationController sharedNavigationController];
    UIViewController *vc = [nc.viewControllers lastObject];
    // 현재화면이 음성검색 화면이어야 동작
    if ( [vc isKindOfClass:[VoiceSearchViewController class]] )
        [OMMessageBox showAlertMessageTwoButtonsWithTitle:@"" message:NSLocalizedString(@"Msg_VoiceSearch_Controller_FailedRecognize", @"") target:self firstAction:@selector(closeVoiceSearchView) secondAction:@selector(retryVoiceSearchView) firstButtonLabel:@"닫기" secondButtonLabel:@"다시 시도"];
}

-(void)notiSuccessRecognize:(NSNotification*) event
{
    //[_lblAanimationKeyword setText:@"음성 분석 성공"];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 음성인식 상태 변경
    _audioCheck = AUDIOSEARCH_SUCESS;
    
    // 음성인식 키워드 애니메이션 배열 초기화
    [_arrayAnimationKeyword removeAllObjects];
    
    // 음성인식 결과 저장소 초기화
    [oms.voiceSearchArray removeAllObjects];
    
    //인식 결과를 담고 있는 오브젝트
    NSData * data = [[event userInfo] objectForKeyGC:@"szResult"];
    if(data == nil)
    {
        _audioCheck = AUDIOSEARCH_FALSE;
        
        [OMMessageBox showAlertMessageTwoButtonsWithTitle:@"" message:NSLocalizedString(@"Msg_VoiceSearch_Controller_FailedRecognize", @"") target:self firstAction:@selector(closeVoiceSearchView) secondAction:@selector(retryVoiceSearchView) firstButtonLabel:@"닫기" secondButtonLabel:@"다시 시도"];
        return;
    }
    
    //BNF parsing 밑에 주석처리하면 검색안됨 ㅇㅅㅎㄴㅇㄴ
    CSemParser *mpBnfParser = [[[CSemParser alloc] init] autorelease];
    int rst = [mpBnfParser ParseHvoiceRes2:(const char*)[data bytes] DataSize:[data length]];
    int cnt = mpBnfParser.xmlResultData.count;
    NSLog(@"BNF - %d:%d:%@",rst,cnt,mpBnfParser.xmlResultData);
    NSMutableArray* aResults = mpBnfParser.xmlResultData;
    
    //.. 검색 결과가 없습니다.
    if(![aResults count])
    {
        _audioCheck = AUDIOSEARCH_FALSE;
        
        [OMMessageBox showAlertMessageTwoButtonsWithTitle:@"" message:NSLocalizedString(@"Msg_VoiceSearch_Controller_FailedRecognize", @"") target:self firstAction:@selector(closeVoiceSearchView) secondAction:@selector(retryVoiceSearchView) firstButtonLabel:@"닫기" secondButtonLabel:@"다시 시도"];
        return;
    }
    
    
    // 음성 인식 결과 단일/다중 여부를 판단해서 처리한다.
    // nTheBest 가 YES 일때 아마 단일값을 의미하는것 같군..???
    if([[[event userInfo] objectForKeyGC:@"nTheBest"] intValue] == NO)
    {
        // 다중값을 루프문을 돌면서 전부 꺼내오기
        for(int j = 0 ; j < [aResults count] ; j++)
        {
            NSMutableArray* aNBest = [aResults objectAtIndexGC:j];
            NSMutableString* strResult = [NSMutableString string];
            NSDictionary* dic = [aNBest objectAtIndexGC:0];
            
            // [dic 샘플 데이터]
            // "ALTER_01" = EMPTY;
            // "CLASS_01" = NULL;
            // "CONFIDENCE_01" = "100.0";
            // COUNT = 1;
            // "INDEX_01" = 1;
            // "WORD_01" = "\Ubc31\Ub450\Ud14d";
            
            int count = [[dic objectForKeyGC:RESULT_XML_KEY_PRE[KEY_COUNT]] integerValue];
            
            _FOR_(count)
            {
                NSString* strCurKeys  = [NSString stringWithFormat:@"%@_%02i", RESULT_XML_KEY_PRE[KEY_WORD], i + 1];
                [strResult appendFormat:@"%@", [dic objectForKeyGC:strCurKeys]];
            }
            
            [oms.voiceSearchArray addObject:strResult];
        }
        
#ifdef DEBUG
        // 디버그 모드에서만 테스트용 가짜 키워드 추가
        [oms.voiceSearchArray addObject:@"뷀뷁뷁뷀"];
#endif
        
    }
    else
    {
        ///< 단일 정보
        //1-Best 결과일 경우 중 외부 연동을 해야 하는 경우를 판단하는 오브젝트.
        ///< 외부 연동
        //N 베스트 가정하여 수정한 코드
        if([[[event userInfo] objectForKeyGC:@"nInfoEnable"] intValue] == YES)
        {
            for (int j = 0, maxJ = [aResults count] ; j < maxJ ; j++)
            {
                NSMutableString *strResult = [NSMutableString string];
                NSMutableArray *aNBest = [aResults objectAtIndexGC:j];
                NSDictionary *dic = [aNBest objectAtIndexGC:0];
                
                int count = [[dic objectForKeyGC:RESULT_XML_KEY_PRE[KEY_COUNT]] integerValue];
                
                _FOR_(count)
                {
                    NSString *strCurKeys = [NSString stringWithFormat:@"%@_%02i", RESULT_XML_KEY_PRE[KEY_WORD], i + 1];
                    [strResult appendFormat:@"%@", [dic objectForKeyGC:strCurKeys]];
                }
                [oms.voiceSearchArray addObject:strResult];
            }
        }
        else
        {
            NSString * resultString = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:-2147481280];
            NSString * tmpString    = [resultString stringByReplacingOccurrencesOfString:@"euc-kr" withString:@"utf-8"];
            [resultString release];
            
            [oms.voiceSearchArray addObject:tmpString];
        }
    }
    
    // MIK.geun :: 20120628 // 바로 검색으로 넘어가지 않고 키워드 애니메이션 처리를 해준다.
    // 검색 시작
    //[self searchVoiceKeyword];
    if (oms.voiceSearchArray.count > 0)
    {
        // 키워드에 NOISE  값이 들어온 경우 처리..
        NSString *keyword = [oms.voiceSearchArray objectAtIndexGC:0];
        if ( [keyword isEqualToString:@"NOISE"] )
        {
            // 음성인식 상태 변경
            _audioCheck = AUDIOSEARCH_FALSE;
            
            OMNavigationController *nc = [OMNavigationController sharedNavigationController];
            UIViewController *vc = [nc.viewControllers lastObject];
            // 현재화면이 음성검색 화면이어야 동작
            if ( [vc isKindOfClass:[VoiceSearchViewController class]] )
                [OMMessageBox showAlertMessageTwoButtonsWithTitle:@"" message:NSLocalizedString(@"Msg_VoiceSearch_Controller_FailedRecognize", @"") target:self firstAction:@selector(closeVoiceSearchView) secondAction:@selector(retryVoiceSearchView) firstButtonLabel:@"닫기" secondButtonLabel:@"다시 시도"];
            
            return;
        }
        
        _audioCheck = AUDIOSEARCH_SUCESS_ANIMATION_KEYWORD;
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :@"음성인식 결과 처리 중 오류가 발생했습니다. (notiSuccessRecognize)"];
    }
    
}

// 음성인식 라이브러리 초기화 실패
-(void)notiFailure:(NSNotification*) event
{
    [_lblAanimationKeyword setText:@"실패(Failure)"];
    
    // 음성인식 상태 변경
    _audioCheck = AUDIO_INIT_ERROR;
    
    OMNavigationController *nc = [OMNavigationController sharedNavigationController];
    UIViewController *vc = [nc.viewControllers lastObject];
    // 현재화면이 음성검색 화면이어야 동작
    if ( [vc isKindOfClass:[VoiceSearchViewController class]] )
        [OMMessageBox showAlertMessageTwoButtonsWithTitle:@"" message:NSLocalizedString(@"Msg_VoiceSearch_Controller_Failure", @"") target:self firstAction:@selector(closeVoiceSearchView) secondAction:@selector(retryVoiceSearchView) firstButtonLabel:@"닫기" secondButtonLabel:@"다시 시도"];
}

// 음성인식 라이브러리 연결해제
-(void)notiDisconnect:(NSNotification*) event
{
    NSLog(@"음성인식 라이브러리 연결해제");
    
    // 음성 분석중인데 연결이 해제됐을 경우... 큰일인데??
    if (_audioCheck == AUDIOSEARCH_PROC)
    {
        OMNavigationController *nc = [OMNavigationController sharedNavigationController];
        UIViewController *vc = [nc.viewControllers lastObject];
        // 현재화면이 음성검색 화면이어야 동작
        if ( [vc isKindOfClass:[VoiceSearchViewController class]] )
            [OMMessageBox showAlertMessageTwoButtonsWithTitle:@"" message:@"음성분석 중 서버와의 연결이 해제됐습니다." target:self firstAction:@selector(closeVoiceSearchView) secondAction:@selector(retryVoiceSearchView) firstButtonLabel:@"닫기" secondButtonLabel:@"다시 시도"];
    }
}

// *******************


// ===============================
// [ 스레드 콜백 메소드 - private ]
// ===============================

- (void) doWorkVoiceWaveLevelProcess
{
    NSAutoreleasePool*	pool = [[NSAutoreleasePool alloc] init];
    @try
    {
        while ( _threadVoiceWaveLevelProcessor != nil && [_threadVoiceWaveLevelProcessor isCancelled] == NO )
        {
            // 스레드 실행중
            if (_audioCheck == AUDIOSEARCH_RECORDING)
                [self performSelectorOnMainThread:@selector(doWorkVoiceWaveLevelProcessByMainThread) withObject:nil waitUntilDone:YES];
            [NSThread sleepForTimeInterval:0.02];
        }
    }
    @catch (NSException *exception)
    {
#ifdef DEBUG
        [OMMessageBox showAlertMessage:@"doWorkVoiceWaveLevelProcess Exception" :[NSString stringWithFormat:@"%@", exception]];
#endif
    }
    [pool release];
    
}
- (void) doWorkVoiceWaveLevelProcessByMainThread
{
    NSAutoreleasePool*	pool = [[NSAutoreleasePool alloc] init];
    @try
    {
        
        if ( _audioCheck != AUDIOSEARCH_RECORDING ) return;
        
        //6140: 오디오 버퍼에 접근
        if ( _aqBufRef == NULL)_aqBufRef = [[avrController sharedAVRController] Queue];
        
        if(_aqBufRef != NULL)
        {
            // 콜백 애러 카운트 체크
            _audioErrorCount = 0;
            
            UInt32 ioDataSize = sizeof(AudioQueueLevelMeterState);
            
            if (_aqLevelArr != NULL)
            {
                memset(_aqLevelArr, 0x00, sysconf(sizeof(_aqLevelArr)));
                
                //OSStatus tmpSts = AudioQueueGetProperty (_aqBufRef,kAudioQueueProperty_CurrentLevelMeter, _aqLevelArr, &ioDataSize);
                AudioQueueGetProperty (_aqBufRef,kAudioQueueProperty_CurrentLevelMeter, _aqLevelArr, &ioDataSize);
                
                // 음성데이터 파형값 저장 하기
                float average = _aqLevelArr[0].mAveragePower;
                //float peak = _aqLevelArr[0].mPeakPower;
                
                //float sound = log10f((average/peak)*100) * 10 - 10;
                float sound = average * 100;
                
                int animationNumber = sound;
                if (animationNumber < 1) animationNumber = 1;
                if (animationNumber > 11) animationNumber = 11;
                
                NSString *animationImageName = [NSString stringWithFormat:@"voice_ani_%02d.png", animationNumber];
                [_imgvwMikeAnimation setImage:[UIImage imageNamed:animationImageName]];
                
                //NSLog(@"Decibel => sound :%f /  Average : %f / Pea :  %f", sound, average, peak);
            }
            else
            {
                [_imgvwMikeAnimation setImage:[UIImage imageNamed:@"voice_ani_01.png"]];
            }
            
            
        }
        // 오디오 버퍼가 비었을 경우
        else
        {
            // 오디오 검색이 실행중이 아닐 경우
            //if(AUDIOSEARCH_ING != _audiocheck) return;
            
            // 콜백 애러 카운트 체크 50 보다 크면 애러로 판별 애러창을 띄운다.
            if(_audioErrorCount > 50)
            {
                [OMMessageBox showAlertMessageTwoButtonsWithTitle:@"" message:NSLocalizedString(@"Msg_VoiceSearch_Controller_Failure", @"") target:self firstAction:@selector(closeVoiceSearchView) secondAction:@selector(retryVoiceSearchView) firstButtonLabel:@"닫기" secondButtonLabel:@"다시 시도"];
                _audioCheck = AUDIOSEARCH_FALSE;
            }
            else if(_audioErrorCount == 0)
            {
            }
            
            // 콜백 애러 카운트 체크
            _audioErrorCount++;
        }
        
    }
    @catch (NSException *exception)
    {
#ifdef DEBUG
        [OMMessageBox showAlertMessage:@"doWorkVoiceWaveLevelProcess Exception" :[NSString stringWithFormat:@"%@", exception]];
#endif
    }
    [pool release];
    
}


-(void) doWorkRenderKeyword
{
    NSAutoreleasePool*	pool = [[NSAutoreleasePool alloc] init];
    @try
    {
        while (_threadKeywordRenderer != nil && [_threadKeywordRenderer isCancelled] == NO)
        {
            // 음성 분석이 완료되서 문자열 처리하고 있을 동안만 동작하도록 한다.
            if (_audioCheck == AUDIOSEARCH_SUCESS_ANIMATION_KEYWORD )
            {
                NSString *keyword = [[[OllehMapStatus sharedOllehMapStatus] voiceSearchArray] objectAtIndexGC:0];
                
                for (int cnt=1, maxcnt=keyword.length ; cnt<=maxcnt; cnt++)
                {
                    [self performSelectorOnMainThread:@selector(renderKeywordLabel:) withObject:[keyword substringToIndex:cnt] waitUntilDone:YES];
                    [NSThread  sleepForTimeInterval:0.35];
                }
                
                // 인식된 키워드 검색하기
                //[self searchVoiceKeyword];
                [self performSelectorOnMainThread:@selector(searchVoiceKeyword) withObject:nil waitUntilDone:NO];
                
                // 음성인식 상태 되돌리기
                _audioCheck = AUDIOSEARCH_SUCESS;
            }
            [NSThread sleepForTimeInterval:0.1];
        }
    }
    @catch (NSException *exception)
    {
#ifdef DEBUG
        [OMMessageBox showAlertMessage:@"doWorkRenderKeyword Exception" :[NSString stringWithFormat:@"%@", exception]];
#endif
    }
    [pool release];
}

- (void) renderKeywordLabel :(NSString *)keyword
{
    [_lblAanimationKeyword setText:keyword];
}

// *******************************


// ============================
// [ 검색서비스 호출 - private ]
// ============================

- (void) searchVoiceKeyword
{
    [self searchVoiceKeyword:0];
}
- (void) searchVoiceKeyword :(int)voiceSearchIndex
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 현재화면이 음성검색 화면이 아니면 .... 검색API 호출을 하지 말자
    OMNavigationController *nc = [OMNavigationController sharedNavigationController];
    if ( ! [[nc.viewControllers lastObject] isKindOfClass:[VoiceSearchViewController class]] )
    {
        return;
    }
    
    oms.keyword = [oms.voiceSearchArray objectAtIndexGC:voiceSearchIndex];
    [_lblAanimationKeyword setText:oms.keyword];
    
    [_lblEventNoti setText:NSLocalizedString(@"Body_VoiceSearch_Searching", @"")];
    
    // 검색결과 초기화
    [oms resetLocalSearchDictionary:@"Place"];
    [oms resetLocalSearchDictionary:@"Address"];
    [oms resetLocalSearchDictionary:@"PublicBusStation"];
    [oms resetLocalSearchDictionary:@"PublicBusNumber"];
    [oms resetLocalSearchDictionary:@"PublicSubwayStation"];
    
    // ===============================
    // [ 최초 검색어 결과(카운트) 처리 ]
    // ===============================
    // 최초 진입시에는 "장소"만 검색결과를 포함하며, "주소""대중교통"은 결과 카운트만 처리하도록 한다.
    
    // 검색실패 여부 초기화
    _searchFailed = NO;
    
    // A. 대중교통 카운트만 처리하도록
    [[ServerConnector sharedServerConnection] requestSearchPublicBusStation:self action:@selector(didFinishSearchInit:) Name:oms.keyword ViewCnt:15 Page:0];
    [[ServerConnector sharedServerConnection] requestSearchPublicBusNumber:self action:@selector(didFinishSearchInit:) key:oms.keyword startPage:0 indexCount:15];
    [[ServerConnector sharedServerConnection] requestSearchPublicSubwayStation:self action:@selector(didFinishSearchInit:) Name:oms.keyword];
    
    // B. 장소/주소 검색 실행 (**단, 장소만 실제 데이터를 받도록 설정)
    Coord searchCrd = [MapContainer sharedMapContainer_Main].kmap.centerCoordinate;
    [[ServerConnector sharedServerConnection] requestSearchPlaceAndAddress:self action:@selector(didFinishSearchInit:) key:oms.keyword mapX:searchCrd.x mapY:searchCrd.y s:@"an" sr:@"RANK" p_startPage:0 a_startPage:0 n_startPage:0 indexCount:0 option:1];
    [[ServerConnector sharedServerConnection] requestSearchPlaceAndAddress:self action:@selector(didFinishSearchInit:) key:oms.keyword mapX:searchCrd.x mapY:searchCrd.y s:@"p" sr:@"RANK" p_startPage:0 a_startPage:0 n_startPage:0 indexCount:15 option:1];
}

- (void) didFinishSearchInit :(id)request
{
    // 검색결과를 받아서 처리한다.
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        [_lockSearchInit lock];
        
        @try
        {
            OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
            
            // 검색결과 카운트 계산
            int countPlace, countAddress, countPublicBs, countPublicBn, countPublicSs, countPublic, countTotal;
            countPlace =  [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountPlace"] intValue];
            countAddress = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountAddress"] intValue];
            countPublicBs = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountPublicBusStation"] intValue];
            countPublicBn = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountPublicBusNumber"] intValue];
            countPublicSs = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountPublicSubwayStation"] intValue];
            countPublic = countPublicBs + countPublicBn + countPublicSs;
            countTotal = countPlace + countAddress + countPublic;
            
            if (countPlace >= 0 && countAddress >= 0 && countPublicBs >= 0 && countPublicBn >= 0 && countPublicSs >= 0 && countTotal > 0)
            {
                // 모든 검색이 완료된 상황, 결과뷰를 띄우도록 한다.
                NSLog(@"검색완료 (%@)", [request userString]);
                NSLog(@"장소 %d, 주소 %d, 버스정류장 %d, 버스번호 %d, 지하철역 %d", countPlace, countAddress, countPublicBs, countPublicBn, countPublicSs);
                
                // 혹시 모를 중복 검색완료 들어올 경우 대비해서 최상위뷰컨트롤러에 하나의 검색결과뷰만 들어가게ㅐ 처리
                OMNavigationController *nc = [OMNavigationController sharedNavigationController];
                if ( ![[nc.viewControllers objectAtIndexGC:nc.viewControllers.count-1] isKindOfClass:[SearchResultViewController2 class]])
                {
                    SearchResultViewController2 *srvc = [[SearchResultViewController2 alloc] initWithNibName:@"SearchResultViewController2" bundle:nil];
                    
                    if (_currentSearchTargetType == SearchTargetType_VOICESTART)
                    {
                        [srvc setCurrentSearchTargetType:SearchTargetType_VOICESTART];
                    }
                    else if (_currentSearchTargetType == SearchTargetType_VOICEVISIT)
                    {
                        [srvc setCurrentSearchTargetType:SearchTargetType_VOICEVISIT];
                    }
                    else if (_currentSearchTargetType == SearchTargetType_VOICEDEST)
                    {
                        [srvc setCurrentSearchTargetType:SearchTargetType_VOICEDEST];
                    }
                    else if(_currentSearchTargetType == SearchTargetType_VOICENONE)
                    {
                        [srvc setCurrentSearchTargetType:SearchTargetType_VOICENONE];
                    }
                    
                    
                    [srvc setSearchKeyword:oms.keyword];
                    
                    [nc pushViewController:srvc animated:NO];
                    [srvc release];
                }
            }
            else if (countPlace >= 0 && countAddress >= 0 && countPublicBs >= 0 && countPublicBn >= 0 && countPublicSs >= 0)
            {
                // 모든 검색이 완료된 상황, 그러나 결과가 하나도 없을 경우
                NSLog(@"검색결과 없음 (%@)", [request userString]);
                [OMMessageBox showAlertMessageTwoButtonsWithTitle:@"" message:NSLocalizedString(@"Msg_SearchFailed", @"") target:self firstAction:@selector(closeVoiceSearchView) secondAction:@selector(retryVoiceSearchView) firstButtonLabel:@"닫기" secondButtonLabel:@"다시 시도"];
                
            }
            else
            {
                // 검색중인 상황.. (모든 카운트가 0보다 같거나 커야함 .. 검색이전값이 -1인상태..)
                NSLog(@"검색중...(%@)", [request userString]);
                NSLog(@"장소 %d, 주소 %d, 버스정류장 %d, 버스번호 %d, 지하철역 %d", countPlace, countAddress, countPublicBs, countPublicBn, countPublicSs);
            }
        }
        @catch (NSException *ex)
        {
            NSLog(@"didFinishSearchInit 메소드 예외발생 : %@", [ex reason]);
        }
        @finally
        {
            [_lockSearchInit unlock];
        }
        
    }
    else
    {
        [_lockSearchInit lock];
        
        @try
        {
            if (_searchFailed == NO)
            {
                OMNavigationController *nc = [OMNavigationController sharedNavigationController];
                UIViewController *vc = [nc.viewControllers lastObject];
                // 현재화면이 음성검색 화면이어야 동작
                if ( [vc isKindOfClass:[VoiceSearchViewController class]] )
                    [OMMessageBox showAlertMessageTwoButtonsWithTitle:@"" message:NSLocalizedString(@"Msg_SearchFailedWithException", @"") target:self firstAction:@selector(closeVoiceSearchView) secondAction:@selector(retryVoiceSearchView) firstButtonLabel:@"닫기" secondButtonLabel:@"다시 시도"];
                _searchFailed = YES;
            }
        }
        @catch (NSException *exception)
        {
        }
        @finally
        {
            [_lockSearchInit unlock];
        }
    }
}

// ****************************


// =========================
// [ 음성검색 화면닫기 제어 ]
// =========================

- (void) closeVoiceSearchView
{
    [self manageNotification:NO];
    [[VoiceAssistController sharedVoiceAssist] Stop:nil];
    
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}

- (void) retryVoiceSearchView
{
    // 이벤트 라벨 변경
    [_lblEventNoti setText:NSLocalizedString(@"Body_VoiceSearch_Request", @"")];
    [_lblAanimationKeyword setText:@""];
    
    // 스레드가 종료된 경우 초기화
    if (_threadVoiceWaveLevelProcessor == nil)
        [self initComponents_AnimationThread];
    
    // 알림 메세지 재등록
    [self manageNotification:YES];
    
    // 디바이스 오디오 세션 초기화
    [self resetDeviceAudioSession];
    
    // 음성 버퍼 초기화 **버퍼 초기화 해주지 않으면 재시도이후로 파형 레벨값이 들어오지 않음.
    _aqBufRef = NULL;
    if (_aqLevelArr)
    {
        free(_aqLevelArr);
        _aqLevelArr = NULL;
    }
    
    // 음성인식 상태 변경
    _audioCheck = AUDIOSEARCH_READY;
    
    // 음성인식 라이브러리 시작
    [[VoiceAssistController sharedVoiceAssist] Start:nil];
    
}

// *************************


// ==================
// [ 검색서비스 호출 ]
// ==================

- (void) searchVoiceKeywordFromExtern :(int)voiceSearchIndex
{
    [self searchVoiceKeyword:voiceSearchIndex];
}

// ******************

@end
