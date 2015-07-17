//
//  RouteInfo.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 9..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchTypes.h"
#import "LinksInfo.h"
#import "RouteInfo.h"

enum {
    kShortPathRouteInfoProperty_isroute = 0,
	kShortPathRouteInfoProperty_links,
	kShortPathRouteInfoProperty_routes,
	kShortPathRouteInfoProperty_none
};
typedef NSUInteger ShortPathRouteInfoProperty;

@interface ShortPathRouteInfo : NSObject <NSXMLParserDelegate> {
    BOOL isroute;
    LinksInfo *links;
    RouteInfo *routes;
	id <NSXMLParserDelegate> parentDelegate;
    ShortPathRouteInfoProperty currentProperty;
}
@property (nonatomic, retain) id <NSXMLParserDelegate>parentDelegate;
@property (nonatomic, retain) LinksInfo *links;
@property (nonatomic, retain) RouteInfo *routes;
@property (assign) BOOL isroute;
@property (assign) ShortPathRouteInfoProperty currentProperty;

-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;

@end
