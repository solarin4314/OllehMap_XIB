//
//  ServerConnector.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 5. 15..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#include <sys/sysctl.h>
#import "ServerConnector.h"
#import "ServerRequester.h"
#import "OllehMapStatus.h"
#import "JSON.h"
#import "CommonGWXmlParser.h"
#import "SearchViewController.h"

// 파일 hash 체크를 위한 준비운동..
// Standard library
#include <stdint.h>
#include <stdio.h>
// Core Foundation
#include <CoreFoundation/CoreFoundation.h>
// Cryptography
#include <CommonCrypto/CommonDigest.h>
// In bytes
#define FileHashDefaultChunkSizeForReadingData 4096

// Function
CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath, size_t chunkSizeForReadingData)
{
    
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) goto done;
    
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData)
    {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream, (UInt8 *)buffer, (CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0)
        {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject, (const void *)buffer, (CC_LONG)readBytesCount);
    }
    
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault, (const char *)hash, kCFStringEncodingUTF8);
    
done:
    
    if (readStream)
    {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL)
    {
        CFRelease(fileURL);
    }
    return result;
}



// UrlEncoding을 위한 확장함수 등록
@interface NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end
@implementation NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding
{
    NSString *urlString;
    
	urlString = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                    CFStringConvertNSStringEncodingToEncoding(encoding));
    [urlString autorelease];
    return urlString;
}
@end

@interface generalDic : NSObject
{
    NSString *_testId;
    NSString *_testName;
    NSString *_testX;
    NSString *_testY;
}

@property (retain, nonatomic) NSString *testId;
@property (retain, nonatomic) NSString *testName;
@property (retain, nonatomic) NSString *testX;
@property (retain, nonatomic) NSString *testY;

- (id)initAttribute:(NSDictionary *)dic;
@end

@implementation generalDic

- (id) initAttribute:(NSDictionary *)dic;
{
    if(self == [super init])
    {
        self.testId = dic[@"ORG_DB_ID"];
        self.testName = dic[@"NAME"];
        self.testX = dic[@"X"];
        self.testY = dic[@"Y"];
    }
    
    return self;
    
}

@end

@implementation ServerConnector

@synthesize sessionString = _sessionString;


- (id)init
{
	if ((self = [super init]))
    {
    }
	return self;
}

- (void)dealloc
{
	[_sessionString release];
	[super dealloc];
}


// ==============================
// [ ServerConnector 싱글턴 처리 ]
// ==============================
static ServerConnector *_ServerConnector = nil;
+ (ServerConnector *)sharedServerConnection
{
	if (_ServerConnector == nil)
	{
		_ServerConnector = [[ServerConnector alloc] init];
	}
	
	return _ServerConnector;
}
+ (void)releaseSharedServerConnection
{
	if (_ServerConnector)
	{
		[_ServerConnector release];
		_ServerConnector = nil;
	}
}
// ******************************




// =============================
// [ ServerConnector 보조메소드 ]
// =============================

// 플렛폼 정보 가져오기
- (NSString *)getPlatform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    
    return platform;
}

// ApplicationServer 헤더 정보 설정 함수
// request => 해더정보 세팅전까지의 URLRequest 정보
- (void)addHeaderForApplicationServer:(NSMutableURLRequest *)request
{
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
	[request setTimeoutInterval:DEFAULT_TIMEOUT_INTERVAL];
	
	// Device string
	UIDevice *device = [UIDevice currentDevice];
	NSString *deviceString = [NSString stringWithFormat:@"Apple/%@/%@ %@",[device model],[device systemName],[device systemVersion]];
    
    NSLog(@"%@", deviceString);
	
	// Platform
	int platform = 1;
	NSString *platformString = [self getPlatform];
	if ([platformString isEqual:@"iPhone1,2"]) platform = 1;
	else if ([platformString isEqual:@"iPhone2,1"]) platform = 1;
	else if ([platformString isEqual:@"iPhone3,1"]) platform = 2;
    
	// Device resolution
	NSString *deviceResolutionString = nil;
	if(platform == 2)
    {
        deviceResolutionString =[NSString stringWithFormat:@"640*960"];
    }else{
        deviceResolutionString =[NSString stringWithFormat:@"320*480"];
    }
    
	// GMT
	char tbuf[64];
	time_t t = time(NULL);
	struct tm *curTime = gmtime(&t);
	strftime(tbuf,sizeof(tbuf),"%a, %d %b %Y %H:%M:%S GMT",curTime);
    
    
    // Set KTLBS Header
	NSString *gpsdataString = [NSString stringWithFormat:@"{\"coordinates\":[%f, %f], \"optional\":{\"accuracy\":%f, \"speed\":%f, \"utc\":\"%@\"}}",
							   0.0,	// 경도
							   0.0,	// 위도
							   0.0,	// Accuracy
							   0.0,	// Speed
							   @""];// GMT
	
    [request setValue:[NSString stringWithFormat:@"%d", platform] forHTTPHeaderField :@"KTLBS-platform"];
    NSString *deviceVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSLog(@"%@", deviceVersion);
    [request setValue:deviceVersion forHTTPHeaderField :@"KTLBS-version"];
    [request setValue:deviceString forHTTPHeaderField :@"KTLBS-device"];
    [request setValue:@"" forHTTPHeaderField :@"KTLBS-guid"];
    [request setValue:self.sessionString forHTTPHeaderField :@"KTLBS-session"];
    [request setValue:@"" forHTTPHeaderField :@"KTLBS-view-address"];
    [request setValue:deviceResolutionString forHTTPHeaderField :@"KTLBS-resolution"];
    [request setValue:gpsdataString forHTTPHeaderField :@"KTLBS-gpsdata"];
    
}

// CommonGateway 헤더 정보 설정 함수
// request => 해더정보 세팅전까지의 URLRequest 정보

- (void)addHeaderForCommonGateway:(NSMutableURLRequest *)request
{
	[request setValue:@"kumi5GUCdQ8jia2T" forHTTPHeaderField :@"APPKEY"];
}

// request 에서 꺼내온 receive data 를 json 문자열로 변환
- (NSString *) convertToJsonStringFromReceiveData :(ServerRequester *)request :(BOOL)isXml
{
    NSString *strReceiveData = nil;
    
    if (isXml)
    {
        // 올레맵 2.0에서 1차 개발버전까지 XML 사용하는 케이스 없음 (길찾기는 별도 처리)
        // 2.0에서 모든 API 가 JSON 처리로 확정되면 해당 코드 제거하는게 정답 // CommonGWXmlParser 제거요망!!!
        CommonGWXmlParser *xmlParser = [[CommonGWXmlParser alloc] init];
        strReceiveData = [xmlParser objectWithData:[request data]];
        [xmlParser release];
        //NSLog(@"%@", strReceiveJsonData);
    }
    else
    {
        strReceiveData = [[[NSString alloc] initWithData:[request data] encoding:NSUTF8StringEncoding]  autorelease];
        //NSLog(@"%@",strReceiveJsonData);
    }
    
    return strReceiveData;
}


#pragma mark -
#pragma mark - 서버
// *****************************


// ====================
// [ URL 인코딩 메소드 ]
// ====================
- (NSString *) getEncodedTargetURL :(NSString *)targetUrl
{
    // 기존  TB바라볼경우 인코딩하지 않느다.
#if 0
    return targetUrl;
#endif
    
    // targetUrl을 인코딩해서 넘겨준다.
    return [targetUrl urlEncodeUsingEncoding:NSUTF8StringEncoding];
}
// ********************



// ====================
// [ 근접거리 POI 검색 ]
// ====================
// OnetouchPOI

- (ServerRequester *)requestOneTouchPOI:(id)target action:(SEL)action PX:(int)PX PY:(int)PY Level:(int)Level
{
	ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
	
    NSString *rawUrl = [NSString stringWithFormat:@"/v2/search/km2_OneTouchPOI.json?PX=%d&PY=%d&LEVEL=%d",PX, PY, Level];
    //NSString *refinedUrl = [self getEncodedTargetURL:rawUrl];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_GW, rawUrl]]];
    
	NSLog(@"원터치POI URL : %@", [request URL]);
    
	[request setHTTPMethod:@"GET"];
    
    [request useErrorNotify:NO];
	
	[request addFinishTarget:self action:@selector(finishOneTouchPOI:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
	return request;
}

-(void)finishOneTouchPOI:(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        @try
        {
            NSString *strReceiveJsonData = nil;
            
            // XML to JSON // 현재 서버가 XML형태로 넘겨주는 데이터를 JSON 스트링으로 변환한다.
            strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            // JSON 오브젝트 변환
            SBJSON *json = [[SBJSON alloc] init];
            NSMutableDictionary *dic = [json objectWithString:strReceiveJsonData];
            [[OllehMapStatus sharedOllehMapStatus].oneTouchPOIDictionary setValuesForKeysWithDictionary:dic];
            [json release];
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error_Parser];
        }
    }
}

// ************************



// =======================
// [ 길찾기 - 자동차 검색 ]
// =======================

// @brief 길찾기 검색 결과 요청 함수
// @param target 콜백 타겟 클래스
// @param action 타겟 클래스 콜백함수
// @param SX : 출발지 x 좌표
// @param SY : 출발지 y 좌표
// @param EX : 경유지 x 좌표
// @param EY : 경유지 y 좌표
// @param RPType : 길찾기 종류 ( 0:자동차 , 1:대중교통 )
// @param CoordType : 좌표 타입
// @param VX1 : 도착지 x 좌표
// @param VY1 : 도착지 y 좌표
// @param priority : ( 0:추천, 1:버스, 2:지하철, 3:버스+지하철 )
// @return ServerRequest 정보를 리턴
- (ServerRequester *)requestRouteSearch:(id)target action:(SEL)action SX:(float)SX SY:(float)SY EX:(float)EX EY:(float)EY RPType:(int)RPType CoordType:(int)CoordType VX1:(float)VX1 VY1:(float)VY1 Priority:(int)Priority
{
	ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    // RPType = 0 : 자동차 길찾기
    // RPType = 1 : 대중교통 길찾기
    request.userInt = RPType;
    
    // 길찾기 (자동차/대중교통) 통계
    if (RPType == 0) [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/find_route/car"];
    else [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/find_route/public"];
    
    NSString *rawUrl = [NSString stringWithFormat:@"/v1/route/RouteSearch.xml?SX=%f&SY=%f&EX=%f&EY=%f&RPTYPE=%d&COORDTYPE=%d&PRIORITY=%d"
                        ,SX
                        ,SY
                        ,EX
                        ,EY
                        ,RPType
                        ,CoordType
                        ,Priority];
    
    // 경유지 존재할 경우 추가
    if ((VX1 > 0.0) && (VY1 > 0.0))
        rawUrl = [rawUrl stringByAppendingFormat:@"&VX1=%f&VY1=%f", VX1, VY1];
    
    //NSString *refinedUrl = [self getEncodedTargetURL:rawUrl];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_GW, rawUrl]]];
    
    [request setUserString:  [NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_GW, rawUrl] ];
    
    NSLog(@"길찾기 URL : %@", [request URL]);
    
	[request setHTTPMethod:@"GET"];
    
    [request useErrorNotify:YES];
	
	[request addFinishTarget:self action:@selector(finishRouteSearch:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
    
	[request sendRequest: 20];
	
	return request;
}


// @brief requestRouteSearch 길찾기 검색 결과 콜백 함수
- (void)finishRouteSearch:(id)request
{
	if ([request finishCode] == OMSRFinishCode_Completed)
	{
        
        @try
        {
            
            OMSearchRouteDataParser *omSRDP = [[OMSearchRouteDataParser alloc] initWithData:[request data]];
            [omSRDP setNVehicleType:[request userInt]];
            [omSRDP parseRouteData:[request data]];
            [omSRDP release];
            
            
            // 자동차 검색인 경우 강제로 도착점에 대한 커스터마이징 실행.
            if ( [request userInt] == 0)
            {
                OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
                
                if ( oms.searchRouteData.isRouteCar && oms.searchRouteData.routeCarPointCount > 0 )
                {
                    // 포인트 카운터 증가 (임의로 추가함)
                    oms.searchRouteData.routeCarPointCount++;
                    // 포인트 정보 추가
                    
                    NSMutableDictionary *destPointDic = [oms.searchRouteData.routeCarPoints objectAtIndexGC:oms.searchRouteData.routeCarPoints.count-1] ;
                    NSMutableDictionary *addDic = [destPointDic mutableCopy];
                    [oms.searchRouteData.routeCarPoints addObject:addDic];
                    
                    // 타입 변경
                    [destPointDic setObject:@"-1" forKey:@"Type"];
                    // 최종 포인트 인덱스 수정
                    [addDic setObject:[NSNumber numberWithInt:[[addDic objectForKeyGC:@"Index"] intValue]+1] forKey:@"Index"];
                    
                    [addDic release];
                }
            }
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
	}
}

// ***********************

#pragma mark -
#pragma mark 로컬서치

// ========
// [ 검색 ]
// ========

// @brief 장소 검색 정보 요청 함수
// @param target 콜백 타겟 클래스
// @param action 타겟 클래스 콜백함수
// @param key : 검색어
// @param mapX : 맵 x 좌표
// @param mapY : 맵 y 좌표
// @param s : p(상호), a(주소)
// @param sr : DIS(거리순), RANK(정확도순), MATCH(일치)
// @param startPage :현재 페이지
// @param indexCount : 카운트 수 ( 10 )
// @return ServerRequest 정보를 리턴
- (ServerRequester *) requestSearchPlaceAndAddress :(id)target action:(SEL)action key:(NSString *)key mapX:(int)mapX mapY:(int)mapY s:(NSString *)s sr:(NSString *)sr p_startPage:(int)p_startPage a_startPage:(int)a_startPage n_startPage:(int)n_startPage indexCount:(int)indexCount option:(int)option

{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    
    [request setUserString:s];
    [request setUserObject:key];
    [request setUserInt2:option];
    NSString *keyString = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //NSString *rawerURL = [NSString stringWithFormat:@"%@%@&X=%d&Y=%d&sr=%@&P_places=%d&P_addrs=%d&P_newaddrs=%d&option=%d", rawRawURL, key, mapX, mapY, sr, p_startPage, a_startPage, n_startPage, option];
    
    
    NSString *rawUrl = [NSString stringWithFormat:@"/v2/search/km2_LocalSearch.json?Query=%@&X=%d&Y=%d&sr=%@&P_places=%d&P_addrs=%d&P_newaddrs=%d&option=%d"
                        ,keyString
                        ,mapX
                        ,mapY
                        ,sr
                        ,p_startPage, a_startPage, n_startPage,option];
    
    
    // "장소/주소" 검색 쿼리를 날린다. 검색대상이 아닌 경우는 카운트 0으로 처리하며 전체카운트만 얻도록 한다.
    if ([s isEqualToString:@"p"]) //장소
    {
        rawUrl = [rawUrl stringByAppendingFormat:@"&places=%d&addrs=%d", indexCount, indexCount]
        ;
        [request setUserInt:p_startPage];
    }
    else if ([s isEqualToString:@"an"]) // 주소
    {
        rawUrl = [rawUrl stringByAppendingFormat:@"&places=%d&addrs=%d&newaddrs=%d", 15, indexCount, indexCount];
        [request setUserInt:n_startPage];
    }
    
    //NSLog(@"로컬서치 rawURL : %@", rawUrl);
    
    //NSString *refinedUrl = [self getEncodedTargetURL:rawUrl];
    //NSString *refinedUrl = [rawUrl urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_GW, rawUrl]]];
    
    NSLog(@"로컬서치 URL : %@", [request URL]);
    
    // HttpMethod 방식
    [request setHTTPMethod:@"GET"];
    
    // 데이터쿼리, UI 관련 콜백 등록
    [request addFinishTarget:self action:@selector(finishSearchPlaceAndAddress:)];
    [request addFinishOuterTarget:target action:action];
    
    // 검색 요청
    [self addHeaderForCommonGateway:request];
    [request sendRequest];
    
    return request;
}

- (void) finishSearchPlaceAndAddress :(id)request
{
    // 검색 결과가 정상적으로 수신됐을 경우에만 동작하도록 함.
	if ([request finishCode] == OMSRFinishCode_Completed)
	{
        
        @try
        {
            OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
            NSString *strReceiveJsonData = nil;
            
            // XML to JSON // 현재 서버가 XML형태로 넘겨주는 데이터를 JSON 스트링으로 변환한다.
            strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            NSLog(@"로컬서치파싱 : %@", strReceiveJsonData);
            
            // JSON 오브젝트 변환
            SBJSON *json = [[SBJSON alloc] init];
            NSMutableDictionary *dic = [json objectWithString:strReceiveJsonData];
            
            // RESULTDATA 가끔 null 로 올때가 있다.
            // 정말... 정말...... 너무한다..??? 일단 예외처리..
            if([[dic objectForKeyGC:@"RESULTDATA"] isEqual:[NSNull null]])
            {
                NSMutableDictionary *rdDic = [NSMutableDictionary dictionary];
                
                NSMutableDictionary *addrDic = [NSMutableDictionary dictionary];
                NSMutableDictionary *placeDic = [NSMutableDictionary dictionary];
                NSMutableDictionary *newaddrDic = [NSMutableDictionary dictionary];
                
                
                
                [addrDic setObject:@"0" forKey:@"TotalCount"];
                [addrDic setObject:@"0" forKey:@"CurrentCount"];
                [addrDic setObject:[NSArray array] forKey:@"Data"];
                [rdDic setObject:addrDic forKey:@"addr"];
                
                [placeDic setObject:@"0" forKey:@"TotalCount"];
                [placeDic setObject:@"0" forKey:@"CurrentCount"];
                [placeDic setObject:[NSArray array] forKey:@"Data"];
                [rdDic setObject:placeDic forKey:@"place"];
                
                [newaddrDic setObject:@"0" forKey:@"TotalCount"];
                [newaddrDic setObject:@"0" forKey:@"CurrentCount"];
                [newaddrDic setObject:[NSArray array] forKey:@"Data"];
                [rdDic setObject:newaddrDic forKey:@"newaddr"];
                
                
                
                
                [dic setObject:rdDic forKey:@"RESULTDATA"];
                
                // 주석처리필요.. (일단 개발기간중 확인용)
#ifdef DEBUG
                [OMMessageBox showAlertMessage:@"오류" :@"서버 검색결과(RESULTDATA)가 Null로 넘어왔습니다. "];
#endif
            }
            
            // *****************************************
            // [ 장소 and 주소 결과를 모두 메모리에 할당 ]
            // *****************************************
            //[oms.searchLocalDictionary removeAllObjects];
            // A. 장소 데이터 정리
            if ([request userInt2] == 2)
            {
                @try
                {
                    
                    NSMutableDictionary *dicPlace = [[dic objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"place"];
                    [oms.searchLocalDictionary setValue:[[dic objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"QueryResult"] forKey:@"QueryResult"];
                    [oms.searchLocalDictionary setValue:[[dic objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"na_result"] forKey:@"Na_Result"];
                    
                    [oms.searchLocalDictionary setValue:[[dic objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"searchType"] forKey:@"SearchType"];
                    [oms.searchLocalDictionary setValue:[dicPlace objectForKeyGC:@"TotalCount"] forKey:@"TotalCountPlace"];
                    // 현재 카운트가 0보다 클경우에만 데이터를 입력한다.
                    if (([[dicPlace objectForKeyGC:@"TotalCount"] intValue] > 0
                         && [[dicPlace objectForKeyGC:@"Count"] intValue] > 0) || [request userInt2] == 2)
                    {
                        [oms.searchLocalDictionary setValue:[[dic objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"QueryResult"] forKey:@"QueryResult"];
                        [oms.searchLocalDictionary setValue:[[dic objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"na_result"] forKey:@"Na_Result"];
                        [oms.searchLocalDictionary setValue:[[dic objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"searchType"] forKey:@"SearchType"];
                        [oms.searchLocalDictionary setValue:[dicPlace objectForKeyGC:@"Count"] forKey:@"CurrentCountPlace"];
                        [oms.searchLocalDictionary setValue:[dicPlace objectForKeyGC:@"Data"] forKey:@"DataPlace"];
                        
                    }
                    else
                    {
                        [oms.searchLocalDictionary setValue:@"-1" forKey:@"CurrentCountPlace"];
                        [oms.searchLocalDictionary removeObjectForKey:@"DataPlace"];
                        [oms.searchLocalDictionary removeObjectForKey:@"QueryResult"];
                        [oms.searchLocalDictionary removeObjectForKey:@"searchType"];
                        [oms.searchLocalDictionary removeObjectForKey:@"Na_Result"];
                    }
                }
                @catch (NSException *exception)
                {
                    [oms.searchLocalDictionary setValue:@"-1" forKey:@"CurrentCountPlace"];
                    [oms.searchLocalDictionary removeObjectForKey:@"DataPlace"];
                    [oms.searchLocalDictionary removeObjectForKey:@"QueryResult"];
                    [oms.searchLocalDictionary removeObjectForKey:@"searchType"];
                    [oms.searchLocalDictionary removeObjectForKey:@"Na_Result"];
                }
                // 현재 검색이 장소검색일 경우에만 페이징 반영
                [oms.searchLocalDictionary setValue:[NSString stringWithFormat:@"%d",[request userInt]] forKey:@"CurrentPagePlace"];
                
                @try
                {
                    NSMutableDictionary *dicAddress = [[dic objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"addr"];
                    
                    NSMutableDictionary *dicNewAddress = [[dic objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"New_addrs"];
                    
                    [oms.searchLocalDictionary setValue:[dicAddress objectForKeyGC:@"TotalCount"] forKey:@"TotalCountAddress"];
                    
                    [oms.searchLocalDictionary setValue:[dicNewAddress objectForKeyGC:@"TotalCount"] forKey:@"TotalCountNewAddress"];
                    // 현재 카운트가 0보다 클경우에만 데이터를 입력한다.
                    if ([[dicAddress objectForKeyGC:@"TotalCount"] intValue] > 0
                        && [[dicAddress objectForKeyGC:@"Count"] intValue] > 0)
                    {
                        [oms.searchLocalDictionary setValue:[dicAddress objectForKeyGC:@"Count"] forKey:@"CurrentCountAddress"];
                        [oms.searchLocalDictionary setObject:[dicAddress objectForKeyGC:@"Data"] forKey:@"DataAddress"];
                    }
                    else
                    {
                        [oms.searchLocalDictionary setValue:@"-1" forKey:@"CurrentCountAddress"];
                        [oms.searchLocalDictionary removeObjectForKey:@"DataAddress"];
                    }
                    
                    // 현재 카운트가 0보다 클경우에만 데이터를 입력한다.
                    if ([[dicNewAddress objectForKeyGC:@"TotalCount"] intValue] > 0
                        && [[dicNewAddress objectForKeyGC:@"Count"] intValue] > 0)
                    {
                        [oms.searchLocalDictionary setValue:[dicNewAddress objectForKeyGC:@"Count"] forKey:@"CurrentCountNewAddress"];
                        [oms.searchLocalDictionary setObject:[dicNewAddress objectForKeyGC:@"Data"] forKey:@"DataNewAddress"];
                    }
                    else
                    {
                        [oms.searchLocalDictionary setValue:@"-1" forKey:@"CurrentCountNewAddress"];
                        [oms.searchLocalDictionary removeObjectForKey:@"DataNewAddress"];
                    }
                    
                }
                @catch (NSException *exception)
                {
                    [oms.searchLocalDictionary setValue:@"-1" forKey:@"CurrentCountAddress"];
                    [oms.searchLocalDictionary removeObjectForKey:@"DataAddress"];
                    
                    [oms.searchLocalDictionary setValue:@"-1" forKey:@"CurrentCountNewAddress"];
                    [oms.searchLocalDictionary removeObjectForKey:@"DataNewAddress"];
                }
                // 현재 검색이 주소검색일 경우에만 페이징 반영
                [oms.searchLocalDictionary setValue:[NSString stringWithFormat:@"%d",[request userInt]] forKey:@"CurrentPageAddress"];
                [oms.searchLocalDictionary setValue:[NSString stringWithFormat:@"%d",[request userInt]] forKey:@"CurrentPageNewAddress"];
            }
            
            else if([[request userString] isEqualToString:@"p"])
            {
                @try
                {
                    
                    NSMutableDictionary *dicPlace = [[dic objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"place"];
                    
                    // ver3 장소검색에도 구주소데이터가 필요함
                    NSMutableDictionary *dicAddress = [[dic objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"addr"];
                    
                    NSMutableDictionary *dicNewAddress = [[dic objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"New_addrs"];
                    
                    [oms.searchLocalDictionary setValue:[dicAddress objectForKeyGC:@"TotalCount"] forKey:@"TotalCountAddress"];
                    
                    [oms.searchLocalDictionary setValue:[dicNewAddress objectForKeyGC:@"TotalCount"] forKey:@"TotalCountNewAddress"];
                    
                    
                    [oms.searchLocalDictionary setValue:[[dic objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"QueryResult"] forKey:@"QueryResult"];
                    [oms.searchLocalDictionary setValue:[[dic objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"na_result"] forKey:@"Na_Result"];
                    
                    [oms.searchLocalDictionary setValue:[[dic objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"searchType"] forKey:@"SearchType"];
                    [oms.searchLocalDictionary setValue:[dicPlace objectForKeyGC:@"TotalCount"] forKey:@"TotalCountPlace"];
                    // 현재 카운트가 0보다 클경우에만 데이터를 입력한다.
                    if (([[dicPlace objectForKeyGC:@"TotalCount"] intValue] > 0
                         && [[dicPlace objectForKeyGC:@"Count"] intValue] > 0) || ([request userInt2] == 2 || [request userInt2] == 3))
                    {
                        [oms.searchLocalDictionary setValue:[[dic objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"QueryResult"] forKey:@"QueryResult"];
                        [oms.searchLocalDictionary setValue:[[dic objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"na_result"] forKey:@"Na_Result"];
                        [oms.searchLocalDictionary setValue:[[dic objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"searchType"] forKey:@"SearchType"];
                        [oms.searchLocalDictionary setValue:[dicPlace objectForKeyGC:@"Count"] forKey:@"CurrentCountPlace"];
                        [oms.searchLocalDictionary setValue:[dicPlace objectForKeyGC:@"Data"] forKey:@"DataPlace"];
                        
                        // ver3. 구주소데이터 필요함
                        [oms.searchLocalDictionary setValue:[dicAddress objectForKeyGC:@"Data"] forKey:@"DataAddress"];
                        
                        [oms.searchLocalDictionary setValue:[dicNewAddress objectForKeyGC:@"Data"] forKey:@"DataNewAddress"];
                        
                    }
                    else
                    {
                        [oms.searchLocalDictionary setValue:@"-1" forKey:@"CurrentCountPlace"];
                        [oms.searchLocalDictionary removeObjectForKey:@"DataPlace"];
                        [oms.searchLocalDictionary removeObjectForKey:@"QueryResult"];
                        [oms.searchLocalDictionary removeObjectForKey:@"searchType"];
                        [oms.searchLocalDictionary removeObjectForKey:@"Na_Result"];
                    }
                }
                @catch (NSException *exception)
                {
                    [oms.searchLocalDictionary setValue:@"-1" forKey:@"CurrentCountPlace"];
                    [oms.searchLocalDictionary removeObjectForKey:@"DataPlace"];
                    [oms.searchLocalDictionary removeObjectForKey:@"QueryResult"];
                    [oms.searchLocalDictionary removeObjectForKey:@"searchType"];
                    [oms.searchLocalDictionary removeObjectForKey:@"Na_Result"];
                }
                // 현재 검색이 장소검색일 경우에만 페이징 반영
                [oms.searchLocalDictionary setValue:[NSString stringWithFormat:@"%d",[request userInt]] forKey:@"CurrentPagePlace"];
            }
            // B. 주소 데이터 정리
            else if ([[request userString] isEqualToString:@"an"])
            {
                @try
                {
                    NSMutableDictionary *dicAddress = [[dic objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"addr"];
                    
                    NSMutableDictionary *dicNewAddress = [[dic objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"New_addrs"];
                    
                    [oms.searchLocalDictionary setValue:[dicAddress objectForKeyGC:@"TotalCount"] forKey:@"TotalCountAddress"];
                    
                    [oms.searchLocalDictionary setValue:[dicNewAddress objectForKeyGC:@"TotalCount"] forKey:@"TotalCountNewAddress"];
                    
                    NSLog(@" %d \n %d \n %d \n %d", [[dicAddress objectForKeyGC:@"TotalCount"] intValue], [[dicAddress objectForKeyGC:@"Count"] intValue], [[dicNewAddress objectForKeyGC:@"TotalCount"] intValue], [[dicNewAddress objectForKeyGC:@"Count"] intValue]);
                    
                    
                    // 현재 카운트가 0보다 클경우에만 데이터를 입력한다.
                    if ([[dicAddress objectForKeyGC:@"TotalCount"] intValue] > 0
                        && [[dicAddress objectForKeyGC:@"Count"] intValue] > 0)
                    {
                        [oms.searchLocalDictionary setValue:[dicAddress objectForKeyGC:@"Count"] forKey:@"CurrentCountAddress"];
                        [oms.searchLocalDictionary setObject:[dicAddress objectForKeyGC:@"Data"] forKey:@"DataAddress"];
                    }
                    else
                    {
                        [oms.searchLocalDictionary setValue:@"-1" forKey:@"CurrentCountAddress"];
                        [oms.searchLocalDictionary removeObjectForKey:@"DataAddress"];
                    }
                    
                    // 현재 카운트가 0보다 클경우에만 데이터를 입력한다.
                    if ([[dicNewAddress objectForKeyGC:@"TotalCount"] intValue] > 0
                        && [[dicNewAddress objectForKeyGC:@"Count"] intValue] > 0)
                    {
                        [oms.searchLocalDictionary setValue:[dicNewAddress objectForKeyGC:@"Count"] forKey:@"CurrentCountNewAddress"];
                        [oms.searchLocalDictionary setObject:[dicNewAddress objectForKeyGC:@"Data"] forKey:@"DataNewAddress"];
                    }
                    else
                    {
                        [oms.searchLocalDictionary setValue:@"-1" forKey:@"CurrentCountNewAddress"];
                        [oms.searchLocalDictionary removeObjectForKey:@"DataNewAddress"];
                    }
                    
                }
                @catch (NSException *exception)
                {
                    [oms.searchLocalDictionary setValue:@"-1" forKey:@"CurrentCountAddress"];
                    [oms.searchLocalDictionary removeObjectForKey:@"DataAddress"];
                    
                    [oms.searchLocalDictionary setValue:@"-1" forKey:@"CurrentCountNewAddress"];
                    [oms.searchLocalDictionary removeObjectForKey:@"DataNewAddress"];
                }
                // 현재 검색이 주소검색일 경우에만 페이징 반영
                [oms.searchLocalDictionary setValue:[NSString stringWithFormat:@"%d",[request userInt]] forKey:@"CurrentPageAddress"];
                [oms.searchLocalDictionary setValue:[NSString stringWithFormat:@"%d",[request userInt]] forKey:@"CurrentPageNewAddress"];
            }
            
            
            // JSON 오브젝트 해제
            [json release];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
	}
}

#pragma mark -
#pragma mark 대중교통서치

// @brief 대중교통 - 정류소 정보 요청 함수
// @param target 콜백 타겟 클래스
// @param action 타겟 클래스 콜백함수
// @param Name : 검색 정류소 이름
// @param ViewCnt : 검색 갯수 ( 10 )
// @param Page : 페이지
// @return ServerRequest 정보를 리턴
- (ServerRequester *) requestSearchPublicBusStation :(id)target action:(SEL)action Name:(NSString *)Name ViewCnt:(int)ViewCnt Page:(int)Page
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
  	NSString *keyString = [Name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *rawUrl = [NSString stringWithFormat:@"/v1/masstransit/TrafficSearchStation.json?NAME=%@&VIEWCNT=%d&PAGE=%d"
                        ,keyString, ViewCnt, Page];
    
    //NSString *refinedUrl = [rawUrl urlEncodeUsingEncoding:NSUTF8StringEncoding];
    //NSString *refinedUrl = [self getEncodedTargetURL:rawUrl];
    
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_GW, rawUrl]]];
    
    [request setUserInt:Page];
    [request setUserString:@"BS"];
	
    NSLog(@"버정검색 URL : %@", [request URL]);
    
	[request setHTTPMethod:@"GET"];
	
	[request addFinishTarget:self action:@selector(finishSearchPublic:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
	return request;
}

// @brief POI 버스번호 검색 요청 함수
// @param target 콜백 타겟 클래스
// @param action 타겟 클래스 콜백함수
// @param key : 검색할 문자
// @param startPage : 페이지
// @param indexCount : 페이지당 카운트 수
// @return ServerRequest 정보를 리턴
- (ServerRequester *) requestSearchPublicBusNumber :(id)target action:(SEL)action key:(NSString *)key startPage:(int)startPage indexCount:(int)indexCount
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
	
    [request setUserInt:startPage];
    [request setUserString:@"BN"];
	
	NSString *keyString = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *rawUrl = [NSString stringWithFormat:@"/v1/masstransit/BusNo.json?BUSNO=%@&PAGE=%d&VIEWCNT=%d"
                        ,keyString, startPage, indexCount];
    
    //NSString *refinedUrl = [rawUrl urlEncodeUsingEncoding:NSUTF8StringEncoding];
    //NSString *refinedUrl = [self getEncodedTargetURL:rawUrl];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_GW, rawUrl]]];
	
    NSLog(@"버번검색 URL : %@", [request URL]);
    
	[request setHTTPMethod:@"GET"];
	
	[request addFinishTarget:self action:@selector(finishSearchPublic:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
	return request;
}

// @brief 대중교통 - 지하철역 정보 요청 함수
// @param target 콜백 타겟 클래스
// @param action 타겟 클래스 콜백함수
// @param Name : 검색 정류소 이름
// @return ServerRequest 정보를 리턴
- (ServerRequester *) requestSearchPublicSubwayStation :(id)target action:(SEL)action Name:(NSString *)Name
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    [request setUserString:@"SS"];
    
  	NSString *keyString = [Name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
    NSString *rawUrl = [NSString stringWithFormat:@"/v1/masstransit/TrafficSearchSubStation.json?NAME=%@", keyString];
    //NSString *refinedUrl = [rawUrl urlEncodeUsingEncoding:NSUTF8StringEncoding];
    //NSString *refinedUrl = [self getEncodedTargetURL:rawUrl];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_GW, rawUrl]]];
	
    NSLog(@"지하철역검색 URL : %@", [request URL]);
	[request setHTTPMethod:@"GET"];
	
	[request addFinishTarget:self action:@selector(finishSearchPublic:)];
    
    [request addFinishOuterTarget:target action:action];
	
    
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
	return request;
}


- (void) finishSearchPublic:(id)request
{
    // 검색 결과가 정상적으로 수신됐을 경우에만 동작하도록 함.
	if ([request finishCode] == OMSRFinishCode_Completed)
	{
        
        @try
        {
            
            OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
            NSString *strReceiveJsonData = nil;
            
            // XML to JSON // 현재 서버가 XML형태로 넘겨주는 데이터를 JSON 스트링으로 변환한다.
            strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            //NSLog(@"대중교통 (%@) : %@", [request userString],strReceiveJsonData);
            // JSON 오브젝트 변환
            SBJSON *json = [[SBJSON alloc] init];
            NSMutableDictionary *dic = [json objectWithString:strReceiveJsonData];
            
            // *****************************
            // [ 대중교통 3종류 데이터 처리 ]
            // *****************************
            
            // A. 버스 정류장
            if ([[request userString] isEqualToString:@"BS"])
            {
                
                NSMutableDictionary *dicRD = [dic objectForKeyGC:@"RESULTDATA"];
                [oms resetLocalSearchDictionary:@"PublicBusStation"];
                
                @try
                {
                    if ([dicRD isEqual:[NSNull null]])
                    {
                        [oms resetLocalSearchDictionary:@"PublicBusStation"];
                        [oms.searchLocalDictionary setObject:@"0" forKey:@"TotalCountPublicBusStation"];
                        [oms.searchLocalDictionary setObject:@"0" forKey:@"CurrentCountPublicBusStation"];
                        [oms.searchLocalDictionary setObject:@"0" forKey:@"CurrentPagePublicBusStation"];
                    }
                    else
                    {
                        [oms.searchLocalDictionary setObject:[dicRD objectForKeyGC:@"TOTALCNT"] forKey:@"TotalCountPublicBusStation"];
                        [oms.searchLocalDictionary setObject:[dicRD objectForKeyGC:@"CNT"] forKey:@"CurrentCountPublicBusStation"];
                        [oms.searchLocalDictionary setObject:[NSString stringWithFormat:@"%d",[request userInt]] forKey:@"CurrentPagePublicBusStation"];
                        if ([[oms.searchLocalDictionary objectForKeyGC:@"CurrentCountPublicBusStation"] intValue] > 0)
                            [oms.searchLocalDictionary setObject:[dicRD objectForKeyGC:@"PAGERESULT_LIST"] forKey:@"DataPublicBusStation"];
                    }
                }
                @catch (NSException *exception)
                {
                    [oms resetLocalSearchDictionary:@"PublicBusStation"];
                    [oms.searchLocalDictionary setObject:@"0" forKey:@"TotalCountPublicBusStation"];
                    [oms.searchLocalDictionary setObject:@"0" forKey:@"CurrentCountPublicBusStation"];
                    [oms.searchLocalDictionary setObject:@"0" forKey:@"CurrentPagePublicBusStation"];
                    //[OMMessageBox showAlertMessage:@"*검색서버응답오류* -버스정류장" :exception.reason];
                    //NSLog(@"오류발생 json (%@) : %@", [request userString],strReceiveJsonData);
                }
                
            }
            // B. 버스 번호
            else if ([[request userString] isEqualToString:@"BN"])
            {
                NSMutableDictionary *dicRD = [dic objectForKeyGC:@"RESULTDATA"];
                [oms resetLocalSearchDictionary:@"PublicBusNumber"];
                
                @try
                {
                    if ([dicRD isEqual:[NSNull null]])
                    {
                        [oms resetLocalSearchDictionary:@"PublicBusNumber"];
                        [oms.searchLocalDictionary setObject:@"0" forKey:@"TotalCountPublicBusNumber"];
                        [oms.searchLocalDictionary setObject:@"0" forKey:@"CurrentCountPublicBusNumber"];
                        [oms.searchLocalDictionary setObject:@"0" forKey:@"CurrentPagePublicBusNumber"];
                    }
                    else
                    {
                        [oms.searchLocalDictionary setObject:[dicRD objectForKeyGC:@"TOTALCNT"] forKey:@"TotalCountPublicBusNumber"];
                        [oms.searchLocalDictionary setObject:[dicRD objectForKeyGC:@"CNT"] forKey:@"CurrentCountPublicBusNumber"];
                        [oms.searchLocalDictionary setObject:[NSString stringWithFormat:@"%d",[request userInt]] forKey:@"CurrentPagePublicBusNumber"];
                        
                        if ([[oms.searchLocalDictionary objectForKeyGC:@"CurrentCountPublicBusNumber"] intValue] > 0)
                        {
                            [oms.searchLocalDictionary setObject:[dicRD objectForKeyGC:@"PAGERESULT_LIST"] forKey:@"DataPublicBusNumber"];
                        }
                    }
                }
                @catch (NSException *exception)
                {
                    [oms resetLocalSearchDictionary:@"PublicBusNumber"];
                    [oms.searchLocalDictionary setObject:@"0" forKey:@"TotalCountPublicBusNumber"];
                    [oms.searchLocalDictionary setObject:@"0" forKey:@"CurrentCountPublicBusNumber"];
                    [oms.searchLocalDictionary setObject:@"0" forKey:@"CurrentPagePublicBusNumber"];
                    //[OMMessageBox showAlertMessage:@"*검색서버응답오류* -버스번호" :exception.reason];
                    //NSLog(@"오류발생 json (%@) : %@", [request userString],strReceiveJsonData);
                }
                
            }
            // C. 지하철 역
            else if ([[request userString] isEqualToString:@"SS"])
            {
                NSArray *arrRD = [dic objectForKeyGC:@"RESULTDATA"];
                [oms resetLocalSearchDictionary:@"PublicSubwayStation"];
                
                @try
                {
                    if ([arrRD isEqual:[NSNull null]])
                    {
                        [oms resetLocalSearchDictionary:@"PublicSubwayStation"];
                        [oms.searchLocalDictionary setObject:@"0" forKey:@"TotalCountPublicSubwayStation"];
                        [oms.searchLocalDictionary setObject:@"0" forKey:@"CurrentCountPublicSubwayStation"];
                        [oms.searchLocalDictionary setObject:@"0" forKey:@"CurrentPagePublicSubwayStation"];
                        [oms.searchLocalDictionary setObject:[NSArray array] forKey:@"DataPublicSubwayStation"];
                    }
                    else
                    {
                        [oms.searchLocalDictionary setObject:[NSString stringWithFormat:@"%d",arrRD.count] forKey:@"TotalCountPublicSubwayStation"];
                        [oms.searchLocalDictionary setObject:[NSString stringWithFormat:@"%d",arrRD.count] forKey:@"CurrentCountPublicSubwayStation"];
                        [oms.searchLocalDictionary setObject:@"1" forKey:@"CurrentPagePublicSubwayStation"];
                        [oms.searchLocalDictionary setObject:arrRD forKey:@"DataPublicSubwayStation"];
                    }
                }
                @catch (NSException *exception)
                {
                    [oms resetLocalSearchDictionary:@"PublicSubwayStation"];
                    [oms.searchLocalDictionary setObject:@"0" forKey:@"TotalCountPublicSubwayStation"];
                    [oms.searchLocalDictionary setObject:@"0" forKey:@"CurrentCountPublicSubwayStation"];
                    [oms.searchLocalDictionary setObject:@"0" forKey:@"CurrentPagePublicSubwayStation"];
                    [oms.searchLocalDictionary setObject:[NSArray array] forKey:@"DataPublicSubwayStation"];
                    //[OMMessageBox showAlertMessage:@"*검색서버응답오류* -지하철역" :exception.reason];
                    //NSLog(@"오류발생 json (%@) : %@", [request userString],strReceiveJsonData);
                }
                
            }
            
            // JSON 오브젝트 해제
            [json release];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
	}
    
}

#pragma mark - GW 고유번호로 STID 찾기
- (ServerRequester *)requestSearchPublicBusStationUnique:(id)target action:(SEL)action UniqueId:(NSString *)UniqueId
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
	
    NSString *rawUrl = [NSString stringWithFormat:@"/v1/masstransit/TrafficSearchStationByNo.json?stationNo=%@", UniqueId];
	
    //NSString *refinedUrl = [self getEncodedTargetURL:rawUrl];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_GW, rawUrl]]];
	
    [request setUserString:@"BS"];
    
    NSLog(@"유니크아디로 정류장검색 url %@", [request URL]);
	
	[request setHTTPMethod:@"GET"];
	
	[request addFinishTarget:self action:@selector(finishSearchPublic:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
	return request;
    
}


// ********


// =================
// [ 좌표-주소 변환 ]
// =================
- (ServerRequester *) requestGeocodingCoordToAddress :(id)target action:(SEL)action x:(double)x y:(double)y radius:(int)radius type:(int)type
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    [request setUserInt:type];
    request.userString = nil;
	
    NSString *rawUrl = [NSString stringWithFormat:@"/v2/search/km2_AddrNearestPosSearch.json?PX=%d&PY=%d&RADIUS=%d",(int)x, (int)y, radius];
    //NSString *refinedUrl = [self getEncodedTargetURL:rawUrl];
    
    // 상:UrlEncoding처리, 하:원본그대로 사용
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_GW, rawUrl]]];
    
	NSLog(@"좌표-주소변환 URL : %@", [request URL]);
	
    // 현재위치 좌표 검색 실패시 오류메세지 리턴하지 않는다. UI 콜백에서 처리하도록하자.
    if (type == 0 || type == 10 )
    {
        [request useIndicator:NO];
        [request useErrorNotify:NO];
    }
    // 원터치 좌표 검색시에도 오류메세지는 UI콜백에서 담당한다.
    else if (type == 1)
    {
        [request useIndicator:YES];
        [request useErrorNotify:NO];
    }
    
	[request setHTTPMethod:@"GET"];
	
	[request addFinishTarget:self action:@selector(finishGeocodingCoordToAddress:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
    // 원터치 좌표검색은 타임아웃을 10초로 처리하자.
    if ( type == 1)
        [request sendRequest:10];
    else
        [request sendRequest];
	
	return request;
}
- (void) finishGeocodingCoordToAddress :(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        @try
        {
            
            NSString *strReceiveJsonData = nil;
            
            // XML to JSON // 현재 서버가 XML형태로 넘겨주는 데이터를 JSON 스트링으로 변환한다.
            strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            // JSON 오브젝트 변환
            SBJSON *json = [[SBJSON alloc] init];
            
            
            NSDictionary *dicResult = [[json objectWithString:strReceiveJsonData] objectForKeyGC:@"RESULTDATA"];
            if ([dicResult isEqual:[NSNull null]] || dicResult.count <= 0)
            {
                [request setUserString:@""];
            }
            else
            {
                NSDictionary *dicAddr = [[[json objectWithString:strReceiveJsonData] objectForKeyGC:@"RESULTDATA"] objectAtIndexGC:0];
                
                NSMutableString *strAddress = [NSMutableString string];
                
                //NSLog(@"%@", dicAddr);
                
                NSString *sido = stringValueOfDictionary(dicAddr, @"SIDO");
                NSString *sigungu = stringValueOfDictionary(dicAddr, @"L_SIGUN_GU");
                NSString *dong = stringValueOfDictionary(dicAddr, @"L_DONG");
                
                // userInt 값이 10인 경우 시도만 리턴
                if ( sido.length > 0 ) [strAddress appendString:sido];
                if ( sigungu.length > 0 && [request userInt] != 10 ) [strAddress appendFormat:@" %@", sigungu];
                if ( dong.length > 0  && [request userInt] != 10) [strAddress appendFormat:@" %@", dong];
                
                // 이 단계까지는 일반적인 시도-(시군구)-(동) 까지만 처리했으며
                // 1. 주소표시창에 사용
                // 2. 롱탭시  POI 이름 용도로 사용한다.
                
                
                // 다음 단계는 지번까지 포함한 ( **지번존재할경우에만) 주소를 처리하며
                // 1. 롱탭시 PIO 주소 용도로 사용하고
                // userObject 에 별도로 저장해서 리턴한다.
                if ([request userInt] == 1 )
                {
                    NSString *gibun = stringValueOfDictionary(dicAddr, @"GIBUN");
                    if ( gibun.length > 0 )
                    {
                        [request setUserObject:[NSString stringWithFormat:@"%@ %@", strAddress, gibun]];
                    }
                    else
                    {
                        [request setUserObject:[NSString stringWithFormat:@"%@", strAddress]];
                    }
                }
                
                // 정제된 주소 문자열 처리
                [request setUserString:strAddress];
                
            }
            
            [json release];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
    }
}

- (ServerRequester *) requestGeocodingCoordToShortAddress :(id)target action:(SEL)action type:(int)type x:(double)x y:(double)y dong:(int)dong
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    [request setUserInt:type];
    request.userString = nil;
	
    NSString *rawUrl = [NSString stringWithFormat:@"/v1/search/AddrNearestPosSearch2.json?PX=%d&PY=%d&DONG=%d&SRC_COORDTYPE=UTMK",(int)x, (int)y, dong];
    //NSString *refinedUrl = [self getEncodedTargetURL:rawUrl];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_GW, rawUrl]]];
    
	//NSLog(@"좌표-주소변환 URL : %@", [request URL]);
	
	[request setHTTPMethod:@"GET"];
    
    
    // 길찾기 "현재위치" 주소정보 검색시 오류메세지 리턴하지 않는다.
    if (type == 2 || type == 3 || type == 4)
    {
        [request useIndicator:NO];
        [request useErrorNotify:NO];
    }
	
	[request addFinishTarget:self action:@selector(finishGeocodingCoordToShortAddress:)];
    
	[request addFinishOuterTarget:target action:action];
    
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
	return request;
}
- (void) finishGeocodingCoordToShortAddress:(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        
        @try
        {
            
            NSString *strReceiveJsonData = nil;
            
            // XML to JSON // 현재 서버가 XML형태로 넘겨주는 데이터를 JSON 스트링으로 변환한다.
            strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            // JSON 오브젝트 변환
            SBJSON *json = [[SBJSON alloc] init];
            NSDictionary *dic = [[[json objectWithString:strReceiveJsonData] objectForKeyGC:@"RESULTDATA"] objectAtIndexGC:0];;
            
            NSMutableString *strAddress = [NSMutableString string];
            
            NSString *sido = stringValueOfDictionary(dic, @"SIDO");
            if ( sido.length > 0 )
                [strAddress appendString:sido];
            
            if ([request userInt] != 10)
            {
                NSString *sigungu = stringValueOfDictionary(dic, @"SIGUNGU");
                NSString *dong = stringValueOfDictionary(dic, @"DONG");
                if ( sigungu.length > 0 )
                    [strAddress appendFormat:@" %@", sigungu];
                if ( dong.length > 0 )
                    [strAddress appendFormat:@" %@", dong];
            }
            [request setUserString:strAddress];
            
            // type이 2~4 일경우는 현재위치 좌표를 이용한 길찾기 상태일때 호출되며
            // 현재위치 문구 대신 실제 주소를 대입해주기 위해 파싱콜백에서 바로처리해주도록한다.
            switch ([request userInt])
            {
                case 2:
                {
                    // 길찾기 출발지 현재위치 사용시
                    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
                    [oms.searchResultRouteStart setStrLocationAddress:[request userString]];
                    [oms.searchResultRouteStart setStrLocationName:[request userString]];
                    break;
                }
                case 3:
                {
                    // 길찾기 경유지 현재위치 사용시
                    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
                    [oms.searchResultRouteVisit setStrLocationAddress:[request userString]];
                    [oms.searchResultRouteVisit setStrLocationName:[request userString]];
                    break;
                }
                case 4:
                {
                    // 길찾기 도착지 현재위치 사용시
                    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
                    [oms.searchResultRouteDest setStrLocationAddress:[request userString]];
                    [oms.searchResultRouteDest setStrLocationName:[request userString]];
                    break;
                }
            }
            
            [json release];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
    }
}


- (ServerRequester *) requestGeocodingCoordForSearchRoute :(id)target action:(SEL)action type:(int)type x:(double)x y:(double)y dong:(int)dong searchType:(int)searchType
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    [request setUserInt:type];
    [request setUserObject:[NSNumber numberWithInt:searchType]];
	
    NSString *rawUrl = [NSString stringWithFormat:@"/v1/search/AddrNearestPosSearch2.json?PX=%d&PY=%d&DONG=%d&SRC_COORDTYPE=UTMK",(int)x, (int)y, dong];
    //NSString *refinedUrl = [self getEncodedTargetURL:rawUrl];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_GW, rawUrl]]];
    
	//NSLog(@"좌표-주소변환 URL : %@", [request URL]);
	
	[request setHTTPMethod:@"GET"];
    
    
    // 길찾기 "현재위치" 주소정보 검색시 오류메세지 리턴하지 않는다.
    [request useIndicator:NO];
    [request useErrorNotify:NO];
	
	[request addFinishTarget:self action:@selector(finishGeocodingCoordForSearchRoute:)];
    
	[request addFinishOuterTarget:target action:action];
    
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
	return request;
}
- (void) finishGeocodingCoordForSearchRoute :(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        @try
        {
            NSString *strReceiveJsonData = nil;
            
            // XML to JSON // 현재 서버가 XML형태로 넘겨주는 데이터를 JSON 스트링으로 변환한다.
            strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            // JSON 오브젝트 변환
            SBJSON *json = [[SBJSON alloc] init];
            NSDictionary *dic = [[[json objectWithString:strReceiveJsonData] objectForKeyGC:@"RESULTDATA"] objectAtIndexGC:0];;
            
            NSMutableString *strAddress = [NSMutableString string];
            
            NSString *sido = stringValueOfDictionary(dic, @"SIDO");
            
            if ( sido.length > 0 )
                [strAddress appendString:sido];
            
            if ([request userInt] != 10)
            {
                NSString *sigungu = stringValueOfDictionary(dic, @"SIGUNGU");
                NSString *dong = stringValueOfDictionary(dic, @"DONG");
                if ( sigungu.length > 0)
                    [strAddress appendFormat:@" %@", sigungu];
                if ( dong.length > 0 )
                    [strAddress appendFormat:@" %@", dong];
            }
            [request setUserString:strAddress];
            [json release];
            
            switch ( [request userInt] )
            {
                case 1:
                    [[OllehMapStatus sharedOllehMapStatus].searchResultRouteStart setStrLocationName:strAddress];
                    break;
                case 2:
                    [[OllehMapStatus sharedOllehMapStatus].searchResultRouteVisit setStrLocationName:strAddress];
                    break;
                case 3:
                    [[OllehMapStatus sharedOllehMapStatus].searchResultRouteDest setStrLocationName:strAddress];
                    break;
                    
                default:
                    break;
            }
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
    }
}

// *****************

// =================
// [ POI상세 method ]
// =================
#pragma mark - POI상세
/*
 @brief POI 상세 정보 조회 요청 함수
 @param target 콜백 타겟 클래스
 @param action 타겟 클래스 콜백함수
 @param poiId
 @return ServerRequest 정보를 리턴
 */
- (ServerRequester *)requestPoiDetailAtPoiId:(id)target action:(SEL)action poiId:(NSString *)poiId isSimple:(int)isSimple
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    [request setUserInt:isSimple];
    
    NSString *rawUrl = [NSString stringWithFormat:@"/v2/search/km2_PoiInfo.json?POI_ID=%@", poiId];
    
    //NSString *refinedUrl = [self getEncodedTargetURL:rawUrl];
    
    NSString *strIsSimple = [NSString stringWithFormat:@"&isSimple=%d", isSimple];
    
    // http:// m.ktgis.com:4555/tr/service.do?transType=GW&returnType=nop&targetUrl=XXXXX&isSimple=1
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@%@",COMMON_SERVER_GW, rawUrl, strIsSimple]]];
    
    NSLog(@"poi상세 URL : %@", [request URL]);
    
    [request setHTTPMethod:@"GET"];
    
    [request addFinishTarget:self action:@selector(finishPoiDetailAtPoiId:)];
    
    [request addFinishOuterTarget:target action:action];
    
    [self addHeaderForCommonGateway:request];
    
    [request sendRequest];
    
    return request;
    
}
- (ServerRequester *)requestPoiDetailAtPoiId:(id)target action:(SEL)action poiId:(NSString *)poiId
{
    return [self requestPoiDetailAtPoiId:target action:action poiId:poiId isSimple:0];
}

/*
 @brief requestPoiDetailAtPoiId POI 상세 정보 조회 콜백 함수
 */
- (void)finishPoiDetailAtPoiId:(id)request
{
	if ([request finishCode] == OMSRFinishCode_Completed)
	{
        
        @try
        {
            
            OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
            
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            //NSLog(@"POI상세 파싱 : %@", strReceiveJsonData);
            
            // JSON 오브젝트 변환
            SBJSON *json = [[SBJSON alloc] init];
            
            NSMutableDictionary *dic = [json objectWithString:strReceiveJsonData];
            [oms.poiDetailDictionary removeAllObjects];
            
            @try
            {
                if ( [[dic allKeys] containsObject:@"RESULTDATA"] && [[dic objectForKeyGC:@"RESULTDATA"] count] > 0)
                {
                    [oms.poiDetailDictionary setValuesForKeysWithDictionary:[[dic objectForKeyGC:@"RESULTDATA"] objectAtIndexGC:0]];
                    
                    // 심플모드일경우
                    if ( [request userInt] )
                    {
                        [request setUserObject:oms.poiDetailDictionary];
                    }
                    
                    //[request setUserObject:oms.poiDetailDictionary];
                }
                
                
                generalDic *gd = [[generalDic alloc] initAttribute:oms.poiDetailDictionary];
                
                NSLog(@"id = %@, name = %@, x = %@, y = %@", gd.testId, gd.testName, gd.testX, gd.testY);
                
                
                
            }
            @catch (NSException *exception)
            {
            }
            
            [json release];
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
	}
}
#pragma mark -
#pragma mark - 지하철상세
/*
 @brief 지하철역 정보 요청 함수
 @param target 콜백 타겟 클래스
 @param action 타겟 클래스 콜백함수
 @param stationId : 지하철역ID
 @return ServerRequest 정보를 리턴
 */
- (ServerRequester *)requestSubStation:(id)target action:(SEL)action stationId:(NSString *)stationId
{
    
    return [self requestTransSubStation:target action:action stationId:stationId counter:0 max:0];
}
//
- (ServerRequester *)requestTransSubStation:(id)target action:(SEL)action stationId:(NSString *)stationId counter:(int)counter max:(int)max
{
	ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
	
    [request setUserInt:counter];
    [request setUserInt2:max];
    
    NSString *rawUrl = [NSString stringWithFormat:@"/v1/masstransit/TrafficSubStationInfo.json?STID=%@", stationId];
	
    //NSString *refinedUrl = [rawUrl urlEncodeUsingEncoding:NSUTF8StringEncoding];
    //NSString *refinedUrl = [self getEncodedTargetURL:rawUrl];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_GW, rawUrl]]];
	
    NSLog(@"지하철 상세 url : %@", [request URL]);
    
	[request setHTTPMethod:@"GET"];
	
	[request addFinishTarget:self action:@selector(finishSubStation:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
	return request;
    
}

/*
 @brief requestSubStation 지하철역 정보 콜백 함수
 */
- (void)finishSubStation:(id)request
{
	if ([request finishCode] == OMSRFinishCode_Completed)
	{
        
        @try
        {
            
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            // JSON 오브젝트 변환
            
            //NSLog(@"지하철상세파싱 : %@", strReceiveJsonData);
            
            SBJSON *json = [[SBJSON alloc] init];
            
            NSMutableDictionary *dic = [json objectWithString:strReceiveJsonData];
            
            //NSLog(@"지하철상세 딕 : %@", dic);
            
            if([request userInt2] == 0)
            {
                [[OllehMapStatus sharedOllehMapStatus].subwayDetailDictionary removeAllObjects];
                
                [[OllehMapStatus sharedOllehMapStatus].subwayDetailDictionary setValuesForKeysWithDictionary:[dic objectForKeyGC:@"RESULTDATA"]];
            }
            
            else
            {
                [[OllehMapStatus sharedOllehMapStatus].subwayExistArr addObject:[[dic objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"LANEID"]];
                
                NSLog(@"%@", [OllehMapStatus sharedOllehMapStatus].subwayExistArr);
            }
            [json release];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
	}
	
}

#pragma mark - 지하철열차 시간
///*
// @brief 지하철역 열차 시간 정보 요청 함수
// @param target 콜백 타겟 클래스
// @param action 타겟 클래스 콜백함수
// @param STId : 지하철역ID
// @param DayType : 요일 타입 ( 0:모든요일 1:평일 2:토요일 3:일요일 )
// @return ServerRequest 정보를 리턴
// */
- (ServerRequester *)requestTrafficSubwayTime:(id)target action:(SEL)action STId:(NSString *)stationId DayType:(int)DayType
{
	ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
	
    NSString *rawUrl = [NSString stringWithFormat:@"/v1/masstransit/TrafficSubwayTime.json?STID=%@&DAYTYPE=%d", stationId, DayType];
	
    //NSString *refinedUrl = [rawUrl urlEncodeUsingEncoding:NSUTF8StringEncoding];
    //NSString *refinedUrl = [self getEncodedTargetURL:rawUrl];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_GW, rawUrl]]];
	
    NSLog(@"열차시간url %@", [request URL]);
	
	[request setHTTPMethod:@"GET"];
	
	[request addFinishTarget:self action:@selector(finishTrafficSubwayTime:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
	return request;
}

///*
// @brief requestTrafficSubwayTime 지하철역 열차 시간 정보 콜백 함수
// */
- (void)finishTrafficSubwayTime:(id)request
{
	if ([request finishCode] == OMSRFinishCode_Completed)
	{
        @try
        {
            
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            // JSON 오브젝트 변환
            
            //NSLog(@"%@", strReceiveJsonData);
            
            SBJSON *json = [[SBJSON alloc] init];
            
            NSMutableDictionary *dic = [json objectWithString:strReceiveJsonData];
            
            //NSMutableDictionary *dicDetail = [[NSMutableDictionary alloc] init];
            
            
            [[OllehMapStatus sharedOllehMapStatus].subwayTimeDictionary removeAllObjects];
            
            [[OllehMapStatus sharedOllehMapStatus].subwayTimeDictionary setValuesForKeysWithDictionary:[[dic objectForKeyGC:@"RESULTDATA"] objectAtIndexGC:0]];
            
            [json release];
            
        }
        @catch (NSException *exception)
        {
            //[request setFinishCode:OMSRFinishCode_Error];
            [request setFinishCode:OMSRFinishCode_Error_Parser];
        }
        
	}
	
    
}

#pragma mark - 지하철 출구정보

- (ServerRequester *)requestTrafficSubwayExit:(id)target action:(SEL)action STId:(NSString *)stationId
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    NSString *rawUrl = [NSString stringWithFormat:@"/subway/Gate/DJT_TrafficSubStationGate.jsp?SID=%@&OPT=2&OutPut=Json", stationId];
	
    //NSString *refinedUrl = [rawUrl urlEncodeUsingEncoding:NSUTF8StringEncoding];
    //NSString *refinedUrl = [self getEncodedTargetURL:rawUrl];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@", COMMON_SERVER_DJT, rawUrl]]];
	
    NSLog(@"지하철출구 url %@", [request URL]);
	
	[request setHTTPMethod:@"GET"];
	
	[request addFinishTarget:self action:@selector(finishTrafficSubwayExit:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
	return request;
    
}

- (void)finishTrafficSubwayExit:(id)request
{
    
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        @try
        {
            
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            // JSON 오브젝트 변환
            
            //NSLog(@"출구정보 파슁 : %@", strReceiveJsonData);
            
            SBJSON *json = [[SBJSON alloc] init];
            
            NSMutableDictionary *dic = [json objectWithString:strReceiveJsonData];
            
            //NSMutableDictionary *dicDetail = [[NSMutableDictionary alloc] init];
            
            NSLog(@"딕셔너리 : %@", dic);
            
            [[OllehMapStatus sharedOllehMapStatus].subwayExitDictionary removeAllObjects];
            
            [[OllehMapStatus sharedOllehMapStatus].subwayExitDictionary setValuesForKeysWithDictionary:[dic objectForKeyGC:@"result"]];
            
            [json release];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
    }
    
}
#pragma mark -
#pragma mark - 영화관 상세

- (ServerRequester *)requestMovieInfo:(id)target action:(SEL)action mId:(NSString *)mId
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    NSString *rawUrl = [NSString stringWithFormat:@"/v1/movie/TheaterDetailByTid.json?THCODE=%@" ,mId];
	
    //NSString *refinedUrl = [rawUrl urlEncodeUsingEncoding:NSUTF8StringEncoding];
    //NSString *refinedUrl = [self getEncodedTargetURL:rawUrl];
    
    //NSLog(@"URL 인코딩 %@", refinedUrl);
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_GW, rawUrl]]];
    
    
    NSLog(@"영화상세url : %@", [request URL]);
    
	[request setHTTPMethod:@"GET"];
    
    [request addFinishTarget:self action:@selector(finishMovieDetail:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
	return request;
    
    
    
    
}
- (void)finishMovieDetail:(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
	{
        @try
        {
            
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            // JSON 오브젝트 변환
            
            //        NSLog(@"제이스으은 : %@", strReceiveJsonData);
            
            SBJSON *json = [[SBJSON alloc] init];
            
            NSMutableDictionary *dic = [json objectWithString:strReceiveJsonData];
            
            //NSMutableDictionary *dicDetail = [[NSMutableDictionary alloc] init];
            
            
            [[OllehMapStatus sharedOllehMapStatus].movieDetailDictionary removeAllObjects];
            
            
            [[OllehMapStatus sharedOllehMapStatus].movieDetailDictionary setValuesForKeysWithDictionary:[dic objectForKeyGC:@"RESULTDATA"]];
            
            [json release];
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
    }
    
}


#pragma mark - 영화리스트

- (ServerRequester *)requestMovieList:(id)target action:(SEL)action mId:(NSString *)mId
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    NSString *rawUrl = [NSString stringWithFormat:@"/v1/movie/MovieListByTid.json?THCODE=%@" ,mId];
	
    //NSString *refinedUrl = [rawUrl urlEncodeUsingEncoding:NSUTF8StringEncoding];
    //NSString *refinedUrl = [self getEncodedTargetURL:rawUrl];
    
    
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_GW, rawUrl]]];
    
    
    //NSLog(@"%@", refinedUrl);
    
    NSLog(@"영화리스트 URL  %@", [request URL]);
    
	[request setHTTPMethod:@"GET"];
    
    [request addFinishTarget:self action:@selector(finishMovieListDetail:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
	return request;
    
}
- (void)finishMovieListDetail:(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
	{
        
        @try
        {
            
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            // JSON 오브젝트 변환
            
            //NSLog(@"%@", strReceiveJsonData);
            
            SBJSON *json = [[SBJSON alloc] init];
            
            NSMutableDictionary *dic = [json objectWithString:strReceiveJsonData];
            
            //NSMutableDictionary *dicDetail = [[NSMutableDictionary alloc] init];
            
            
            [[OllehMapStatus sharedOllehMapStatus].movieListDictionary removeAllObjects];
            
            [[OllehMapStatus sharedOllehMapStatus].movieListDictionary setValuesForKeysWithDictionary:[dic objectForKeyGC:@"RESULTDATA"]];
            
            [json release];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
    }
    
}

// =================
// [ 유가정보 method ]
// =================
#pragma mark -
#pragma mark - 유가정보
/*
 @brief POI 유가 정보 조회 요청 함수
 @param target 콜백 타겟 클래스
 @param action 타겟 클래스 콜백함수
 @param Uid
 @return ServerRequest 정보를 리턴
 */

// *****************
- (ServerRequester *)requestOilDetail:(id)target action:(SEL)action uId:(NSString *)uId
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    NSString *rawUrl = [NSString stringWithFormat:@"/Oil/DJT_OilResult.jsp?Uid=%@&OutPut=Json", uId];
	
    //NSString *refinedUrl = [rawUrl urlEncodeUsingEncoding:NSUTF8StringEncoding];
    //NSString *refinedUrl = [self getEncodedTargetURL:rawUrl];
    
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_DJT, rawUrl]]];
    
    
    NSLog(@"유가정보 url %@", [request URL]);
    
	[request setHTTPMethod:@"GET"];
    
    [request addFinishTarget:self action:@selector(finishOilDetail:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
	return request;
    
}
- (void)finishOilDetail:(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
	{
        @try
        {
            
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            // JSON 오브젝트 변환
            
            //NSLog(@"%@", strReceiveJsonData);
            
            SBJSON *json = [[SBJSON alloc] init];
            
            NSMutableDictionary *dic = [json objectWithString:strReceiveJsonData];
            
            //NSMutableDictionary *dicDetail = [[NSMutableDictionary alloc] init];
            
            
            [[OllehMapStatus sharedOllehMapStatus].oilDetailDictionary removeAllObjects];
            
            [[OllehMapStatus sharedOllehMapStatus].oilDetailDictionary setValuesForKeysWithDictionary:[dic objectForKeyGC:@"result"]];
            
            [json release];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
    }
    
}

// 콜링크
#pragma mark - CallLink -

- (ServerRequester *)requestCallLink:(id)target action:(SEL)action mid:(NSString*)mid caller:(NSString*)caller called:(NSString*)called
{
	ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
	[request setURL:[NSURL URLWithString:[NSString stringWithFormat:
                                          @"http://www.calllink.co.kr/ktppc/local_connect.jsp?cmd=send_ctc_mobile&mid=%@&caller=%@&called=%@",
										  mid,
										  caller,
										  called]]];
	
    NSLog(@"콜링크 URL : %@", request);
    
	[request setHTTPMethod:@"GET"];
	
	[request addFinishTarget:self action:@selector(finishCallLink:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[request sendRequest];
	
	return request;
}

/*
 @brief requestCallLink 콜백 함수
 */
- (void)finishCallLink:(id)request
{
	if ([request finishCode] == OMSRFinishCode_Completed)
	{
        @try
        {
            
            NSString *returnString = [[NSString alloc] initWithData:[request data] encoding:NSUTF8StringEncoding];
            
            NSLog(@"콜링크 파싱 : %@", returnString);
            
            [request setUserObject:returnString];
            
            [returnString release];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
	}
	
}

#pragma mark - 단축 URL 관련 -
/*
 @brief 단축 URL 정보 요청 함수 (정보를 단축 URL 로 바꾸어 준다.)
 @param target 콜백 타겟 클래스
 @param action 타겟 클래스 콜백함수
 @param PX : x 좌표
 @param PY : y 좌표
 @param Level : 맵 레벨
 @param Maptype : 맵 타입
 @param Name : 이름
 @param PID : ID 값
 @param ADDRESS : 주소
 @param TELEPHONE : 전화번호
 @param sendNum : 보낼타입
 @return ServerRequest 정보를 리턴
 */
- (ServerRequester *)requestShortenURL:(id)target action:(SEL)action PX:(int)PX PY:(int)PY Level:(int)Level MapType:(int)MapType Name:(NSString *)Name PID:(NSString *)PID Addr:(NSString *)addr Tel:(NSString *)tel Type:(NSString *)type ID:(NSString *)Id
{
    return [self requestShortenURL:target action:action PX:PX PY:PY Level:Level MapType:MapType Name:Name PID:PID Addr:addr Tel:tel Type:type ID:Id poiButton:nil];
}
- (ServerRequester *)requestShortenURL:(id)target action:(SEL)action PX:(int)PX PY:(int)PY Level:(int)Level MapType:(int)MapType Name:(NSString *)Name PID:(NSString *)PID Addr:(NSString *)addr Tel:(NSString *)tel Type:(NSString *)type ID:(NSString *)Id poiButton:(UIButton *)poiButton
{
	ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    [request setUserObject:poiButton];
    
    NSString *requestLongURL;
    
    NSString *mapStr;
    
    if (MapType == KMapTypeHybrid)
    {
        mapStr = @"air";
    }
    else
    {
        mapStr = @"";
    }
    
    requestLongURL = [NSString stringWithFormat:
                      @"http://%@/MMV/webViewer.html?x=%d&y=%d&level=%d&name=%@&pid=%@&maptype=%@&addr=%@&tel=%@&ptype=%@&id=%@", COMMON_MMV_SERVER,PX,PY,Level,Name,PID, mapStr, addr, tel, type, Id];
    
    
    // 구글 단축 url은 데이타 전송시 json 데이타로 만들어서 전송해야 한다.
    NSString *postBody = [NSString stringWithFormat:@"{\"longUrl\":\"%@\"}", requestLongURL];
    NSURL *url = [NSURL URLWithString:@"https://www.googleapis.com/urlshortener/v1/url"];
    [request setURL:url];
    
    
    NSLog(@"url >>>> [%@]", postBody);
    
    // 전송 방식 설정
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    
	[request addFinishTarget:self action:@selector(finishShortenURL:)];
    
	[request addFinishOuterTarget:target action:action];
    
	[request sendRequest];
    
	return request;
}

// 지도페이지
- (ServerRequester *)requestMapURL:(id)target action:(SEL)action PX:(int)PX PY:(int)PY PID:(NSString *)PID Name:(NSString *)Name Addr:(NSString *)addr Tel:(NSString *)tel poiButton:(UIButton *)poiButton detailType:(int)type mapType:(int)mapType
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    [request setUserObject:poiButton];
    
    
    NSString *mapTypeString = @"base";
    
    switch (mapType) {
        case KMapTypeHybrid:
            mapTypeString = @"hybrid";
            break;
        case KMapTypeSatellite:
            mapTypeString = @"air";
            break;
        default:
            mapTypeString = @"base";
            break;
    }
        
    NSMutableString *preUrl = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@ptype=m_map&x=%d&y=%d&pid=%@&name=%@&detailtype=%d&maptype=%@&zoom=10&coordtype=utmk", COMMON_URL_SHARE, PX, PY,PID, Name, type, mapTypeString]];

    if(![addr isEqualToString:@""])
    {
        [preUrl appendString:@"&addr="];
        [preUrl appendString:addr];
    }
    
    if(![tel isEqualToString:@""])
    {
        [preUrl appendString:@"&tel="];
        [preUrl appendString:tel];
    }
    
    NSLog(@"새로운 지도페이지 공유 url : %@", preUrl);
    
    // 구글 단축 url은 데이타 전송시 json 데이타로 만들어서 전송해야 한다.
    NSString *postBody = [NSString stringWithFormat:@"{\"longUrl\":\"%@\"}", preUrl];
    NSURL *url = [NSURL URLWithString:@"https://www.googleapis.com/urlshortener/v1/url"];
    [request setURL:url];
    
    
    NSLog(@"url >>>> [%@]", postBody);
    
    // 전송 방식 설정
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    
	[request addFinishTarget:self action:@selector(finishShortenURL:)];
    
	[request addFinishOuterTarget:target action:action];
    
	[request sendRequest];
    
	return request;
    
}

// 검색결과페이지
- (ServerRequester *)requestSearchURL:(id)target action:(SEL)action PX:(int)PX PY:(int)PY Query:(NSString *)query SearchType:(NSString *)searchType order:(NSString *)order
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    NSString *requestLongURL = [NSString stringWithFormat:
                                @"%@ptype=m_search&x=%d&y=%d&query=%@&searchtype=%@&order=%@&coordtype=utmk",COMMON_URL_SHARE,PX, PY,[query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], searchType, order];
    
    
    
    NSLog(@"새로운 검색결과페이지 공유 url : %@", requestLongURL);
    
    
    // 구글 단축 url은 데이타 전송시 json 데이타로 만들어서 전송해야 한다.
    NSString *postBody = [NSString stringWithFormat:@"{\"longUrl\":\"%@\"}", requestLongURL];
    NSURL *url = [NSURL URLWithString:@"https://www.googleapis.com/urlshortener/v1/url"];
    [request setURL:url];
    
    
    NSLog(@"url >>>> [%@]", postBody);
    
    // 전송 방식 설정
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    
	[request addFinishTarget:self action:@selector(finishShortenURL:)];
    
	[request addFinishOuterTarget:target action:action];
    
	[request sendRequest];
    
	return request;
    
}

// 상세페이지
- (ServerRequester *)requestDetailURL:(id)target action:(SEL)action PID:(NSString *)poi_id DetailType:(int)detailType Addr:(NSString *)addr StId:(NSString *)stId
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];

    
    NSMutableString *preURL = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@ptype=m_detail&detailtype=%d",COMMON_URL_SHARE, detailType]];
    
    NSString *stringFromURL = @"";
    
    // 주소타입이면 addr만
    if (detailType == 4)
        [preURL appendString:[NSString stringWithFormat:@"&addr=%@", addr]];
    // cctv타입이면 cctv만
    else if (detailType == 3)
        [preURL appendString:[NSString stringWithFormat:@"&cctvid=%@", poi_id]];
    else
    {
        if(![stId isEqualToString:@""])
            [preURL appendString:[NSString stringWithFormat:@"&stid=%@", stId]];
        
        if (![poi_id isEqualToString:@""])
            [preURL appendString:[NSString stringWithFormat:@"&poi_id=%@", poi_id]];
    }
    
    NSString *requestLongURL = [NSString stringWithFormat:@"%@%@", preURL, stringFromURL];
    
    NSLog(@"새로운 상세페이지 공유 url : %@", requestLongURL);
    
    // 구글 단축 url은 데이타 전송시 json 데이타로 만들어서 전송해야 한다.
    NSString *postBody = [NSString stringWithFormat:@"{\"longUrl\":\"%@\"}", requestLongURL];
    NSURL *url = [NSURL URLWithString:@"https://www.googleapis.com/urlshortener/v1/url"];
    [request setURL:url];
    
    
    NSLog(@"url >>>> [%@]", postBody);
    
    // 전송 방식 설정
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    
	[request addFinishTarget:self action:@selector(finishShortenURL:)];
    
	[request addFinishOuterTarget:target action:action];
    
	[request sendRequest];
    
	return request;
    
}


/*
 @brief requestShortenURL 단축 URL 정보 콜백 함수
 */
- (void)finishShortenURL:(id)request
{
    //NSLog(@"request >>>>>>> [ %@ ]", request);
	if ([request finishCode] == OMSRFinishCode_Completed)
	{
        
        @try
        {
            
            //		NSString *jsonString = [[NSString alloc] initWithData:[request data] encoding:NSUTF8StringEncoding];
            //		//NSLog(@"%@", jsonString);
            //
            //		SBJSON *json = [[SBJSON alloc] init];
            //		[DataBox sharedDataBox].ShortenURLDictionary = [json objectWithString:jsonString];
            //
            //        /*
            //         google --> goo.gl 단축 url
            //         "kind": "urlshortener#url",
            //         "id": "http://goo.gl/1yDb8",
            //         "longUrl":
            //         */
            //
            //        //NSLog(@"%@",[[[DataBox sharedDataBox].ShortenURLDictionary objectForKeyGC:@"data"]  objectForKeyGC:@"url"]);
            //		[json release];
            //
            //        //[xmlParser release];
            //		[jsonString release];
            
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            // JSON 오브젝트 변환
            
            //NSLog(@"단축 url 파싱 %@", strReceiveJsonData);
            
            SBJSON *json = [[SBJSON alloc] init];
            
            NSMutableDictionary *dic = [json objectWithString:strReceiveJsonData];
            
            [[OllehMapStatus sharedOllehMapStatus].shareDictionary removeAllObjects];
            
            [[OllehMapStatus sharedOllehMapStatus].shareDictionary setObject:[dic objectForKeyGC:@"id"] forKey:@"ShortURL"];
            
            [json release];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
	}
    else
    {
        // 리퀘스트 실패
    }
	
}


// ===================
// [ 예외처리 method ]
// ===================

- (ServerRequester *)requestExceptionLogging:(id)target action:(SEL)action exceptionMessage:(NSString*)exceptionMessage
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/ExceptionCallback", COMMON_SERVER_IP]]];
    
	[request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[NSString stringWithFormat:@"data=%@", exceptionMessage] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request useErrorNotify:NO];
	
	[request addFinishTarget:self action:@selector(finishExceptionLogging:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
	return request;
}

- (void)finishExceptionLogging:(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        @try
        {
            
            NSString *strReceiveJsonData = nil;
            // XML to JSON // 현재 서버가 XML형태로 넘겨주는 데이터를 JSON 스트링으로 변환한다.
            strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            NSLog(@"LOG:%@", strReceiveJsonData);
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
    }
}



#pragma mark -
#pragma mark - 공지사항
- (ServerRequester *)requestNoticeList:(id)target action:(SEL)action
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
	
    NSString *rawUrl = [NSString stringWithFormat:@"/NoticeList.json"];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_IP, rawUrl]]];
	
    NSLog(@"공지사항 url %@", [request URL]);
	
	[request setHTTPMethod:@"GET"];
	
	[request addFinishTarget:self action:@selector(finishNoticeList:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
	return request;
    
}
- (void) finishNoticeList:(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
	{
        
        @try
        {
            
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            // JSON 오브젝트 변환
            
            
            SBJSON *json = [[SBJSON alloc] init];
            
            NSArray *dic = [json objectWithString:strReceiveJsonData];
            
            [[OllehMapStatus sharedOllehMapStatus].noticeListDictionary removeAllObjects];
            
            NSMutableArray *dic2 = [[NSMutableArray alloc] init];
            for(NSMutableDictionary *d in dic)
            {
                NSString *str = [d objectForKeyGC:@"startDate"];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy.MM.dd HH.mm"];
                
                NSDate *date = [dateFormatter dateFromString:str];
                
                [d setValue:date forKey:@"sortDate"];
                [dateFormatter release];
                
                [dic2 addObject:d];
            }
            
            
            [[OllehMapStatus sharedOllehMapStatus].noticeListDictionary setObject:dic2 forKey:@"NOTICELIST"];
            
            [json release];
            [dic2 autorelease];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
    }
    
    
}
// 공지사항 상세
- (ServerRequester *)requestNoticeDetail:(id)target action:(SEL)action SeqNo:(int)SeqNo :(int)number
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    [request setUserInt:number];
    NSString *rawUrl = [NSString stringWithFormat:@"/NoticeDetail.json?seqNo=%d", SeqNo];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_IP, rawUrl]]];
	
    NSLog(@"공지사항 상세 url %@", [request URL]);
	
	[request setHTTPMethod:@"GET"];
	
	[request addFinishTarget:self action:@selector(finishNoticeDetail:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
	return request;
    
}

- (void) finishNoticeDetail:(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
	{
        
        @try
        {
            
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            // JSON 오브젝트 변환
            
            
            SBJSON *json = [[SBJSON alloc] init];
            
            NSMutableDictionary *dic = [json objectWithString:strReceiveJsonData];
            
            
            [[OllehMapStatus sharedOllehMapStatus].noticeDetailDictionary removeAllObjects];
            
            NSLog(@"userInt : %d", [request userInt]);
            
            int number = [request userInt];
            [[OllehMapStatus sharedOllehMapStatus].noticeDetailDictionary setObject:[NSString stringWithFormat:@"%d", number] forKey:@"SEQNUMBER"];
            
            [[OllehMapStatus sharedOllehMapStatus].noticeDetailDictionary setObject:dic forKey:@"NOTICEDETAIL"];
            
            [json release];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
    }
    
}
// 앱버전
- (ServerRequester *)requestAppVersion:(id)target action:(SEL)action
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
	
    NSString *rawUrl = [NSString stringWithFormat:@"/AppVersion.json"];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_IP, rawUrl]]];
	
    NSLog(@"앱버전 url %@", [request URL]);
	
	[request setHTTPMethod:@"GET"];
	
	[request addFinishTarget:self action:@selector(finishVersion:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
	return request;
    
}
- (void) finishVersion:(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
	{
        
        @try
        {
            
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            // JSON 오브젝트 변환
            SBJSON *json = [[SBJSON alloc] init];
            
            NSMutableDictionary *dic = [json objectWithString:strReceiveJsonData];
            
            [[OllehMapStatus sharedOllehMapStatus].appVersionDictionary removeAllObjects];
            
            [[OllehMapStatus sharedOllehMapStatus].appVersionDictionary setObject:dic forKey:@"VERSION"];
            
            [json release];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
    }
    
}
#pragma mark -
#pragma mark - 테마관련

// 테마버전
- (ServerRequester *)requestThemeVersion:(id)target action:(SEL)action
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
	
    NSString *rawUrl = [NSString stringWithFormat:@"/Theme/Version.json?device=%@", [OllehMapStatus sharedOllehMapStatus].deviceDisplayID ];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_IP, rawUrl]]];
	
    NSLog(@"테마버전 URL : %@", [request URL]);
	
	[request setHTTPMethod:@"GET"];
	
	[request addFinishTarget:self action:@selector(finishThemeVersion:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
	return request;
    
}
- (void) finishThemeVersion:(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
	{
        @try
        {
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            // JSON 오브젝트 변환
            SBJSON *json = [[SBJSON alloc] init];
            
            NSMutableDictionary *dic = [json objectWithString:strReceiveJsonData];
            
            if ( dic )
            {
                NSMutableDictionary *themeVersionInfo = [[NSMutableDictionary alloc] init];
                for (NSString *key in [dic allKeys] )
                {
                    [themeVersionInfo setObject:[dic objectForKeyGC:key] forKey:key];
                }
                [request setUserObject:themeVersionInfo];
                [themeVersionInfo release];
            }
            else // 정보가 존재하지 않을 경우 오류처리
            {
                [request setFinishCode:OMSRFinishCode_Error];
            }
            
            [json release];
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
    }
    
}


// 테마검색
- (ServerRequester *)requestThemeInfoList:(id)target action:(SEL)action version:(NSString *)ver
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    NSString *rawUrl = [NSString stringWithFormat:@"/Theme/ListInfo.json?version=%@&device=%@", ver, [OllehMapStatus sharedOllehMapStatus].deviceDisplayID];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_IP, rawUrl]]];
	
    NSLog(@"테마리스트 정보 URL : %@", [request URL]);
	
	[request setHTTPMethod:@"GET"];
	
	[request addFinishTarget:self action:@selector(finishThemeInfoList:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
	return request;
    
}
- (void) finishThemeInfoList:(id)request
{
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        @try
        {
            
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            SBJSON *json = [[SBJSON alloc] init];
            
            NSArray *sourceThemeInfoList = [json objectWithString:strReceiveJsonData];
            
            // 기존 검색결과 클리어
            [[OllehMapStatus sharedOllehMapStatus].themeInfoList removeAllObjects];
            [[OllehMapStatus sharedOllehMapStatus].themeInfoList addObjectsFromArray:sourceThemeInfoList];
            
            [json release];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
    }
}

- (ServerRequester *) requestThemeInfoImageDownload :(id)target action:(SEL)action downloadList:(NSArray*)downloadList downloadIndex:(NSInteger)downloadIndex
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    [request setUserObject:downloadList];
    [request setUserInt:downloadIndex];
    
    NSString *url = [[downloadList objectAtIndexGC:downloadIndex] objectForKeyGC:@"URL"];
    [request setURL:[NSURL URLWithString: [NSString stringWithFormat:@"http://%@%@", COMMON_SERVER_IP, url] ]];
	
    NSLog(@"테마 이미지 다운로드 URL : %@", [request URL]);
    
    [request useIndicator:NO];
    [request useErrorNotify:NO];
    
	[request setHTTPMethod:@"GET"];
	
	[request addFinishTarget:self action:@selector(finishThemeInfoImageDownload:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest :50];
	
    return request;
}
- (void) finishThemeInfoImageDownload :(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        @try
        {
            NSArray *downloadList = (NSArray*)[request userObject];
            NSInteger downloadIndex = [request userInt];
            NSString *filename = stringValueOfDictionary([downloadList objectAtIndexGC:downloadIndex], @"FILENAME");
            
            // 다운로드 받은 데이터 파일로 생성
            NSData *fileData = [request data];
            BOOL success = [self CreateThemeImage:fileData :filename];
            
            // 파일 생성 결과를 리턴함
            if ( success == NO )
                [request setFinishCode:OMSRFinishCode_Error];
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
    }
}
- (BOOL) CreateThemeImage :(NSData*)fileData :(NSString*)filename
{
	
	/////////////////////////////////////////////////////////////////////////////
	// 파일 시스템의 디렉터리 및 파일 준비
    
    // Documents 경로생성
	NSArray *documentsDirecotryPathArray = NSSearchPathForDirectoriesInDomains(
                                                                               NSDocumentDirectory,
                                                                               NSUserDomainMask,
                                                                               YES);
	NSString *documentsDirectoryPath = [documentsDirecotryPathArray objectAtIndexGC:0];
    // 도큐먼트 이미지 파일 경로
    NSString *documentImageFilePath = [NSString stringWithFormat:@"%@/Theme/%@%@.PNG", documentsDirectoryPath, filename, [OllehMapStatus sharedOllehMapStatus].isRetinaDisplay ? @"@2x" : @""];
    
    // 임시폴더 경로
    NSString *temporaryDirectoryPath = NSTemporaryDirectory();
    // 다운로드파일 전체경로
    NSString *downloadFilePath = [NSString stringWithFormat:@"%@/ThemeTempImage.PNG", temporaryDirectoryPath];
	NSLog(@"테마이미지 임시 다운경로 : %@", downloadFilePath);
    
	// 먼저 파일을 생성한다.
	[[NSFileManager defaultManager] createFileAtPath:downloadFilePath contents:nil attributes:nil];
	
	////////////////////////////////////////////////////////////////////////
	// 파일을 연다.
    NSFileHandle *hFile = [NSFileHandle fileHandleForWritingAtPath:downloadFilePath];
	if ( hFile == nil )
	{
		NSLog(@"no file to write");
        return NO;
	}
	
	// 파일을 쓰고 파일 포인터를 전진하고 파일을 닫는다.
    NSLog(@"%d", fileData.length);
	[hFile writeData:fileData];
    [hFile truncateFileAtOffset:fileData.length];
    [hFile closeFile];
	
	
	////////////////////////////////////////////////////////////////////////
	// 파일을 연다.
    NSFileHandle *hFile2 = [NSFileHandle fileHandleForReadingAtPath:downloadFilePath];
	if ( hFile2 == nil )
	{
		NSLog(@"no file to read");
        return NO;
	}
    // 파일 핸들러 해제
    [hFile2 closeFile];
    
    
    NSError *copyError;
    
    if ( [[NSFileManager defaultManager] fileExistsAtPath:documentImageFilePath]  && ! [[NSFileManager defaultManager] removeItemAtPath:documentImageFilePath error:&copyError] )
    {
        NSLog(@"기존 이미지 삭제 실패 : %@ => %@", documentImageFilePath, copyError.localizedDescription);
        return NO;
    }
    else if ( ! [[NSFileManager defaultManager] copyItemAtPath:downloadFilePath toPath:documentImageFilePath error:&copyError] )
    {
        NSLog(@"이미지 교체 실패 : %@", copyError.localizedDescription);
        return NO;
    }
    else if (  ! [[NSFileManager defaultManager] removeItemAtPath:downloadFilePath error:&copyError] )
    {
        NSLog(@"이미지 임시다운로드 파일 삭제 실패 : %@", copyError.localizedDescription);
        return NO;
    }
    
    return YES;
}

- (ServerRequester *)requestThemeDetail:(id)target action:(SEL)action themeCode:(NSString *)themeCode pX:(int)px pY:(int)py radius:(int)rad
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
	
    NSString *rawUrl = [NSString stringWithFormat:@"/Theme/Search.json?code=%@&px=%d&py=%d&radius=%d", themeCode, px, py, rad];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_IP, rawUrl]]];
	
    NSLog(@"테마상세 url %@", [request URL]);
	
	[request setHTTPMethod:@"GET"];
    
    [request useErrorNotify:NO];
    [request useIndicator:NO];
	
	[request addFinishTarget:self action:@selector(finishThemeDetail:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
	return request;
    
}
- (void) finishThemeDetail:(id)request
{
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        @try
        {
            
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            SBJSON *json = [[SBJSON alloc] init];
            
            NSMutableArray *themeDetailList = [json objectWithString:strReceiveJsonData];
            
            //[[OllehMapStatus sharedOllehMapStatus].themeSearchResultList removeAllObjects];
            NSMutableArray *tempList = [[NSMutableArray alloc] init];
            [OllehMapStatus sharedOllehMapStatus].themeSearchResultList = tempList;
            [tempList release];
            
            if (themeDetailList && themeDetailList.count>0)
                [[OllehMapStatus sharedOllehMapStatus].themeSearchResultList addObjectsFromArray:themeDetailList];
            
            [json release];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
    }
    
}
// *******************


// ===================
// [ 추천검색어 method ]
// ===================

- (ServerRequester *) requestRecommendWordVersion :(id)target action:(SEL)action;
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
	
    NSString *rawUrl = [NSString stringWithFormat:@"/AutoCompleteVersion.json"];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_IP, rawUrl]]];
	
    [request useIndicator:NO];
    
	[request setHTTPMethod:@"GET"];
	
	[request addFinishTarget:self action:@selector(finishRecommendWordVersion:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
	return request;
}

- (void) finishRecommendWordVersion :(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
	{
        
        @try
        {
            
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            SBJSON *json = [[SBJSON alloc] init];
            NSMutableDictionary *dic = [json objectWithString:strReceiveJsonData];
            
            NSString *hash = [NSString stringWithFormat:@"%@", [dic objectForKeyGC:@"hash"]];
            int updateVersion = [[dic objectForKeyGC:@"version"] intValue];
            int updateSize = [[dic objectForKeyGC:@"size"] intValue];
            
            [request setUserString:hash];
            [request setUserInt:updateVersion];
            [request setUserObject:[NSNumber numberWithInt:updateSize]];
            
            [json release];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
    }
    else
    {
        //실패했을 경우 무시하자..
    }
    
}

- (ServerRequester *) requestRecommendWordDownload :(id)target action:(SEL)action version:(int)version hash:(NSString*)hash
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    [request setUserString:hash];
    [request setUserInt:version];
	
    NSString *rawUrl = [NSString stringWithFormat:@"/AutoComplete.file?version=%d", version];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_IP, rawUrl]]];
	
    NSLog(@"추천검색어 다운로드 URL : %@", [request URL]);
    
    [request useIndicator:NO];
    [request useErrorNotify:NO];
    
	[request setHTTPMethod:@"GET"];
	
	[request addFinishTarget:self action:@selector(finishRecommendWordDownload:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest :60];
	
    return request;
}
- (void) finishRecommendWordDownload :(id)request
{
    
    if ([request finishCode] == OMSRFinishCode_Completed)
	{
        
        @try
        {
            
            // 다운로드 받은 데이터 파일로 생성
            NSData *fileData = [request data];
            BOOL success = [self CreateRecommendDataFile:fileData :[request userInt] :[request userString]];
            // 파일 생성 결과를 리턴함
            [request setUserObject:[NSNumber numberWithBool:success]];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
    }
    else
    {
        //실패했을 경우 무시하자..
    }
    
}
- (BOOL) CreateRecommendDataFile :(NSData*)fileData :(int)version   :(NSString*)hash
{
	
	/////////////////////////////////////////////////////////////////////////////
	// 파일 시스템의 디렉터리 및 파일 준비
    
    // Documents 경로생성
	NSArray *documentsDirecotryPathArray = NSSearchPathForDirectoriesInDomains(
                                                                               NSDocumentDirectory,
                                                                               NSUserDomainMask,
                                                                               YES);
	NSString *documentsDirectoryPath = [documentsDirecotryPathArray objectAtIndexGC:0];
    
    // 임시폴더 경로
    NSString *temporaryDirectoryPath = NSTemporaryDirectory();
    //NSString *temporaryDirectoryPath = [NSString stringWithFormat:@"%@/tmp", NSHomeDirectory()];
    
    // 다운로드파일 전체경로
    NSString *downloadFilePath = [NSString stringWithFormat:@"%@/RecommendWord.download", temporaryDirectoryPath];
	NSLog(@"추천검색어 임시 다운경로 : %@", downloadFilePath);
    
	// 먼저 파일을 생성한다.
	[[NSFileManager defaultManager] createFileAtPath:downloadFilePath contents:nil attributes:nil];
	
	////////////////////////////////////////////////////////////////////////
	// 파일을 연다.
    NSFileHandle *hFile = [NSFileHandle fileHandleForWritingAtPath:downloadFilePath];
	if ( hFile == nil )
	{
		NSLog(@"no file to write");
        return NO;
	}
	
	// 파일을 쓰고 파일 포인터를 전진하고 파일을 닫는다.
    NSLog(@"%d", fileData.length);
	[hFile writeData:fileData];
    [hFile truncateFileAtOffset:fileData.length];
    [hFile closeFile];
	
	
	////////////////////////////////////////////////////////////////////////
	// 파일을 연다.
    BOOL isValidFileHashValue = NO;
    NSFileHandle *hFile2 = [NSFileHandle fileHandleForReadingAtPath:downloadFilePath];
	if ( hFile2 == nil )
	{
		NSLog(@"no file to read");
        return NO;
	}
    else
    {
        CFStringRef md5hash = FileMD5HashCreateWithPath((CFStringRef)downloadFilePath, FileHashDefaultChunkSizeForReadingData);
        NSLog(@"MD5 hash of file at path \"%@\": %@", downloadFilePath, (NSString *)md5hash);
        isValidFileHashValue = [hash isEqualToString:(NSString*)md5hash] ;
        if ( md5hash )
            CFRelease(md5hash);
    }
    // 파일 핸들러 해제
    [hFile2 closeFile];
    
    
    // 파일 hash체크까지 통과됐으면 실제 추천검색어 파일을 덮어쓰도록 한다.
    if (isValidFileHashValue)
    {
        // 기존 추천검색어 파일 경로
        NSString *filePathPrevious = [NSString stringWithFormat:@"%@/RecommendWord.sqlite", documentsDirectoryPath];
        
        // 기존파일 삭제후 새 파일로 대체
        NSError *copyError;
        
        if ( [[NSFileManager defaultManager] fileExistsAtPath:filePathPrevious]  && ! [[NSFileManager defaultManager] removeItemAtPath:filePathPrevious error:&copyError] )
        {
            NSLog(@"추천검색어 기존 DB파일 삭제 실패 : %@ => %@", filePathPrevious, copyError.localizedDescription);
            return NO;
        }
        else if ( ! [[NSFileManager defaultManager] copyItemAtPath:downloadFilePath toPath:filePathPrevious error:&copyError] )
        {
            NSLog(@"추천검색어 DB파일 교체 실패 : %@", copyError.localizedDescription);
            return NO;
        }
        else if (  ! [[NSFileManager defaultManager] removeItemAtPath:downloadFilePath error:&copyError] )
        {
            NSLog(@"추천검색어 임시다운로드 파일 삭제 실패 : %@", copyError.localizedDescription);
        }
        
    }
    
    return isValidFileHashValue;
    
}

// ===================
// [디바이스 정보 method ]
// ===================
- (ServerRequester *) requestDeviceDisplay:(id)target action:(SEL)action
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
	
    NSString *platform = [[OllehMapStatus sharedOllehMapStatus] getDeviceModel];
#ifdef DEBUG // 디버깅모드-시뮬레이터일때 아이폰3Gs / 아이폰4 로 기본값 변경셋팅.
    if ( [platform isEqualToString:@"x86_64"] || [platform isEqualToString:@"i386"] )
    {
        if ( [[OllehMapStatus sharedOllehMapStatus] isRetinaDisplay] )
            platform = @"iPhone3,1";
        else
            platform = @"iPhone2,1";
    }
#endif
    
    NSString *rawUrl = [NSString stringWithFormat:@"/Device/DisplayQuery.json?category=apple&model=%@", platform];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_IP, rawUrl]]];
	
    NSLog(@"단말기 해상도정보 URL : %@", [request URL]);
    
	[request setHTTPMethod:@"GET"];
	
	[request addFinishTarget:self action:@selector(finishDeviceDisplay:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
    return request;
}
- (void) finishDeviceDisplay:(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
        
        // JSON 오브젝트 변환
        SBJSON *json = [[SBJSON alloc] init];
        NSDictionary *deviceDisplay = [json objectWithString:strReceiveJsonData];
        [json release];
        
        [OllehMapStatus sharedOllehMapStatus].deviceDisplayID = stringValueOfDictionary(deviceDisplay, @"id");
    }
    else
    {
        [request setUserObject:nil];
    }
}


// ===================
// [메인공지사항 method ]
// ===================
- (ServerRequester *) requestNoticePopup :(id)target  action:(SEL)action
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
	
    NSString *rawUrl = [NSString stringWithFormat:@"/NoticePopup.json"];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_IP, rawUrl]]];
	
    NSLog(@"팝업공지 URL : %@", [request URL]);
    
    [request useIndicator:NO];
    [request useErrorNotify:NO];
    
	[request setHTTPMethod:@"GET"];
	
	[request addFinishTarget:self action:@selector(finishNoticePopup:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest :60];
	
    return request;
}
- (void) finishNoticePopup :(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
	{
        @try
        {
            
            NSString *strReceiveJsonData = nil;
            
            // XML to JSON // 현재 서버가 XML형태로 넘겨주는 데이터를 JSON 스트링으로 변환한다.
            strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            NSLog(@"%@", strReceiveJsonData);
            // JSON 오브젝트 변환
            SBJSON *json = [[SBJSON alloc] init];
            [request setUserObject:[json objectWithString:strReceiveJsonData]];
            [json release];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
    }
    else
    {
        //실패했을 경우 무시하자..
    }
}

- (ServerRequester *) requestJoinInfo:(id)target action:(SEL)action phoneNum:(NSString *)phoneNumber
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
	
    NSString *rawUrl = [NSString stringWithFormat:@"/Khub/JoinInfoManage.json?REQ_MDN=%@&SVC_TYPE=", phoneNumber];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_IP, rawUrl]]];
	
    NSLog(@"khub URL : %@", [request URL]);
    
    [request useIndicator:NO];
    [request useErrorNotify:NO];
    
	[request setHTTPMethod:@"GET"];
	
	[request addFinishTarget:self action:@selector(finishJoinInfo:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest];
	
    return request;
    
}
- (void) finishJoinInfo:(id)request
{
    if([request finishCode] == OMSRFinishCode_Completed)
    {
        @try
        
        {
            
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            SBJSON *json = [[SBJSON alloc] init];
            
            NSMutableDictionary *dic = [json objectWithString:strReceiveJsonData];
            
            NSLog(@"khub : %@", dic);
            
            if (dic)
            {
                NSMutableDictionary *JoinInfo = [[NSMutableDictionary alloc] init];
                for (NSString *key in [dic allKeys] )
                {
                    [JoinInfo setObject:[dic objectForKeyGC:key] forKey:key];
                }
                [request setUserObject:JoinInfo];
                [JoinInfo release];
            }
            else // 정보가 존재하지 않을 경우 오류처리
            {
                [request setFinishCode:OMSRFinishCode_Error];
            }
            
            [json release];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
    }
    
}


// ===========================
// [ 교통옵션 method ]
// ===========================
#pragma mark -
#pragma mark - CCTV API
- (ServerRequester*) requestTrafficOptionCCTVList :(id)target action:(SEL)action minX:(float)minX minY:(float)minY maxX:(float)maxX maxY:(float)maxY
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    NSString *rawUrl = [NSString stringWithFormat:@"/CCTV/RangeList.json?px=%f,%f&py=%f,%f", minX, maxX, minY, maxY ];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@", COMMON_SERVER_IP, rawUrl]]];
    
    NSLog(@"교통옵션 CCTV목록 호출  URL : %@", [request URL]);
    
    [request setHTTPMethod:@"GET"];
    
    [request useIndicator:NO];
    
    [request addFinishTarget:self action:@selector(finishTrafficOptionCCTVList:)];
    
    [request addFinishOuterTarget:target action:action];
    
    [self addHeaderForCommonGateway:request];
    
    [request sendRequest];
    
    return request;
}
- (void) finishTrafficOptionCCTVList :(ServerRequester*)request
{
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        @try
        {
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            SBJSON *json = [[SBJSON alloc] init];
            NSMutableArray *cctvList = [json objectWithString:strReceiveJsonData];
            [json release];
            
            [request setUserObject:cctvList];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        @finally
        {
        }
    }
}
- (ServerRequester*) requestTrafficOptionCCTVInfo:(id)target action:(SEL)action cctvid:(NSString *)cctvid cctvCoordinate:(Coord)cctvCoordinate
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    NSMutableDictionary *cctvInfo = [[NSMutableDictionary alloc] init];
    [cctvInfo setObject:cctvid forKey:@"id"];
    [cctvInfo setObject:[NSNumber numberWithDouble:cctvCoordinate.x] forKey:@"x"];
    [cctvInfo setObject:[NSNumber numberWithDouble:cctvCoordinate.y] forKey:@"y"];
    [request setUserObject:cctvInfo];
    [cctvInfo release];
    
    NSString *rawUrl = [NSString stringWithFormat:@"/CCTV/Streaming.json?id=%@", cctvid];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@", COMMON_SERVER_IP, rawUrl]]];
    
    NSLog(@"교통옵션 CCTV 정보  URL : %@", [request URL]);
    
    [request setHTTPMethod:@"GET"];
    
    [request useIndicator:YES];
    
    [request addFinishTarget:self action:@selector(finishTrafficOptionCCTVInfo:)];
    
    [request addFinishOuterTarget:target action:action];
    
    [self addHeaderForCommonGateway:request];
    
    [request sendRequest];
    
    return request;
    
}
- (void) finishTrafficOptionCCTVInfo :(ServerRequester*)request
{
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        @try
        {
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            SBJSON *json = [[SBJSON alloc] init];
            NSMutableDictionary *cctvInfoContainer = [json objectWithString:strReceiveJsonData];
            [json release];
            
            NSDictionary *cctvInfoUnderRequest = (NSDictionary*)[request userObject];
            for (NSString *key in [cctvInfoUnderRequest allKeys])
            {
                [cctvInfoContainer setObject:[cctvInfoUnderRequest objectForKeyGC:key] forKey:key];
            }
            
            [request setUserObject:cctvInfoContainer];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        @finally
        {
        }
    }
}
#pragma mark -
#pragma mark - Traffic API
- (ServerRequester*) requestTrafficOptionBusStationList:(id)target action:(SEL)action coordidate:(Coord)coordinate radius:(int)radius
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    NSString *rawUrl = [NSString stringWithFormat:@"/Bus/RadiusList.json?px=%.0f&py=%.0f&radius=%d", coordinate.x, coordinate.y, radius];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@", COMMON_SERVER_IP, rawUrl]]];
    
    NSLog(@"교통옵션 버스정류장 목록 호출  URL : %@", [request URL]);
    
    [request setHTTPMethod:@"GET"];
    
    [request useIndicator:NO];
    
    [request addFinishTarget:self action:@selector(finishTrafficOptionBusStationList:)];
    
    [request addFinishOuterTarget:target action:action];
    
    [self addHeaderForCommonGateway:request];
    
    [request sendRequest];
    
    return request;
}
- (void) finishTrafficOptionBusStationList :(ServerRequester*)request
{
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        @try
        {
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            SBJSON *json = [[SBJSON alloc] init];
            NSMutableDictionary *busStationListContainer = [json objectWithString:strReceiveJsonData];
            [json release];
            
            [request setUserObject:busStationListContainer];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        @finally
        {
        }
    }
}
- (ServerRequester*) requestTrafficOptionSubwayStationList:(id)target action:(SEL)action coordidate:(Coord)coordinate radius:(int)radius
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    NSString *rawUrl = [NSString stringWithFormat:@"/Metro/RadiusList.json?px=%.0f&py=%.0f&radius=%d", coordinate.x, coordinate.y, radius];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@", COMMON_SERVER_IP, rawUrl]]];
    
    NSLog(@"교통옵션 지하철역 목록 호출  URL : %@", [request URL]);
    
    [request setHTTPMethod:@"GET"];
    
    [request useIndicator:NO];
    
    [request addFinishTarget:self action:@selector(finishTrafficOptionSubwayStationList:)];
    
    [request addFinishOuterTarget:target action:action];
    
    [self addHeaderForCommonGateway:request];
    
    [request sendRequest];
    
    return request;
}
- (void) finishTrafficOptionSubwayStationList :(ServerRequester*)request
{
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        @try
        {
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            SBJSON *json = [[SBJSON alloc] init];
            NSMutableDictionary *subwayStationListContainer = [json objectWithString:strReceiveJsonData];
            [json release];
            
            [request setUserObject:subwayStationListContainer];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        @finally
        {
        }
    }
}
#pragma mark -
#pragma mark - Map realTime API
- (ServerRequester *)requestTrafficRealtimeBusTimeTable :(id)target action:(SEL)action busid:(NSString*)busid
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    [request setUserString:busid];
    
    NSString *rawUrl = [NSString stringWithFormat:@"/Bus/CurrentTraffic.json?id=%@", busid];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@", COMMON_SERVER_IP, rawUrl]]];
    
    NSLog(@"버스 실시간 정보  URL : %@", [request URL]);
    
    [request setHTTPMethod:@"GET"];
    
    [request useIndicator:YES];
    
    [request addFinishTarget:self action:@selector(finishTrafficRealtimeBusTimeTable:)];
    
    [request addFinishOuterTarget:target action:action];
    
    [self addHeaderForCommonGateway:request];
    
    [request sendRequest];
    
    return request;
}
- (void) finishTrafficRealtimeBusTimeTable :(ServerRequester*)request
{
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        @try
        {
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            SBJSON *json = [[SBJSON alloc] init];
            NSMutableDictionary *timetableContainer = [json objectWithString:strReceiveJsonData];
            [json release];
            
            [request setUserObject:timetableContainer];
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        @finally
        {
        }
    }
}

- (ServerRequester *)requestTrafficRealtimeSubwayTimeTable :(id)target action:(SEL)action subwayid:(NSString*)subwayid
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    [request setUserString:subwayid];
    
    NSString *rawUrl = [NSString stringWithFormat:@"/Metro/CurrentTraffic.json?id=%@", subwayid];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@", COMMON_SERVER_IP, rawUrl]]];
    
    NSLog(@"지하철 실시간 정보  URL : %@", [request URL]);
    
    [request setHTTPMethod:@"GET"];
    
    [request useIndicator:YES];
    
    [request addFinishTarget:self action:@selector(finishTrafficRealtimeSubwayTimeTable:)];
    
    [request addFinishOuterTarget:target action:action];
    
    [self addHeaderForCommonGateway:request];
    
    [request sendRequest];
    
    return request;
}
- (void) finishTrafficRealtimeSubwayTimeTable :(ServerRequester*)request
{
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        @try
        {
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            SBJSON *json = [[SBJSON alloc] init];
            NSArray *timetableContainer = [json objectWithString:strReceiveJsonData];
            [json release];
            
            [request setUserObject:timetableContainer];
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        @finally
        {
        }
    }
}


#pragma mark -
#pragma mark - busStation API
- (ServerRequester *) requestBusStationInfoUniqueId:(id)target action:(SEL)action uniqueId:(NSString *)uniqueId cityCode:(NSString *)cityCode
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    NSString *rawUrl = [NSString stringWithFormat:@"/Bus/GetBusStationDetail.json?STATIONNO=%@&CITYCODE=%@", uniqueId, cityCode];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_IP, rawUrl]]];
    
    NSLog(@"새로운 버스정류장 검색 URL : %@", [request URL]);
    
    [request setHTTPMethod:@"GET"];
    
    [request addFinishTarget:self action:@selector(finishNewBusStationInfo:)];
    
    [request addFinishOuterTarget:target action:action];
    
    [self addHeaderForCommonGateway:request];
    
    [request sendRequest:10];
    
    return request;
    
}
- (ServerRequester *) requestBusStationInfoStid:(id)target action:(SEL)action stId:(NSString *)stationId
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    NSString *rawUrl = [NSString stringWithFormat:@"/Bus/GetBusStationDetail.json?STID=%@", stationId];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_IP, rawUrl]]];
    
    NSLog(@"새로운 버스정류장 검색 URL : %@", [request URL]);
    
    [request setHTTPMethod:@"GET"];
    
    [request addFinishTarget:self action:@selector(finishNewBusStationInfo:)];
    
    [request addFinishOuterTarget:target action:action];
    
    [self addHeaderForCommonGateway:request];
    
    [request sendRequest:10];
    
    return request;
    
}
- (void)finishNewBusStationInfo:(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
	{
        @try
        {
            
            
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            // JSON 오브젝트 변환
            
            //NSLog(@"버정상세 파싱 : %@", strReceiveJsonData);
            
            SBJSON *json = [[SBJSON alloc] init];
            
            NSMutableDictionary *dic = [json objectWithString:strReceiveJsonData];
            
            NSLog(@"%@", dic);
            
            
            [[OllehMapStatus sharedOllehMapStatus].busStationNewDictionary removeAllObjects];
            
            [[OllehMapStatus sharedOllehMapStatus].busStationNewDictionary setValuesForKeysWithDictionary:dic];
            [json release];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
    }
}
#pragma mark -
#pragma mark - busNumber API
- (ServerRequester *)requestBusNumberInfo:(id)target action:(SEL)action laneId:(NSString *)laneId
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
	
    NSString *rawUrl = [NSString stringWithFormat:@"/Bus/GetBusLineDetail.json?LANEID=%@", laneId];
	
    //NSString *refinedUrl = [self getEncodedTargetURL:rawUrl];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_IP, rawUrl]]];
	
    NSLog(@"새로운 버스노선url %@", [request URL]);
	
	[request setHTTPMethod:@"GET"];
	
	[request addFinishTarget:self action:@selector(finishBusNumberInfo:)];
    
	[request addFinishOuterTarget:target action:action];
	
	[self addHeaderForCommonGateway:request];
	
	[request sendRequest:10];
	
	return request;
    
}
- (void)finishBusNumberInfo:(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
	{
        
        @try
        {
            
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            // JSON 오브젝트 변환
            
            //NSLog(@"버스노선상세 파싱 : %@", strReceiveJsonData);
            
            SBJSON *json = [[SBJSON alloc] init];
            
            NSMutableDictionary *dic = [json objectWithString:strReceiveJsonData];
            
            //NSMutableDictionary *dicDetail = [[NSMutableDictionary alloc] init];
            
            [[OllehMapStatus sharedOllehMapStatus].busNumberNewDictionary removeAllObjects];
            
            
            [[OllehMapStatus sharedOllehMapStatus].busNumberNewDictionary setValuesForKeysWithDictionary:dic];
            
            [json release];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
	}
    
    
}

- (ServerRequester *)requestBusRouteId:(id)target action:(SEL)action arsId:(NSString *)laneId
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    NSString *rawUrl = [NSString stringWithFormat:@"/v1/getTopisBusidByAid.json?ablId=%@", laneId];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_BIS, rawUrl]]];
    
    NSLog(@"BIS laneID로 RouteID 찾기 URL : %@", [request URL]);
    
    [request setHTTPMethod:@"GET"];
    
    [request addFinishTarget:self action:@selector(finishBusRouteId:)];
    
    [request addFinishOuterTarget:target action:action];
    
    [self addHeaderForCommonGateway:request];
    
    [request sendRequest];
    
    return request;
    
}
- (void)finishBusRouteId:(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
	{
        
        @try
        {
            
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            // JSON 오브젝트 변환
            
            //NSLog(@"BIS버정아이디 파싱 %@", strReceiveJsonData);
            
            SBJSON *json = [[SBJSON alloc] init];
            
            NSMutableDictionary *dic = [json objectWithString:strReceiveJsonData];
            //NSLog(@"딕 : %@", dic);
            
            NSLog(@"%@", [OllehMapStatus sharedOllehMapStatus].laneIdToBisIdDictionary);
            
            [[OllehMapStatus sharedOllehMapStatus].laneIdToBisIdDictionary removeAllObjects];
            
            [[OllehMapStatus sharedOllehMapStatus].laneIdToBisIdDictionary setObject:[dic objectForKeyGC:@"RESDATA"] forKey:@"BISID"];
            
            [json release];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
        
    }
    
}

// 버스노선 그리기(서울)
- (ServerRequester *)requestBusLineDraw:(id)target action:(SEL)action busRouteId:(NSString *)RouteId
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    NSString *rawUrl = [NSString stringWithFormat:@"/v1/getRoutePath.json?busRouteId=%@", RouteId];
    
    //NSString *refinedUrl = [self getEncodedTargetURL:rawUrl];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_BIS, rawUrl]]];
    
    NSLog(@"BIS버스노선 그리기 URL : %@", [request URL]);
    
    [request setHTTPMethod:@"GET"];
    
    [request addFinishTarget:self action:@selector(finishBusLineDraw:)];
    
    [request addFinishOuterTarget:target action:action];
    
    [self addHeaderForCommonGateway:request];
    
    [request sendRequest];
    //[request sendRequest:1];
    
    return request;
    
}

// 버스노선 그리기(경기)
- (ServerRequester *)requestBusLineDraw_G:(id)target action:(SEL)action busRouteId:(NSString *)RouteId
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    NSString *rawUrl = [NSString stringWithFormat:@"/v1/g_getRoutePath.json?busRouteId=%@", RouteId];
    
    //NSString *refinedUrl = [self getEncodedTargetURL:rawUrl];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_BIS, rawUrl]]];
    
    NSLog(@"BIS경기버스노선 그리기 URL : %@", [request URL]);
    
    [request setHTTPMethod:@"GET"];
    
    [request addFinishTarget:self action:@selector(finishBusLineDraw:)];
    
    [request addFinishOuterTarget:target action:action];
    
    [self addHeaderForCommonGateway:request];
    
    [request sendRequest];
    
    //[request sendRequest:1];
    
    return request;
    
}

- (void) finishBusLineDraw:(id)request
{
    
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        @try
        {
            
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            // JSON 오브젝트 변환
            
            //NSLog(@"BIS버스상세 파싱 %@", strReceiveJsonData);
            
            SBJSON *json = [[SBJSON alloc] init];
            
            NSMutableDictionary *dic = [json objectWithString:strReceiveJsonData];
            
            // 버스노선 그리기 리스트
            [[OllehMapStatus sharedOllehMapStatus].busLineDrawingDictionary removeAllObjects];
            
            [[OllehMapStatus sharedOllehMapStatus].busLineDrawingDictionary setObject:[dic objectForKeyGC:@"RESDATA"] forKey:@"BUSLINE"];
            
            [json release];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
    }
    
}

#pragma mark -
#pragma mark - line Polygon
- (ServerRequester *) requestPolygonSearch:(id)target action:(SEL)action table:(NSString *)fcNm loadKey:(NSString *)idBgm
{
    ServerRequester *request = [[[ServerRequester alloc] init] autorelease];
    
    NSString *rawUrl = [NSString stringWithFormat:@"/v2/spaceSearch/km2_sShapeSearch.json?FC_NM=%@&ID_BGM=%@", fcNm, idBgm];
    
    //NSString *refinedUrl = [self getEncodedTargetURL:rawUrl];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@",COMMON_SERVER_GW, rawUrl]]];
    
    NSLog(@"폴리곤 검색 URL : %@", [request URL]);
    
    [request setHTTPMethod:@"GET"];
    
    [request addFinishTarget:self action:@selector(finishSearchPolygon:)];
    
    [request addFinishOuterTarget:target action:action];
    
    [self addHeaderForCommonGateway:request];
    
    [request sendRequest];
    
    return request;
    
}
- (void) finishSearchPolygon:(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
	{
        
        @try
        {
            
            NSString *strReceiveJsonData = [self convertToJsonStringFromReceiveData:request :NO];
            
            // JSON 오브젝트 변환
            
            SBJSON *json = [[SBJSON alloc] init];
            
            NSMutableDictionary *dic = [json objectWithString:strReceiveJsonData];
            
            [[OllehMapStatus sharedOllehMapStatus].linePolygonDictionary removeAllObjects];
            
            [[OllehMapStatus sharedOllehMapStatus].linePolygonDictionary setObject:[dic objectForKeyGC:@"RESULTDATA"] forKey:@"LinePolygon"];
            //[[OllehMapStatus sharedOllehMapStatus].linePolygonArray addObjectsFromArray:[[[[[dic objectForKeyGC:@"RESULTDATA"] objectAtIndexGC:0] objectForKeyGC:@"part"] objectAtIndexGC:0] objectForKeyGC:@"vertex"]];
            
            [json release];
            
        }
        @catch (NSException *exception)
        {
            [request setFinishCode:OMSRFinishCode_Error];
        }
        
        
    }
    
}
@end
