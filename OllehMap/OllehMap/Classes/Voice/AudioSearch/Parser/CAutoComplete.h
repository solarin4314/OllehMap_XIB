//
//  CAutoComplete.h
//  Sem
//
//  Created by c2con on 10. 9. 16..
//  Copyright 2010 01. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAutoCompleteParser.h"



@interface CAutoComplete : NSObject {

	CAutoCompleteParser*	mpXmlParser;
	
}
@property (nonatomic, retain) CAutoCompleteParser* mpXmlParser;

+(CAutoComplete*)	GetInstance;
-(void)				InitInstance;
-(void)				ExitInstance;
-(void)				ReqAutoCompleteUquery:(NSString*)uquery; 
@end
