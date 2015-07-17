//
//  RgeoPOIInfo.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 24..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kRgeoPOIInfoProperty_id_poi = 0,
    kRgeoPOIInfoProperty_poi_address,
    kRgeoPOIInfoProperty_poi_newaddress,
    kRgeoPOIInfoProperty_poi_name,
    kRgeoPOIInfoProperty_poi_distance,
    kRgeoPOIInfoProperty_x,
    kRgeoPOIInfoProperty_y,
	kRgeoPOIInfoProperty_none
};
typedef NSUInteger RgeoPOIInfoProperty;

@interface RgeoPOIInfo : NSObject <NSXMLParserDelegate> {
	NSString *id_poi;
	NSString *poi_address;
    NSString *poi_newaddress;
	NSString *poi_name;
	double	 poi_distance;
	double	 x;
	double	 y;
	id <NSXMLParserDelegate> parentDelegate;
	RgeoPOIInfoProperty currentProperty;
}

@property (nonatomic, retain) NSString *id_poi;
@property (nonatomic, retain) NSString *poi_address;
@property (nonatomic, retain) NSString *poi_newaddress;
@property (nonatomic, retain) NSString *poi_name;
@property (assign) double	 poi_distance;
@property (assign) double	 x;
@property (assign) double	 y; 
@property (nonatomic, retain) id <NSXMLParserDelegate>parentDelegate;
-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;

@end
