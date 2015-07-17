//
//  ThemeInfo.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 17..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kThemeInfoProperty_thcd = 0,
	kThemeInfoProperty_thid,
	kThemeInfoProperty_level,
	kThemeInfoProperty_thnm,
	kThemeInfoProperty_is_show,
	kThemeInfoProperty_des,
	kThemeInfoProperty_none
};
typedef NSUInteger ThemeInfoProperty;

@interface ThemeInfo : NSObject <NSXMLParserDelegate> {
	NSString *thcd;
	NSString *thid;
	NSString *level;
	NSString *thnm;
	NSString *is_show;
	NSString *des;
	id <NSXMLParserDelegate> parentDelegate;	
	ThemeInfoProperty currentProperty;
}
@property (nonatomic, retain) NSString *thcd;
@property (nonatomic, retain) NSString *thid;
@property (nonatomic, retain) NSString *level;
@property (nonatomic, retain) NSString *thnm;
@property (nonatomic, retain) NSString *is_show;
@property (nonatomic, retain) NSString *des;
@property (nonatomic, retain) id <NSXMLParserDelegate>parentDelegate;
@property (assign) ThemeInfoProperty currentProperty;

-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;

@end
