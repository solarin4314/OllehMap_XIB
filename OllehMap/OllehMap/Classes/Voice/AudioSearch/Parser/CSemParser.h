//
//  CSemParser.h
//  Sem
//
//  Created by c2con on 10. 9. 7..
//  Copyright 2010 01. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoiceCommon.h"
enum ASR_RTN {
	ASR_RTN_SUCCESS,
	ASR_RTN_CONTINUE,
	ASR_RTN_FAIL,
	ASR_RTN_CONNFAIL,
	ASR_RTN_MAX
};

extern NSString* RESULT_XML_RETURN[ASR_RTN_MAX];
extern NSString* RESULT_XML_KEY_PRE[KEY_MAX];
extern int CUR_RESULT_KEY_COUNT[KEY_MAX];

@interface CSemParser : NSObject<NSXMLParserDelegate> {
	NSMutableString*		xmlValue;
	NSMutableArray*			xmlResultData;
	NSMutableArray*			xmlNBestData;
	NSMutableDictionary*	aResult;
	
	int						mAsrRtn;
	int						mCurIndex;
	int						mNBestXX_Count;
}

@property (nonatomic, retain) NSMutableArray* xmlResultData;
@property (nonatomic, retain) NSMutableArray* xmlNBestData;

- (int) ParseHvoiceRes:(const void*) rxData DataSize:(int)datasize;
- (int) ParseHvoiceRes2:(const char*) rxData DataSize:(int)datasize;

@end
