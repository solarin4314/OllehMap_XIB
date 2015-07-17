//
//  PublicPathInfo.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 20..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kPublicPathInfoProperty_resultcount = 0,
    kPublicPathInfoProperty_resultlist,
    kPublicPathInfoProperty_none
};
typedef NSUInteger PublicPathInfoProperty;

@interface PublicPathInfo : NSObject <NSXMLParserDelegate> {
    NSString *pathtype;
    int resultcount;
    NSMutableArray *resultlist;
	id <NSXMLParserDelegate> parentDelegate;	
    PublicPathInfoProperty currentProperty;
}
@property (nonatomic, retain) NSString *pathtype;
@property (assign) int resultcount;
@property (nonatomic, retain) NSMutableArray *resultlist;
@property (nonatomic, retain) id <NSXMLParserDelegate> parentDelegate;	
@property (assign) PublicPathInfoProperty currentProperty;

-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;

@end
