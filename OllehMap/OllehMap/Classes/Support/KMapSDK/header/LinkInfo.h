//
//  LinkInfo.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 20..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kLinkInfoProperty_length = 0,
	kLinkInfoProperty_vertex_cnt,
	kLinkInfoProperty_vertexlist,
	kLinkInfoProperty_none
};
typedef NSUInteger LinkInfoProperty;

@interface LinkInfo : NSObject <NSXMLParserDelegate> {
    int length;
    int vertex_cnt;
    NSMutableArray *vertexList;
	id <NSXMLParserDelegate> parentDelegate;	
	LinkInfoProperty currentProperty;
}
@property (nonatomic, retain) NSMutableArray *vertexList;
@property (assign) int length;
@property (assign) int vertex_cnt;
@property (nonatomic, retain) id <NSXMLParserDelegate> parentDelegate;
@property (assign) LinkInfoProperty currentProperty;

-(void)parser:(NSXMLParser *)parser delegate:(id <NSXMLParserDelegate>)delegate;

@end
