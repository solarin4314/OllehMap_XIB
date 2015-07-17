//
//  TXBuffer.h
//  VoiceAssist
//
//  Created by infinity on 11. 4. 10..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjBuffer.h"

/**
 * 서버로 전달할 데이터의 임시 저장 큐를 위한 클래스 선언
 * ObjBuffer 클래스로부터 상속
**/

/**
 *   AddrBook interface
**/
@interface AddrBook : ObjBuffer {
    
}

-(void) appendData:(id)address;

@end

/**
 * Text interface
**/
@interface Text : ObjBuffer {

}

@end

/**
 * RecordBuffer interface
**/
@interface RecordBuffer : ObjBuffer {
    
}

@end

/**
 * FeatureBuffer interface
**/

@interface FeatureBuffer : RecordBuffer {

}

@end

/**
 * EncoderBuffer interface
**/

#include "KT_Speex_Encoder.h"
#define FRAME_SIZE 320

@interface EncoderBuffer : RecordBuffer {
    KT_Speex_Encoder kt_Encoder;
    BOOL instance;
    NSInteger sampleRate;
    NSInteger quality;
    NSInteger codecBytes;
}
@property (readwrite) KT_Speex_Encoder kt_Encoder;
@property (readwrite) BOOL instance;
@property (readwrite) NSInteger codecBytes;
@property (readwrite) NSInteger sampleRate;
@property (readwrite) NSInteger quality;


-(void)ready:(NSInteger)rate Quality:(NSInteger)qual;
-(void) appendData:(const void*)buffer Length:(NSInteger)length;

@end

