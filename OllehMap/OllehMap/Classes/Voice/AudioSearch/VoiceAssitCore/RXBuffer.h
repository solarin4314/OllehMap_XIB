//
//  RXBuffer.h
//  VoiceAssist
//
//  Created by infinity on 11. 4. 22..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjBuffer.h"


//#define FILE_IO

/**
 * 서버로부터 데이터 저장 큐를 위한 클래스 선언
 * ObjBuffer 클래스로부터 상속
 **/


/**
 * XmlBuffer interface
**/

@interface XmlBuffer : ObjBuffer {
    
}

@end

/**
 * PlaybackBuffer interface
**/

@interface PlaybackBuffer : ObjBuffer {
#ifdef FILE_IO
    NSString *filePath;
#endif

}
#ifdef FILE_IO
@property (retain) NSString * filePath;
-(void) reset;
-(void) appendData:(const void*)buffer Length:(NSInteger)length;
#endif

@end

/**
 * DecoderBuffer interface
**/

#include "KT_Speex_Decoder.h"
#define FRAME_SIZE 320

@interface DecoderBuffer : PlaybackBuffer {
    KT_Speex_Decoder kt_Decoder;
    BOOL instance;
    NSInteger sampleRate;
    NSInteger quality;
}
@property (readwrite) KT_Speex_Decoder kt_Decoder;
@property (readwrite) BOOL instance;
@property (readwrite) NSInteger sampleRate;
@property (readwrite) NSInteger quality;

//+(id) sharedBuffer;

-(void)ready:(NSInteger)rate Quality:(NSInteger)qual;
-(NSData*) readData:(NSInteger)wantSize;

@end
