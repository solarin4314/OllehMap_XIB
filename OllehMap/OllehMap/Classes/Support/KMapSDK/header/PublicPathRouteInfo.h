//
//  PublicPathRouteInfo.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 20..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kPublicPathRouteInfoProperty_bus = 0,
	kPublicPathRouteInfoProperty_subway,
	kPublicPathRouteInfoProperty_recommend,
    kPublicPathRouteInfoProperty_isroute,
	kPublicPathRouteInfoProperty_none
};
typedef NSUInteger PublicPathRouteInfoProperty;

@interface PublicPathRouteInfo : NSObject <NSXMLParserDelegate> {
    NSMutableArray *pathlist;
    BOOL isroute;
	id <NSXMLParserDelegate> parentDelegate;	
	PublicPathRouteInfoProperty currentProperty;
}
@property (nonatomic, retain) NSMutableArray *pathlist;
@property (assign) BOOL isroute;
@property (nonatomic, retain) id <NSXMLParserDelegate> parentDelegate;	
@property (assign) PublicPathRouteInfoProperty currentProperty;

-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;

@end
