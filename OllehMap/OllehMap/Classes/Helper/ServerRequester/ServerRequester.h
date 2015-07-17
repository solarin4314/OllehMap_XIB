//
//  ServerRequester.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 5. 15..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OMIndicator.h"
#import "OMMessageBox.h"
#import "OMNavigationController.h"

// 서버 연결상태 
typedef enum
{
    OMSRFinishCode_Progress = 0, OMSRFinishCode_Completed = 1, OMSRFinishCode_Error = 2 , OMSRFinishCode_Error_Parser = 3
} OMSRFinishCode;
// 서버 요청 수신 상태
typedef enum
{
    OMSRResponseCode_None = 0, 
    OMSRResponseCode_StartRecvData = 1, OMSRResponseCode_Completed = 2,
    OMSRResponseCode_Error = -1    
} OMSRResponseCode;

#define OMSR_TIMEOUT_INTERVAL 5

@interface ServerRequester : NSMutableURLRequest <NSURLConnectionDataDelegate>
{
    // 네트워크 커넥션
    NSURLConnection *_connection;
    // 응답컨테츠 보관용 데이터
    NSMutableData *_data;
    // 데이터 정보
    NSMutableDictionary *_resDic;
    
    // Request 구분자 (ServerConnector 에서 넘겨줌)
    int _userInt;
    int _userInt2;
    NSString *_userString;
    NSObject *_userObject;
    
    // 인디케이터 사용여부
    BOOL _useIndicator;
    // 오류발생시 메세지 알림여부
    BOOL _useErrorNotify;
    
    // 연결종료 상태코드 
    OMSRFinishCode _finishCode;
    // 요청에 대한 데이터 수신 상태코드
    OMSRResponseCode _responseCode;
    
    // 네트워크 오류 정보
    NSError *_errorInfo;
    
    // Request 콜백처리 (ServerConnector 내부 - 정보처리)
    id _finishTarget;
    SEL _finishAction;
    // Request 콜백처리 (ServerConnector 외부 - UI처리)
    id _finishOuterTarget;
    SEL _finishOuterAction;    
}

@property (nonatomic, assign) int userInt;
@property (nonatomic, assign) int userInt2;
@property (nonatomic, retain) NSString *userString;
@property (nonatomic, retain) NSObject *userObject;
@property (nonatomic, assign) OMSRFinishCode finishCode;
@property (nonatomic, readonly) NSMutableData *data;
@property (nonatomic, retain) NSError *errorInfo;

- (void) useIndicator :(BOOL)use;
- (void) useErrorNotify :(BOOL)use;

- (void) addFinishTarget:(id)target action:(SEL)action;
- (void) addFinishOuterTarget:(id)target action:(SEL)action;
- (void) sendRequest :(NSTimeInterval)second;
- (void) sendRequest;
- (void) cancel; 
@end


