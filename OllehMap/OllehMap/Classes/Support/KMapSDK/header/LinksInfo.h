//
//  LinksInfo.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 20..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchTypes.h"

enum {
    kLinksInfoProperty_linklist = 0,
	kLinksInfoProperty_mbr_maxx,
	kLinksInfoProperty_mbr_maxy,
	kLinksInfoProperty_mbr_minx,
	kLinksInfoProperty_mbr_miny,
	kLinksInfoProperty_link_ver,
	kLinksInfoProperty_link_cnt,
	kLinksInfoProperty_coordtype,
	kLinksInfoProperty_none
};
typedef NSUInteger LinksInfoProperty;

@interface LinksInfo : NSObject <NSXMLParserDelegate> {
    NSMutableArray *linkList;
    double mbr_maxx;
    double mbr_maxy;
    double mbr_minx;
    double mbr_miny;
    NSString *link_ver;
    int link_cnt;
    CoordType coordtype;
	id <NSXMLParserDelegate> parentDelegate;	
	LinksInfoProperty currentProperty;
}
@property (nonatomic, retain) NSMutableArray *linkList;
@property (assign) double mbr_maxx;
@property (assign) double mbr_maxy;
@property (assign) double mbr_minx;
@property (assign) double mbr_miny;
@property (nonatomic, retain)NSString *link_ver;
@property (assign) int link_cnt;
@property (assign) CoordType coordtype;
@property (nonatomic, retain)id <NSXMLParserDelegate> parentDelegate;	
@property (assign) LinksInfoProperty currentProperty;

-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;

@end
