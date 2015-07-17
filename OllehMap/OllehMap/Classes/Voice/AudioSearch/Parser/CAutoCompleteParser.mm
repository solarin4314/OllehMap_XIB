//
//  CAutoCompleteParser.mm
//  Sem
//
//  Created by c2con on 10. 9. 16..
//  Copyright 2010 01. All rights reserved.
//

#import "CAutoCompleteParser.h"


@implementation CAutoCompleteParser


@synthesize xmlAutoItems;


////////////////////////////////////////////////////////////////////////////////////////


NSString* AUTOCOMPLETE_XML_KEY_PRE[AUTO_KEY_MAX] = {
	@"AUTO_ITEM",
	@"SEARCH_WORD",
};

////////////////////////////////////////////////////////////////////////////////////////


- (BOOL) ParseAutoCompleteRes:(NSData*) theData
{
	//NSLog(@"ParseAutoCompleteRes start =====>%d",[theData length]);
	@try {
		
		mbRtn = FALSE;
		if (xmlValue != nil) {
			[xmlValue release];
		}
		if(xmlAutoItems != nil)
		{
			[xmlAutoItems release];
		}
		if(xmlAutoItem != nil)
		{
			[xmlAutoItem release];
		}
		
		xmlValue = [[NSMutableString alloc] init];
		xmlAutoItems = [[NSMutableArray alloc] init];
		xmlAutoItem = [[NSMutableDictionary alloc] init];
		
		NSString* tmpData = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
		//NSLog(@"[%d]", [tmpData length]);
		
		NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithData:theData];
		[tmpData release];
		[xmlParser setDelegate:self];
		if(FALSE == [xmlParser parse])
            //NSLog(@"Error : %@",[xmlParser parserError]);
		[xmlParser release];
		
	}
	@catch (NSException * e) {
		//NSLog(@"ParseAutoCompleteRes NSException");
	}
	@finally {
		//NSLog(@"===== =====>ParseAutoCompleteRes");
	}
	
	return mbRtn;
	
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
	//NSLog(@"======> %@ , %@ , %@ , %@", elementName, namespaceURI , qName, attributeDict);
	[xmlValue setString:@""];
	NSString*  strAutoItemKeys = [NSString  stringWithFormat:@"%@",	AUTOCOMPLETE_XML_KEY_PRE[AUTO_KEY_AUTOITEM]];
	if ([elementName isEqualToString:strAutoItemKeys]) // AUTO_ITEM 시작
	{
		//NSLog(@"%@ ======>", strAutoItemKeys);
	}
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {		
	//NSLog(@"======> %@ , %@ , %@", elementName, namespaceURI , qName);
	if ([elementName isEqualToString:@"itemNum"]) 
	{
		if( [xmlValue intValue] > 0 ) 
			mbRtn = TRUE;
		else
			mbRtn = FALSE;
	} 
	else if([elementName isEqualToString:AUTOCOMPLETE_XML_KEY_PRE[AUTO_KEY_AUTOITEM]]) // AUTO_ITEM 끝
	{
		if( xmlAutoItem.count > 0)
			[xmlAutoItems addObject: [NSDictionary dictionaryWithDictionary:xmlAutoItem]];
		[xmlAutoItem removeAllObjects];

	}
	else 
	{
		if( [elementName isEqualToString:AUTOCOMPLETE_XML_KEY_PRE[AUTO_KEY_SEARCHWORD]] )
		{
			NSString* val = [xmlValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			[xmlAutoItem setValue:[NSString stringWithString:val] forKey:AUTOCOMPLETE_XML_KEY_PRE[AUTO_KEY_SEARCHWORD]];

			//NSLog(@"[%@]", val);
		}
	}
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[xmlValue appendString:string];
}

- (void)dealloc {
	if (xmlValue != nil) {
		[xmlValue release];
	}
	if(xmlAutoItems != nil)
	{
		[xmlAutoItems release];
	}
	if(xmlAutoItem != nil)
	{
		[xmlAutoItem release];
	}
	
    [super dealloc];
}

@end
