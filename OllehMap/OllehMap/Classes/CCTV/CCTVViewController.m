//
//  CCTVViewController.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 9. 18..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioSession.h>
#import <AVFoundation/AVAudioSession.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioRecorder.h>


#import "CCTVViewController.h"

#import "OMNavigationController.h"
#import "OllehMapStatus.h"
#import "OMMessageBox.h"

#import "DbHelper.h"
#import "FavoriteViewController.h"

#import "NSString+AESCrypt.h"

@interface CCTVViewController ()

- (void) initComponentsMain;

- (void) renderNavigation;

@end

@implementation CCTVViewController

@synthesize player = _player;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        _info = [[NSMutableDictionary alloc] init];
        _player = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/cctv_detail"];
    
    // 백그라운드 진입 노티피케이션 등록
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self initComponentsMain];
}

- (void) didEnterBackground :(id)sender
{
    // 백그라운드 진입 노티피케이션 해제
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    // 창닫기
    //[[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
    [self.player.moviePlayer stop];
}
- (void) willEnterForeground :(id)sender
{
    [self.player.moviePlayer play];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    // 백그라운드 진입 노티피케이션 해제
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 모든 맵뷰에는 기본 UINavigationViewController를 숨김처리해야한다.
    [[OMNavigationController sharedNavigationController] setNavigationBarHidden:YES];
}

- (void) dealloc
{
    [_info release]; _info = nil;
    
    // 플레리어 해제
    [_player release]; _player = nil;
    
    [super dealloc];
}


- (void) initComponentsMain
{
    // 네비게이션바 렌더링
    [self renderNavigation];
}

- (void) renderNavigation
{
    // 네비게이션 뷰 생성
    UIView *vwNavigation = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 37)];
    
    // 배경 이미지
    UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_bg.png"]];
    [vwNavigation addSubview:imgvwBack];
    [imgvwBack release];
    
    // 버튼
    UIButton *btnPrev = [[UIButton alloc] initWithFrame:CGRectMake(7, 4, 47, 28)];
    [btnPrev setImage:[UIImage imageNamed:@"title_btn_close.png"] forState:UIControlStateNormal];
    [btnPrev addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    [vwNavigation addSubview:btnPrev];
    [btnPrev release];
    
    // 타이틀 그림자
    UILabel *lblTitleShadow = [[UILabel alloc] initWithFrame:CGRectMake(61, (37-20)/2+2, 198, 20)];
    [lblTitleShadow setFont:[UIFont systemFontOfSize:20]];
    [lblTitleShadow setTextColor:convertHexToDecimalRGBA(@"00", @"00", @"00", 0.75f)];
    [lblTitleShadow setBackgroundColor:[UIColor clearColor]];
    [lblTitleShadow setTextAlignment:NSTextAlignmentCenter];
    [lblTitleShadow setText:@"CCTV"];
    [vwNavigation addSubview:lblTitleShadow];
    [lblTitleShadow release];
    
    // 타이틀
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(61, (37-20)/2, 198, 20)];
    [lblTitle setFont:[UIFont systemFontOfSize:20]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setText:@"CCTV"];
    [vwNavigation addSubview:lblTitle];
    [lblTitle release];
    
    // 네비게이션 뷰 삽입
    [self.view addSubview:vwNavigation];
    [vwNavigation release];
}

- (void) onClose :(id)sender
{
    // 창닫기
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}

- (void) addFavorite :(id)sender
{
    // 즐겨찾기 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail/favorite"];
    // CCTV 이름 조합
    NSString *cctvName = nil;
    if ( [stringValueOfDictionary(_info, @"direction") isEqualToString:@""] )
    {
        cctvName = stringValueOfDictionary(_info, @"name");
    }
    else
    {
        cctvName = [NSString stringWithFormat:@"%@(%@)", stringValueOfDictionary(_info, @"name"), stringValueOfDictionary(_info, @"direction")];
    }
    // 즐겨찾기 추가
    DbHelper *dh = [[DbHelper alloc] init];
    NSMutableDictionary *fdic = [OMDatabaseConverter makeFavoriteDictionary:-1 sortOrder:-1 category:Favorite_Category_Local title1:cctvName title2:@"교통 > CCTV" title3:@"" iconType:Favorite_IconType_CCTV coord1x:[numberValueOfDiction(_info, @"x") doubleValue] coord1y:[numberValueOfDiction(_info, @"y") doubleValue] coord2x:0 coord2y:0 coord3x:0 coord3y:0 detailType:@"CCTV" detailID:stringValueOfDictionary(_info, @"id") shapeType:@"" fcNm:@"" idBgm:@""];
    [dh addFavorite:fdic];
    [dh release];
}

- (void) showCCTV:(NSDictionary *)info
{
    //[OMMessageBox showAlertMessage:@"" :[NSString stringWithFormat:@"%@", info]];
    
    // 즐겨찾기 및 내부 용도로 info 저장
    for (NSString *key in [info allKeys])
    {
        [_info setObject:[info objectForKey:key] forKey:key];
    }
    
    // URL 생성하기
    
    // TimeStamp
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyyMMddKKmmss"];
    NSString *cctv_TimeStamp = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    // 네트워크망 : 3G = W, Wifi = L
    NSString *cctv_NetworkType = @"W";
    if ( [OllehMapStatus sharedOllehMapStatus].getNetworkStatus == OMReachabilityStatus_connected_WiFi )
        cctv_NetworkType = @"L";
    
    NSString *cctv_DeviceName = [[OllehMapStatus sharedOllehMapStatus] getDeviceModel];
    // , 문자열은제거하자.
    cctv_DeviceName = [cctv_DeviceName stringByReplacingOccurrencesOfString:@"," withString:@"."];
    
    NSString *deviceVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    // CCTV 정보호출을 위한 속성 조합
    NSString *cctv_UrlAttribute = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@"
                                   , cctv_TimeStamp
                                   //, @"2", @"00000000000"
                                   , @"0", @"ollehmapuser"
                                   //, @"iPhone 4G"
                                   , cctv_DeviceName
                                   , cctv_NetworkType
                                   , @"0"
                                   //, @"2.0.0"
                                   , deviceVersion
                                   , @"OllehMap"
                                   ];
     
    // 속성 암호화
    cctv_UrlAttribute = [cctv_UrlAttribute AES128EncryptWithKey:[NSString stringWithFormat:@"K-%@-T", @"1234567990ab"]];
    
    // CCTV URL 조합
    NSString *cctv_Url =[NSString stringWithFormat:@"%@?attr=%@&mac=%@"
                         , stringValueOfDictionary(info, @"streaming_url")
                         , cctv_UrlAttribute
                         , @"12-34-56-79-90-ab"
                         ];
    //cctv_Url = [cctv_Url stringByReplacingOccurrencesOfString:@"14.63.237.22" withString:@"14.63.244.62"];
    
    // ====================
    // [ 렌더링 시작 ]
    // ====================
    
    // 배경 통일
    [self.view setBackgroundColor:convertHexToDecimalRGBA(@"27", @"26", @"26", 1.0)];
    
    // 타이틀 박스
    UIView *cctvNameBox = [[UIView alloc] initWithFrame:CGRectMake(0, 37, 320, 58)];
    [cctvNameBox setBackgroundColor:convertHexToDecimalRGBA(@"D9", @"F4", @"FF", 1.0)];
    // MIK.geun :: 20121008 // 도로-지점명 순서교체
    // 타이틀 - 도로명
    UILabel *cctvRoadNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 11, 300, 17)];
    [cctvRoadNameLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [cctvRoadNameLabel setTextColor:[UIColor blackColor]];
    [cctvRoadNameLabel setBackgroundColor:[UIColor clearColor]];
    [cctvRoadNameLabel setText:stringValueOfDictionary(info, @"name")];
    [cctvNameBox addSubview:cctvRoadNameLabel];
    [cctvRoadNameLabel release];
    // 타이틀 - 지점명
    UILabel *cctvDeviceNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 33, 300, 13)];
    [cctvDeviceNameLabel setFont:[UIFont systemFontOfSize:13]];
    [cctvDeviceNameLabel setTextColor:[UIColor blackColor]];
    [cctvDeviceNameLabel setBackgroundColor:[UIColor clearColor]];
    [cctvDeviceNameLabel setText:stringValueOfDictionary(info, @"lane")];
    [cctvNameBox addSubview:cctvDeviceNameLabel];
    [cctvDeviceNameLabel release];
    // 타이틀 박스 삽입
    [self.view addSubview:cctvNameBox];
    // 타이틀 박스 해제
    [cctvNameBox release];
    
    // 방향 박스
    NSString *direction = stringValueOfDictionary(info, @"direction");
    if ( direction.length > 0 )
    {
        UIView *cctvDirectionBox = [[UIView alloc] initWithFrame:CGRectMake(0, 37+58, 320, 32)];
        // 방향
        UILabel *cctvDirectionLabel  = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 12)];
        [cctvDirectionLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [cctvDirectionLabel setTextColor:[UIColor whiteColor]];
        [cctvDirectionLabel setBackgroundColor:[UIColor clearColor]];
        [cctvDirectionLabel setText:[NSString stringWithFormat:@"(%@)",direction ]];
        [cctvDirectionBox addSubview:cctvDirectionLabel];
        [cctvDirectionLabel release];
        // 방향 박스 삽입
        [self.view addSubview:cctvDirectionBox];
        // 방향 박스 해제
        [cctvDirectionBox release];
    }
    
    // 영상플레이어 박스
    UIView *cctvVideoPlayerBox = [[UIView alloc] initWithFrame:CGRectMake(0, 37+58+32, 320, 240)];
    {
        // 오디오 초기화
        AudioSessionInitialize(NULL, NULL, NULL, self);
        // 카테고리 설정 - 레코딩
        UInt32 category = kAudioSessionCategory_AudioProcessing;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory , sizeof(category), &category);
        // 세션공유 설정 - 기존플레이어 유지
        UInt32 otherPlaying = 1;
        AudioSessionSetProperty (kAudioSessionProperty_OtherAudioIsPlaying,sizeof (otherPlaying),&otherPlaying);
        // 세션 활성화
        AudioSessionSetActive(YES);
    }
    // 영상플레이어
    
    MPMoviePlayerViewController *tempPlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:@""]];
	self.player = tempPlayer;
    [tempPlayer release];
	self.player.moviePlayer.shouldAutoplay = YES;
	self.player.moviePlayer.repeatMode = YES;
	self.player.view.frame = CGRectMake(0, 0, 320, 240);
	self.player.view.userInteractionEnabled  = NO;
	self.player.moviePlayer.controlStyle = MPMovieControlStyleNone;
	[self.player.moviePlayer setFullscreen:NO animated:NO];
    [cctvVideoPlayerBox addSubview:self.player.view];
    [self.player.moviePlayer stop];
    [self.player.moviePlayer setContentURL:[NSURL URLWithString:cctv_Url]];
    [self.player.moviePlayer play];
    // 영상플레이어 박스 삽입
    [self.view addSubview:cctvVideoPlayerBox];
    // 영상플레이어 박스 해제
    [cctvVideoPlayerBox release];
    
    // 정보제공처 박스
    UIView *cctvInfoOfferBox = [[UIView alloc] initWithFrame:CGRectMake(0, 37+58+32+240, 320, 56)];
    [cctvInfoOfferBox setBackgroundColor:convertHexToDecimalRGBA(@"27", @"26", @"26", 1.0)];
    [cctvInfoOfferBox setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    // 정보제공처 - 제공처
    UILabel *cctvInfoOfferLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 300, 11)];
    [cctvInfoOfferLabel setFont:[UIFont boldSystemFontOfSize:11]];
    [cctvInfoOfferLabel setTextColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f)];
    [cctvInfoOfferLabel setBackgroundColor:[UIColor clearColor]];
    [cctvInfoOfferLabel setText:[NSString stringWithFormat:@"%@ 제공", stringValueOfDictionary(info, @"offer_name")]];
    [cctvInfoOfferBox addSubview:cctvInfoOfferLabel];
    [cctvInfoOfferLabel release];
    // 정보제공처 - 경고
    UILabel *cctvInfoCaution = [[UILabel alloc] initWithFrame:CGRectMake(10, 15+11+4, 300, 11)];
    [cctvInfoCaution setFont:[UIFont systemFontOfSize:11]];
    [cctvInfoCaution setTextColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f)];
    [cctvInfoCaution setBackgroundColor:[UIColor clearColor]];
    [cctvInfoCaution setText:@"실제 상황과 5~10분 차이가 날수 있습니다."];
    [cctvInfoOfferBox addSubview:cctvInfoCaution];
    [cctvInfoCaution release];
    // 정보제공처 박스 삽입
    [self.view addSubview:cctvInfoOfferBox];
    // 정보제공처 박스 해제
    [cctvInfoOfferBox release];
    
    // 즐겨찾기
    UIButton *cctvAddFavoriteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 37+58+32+240+56, 320, 37)];
    [cctvAddFavoriteButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [cctvAddFavoriteButton setImage:[UIImage imageNamed:@"info_btn_hotlist_01.png"] forState:UIControlStateNormal];
    [cctvAddFavoriteButton addTarget:self action:@selector(addFavorite:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cctvAddFavoriteButton];
    [cctvAddFavoriteButton release];
    
    
}

@end
