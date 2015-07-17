//
//  CSemParser.m
//  Sem
//
//  Created by c2con on 10. 9. 7..
//  Copyright 2010 01. All rights reserved.
//

#import "CSemParser.h"


@implementation CSemParser

@synthesize xmlResultData, xmlNBestData;


////////////////////////////////////////////////////////////////////////////////////////
NSString* RESULT_XML_RETURN[ASR_RTN_MAX] = {
	@"SUCCESS",
	@"CONTINUE",
	@"FAIL",
	@"CONNFAIL"
};

NSString* RESULT_XML_KEY_PRE[KEY_MAX] = {
	@"NBEST",
	@"COUNT",
	@"INDEX",
	@"WORD",
	@"ALTER",
	@"CLASS",
	@"CONFIDENCE"
};

int CUR_RESULT_KEY_COUNT[KEY_MAX] = {
	0, 0, 0, 0, 0, 0, 0
};


////////////////////////////////////////////////////////////////////////////////////////

-(int) ParseHvoiceRes:(const void *)rxData DataSize:(int)datasize
{
	//NSLog(@"ParseHvoiceRes ===== =====>");
	@try {
		mAsrRtn = ASR_RTN_FAIL;
		mCurIndex = 0 ;
		for (int i = 0 ; i < KEY_MAX ; i++) {
			CUR_RESULT_KEY_COUNT[i] = 0;
		}
		
		if (xmlValue != nil) {
			[xmlValue release];
		}
		if(xmlResultData != nil)
		{
			[xmlResultData release];
		}
		if(xmlNBestData != nil)
		{
			[xmlNBestData release];
		}
		if(aResult != nil)
		{
			[aResult release];
		}
		
		xmlValue = [[NSMutableString alloc] init];
		xmlResultData = [[NSMutableArray alloc] init];
		xmlNBestData = [[NSMutableArray alloc] init];
		aResult = [[NSMutableDictionary alloc] init];
		
		NSData* theData = [NSData dataWithBytes:rxData length:datasize];
		
		NSString* tmpData = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
		//NSLog(@"[%@]", tmpData);

		NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithData:theData];
		[tmpData release];
		[xmlParser setDelegate:self];
		[xmlParser parse];
		[xmlParser release];
		
	}
	@catch (NSException * e) {
		//NSLog(@"ParseHvoiceRes NSException");
	}
	@finally {
		//NSLog(@"===== =====>ParseHvoiceRes");
	}
	
	return mAsrRtn;
}

-(int) ParseHvoiceRes2:(const char *)rxData DataSize:(int)datasize
{
	//NSLog(@"ParseHvoiceRes2 ===== =====>");
	@try {
		mAsrRtn = ASR_RTN_SUCCESS;
		mCurIndex = 0 ;
		for (int i = 0 ; i < KEY_MAX ; i++) {
			CUR_RESULT_KEY_COUNT[i] = 0;
		}
		
		if (xmlValue != nil) {
			[xmlValue release];
		}
		if(xmlResultData != nil)
		{
			[xmlResultData release];
		}
		if(xmlNBestData != nil)
		{
			[xmlNBestData release];
		}
		if(aResult != nil)
		{
			[aResult release];
		}
		
		xmlValue = [[NSMutableString alloc] init];
		xmlResultData = [[NSMutableArray alloc] init];
		xmlNBestData = [[NSMutableArray alloc] init];
		aResult = [[NSMutableDictionary alloc] init];
		
		
		NSString* tmpData = [NSString stringWithCString:rxData encoding:EUC_KR];
		//NSLog(@"[%@]", tmpData);
		NSData* theData = [tmpData dataUsingEncoding:NSUTF8StringEncoding];
		
		NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithData:theData];
		//[tmpData release];
		[xmlParser setDelegate:self];
		[xmlParser parse];
		[xmlParser release];
		
	}
	@catch (NSException * e) {
		//NSLog(@"ParseHvoiceRes NSException");
	}
	@finally {
		//NSLog(@"===== =====>ParseHvoiceRes2");
	}
	
	return mAsrRtn;
}


#pragma mark XMLParse delegate methods

- (void)parser:(NSXMLParser *)parser parseErrorOccured:(NSError *)parseError {
	//NSLog(@"parse ErrorOccured");
	NSString* errorString = [NSString stringWithFormat:@"Unable to download feed from web site (Error code %i)",
							 [parseError code]];
	//NSLog(@"Error parsing XML: %@", errorString);
	
	UIAlertView* errorAlert = [[UIAlertView alloc] 
							   initWithTitle:@"Error loading content" 
							   message:errorString 
							   delegate:self 
							   cancelButtonTitle:@"OK" 
							   otherButtonTitles:nil];
	[errorAlert show];
	[errorAlert release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	[xmlValue setString:@""];
	
	NSString*  strNBestKeys = [NSString  stringWithFormat:@"%@_%02i",	RESULT_XML_KEY_PRE[KEY_NBEST],	CUR_RESULT_KEY_COUNT[KEY_NBEST]		+ 1];
	if ([elementName isEqualToString:strNBestKeys]) // NBEST_0X 시작
	{
		//NSLog(@"%@ ======>", strNBestKeys);
		for (int i = KEY_COUNT; i < KEY_MAX ; i++)
		{
			CUR_RESULT_KEY_COUNT[i] = 0;
		}
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {	
	NSString*  strNBestKeys = [NSString  stringWithFormat:@"%@_%02i",	RESULT_XML_KEY_PRE[KEY_NBEST],	CUR_RESULT_KEY_COUNT[KEY_NBEST]		+ 1];
	
	if ([elementName isEqualToString:@"RETURN"]) 
	{
		//NSLog(@"======> RETURN");
		
		mAsrRtn = 0;
		for(int i = 0 ; i < ASR_RTN_MAX ; i++)
		{
			
			if( [xmlValue isEqualToString:RESULT_XML_RETURN[i]] )
			{
				mAsrRtn = i;
				break;
			}
		}
	} 
	else if([elementName isEqualToString:strNBestKeys]) // NBEST_0X 끝
	{
		//NSLog(@"======> %@", strNBestKeys);
		if( xmlNBestData.count > 0)
			[xmlResultData addObject: [NSMutableArray arrayWithArray: xmlNBestData]];
		[xmlNBestData removeAllObjects];
		CUR_RESULT_KEY_COUNT[0]++;
	}
	else if([elementName isEqualToString:@"COUNT"])
	{
		CUR_RESULT_KEY_COUNT[KEY_COUNT] = [xmlValue integerValue];
		[aResult setValue:[NSString stringWithString:xmlValue] forKey:@"COUNT"];
		
	}
	else 
	{
		NSString* strCurKeys[KEY_MAX] = {
			nil, nil, nil, nil, nil, nil, nil
		};
		
		//NSLog(@"elementName = %@", elementName);
		for (int i = KEY_INDEX ; i < KEY_MAX ; i++) 
			// i = KEY_INDEX 부터는 KEY_NBEST가 0번째이기 때문
		{
			strCurKeys[i] = [NSString  stringWithFormat:@"%@_%02i",	RESULT_XML_KEY_PRE[i],	CUR_RESULT_KEY_COUNT[i]		+ 1];
			
			if ([elementName isEqualToString:strCurKeys[i]]) 
			{
				CUR_RESULT_KEY_COUNT[i]++;
				NSString* val = [xmlValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				[aResult setValue:[NSString stringWithString:val] forKey:strCurKeys[i]];
				//NSLog(@"strCurKeys = %@[%@]", strCurKeys[i], val);
				
				for (int j = KEY_INDEX, c = 0; j < KEY_MAX ; j++) 
				{
					if( CUR_RESULT_KEY_COUNT[j] != CUR_RESULT_KEY_COUNT[KEY_COUNT] ){
						break;
					}
					
					if (++c == NEED_TO_PARSE_KEYS) {
						[xmlNBestData addObject:[NSDictionary dictionaryWithDictionary:aResult]];
						//NSLog(@"Add aResult [count = %i]", xmlNBestData.count);
						
						[aResult removeAllObjects];
					}
				}
				
				//[val retain];

			} 
			//[strCurKeys[i] retain];			
		}
		
	}
	//[strNBestKeys retain];

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[xmlValue appendString:string];
}

- (void)dealloc {
	if (xmlValue != nil) {
		[xmlValue release];
	}
	if(xmlResultData != nil)
	{
		[xmlResultData release];
	}
	if(xmlNBestData != nil)
	{
		[xmlNBestData release];
	}
	if(aResult != nil)
	{
		[aResult release];
	}
	
    [super dealloc];
}

@end
