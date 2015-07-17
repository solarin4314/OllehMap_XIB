//
//  VoiceAssistController.h
//  VoiceAssist
//
//  Created by 지뉴소프트 on 11. 4. 12..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "avrController.h"
#import "CAParser.h"

UIKIT_EXTERN NSString *const UIVoiceAssistConnectCannotNotification;
UIKIT_EXTERN NSString *const UIVoiceAssistReadyOKNotification;
UIKIT_EXTERN NSString *const UIVoiceAssistSessionTimeoutNotification;
UIKIT_EXTERN NSString *const UIVoiceAssistStartRecognizeNotification;
UIKIT_EXTERN NSString *const UIVoiceAssistFailedRecognizeNotification;
UIKIT_EXTERN NSString *const UIVoiceAssistSucessRecognizeNotification;
UIKIT_EXTERN NSString *const UIVoiceAssistFailureNotification;
UIKIT_EXTERN NSString *const UIVoiceAssistDisconnectNotification;

@class GCDAsyncSocket;

@class LogFileHandler;

@interface VoiceAssistController : NSObject <AvrControllerDelegate, UIApplicationDelegate> {
    
    LogFileHandler* logHandler;
    
    GCDAsyncSocket *spgateway;
    GCDAsyncSocket *spserver;
    
    NSInteger seed;
    NSTimer * session;
    
    char szPhoneType[20];
    char szDEVID[44];
    BOOL getRptFromSession;
    
    OSStatus mStatus;
    /* GUI */
    NSString * gui_ip;
    NSInteger gui_port;
    NSInteger gui_svc;
    NSInteger gui_reqcontype;
  
}

@property(retain) LogFileHandler* logHandler;

/* GUI */
@property (copy) NSString * gui_ip;
@property (readwrite) NSInteger gui_port;
@property (readwrite) NSInteger gui_svc;
@property (readwrite) NSInteger gui_reqcontype;

+(id) sharedVoiceAssist;

-(IBAction) Start:(id)sender;
-(IBAction) Stop:(id)sender;
-(IBAction) Record:(id)sender;


-(IBAction) Test:(id)sender;

-(void)expiredLib;

@end
