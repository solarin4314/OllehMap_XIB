//
//  avrController.h
//  HelloView
//
//  Created by infinity on 09. 04. 29.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#include <assert.h>
#include <pthread.h>
#import <AudioToolbox/AudioQueue.h>
#import <AVFoundation/AVAudioSession.h>
#import <Foundation/Foundation.h>
#import "AQRecorder.h"
#import "AQPlayer.h"


@class avrController;

//avr protocol method for application
@protocol AvrControllerDelegate

//playing start event
-(void)recognition:(avrController*)avr startedPlay:(BOOL)bSuccess Description:(NSString*)string;
//playing state event
-(BOOL)recognition:(avrController *)avr statePlay:(void**)inUserData Length:(UInt32*)inNumPackets;
//playing stop event
-(void)recognition:(avrController *)avr stoppedPlay:(BOOL)bSuccess Description:(NSString *)string;

//recording start event
-(void)recognition:(avrController*)avr startedRecord:(BOOL)bSuccess Description:(NSString*)string;
//recording state event
-(void)recognition:(avrController*)avr stateRecord:(void*)inUserData Length:(NSUInteger)inNumPackets;
//recording stop event
-(void)recognition:(avrController*)avr stoppedRecord:(BOOL)bSuccess Description:(NSString*)string;
//recording timeout event
-(void)recognition:(avrController*)avr timeoutRecord:(BOOL)bSuccess Description:(NSString*)string;

@end

//avr implementation class
@interface avrController : NSObject <AVAudioSessionDelegate> {

    // playback implementation class
    class AQPlayback : public AQPlayer{
    public:
        BOOL OutputBufferHandler( void **	inUserData,	UInt32*	inNumPackets);

		//set delegate function
		void			SetController(id  ctrl)	{ controller = ctrl; }
		id							controller;
    };
    
    //declare AQPlayback for avrController
    AQPlayback * playback;

	
	// recording implementation class
	class AQRecognition : public AQRecorder {
	public:
		//real recording pollback function.
		void			InputBufferHandler( void *	inUserData,	UInt32	inNumPackets);
		//get recorded buffer
		short *			DataBuffer() const			{ return mRecordBuffer; }
		
		//recording buffer
		short *						mRecordBuffer;

		//set delegate function
		void			SetController(id  ctrl)	{ controller = ctrl; }
		id							controller;
	};
	//declare AQRecognition for avrController
	AQRecognition * recognition;
	
	NSTimer *	expire;
	

//    AudioQueueRef                   Queue;
    CAStreamBasicDescription		DataFormat;
@private
    id <AvrControllerDelegate> delegate;

}

@property (readwrite, assign) id <AvrControllerDelegate> delegate;

@property (readwrite) AQPlayback * playback;
@property (readwrite) AQRecognition * recognition;

+ (avrController *)sharedAVRController;

- (void) Cache:(BOOL)start;

//avr class playback public API
- (BOOL)AudioSessionInitialization:(NSError**)err;

- (BOOL)IsRunning;
- (AudioQueueRef) Queue;
- (CAStreamBasicDescription) DataFormat;

- (OSStatus)StartRecord:(CFStringRef)inRecordFile Sample:(Float64)sample Channel:(UInt32)channel Timeout:(NSInteger)timeout;
- (void)StopRecord;

-(OSStatus)StartPlay:(BOOL)yes Sample:(Float64)sample Channel:(UInt32)channel;
-(void)StopPlay;

@end
