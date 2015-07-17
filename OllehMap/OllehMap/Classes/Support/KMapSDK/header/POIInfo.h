//
//  POIInfo.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 9..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kPOIInfoProperty_id_poi = 0,
    kPOIInfoProperty_poi_code,
    kPOIInfoProperty_poi_code_name,
    kPOIInfoProperty_theme_code,
    kPOIInfoProperty_name,
    kPOIInfoProperty_tel,
    kPOIInfoProperty_sido,
    kPOIInfoProperty_sgg,
    kPOIInfoProperty_dong,
    kPOIInfoProperty_beonji,
    kPOIInfoProperty_road_nm,
    kPOIInfoProperty_bd_no,
    kPOIInfoProperty_badm,
    kPOIInfoProperty_hadm,
    kPOIInfoProperty_distance,
    kPOIInfoProperty_x,
    kPOIInfoProperty_y,
	kPOIInfoProperty_none
};
typedef NSUInteger POIInfoProperty;

@interface POIInfo : NSObject <NSXMLParserDelegate> {
	NSString *id_poi;
	NSString *poi_code;
	NSString *poi_code_name;
	NSString *theme_code;
	NSString *name;
	NSString *tel;
	NSString *sido;
	NSString *sgg;
	NSString *dong;
	NSString *beonji;
	NSString *road_nm;
	NSString *bd_no;
	NSString *badm;
	NSString *hadm;
	double	 distance;
	double	 x;
	double	 y;
	id <NSXMLParserDelegate> parentDelegate;
	POIInfoProperty currentProperty;
}

@property (nonatomic, retain) NSString *id_poi;
@property (nonatomic, retain) NSString *poi_code;
@property (nonatomic, retain) NSString *poi_code_name;
@property (nonatomic, retain) NSString *theme_code;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *tel;
@property (nonatomic, retain) NSString *sido;
@property (nonatomic, retain) NSString *sgg;
@property (nonatomic, retain) NSString *dong;
@property (nonatomic, retain) NSString *beonji;
@property (nonatomic, retain) NSString *road_nm;
@property (nonatomic, retain) NSString *bd_no;
@property (nonatomic, retain) NSString *badm;
@property (nonatomic, retain) NSString *hadm;
@property (assign) double	 distance;
@property (assign) double	 x;
@property (assign) double	 y; 
@property (nonatomic, retain) id <NSXMLParserDelegate>parentDelegate;
-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;

@end
