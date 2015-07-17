//
//  ResponseData.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 9..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResultData.h"

enum {
    kResponseDataProperty_id = 0,
    kResponseDataProperty_errcd,
	kResponseDataProperty_no,
	kResponseDataProperty_errms,
	kResponseDataProperty_none
};
typedef NSUInteger ResponseDataProperty;

@interface ResponseData : NSObject <NSXMLParserDelegate> {
	NSString *_id;
	NSString *errcd;
	NSString *no;
	NSString *errms;
	ResultData *resData;
    BOOL isRgeoPOI;
	ResponseDataProperty currentProperty;
}
@property (nonatomic, retain) NSString *_id;
@property (nonatomic, retain) NSString *errcd;
@property (nonatomic, retain) NSString *no;
@property (nonatomic, retain) NSString *errms;
@property (nonatomic, retain) ResultData *resData;
-(void)parse:(NSString *)response;
-(void)setParseRgeocodingPOI:(BOOL) isParseRgeocodingPOI;
@end
