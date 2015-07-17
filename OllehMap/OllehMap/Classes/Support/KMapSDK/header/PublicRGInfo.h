//
//  PublicRGInfo.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 20..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kPublicRGInfoProperty_rgtype = 0,
    kPublicRGInfoProperty_distance,
    kPublicRGInfoProperty_methodtype,
    kPublicRGInfoProperty_startname,
    kPublicRGInfoProperty_endname,
    kPublicRGInfoProperty_lanename,
    kPublicRGInfoProperty_distancetype,
    kPublicRGInfoProperty_x,
    kPublicRGInfoProperty_y,
    kPublicRGInfoProperty_none
};
typedef NSUInteger PublicRGInfoProperty;

@interface PublicRGInfo : NSObject <NSXMLParserDelegate> {
    int rgtype;
    double distance;
    int methodtype;
    NSString *startname;
    NSString *endname;
    NSString *lanename;
    int distancetype;
    double x;
    double y;
	id <NSXMLParserDelegate> parentDelegate;	
	PublicRGInfoProperty currentProperty;
}
@property (assign) int rgtype;
@property (assign) double distance;
@property (assign) int methodtype;
@property (nonatomic, retain) NSString *startname;
@property (nonatomic, retain) NSString *endname;
@property (nonatomic, retain) NSString *lanename;
@property (assign) int distancetype;
@property (assign) double x;
@property (assign) double y;
@property (nonatomic, retain) id <NSXMLParserDelegate> parentDelegate;	
@property (assign) PublicRGInfoProperty currentProperty;

-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;

@end
