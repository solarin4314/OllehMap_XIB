//
//  CommonGWXmlParser.h
//  OllehMap
//
//  Created by SooYong Park on 10. 11. 17..
//  Copyright 2010 Hubilon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OMClassCategory.h"

@interface CommonGWXmlParser : NSObject<NSXMLParserDelegate>
{
	NSMutableString *_jsonString;
    NSMutableString *_tempDirectionString;
    NSString        *_tempString;
    BOOL            _CCTVParser;
    //.. URL 정보를 체크 할때 사용합니다.
    BOOL            _URLstrCheck;
    NSInteger       _strctn;
}

- (id)objectWithData:(NSData *)data;
- (id)objectWithDataCCTV:(NSData *)data;
- (NSString *)NSStringToJSONString:(NSString *)aString;
@end
