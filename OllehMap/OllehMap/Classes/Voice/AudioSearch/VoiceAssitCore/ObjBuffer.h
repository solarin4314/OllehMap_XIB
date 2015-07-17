//
//  ObjBuffer.h
//  VoiceAssist
//
//  Created by infinity on 11. 4. 22..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * declared Abstract Class for Queue's
 * 
**/
@interface ObjBuffer : NSObject {
    BOOL      isBlock; // Queuing complete
    NSInteger readPos; 
    NSInteger total;

    NSMutableData * Buffer;
}

@property (readwrite) BOOL isBlock;
@property (readwrite) NSInteger readPos;
@property (retain,readwrite) NSMutableData * Buffer;
@property (readonly) NSInteger total;

+(id) sharedBuffer;

-(NSInteger)total;

-(id)   init;
-(void) reset;

-(void) appendData:(const void*)buffer Length:(NSInteger)length;

-(NSData*) readData:(NSInteger)wantSize;


@end
