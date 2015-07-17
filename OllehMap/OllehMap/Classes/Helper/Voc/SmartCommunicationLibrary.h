//
//  SmartCommunicationLibrary.h
//  SmartCommunicationLibrary
//
//  Created by sun ho lee on 11. 11. 23..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum
{
     SmartCommunicationLibraryServerReal = 0,
     SmartCommunicationLibraryServerDev = 1,
};
typedef NSUInteger SmartCommunicationServerType;

enum
{
    SmartCommunicationResponseRawDataType = 0,
    SmartCommunicationResponseParserType = 1,
};
typedef NSUInteger SmartCommunicationResponseType;


@interface SmartCommunicationLibrary : NSObject <NSXMLParserDelegate>{
    NSString *_serverName;      //서버 이름 @"www.xxxx.xxx" , @"127.0.0.1"
    NSString *_httpMethod;      //서버 통신 방법 @"POST", @"GET" default @"GET"
    NSString *_interfaceName;
    
    SmartCommunicationServerType _serverType;      //SmartCommunicationLibraryServerDev 테스트 서버 , SmartCommunicationLibraryServerReal 상용 서버
    SmartCommunicationResponseType _responseType; //SmartCommunicationResponseParserType 파싱된 데이타 , SmartCommunicationResponseDataType 파싱되지 않은 데이타
    
    NSURLResponse *_response;                   //헤더 파악
    NSMutableData *_receivedData;               //받은 데이터
     NSMutableDictionary *_itemDictionary;      //xml 파싱한 데이터 
    NSTimeInterval _timeoutInterval;            //timeout 간격
    
    id _target;                                 //리턴값 돌려 받을 객체 
    SEL _successSelector;                       //성공시 호출될 셀럭터
    SEL _errorSelector;                         //실패시 호출될 셀럭터 
            
    NSMutableString *_xmlValue;                 //xml 파싱시 사용될 문자열
}

@property (nonatomic, retain) NSString *serverName;
@property (nonatomic, retain) NSString *httpMethod;
@property (nonatomic, retain) NSString *interfaceName;

@property (readwrite) SmartCommunicationServerType serverType;
@property (readwrite) SmartCommunicationResponseType responseType;
@property (readwrite) NSTimeInterval timeoutInterval;

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL successSelector;
@property (nonatomic, assign) SEL errorSelector;

@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, retain) NSMutableDictionary *itemDictionary;
@property (nonatomic, retain) NSMutableString *xmlValue;

- (BOOL)request:(NSString *)command bodyObject:(NSDictionary *)bodyObject;

@end
