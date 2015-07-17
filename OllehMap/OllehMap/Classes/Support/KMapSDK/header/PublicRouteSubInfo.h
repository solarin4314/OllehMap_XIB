//
//  PublicRouteSubInfo.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 20..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kPublicRouteSubInfoProperty_busnum = 0,
    kPublicRouteSubInfoProperty_subwaynum,
    kPublicRouteSubInfoProperty_charge,
    kPublicRouteSubInfoProperty_rgcount,
    kPublicRouteSubInfoProperty_totaldis,
    kPublicRouteSubInfoProperty_totaltime,
    kPublicRouteSubInfoProperty_rglist,
    kPublicRouteSubInfoProperty_none
};
typedef NSUInteger PublicRouteSubInfoProperty;

@interface PublicRouteSubInfo : NSObject <NSXMLParserDelegate> {
    int busnum;
    int subwaynum;
    int charge;
    int rgcount;
    double totaldistance;
    double totaltime;
    NSMutableArray *rglist;
	id <NSXMLParserDelegate> parentDelegate;	
    PublicRouteSubInfoProperty currentProperty;
}
@property (assign) int busnum;
@property (assign) int subwaynum;
@property (assign) int charge;
@property (assign) int rgcount;
@property (assign) double totaldistance;
@property (assign) double totaltime;
@property (nonatomic, retain) NSMutableArray *rglist;
@property (nonatomic, retain) id <NSXMLParserDelegate> parentDelegate;	
@property (assign) PublicRouteSubInfoProperty currentProperty;

-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;

@end
