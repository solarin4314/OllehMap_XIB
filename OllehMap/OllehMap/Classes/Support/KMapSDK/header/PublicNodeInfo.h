//
//  PublicNodeInfo.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 20..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kPublicNodeInfoProperty_name = 0,
    kPublicNodeInfoProperty_stationtype,
    kPublicNodeInfoProperty_x, 
    kPublicNodeInfoProperty_y,
    kPublicNodeInfoProperty_none
};
typedef NSUInteger PublicNodeInfoProperty;

@interface PublicNodeInfo : NSObject <NSXMLParserDelegate> {
    NSString *name;
    int stationtype;
    double x;
    double y;
	id <NSXMLParserDelegate> parentDelegate;	
	PublicNodeInfoProperty currentProperty;
}
@property (nonatomic, retain) NSString *name;
@property (assign) int stationtype;
@property (assign) double x;
@property (assign) double y;
@property (nonatomic, retain) id <NSXMLParserDelegate> parentDelegate;	
@property (assign) PublicNodeInfoProperty currentProperty;

-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;

@end
