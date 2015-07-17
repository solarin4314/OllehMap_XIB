//
//  RouteResultInfo.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 20..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PublicRouteSubInfo.h"
#import "DisplayInfo.h"

enum {
    kRouteResultInfoProperty_no = 0,
    kRouteResultInfoProperty_route,
    kRouteResultInfoProperty_display,
    kRouteResultInfoProperty_none
};
typedef NSUInteger RouteResultInfoProperty;

@interface RouteResultInfo : NSObject <NSXMLParserDelegate> {
    int no;
    PublicRouteSubInfo *route;
    DisplayInfo *display;
	id <NSXMLParserDelegate> parentDelegate;	
    RouteResultInfoProperty currentProperty;
}
@property (assign) int no;
@property (nonatomic, retain) PublicRouteSubInfo *route;
@property (nonatomic, retain) DisplayInfo *display;
@property (nonatomic, retain) id <NSXMLParserDelegate> parentDelegate;	
@property (assign) RouteResultInfoProperty currentProperty;

-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;

@end
