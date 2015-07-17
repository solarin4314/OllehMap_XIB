//
//  DetailInfo.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 17..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kDetailInfoProperty_id_mst_add = 0,
    kDetailInfoProperty_id_poi,
    kDetailInfoProperty_addcd,
    kDetailInfoProperty_addnm,
    kDetailInfoProperty_add_contents,
	kDetailInfoProperty_none
};
typedef NSUInteger DetailInfoProperty;

@interface DetailInfo : NSObject <NSXMLParserDelegate> {
	NSString *id_mst_add;
	NSString *id_poi;
	NSString *addcd;
	NSString *addnm;
	NSString *add_contents;
	id <NSXMLParserDelegate> parentDelegate;	
	DetailInfoProperty currentProperty;
}
@property (nonatomic, retain) NSString *id_mst_add;
@property (nonatomic, retain) NSString *id_poi;
@property (nonatomic, retain) NSString *addcd;
@property (nonatomic, retain) NSString *addnm;
@property (nonatomic, retain) NSString *add_contents;
@property (nonatomic, retain) id <NSXMLParserDelegate> parentDelegate;
@property (assign) DetailInfoProperty currentProperty;

-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;
@end
