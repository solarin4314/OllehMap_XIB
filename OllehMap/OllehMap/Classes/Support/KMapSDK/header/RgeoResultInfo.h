//
//  RgeoResultData.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 24..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddressInfo.h"

enum {
    kRgeoResultDataProperty_poi_count = 0,
    kRgeoResultDataProperty_count,
    kRgeoResultDataProperty_POI,
    kRgeoResultDataProperty_ADDRS,
	kRgeoResultDataProperty_none
};
typedef NSUInteger RgeoResultDataProperty;

@interface RgeoResultInfo : NSObject <NSXMLParserDelegate> {
	int poi_count;
	int count;
    AddressInfo *addrs;
	NSMutableArray *infoList;
	id <NSXMLParserDelegate> parentDelegate;
	RgeoResultDataProperty currentProperty;
	BOOL isReachDatas;
}
@property (assign) int poi_count;
@property (assign) int count;
@property (nonatomic, retain) AddressInfo *addrs;
@property (nonatomic, retain) NSMutableArray *infoList;
@property (nonatomic, retain) id <NSXMLParserDelegate>parentDelegate;
-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;

@end
