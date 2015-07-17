//
//  VoiceSearchViewController.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 6. 26..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioQueue.h>
#import <AVFoundation/AVAudioSession.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioRecorder.h>

#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#import <QuartzCore/QuartzCore.h>

#import "OllehMapStatus.h"
#import "OMIndicator.h"
#import "OMMessageBox.h"
#import "OMNavigationController.h"
#import "MapContainer.h"
#import "SearchViewController.h"

#import "SearchViewController.h"
#import "CSemParser.h"

//iPhone5
#import "uiviewcontroller+is4inch.h"

// 음성검색 서버
#ifdef DEBUG
#define SERVER_IP "14.63.242.177"
#else
#define SERVER_IP "speechmap.ktgis.com"
#endif

// 포트
#define SERVER_PORT         80
#define  _FOR_(CTN)         for (int i=0; i<CTN; i++)


typedef enum{
    AUDIOSEARCH_READY = 0,
    AUDIOSEARCH_RECORDING,
    AUDIOSEARCH_PROC,
    AUDIOSEARCH_SUCESS,
    AUDIOSEARCH_SUCESS_ANIMATION_KEYWORD,
    AUDIOSEARCH_FALSE,
    AUDIO_INIT_ERROR,
    AUDIO_NETWORK_ERROR
}AudioSearchCheck;


@interface VoiceSearchViewController : UIViewController<MPMediaPickerControllerDelegate, AVAudioSessionDelegate, AVAudioPlayerDelegate, UIApplicationDelegate>
{
    
    // 마이크 애니메이션 이미지뷰
    UIImageView *_imgvwMikeAnimation;
    
    // 음성 파형 처리 스레드
    NSThread *_threadVoiceWaveLevelProcessor;
    
    // 음원 파형 레벨
    AudioQueueLevelMeterState *_aqLevelArr;
    
    // 음원 Queue데이터
    AudioQueueRef _aqBufRef;
    
    // 오디오 에러 카운트
    NSInteger _audioErrorCount;
    
    // 음성인식 상태
    AudioSearchCheck _audioCheck;
    
    // 음성 인식 후 키워드 렌더링 스레드
    NSThread *_threadKeywordRenderer;
    
    // 음성 인식 후 키워드 렌더링에 사용할 배열
    NSMutableArray *_arrayAnimationKeyword;
    
    // 실제 검색 실패여부
    BOOL _searchFailed;
    
    // 실제 검색 결과대기용 락
    NSLock *_lockSearchInit;
    
    // 키워드 렌더링 라벨
    UILabel *_lblAanimationKeyword;
    
    // 이벤트 알림 라벨
    UILabel *_lblEventNoti;
    
    // 검색대상 (출발/도착/경유)에 대한 내부 플래그 (전역 oms는 화면 전환간 변경될수있음)
    int _currentSearchTargetType;
    
}

@property (nonatomic, assign) int currentSearchTargetType;

// =========================
// [ 음성검색 화면닫기 제어 ]
// =========================
- (void) closeVoiceSearchView;
- (void) retryVoiceSearchView;
// *************************

// ==================
// [ 검색서비스 호출 ]
// ==================
- (void) searchVoiceKeywordFromExtern :(int)voiceSearchIndex;
// ******************
@end
