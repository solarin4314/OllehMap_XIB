//
//  CAutoComplete.mm
//  Sem
//
//  Created by c2con on 10. 9. 16..
//  Copyright 2010 01. All rights reserved.
//

#import "CAutoComplete.h"
#include "UTIL.h"

#define TIMEOUT_REQUEST_AUTOCOMPLETE	10.0
#define AUTOCOMPLETE_DOMAIN		@"59.10.136.231"

//#define EUC_KR				-2147481280

@implementation CAutoComplete

@synthesize mpXmlParser;

+(CAutoComplete*)	GetInstance
{
	static CAutoComplete* spAutoComplete = nil;
	if(spAutoComplete == nil)
    {
        @synchronized(self)
        {
            if(spAutoComplete == nil)
            {
                spAutoComplete = [[self alloc] init];
            }
        }
    }
	
	return spAutoComplete;
}

-(void)		InitInstance
{
	mpXmlParser = [[CAutoCompleteParser alloc] init];
}

-(void)		ExitInstance
{
	[mpXmlParser release];
}

-(void)		ReqAutoCompleteUquery:(NSString *)uquery
{
	
	@try {
		//NSLog(@"ReqAutoCompleteUquery ===============>");
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		//NSLog(@"%@", uquery);
		//NSLog(@"%@", [uquery stringByAddingPercentEscapesUsingEncoding:EUC_KR]);
		// Create the request.

		NSString* urlString = [NSString stringWithFormat:
							   @"http://%@/~ssearch/index.php?uquery=%@&cate=&product_id=&appID=iispeech",
							   AUTOCOMPLETE_DOMAIN,
							   [uquery stringByAddingPercentEscapesUsingEncoding:EUC_KR]];
		//NSLog(@"%@", urlString);
		NSMutableString *resultString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:EUC_KR error:nil];
		
		//NSLog(@"%@", resultString);
		NSString* tmpString = [resultString stringByReplacingOccurrencesOfString:@"euc-kr" withString:@"utf-8"];
		//NSLog(@"%@", tmpString);
		
		
		if( tmpString != nil )
		{
			NSData* resultData = [tmpString dataUsingEncoding:NSUTF8StringEncoding];
			if(resultData != nil )
				[mpXmlParser ParseAutoCompleteRes:resultData];
		}

		
		[pool drain];
	}
	@catch (NSException * e) {
		//NSLog(@"NSException");
	}
	@finally {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

		//NSLog(@"=====> ReqAutoCompleteUquery");
	}
	
}


- (void)dealloc {
	
    [super dealloc];
}

@end
