//
//  MethodInfo.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 20..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kMethodInfoProperty_vertexcount = 0,
    kMethodInfoProperty_type,
    kMethodInfoProperty_vertextlist,
    kMethodInfoProperty_none
};
typedef NSUInteger MethodInfoProperty;

@interface MethodInfo : NSObject <NSXMLParserDelegate> {
    int vertexcount;
    int type;
    NSMutableArray *vertexlist;
	id <NSXMLParserDelegate> parentDelegate;	
    MethodInfoProperty currentProperty;
}
@property (assign) int vertexcount;
@property (assign) int type;
@property (nonatomic, retain) NSMutableArray *vertexlist;
@property (nonatomic, retain) id <NSXMLParserDelegate> parentDelegate;	
@property (assign) MethodInfoProperty currentProperty;

-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;

@end
