//
//  CAutoCompleteParser.h
//  Sem
//
//  Created by c2con on 10. 9. 16..
//  Copyright 2010 01. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoiceCommon.h"
extern NSString* AUTOCOMPLETE_XML_KEY_PRE[AUTO_KEY_MAX];

@interface CAutoCompleteParser : NSObject<NSXMLParserDelegate>  {
	NSMutableString*		xmlValue;
	NSMutableArray*			xmlAutoItems;
	NSMutableDictionary*	xmlAutoItem;
	
	BOOL					mbRtn;
}

@property (nonatomic, retain) NSMutableArray* xmlAutoItems;

- (BOOL) ParseAutoCompleteRes:(NSData*)theData;

@end
