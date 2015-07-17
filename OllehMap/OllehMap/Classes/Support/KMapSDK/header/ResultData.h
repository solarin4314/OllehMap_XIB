//
//  ResultData.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 9..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kResultDataProperty_tcount = 0,
    kResultDataProperty_count,
    kResultDataProperty_POI,
    kResultDataProperty_ADDRS,
    kResultDataProperty_ADDR,
    kResultDataProperty_DETAILPOI,
    kResultDataProperty_COORD,
    kResultDataProperty_THEME,
    kResultDataProperty_SROUTE,
    kResultDataProperty_PROUTE,
	kResultDataProperty_none
};
typedef NSUInteger ResultDataProperty;

@interface ResultData : NSObject <NSXMLParserDelegate> {
	int totalCount;
	int count;
	NSMutableArray *infoList;
	id <NSXMLParserDelegate> parentDelegate;
	ResultDataProperty currentProperty;
	BOOL isReachDatas;
    BOOL isRgeoPOI;
}
@property (assign) int totalCount;
@property (assign) int count;
@property (nonatomic, retain) NSMutableArray *infoList;
@property (nonatomic, retain) id <NSXMLParserDelegate>parentDelegate;
-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;
-(void)setParseRgeocodingPOI:(BOOL) isParseRgeocodingPOI;
@end
