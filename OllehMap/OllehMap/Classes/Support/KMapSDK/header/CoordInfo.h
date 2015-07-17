//
//  CoordInfo.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 9..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchTypes.h"

enum {
    kCoordInfoProperty_coordType = 0,
    kCoordInfoProperty_x,
    kCoordInfoProperty_y,
	kCoordInfoProperty_none
};
typedef NSUInteger CoordInfoProperty;

@interface CoordInfo : NSObject <NSXMLParserDelegate> {
	double		x;
	double		y;
	NSString *coordType;
	id <NSXMLParserDelegate> parentDelegate;
	CoordInfoProperty currentProperty;
}
@property (assign) double		x;
@property (assign) double		y;
@property (nonatomic, retain) NSString *	coordType;
@property (nonatomic, retain) id <NSXMLParserDelegate>parentDelegate;
@property (assign) CoordInfoProperty currentProperty;
-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;
@end
