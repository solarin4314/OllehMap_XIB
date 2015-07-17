//
//  StationInfo.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 20..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kStationInfoProperty_stationcount = 0,
    kStationInfoProperty_node,
    kStationInfoProperty_none
};
typedef NSUInteger StationInfoProperty;

@interface StationInfo : NSObject <NSXMLParserDelegate> {
    NSMutableArray *nodelist;
    int stationcount;
	id <NSXMLParserDelegate> parentDelegate;	
    StationInfoProperty currentProperty;
}
@property (nonatomic, retain) NSMutableArray *nodelist;
@property (assign) int stationcount;
@property (nonatomic, retain) id <NSXMLParserDelegate> parentDelegate;	
@property (assign) StationInfoProperty currentProperty;

-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;

@end
