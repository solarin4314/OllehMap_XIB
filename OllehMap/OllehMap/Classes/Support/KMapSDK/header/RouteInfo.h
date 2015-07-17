//
//  RouteInfo.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 20..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kRouteInfoProperty_total_time = 0,
	kRouteInfoProperty_total_dist,
	kRouteInfoProperty_rg_count,
	kRouteInfoProperty_rglist,
    kRouteInfoProperty_none
};
typedef NSUInteger RouteInfoProperty;

@interface RouteInfo : NSObject <NSXMLParserDelegate> {
    double total_time;
    double total_dist;
    int rg_count;
    NSMutableArray *rgList;
	id <NSXMLParserDelegate> parentDelegate;	
	RouteInfoProperty currentProperty;
}   
@property (assign) double total_time;
@property (assign) double total_dist;
@property (assign) int rg_count;
@property (nonatomic, retain) NSMutableArray *rgList;
@property (nonatomic, retain) id <NSXMLParserDelegate> parentDelegate;	
@property (assign) RouteInfoProperty currentProperty;

-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;

@end
