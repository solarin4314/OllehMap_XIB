//
//  ServerRequester.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 5. 15..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "ServerRequester.h"

@implementation ServerRequester

@synthesize userInt = _userInt;
@synthesize userInt2 = _userInt2;
@synthesize userString = _userString;
@synthesize userObject =_userObject;
@synthesize finishCode = _finishCode;
@synthesize data = _data;
@synthesize errorInfo = _errorInfo;

- (void) useIndicator:(BOOL)use
{
    _useIndicator = use;
}
- (void) useErrorNotify:(BOOL)use
{
    _useErrorNotify = use;
}

- (ServerRequester *) init
{
    self = [super init];
    
    if ( self )
    {
    
    _connection = nil;
    _data = [[NSMutableData alloc] init];
    
    // 인디케이터는 기본적으로 사용.. 
    _useIndicator = YES;
    // 에러 메세지 알림은 기본적을 사용..
    _useErrorNotify = YES;
    _useErrorNotify = NO;
    
    // UI콜백함수용 초기화
    _finishOuterTarget = nil;

    _errorInfo = nil;
        _userString = nil;
        _userObject = nil;
  
    }
    return self;
}

- (void) dealloc
{
   
    [_connection release]; 
    _connection = nil;
    [_data release];  
    _data = nil;
    
    [_userString release];
    _userString = nil;
    [_userObject release];
    _userObject = nil;
    
    [_errorInfo release];
    _errorInfo = nil;
    
#ifdef DEBUG_X
    NSLog(@"finishOUterTargetr RetainCount ; %d", [_finishOuterTarget retainCount]);
    if ([_finishOuterTarget retainCount] == 1) [OMMessageBox showAlertMessage:@"원래는 죽었겠지??" :@"메모리 직접 관리이전에는 UI Callback Object가 릴리즈되어 BadAccess 발생하던 원인... "];
#endif
    [_finishOuterTarget release];
    _finishOuterTarget = nil;
    
    [super dealloc];
}

// 각 콜백함수 등록
- (void)addFinishTarget:(id)target action:(SEL)action
{
	_finishTarget = target;
	_finishAction = action;
}
- (void)addFinishOuterTarget:(id)target action:(SEL)action
{
	//_finishOuterTarget = target;
	//_finishOuterAction = action;
    _finishOuterTarget = target;
    [_finishOuterTarget retain];
    _finishOuterAction = action;
}

// 서버에 요청
- (void) sendRequest { [self sendRequest:OMSR_TIMEOUT_INTERVAL]; }
- (void) sendRequest:(NSTimeInterval)second
{
    // 연결상태 코드를 - 진행중 - 으로 설정
	_finishCode = OMSRFinishCode_Progress;
    _responseCode = OMSRResponseCode_None;
    
    // 타임아웃 설정
    [self setTimeoutInterval:second];
    
    // Request 캐시정책
    [self setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    
    // 네트워크 접속
    if (_connection != nil) {[_connection release]; _connection = nil;}
    _connection = [[NSURLConnection alloc] initWithRequest:self delegate:self startImmediately:YES];
    
    if (_connection) 
    {
        //NSLog(@"ServerRequest (sendRequest) success. [%@]", [NSDate date]);
        
    } 
    else 
    {
        //NSLog(@"ServerRequest (sendRequest) failed. [%@]", [NSDate date]);
    }
    
    // 인디케이터 시작
    if (_useIndicator)
        [[OMIndicator sharedIndicator] startAnimating];
    // 아니면 상단 스테이터스바에서만 네트워크 처리
    else
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
}

// 서버 요청 취소 
- (void) cancel
{    // 커넥션 제거
    if (_connection)
    {
        [_connection cancel];
        [_connection release];
        _connection = nil;
    }
}


// 네트워크 요청시 데이터를 받은 경우 실행
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{	
	[_data appendData:data];
}

// 네트워크 요청시 응답을 받은 경우 실행
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // 응답받음, 데이터수신중
    _responseCode = OMSRResponseCode_StartRecvData;
}

// 네워워크 요청에 대한 모든 데이터를 수신한 경우 실행
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // 데이터수신 완료
    _responseCode = OMSRResponseCode_Completed;
    
    // 인디케이터 비활성화 
    if (_useIndicator)
        [[OMIndicator sharedIndicator] stopAnimating];
    else
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // 상태코드 완료로 전환
	_finishCode = OMSRFinishCode_Completed;
    
    [self cancel];
	
    // 파싱콜백 실행
    if ([_finishTarget respondsToSelector:_finishAction])
        [_finishTarget performSelector:_finishAction withObject:self];
    
    // UI콜백 실행 - 단 현재화면과 일치하는지 확인 후 진행한다.     
    if ([_finishOuterTarget respondsToSelector:_finishOuterAction])
        [_finishOuterTarget performSelector:_finishOuterAction withObject:self];
}

// 네트워크 요층에 의한 데이터 수신중 오류가 발생했을 경우 실행됨
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (_responseCode == OMSRResponseCode_None) _responseCode = OMSRResponseCode_Error;
    
    if (_useIndicator)
        [[OMIndicator sharedIndicator] stopAnimating];
    else
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    
    // 오류메세지 출력
    NSString *strErrorTitle, *strErrorMessage;    
    strErrorTitle = [NSString stringWithFormat:@"%@", error.localizedDescription];
    switch (error.code) 
    {
        case -1001:
            strErrorMessage = [NSString stringWithFormat:@"서버로부터 응답이 없어서 중단되었습니다. 잠시후 이용해주세요."];
            break;
            
        default:
            strErrorMessage = [NSString stringWithFormat:@"네트워크 오류로 인해 중단되었습니다. 잠시후 이용해주세요."];
            break;
    }
    //if (_useErrorNotify) [OMMessageBox showAlertMessage:@"" :strErrorMessage];
    if (_useErrorNotify) [OMMessageBox showAlertMessage:@"" :[NSString stringWithFormat:@"%@\n%@", strErrorTitle, strErrorMessage]];
    NSLog(@"%@", strErrorMessage);
    
    // 오류정보 리턴
    self.errorInfo = error;
    
    // 상태코드 오류로 전환
    _finishCode = OMSRFinishCode_Error;
    
    [self cancel];
    
    
    // 파싱콜백 실행
    if ([_finishTarget respondsToSelector:_finishAction])
        [_finishTarget performSelector:_finishAction withObject:self];
    
    // UI콜백 실행 - 단 현재화면과 일치하는지 확인 후 진행한다.     
    if ([_finishOuterTarget respondsToSelector:_finishOuterAction])
        [_finishOuterTarget performSelector:_finishOuterAction withObject:self];
}

// https를 이용한 서버측 비공인 인증처리
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
	{		
		[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
	}	
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

@end
