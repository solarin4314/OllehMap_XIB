//
//  DisplayInfo.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 20..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchTypes.h"
#import "StationInfo.h"

enum {
    kDisplayInfoProperty_coordtype = 0,
    kDisplayInfoProperty_methodcount,
    kDisplayInfoProperty_mbr_xmin,
    kDisplayInfoProperty_mbr_ymin,
    kDisplayInfoProperty_mbr_xmax,
    kDisplayInfoProperty_mbr_ymax,
    kDisplayInfoProperty_station,
    kDisplayInfoProperty_methodlist,
    kDisplayInfoProperty_none
};
typedef NSUInteger DisplayInfoProperty;

@interface DisplayInfo : NSObject <NSXMLParserDelegate> {
    CoordType coordtype;
    int methodcount;
    double mbr_xmin;
    double mbr_ymin;
    double mbr_xmax;
    double mbr_ymax;
    StationInfo *station;
    NSMutableArray *methodlist;
	id <NSXMLParserDelegate> parentDelegate;	
    DisplayInfoProperty currentProperty;
}
@property (assign) CoordType coordtype;
@property (assign) int methodcount;
@property (assign) double mbr_xmin;
@property (assign) double mbr_ymin;
@property (assign) double mbr_xmax;
@property (assign) double mbr_ymax;
@property (nonatomic, retain) StationInfo *station;
@property (nonatomic, retain) NSMutableArray *methodlist;
@property (nonatomic, retain) id <NSXMLParserDelegate> parentDelegate;	
@property (assign) DisplayInfoProperty currentProperty;

-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;

@end
