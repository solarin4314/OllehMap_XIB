//
//  DetailAddressInfo.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 19..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kDetailAddressInfoProperty_badm = 0,
	kDetailAddressInfoProperty_hadm,
	kDetailAddressInfoProperty_isMain,
	kDetailAddressInfoProperty_name,
	kDetailAddressInfoProperty_level,
	kDetailAddressInfoProperty_full_addr,
	kDetailAddressInfoProperty_x,
	kDetailAddressInfoProperty_y,
	kDetailAddressInfoProperty_none
};
typedef NSUInteger DetailAddressInfoProperty;

@interface DetailAddressInfo : NSObject <NSXMLParserDelegate> {
	NSString *badm;
	NSString *hadm;
	BOOL isMain;
	NSString *name;
	int level;
	NSString *full_addr;
	double x;
	double y;
	id <NSXMLParserDelegate> parentDelegate;	
	DetailAddressInfoProperty currentProperty;
}
@property (nonatomic, retain) NSString *badm;
@property (nonatomic, retain) NSString *hadm;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *full_addr;
@property (assign) BOOL isMain;
@property (assign) int level;
@property (assign) double x;
@property (assign) double y;
@property (nonatomic, retain) id <NSXMLParserDelegate>parentDelegate;
@property (assign) DetailAddressInfoProperty currentProperty;

-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;

@end
