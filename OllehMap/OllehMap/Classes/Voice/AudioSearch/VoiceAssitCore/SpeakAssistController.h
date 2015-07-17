//
//  SpeakAssistController.h
//  VoiceAssist
//
//  Created by infinity on 11. 4. 20..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "avrController.h"
#import "CAParser.h"

UIKIT_EXTERN NSString *const UISpeakAssistNoneDataNotification;
UIKIT_EXTERN NSString *const UISpeakAssistConnectCannotNotification;
UIKIT_EXTERN NSString *const UISpeakAssistReadyOKNotification;
UIKIT_EXTERN NSString *const UISpeakAssistSessionTimeoutNotification;
UIKIT_EXTERN NSString *const UISpeakAssistFailureNotification;
UIKIT_EXTERN NSString *const UISpeakAssistDisconnectNotification;
UIKIT_EXTERN NSString *const UISpeakAssistCompletePlayNotification;

@class GCDAsyncSocket;

@class LogFileHandler;

@interface SpeakAssistController : NSObject <AvrControllerDelegate, UIApplicationDelegate>{
    
    LogFileHandler* logHandler;
    
    GCDAsyncSocket *spgateway;
    GCDAsyncSocket *spserver;
    
    NSInteger seed;
    NSTimer * session;
    
    BOOL bCompleteNetwork;
    
    char szPhoneType[20];
    char szDEVID[44];
    
    OSStatus mStatus;

    /* GUI */
    NSString * gui_ip;
    NSInteger gui_port;
    NSInteger gui_svc;
    NSInteger gui_reqcontype;
    
}

@property(retain) LogFileHandler* logHandler;

@property (copy) NSString * gui_ip;
@property (readwrite) NSInteger gui_port;
@property (readwrite) NSInteger gui_svc;
@property (readwrite) NSInteger gui_reqcontype;

+(id) sharedSpeakAssist;

-(IBAction) Start:(id)sender;
-(IBAction) Stop:(id)sender;
-(IBAction) Play:(id)sender;


-(IBAction) NetworkStop:(id)sender;

-(void)expiredLib;

@end
