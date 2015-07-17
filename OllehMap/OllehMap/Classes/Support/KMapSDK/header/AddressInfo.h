//
//  AddressInfo.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 9..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kAddressInfoProperty_dong_code = 0,
    kAddressInfoProperty_address,
    kAddressInfoProperty_x,
    kAddressInfoProperty_y,
	kAddressInfoProperty_none
} AddressInfoProperty;

@interface AddressInfo : NSObject <NSXMLParserDelegate> {
	NSString *dong_code;
	NSString *address;
	double	 x;
	double	 y;
	id <NSXMLParserDelegate> parentDelegate;
	AddressInfoProperty currentProperty;
}
@property (nonatomic, retain) NSString *dong_code;
@property (nonatomic, retain) NSString *address;
@property (assign) double	 x;
@property (assign) double	 y;
@property (nonatomic, retain) id <NSXMLParserDelegate>parentDelegate;
@property (assign) AddressInfoProperty currentProperty;
-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;
@end
