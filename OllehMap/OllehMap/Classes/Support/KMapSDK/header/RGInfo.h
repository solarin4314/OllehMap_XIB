//
//  RGInfo.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 20..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kRGInfoProperty_dir_name = 0,
	kRGInfoProperty_link_idx,
	kRGInfoProperty_nextdist,
	kRGInfoProperty_node_name,
    kRGInfoProperty_type,
    kRGInfoProperty_x,
    kRGInfoProperty_y,
    kRGInfoProperty_none
};
typedef NSUInteger RGInfoProperty;

@interface RGInfo : NSObject <NSXMLParserDelegate> {
    NSString *dir_name;
    int link_idx;
    double nextdist;
    NSString *node_name;
    int type;
    double x;
    double y;
	id <NSXMLParserDelegate> parentDelegate;	
	RGInfoProperty currentProperty;
}
@property (nonatomic, retain) NSString *dir_name;
@property (assign) int link_idx;
@property (assign) double nextdist;
@property (nonatomic, retain) NSString *node_name;
@property (assign) int type;
@property (assign) double x;
@property (assign) double y;
@property (nonatomic, retain) id <NSXMLParserDelegate> parentDelegate;	
@property (assign) RGInfoProperty currentProperty;

-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;

@end
