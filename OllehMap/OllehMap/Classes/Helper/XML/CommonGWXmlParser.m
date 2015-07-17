
#import "CommonGWXmlParser.h"
#import "Base64.h"

@implementation CommonGWXmlParser

static NSString *currentEnementName;

static int depth;
static int prevDepth;
static BOOL isExistValue;
NSMutableString *valueString;

- (id)objectWithData:(NSData *)data
{
    _CCTVParser = NO;
    _strctn     =   0;
	depth = 0;
	prevDepth = 0;
	_jsonString = [NSMutableString stringWithCapacity:1024];
	valueString = [NSMutableString stringWithCapacity:256];
    _tempDirectionString = [NSMutableString stringWithCapacity:1024];
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	
	[parser setDelegate:self];
	[parser parse];
	
	[parser release];
	
	return _jsonString;
}

// CCTV
- (id)objectWithDataCCTV:(NSData *)data
{
    _CCTVParser = YES;
    _URLstrCheck    =   NO;
	depth = 0;
	prevDepth = 0;
	_jsonString = [NSMutableString stringWithCapacity:1024];
	valueString = [NSMutableString stringWithCapacity:256];
    _tempDirectionString = [NSMutableString stringWithCapacity:1024];
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	
	[parser setDelegate:self];
	[parser parse];
	
	[parser release];
	
	return _jsonString;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    //NSLog(@"elementName :: [%@]",elementName);
    //NSLog(@"attributeDict :: [%@]",attributeDict);
    //.. URL 부분인지를 체크 합니다.
    
	currentEnementName = elementName;
    
    if (_CCTVParser) {
        if ([elementName isEqual:@"Group"])
        {
            depth++;
            if (depth == prevDepth) [_jsonString appendString:@","];
            //            
            [_jsonString appendString:@"{"];
            //            [_jsonString appendFormat:@"\"%@\":", elementName];
        }
        else if ([elementName isEqual:@"ChannelList"])
        {            
            depth++;
            if (depth == prevDepth) [_jsonString appendString:@","];
            //            [_jsonString appendString:@"{"];            
            [_jsonString appendFormat:@"\"%@\":[", elementName];
        }
        else if ([elementName isEqual:@"Channel"])
        {
            depth++;                      
            if (depth == prevDepth) [_jsonString appendString:@","];
            [_jsonString appendString:@"{"];
        }
        else if ([elementName isEqual:@"CCTVID"])
        {
            if (depth == prevDepth) [_jsonString appendString:@","];
            [_jsonString appendFormat:@"\"%@\":\"", elementName];
            isExistValue = NO;            
        }
        else if ([elementName isEqual:@"Available"])
        {
            if (depth == prevDepth) [_jsonString appendString:@","];     
            [_jsonString appendFormat:@"\"%@\":\"", elementName];
            isExistValue = NO;               
        } 
        else if ([elementName isEqual:@"Name"])
        {
            if (depth == prevDepth) [_jsonString appendString:@","];         
            [_jsonString appendFormat:@"\"%@\":\"", elementName];
            isExistValue = NO;               
        }       
        else if ([elementName isEqual:@"Lane"])
        {
            if (depth == prevDepth) [_jsonString appendString:@","]; 
            [_jsonString appendFormat:@"\"%@\":\"", elementName];
            isExistValue = NO;               
        } 
        else if ([elementName isEqual:@"GPSX"])
        {
            if (depth == prevDepth) [_jsonString appendString:@","]; 
            [_jsonString appendFormat:@"\"%@\":\"", elementName];
            isExistValue = NO;               
        }       
        else if ([elementName isEqual:@"GPSY"])
        {
            if (depth == prevDepth) [_jsonString appendString:@","]; 
            [_jsonString appendFormat:@"\"%@\":\"", elementName];
            isExistValue = NO;               
        }       
        else if ([elementName isEqual:@"Direction"])
        {
            if (depth == prevDepth) [_jsonString appendString:@","]; 
            [_jsonString appendFormat:@"\"%@\":\"", elementName];
            isExistValue = NO;               
        }  
        else if ([elementName isEqual:@"OfferName"])
        {
            if (depth == prevDepth) [_jsonString appendString:@","]; 
            [_jsonString appendFormat:@"\"%@\":\"", elementName];
            isExistValue = NO;               
        }       
        else if ([elementName isEqual:@"Version"])
        {
            if (depth == prevDepth) [_jsonString appendString:@","]; 
            [_jsonString appendFormat:@"\"%@\":\"", elementName];
            isExistValue = NO;               
        }  
        else if ([elementName isEqual:@"Ip"])
        {
            if (depth == prevDepth) [_jsonString appendString:@","]; 
            [_jsonString appendFormat:@"\"%@\":\"", elementName];
            isExistValue = NO;               
        }  
        else if ([elementName isEqual:@"Port"])
        {
            if (depth == prevDepth) [_jsonString appendString:@","]; 
            [_jsonString appendFormat:@"\"%@\":\"", elementName];
            isExistValue = NO;               
        }          
        //        else
        //        {
        //            if (depth == prevDepth) [_jsonString appendString:@","];
        //            isExistValue = NO;
        //        }        
    }
    else
    {
        
        if ([elementName isEqual:@"MAP"])
        {
            depth++;
            if (depth == prevDepth) [_jsonString appendString:@","];
            
            [_jsonString appendString:@"{"];
        }
        else if ([elementName isEqual:@"LIST"])
        {
            depth++;
            if (depth == prevDepth) [_jsonString appendString:@","];
            
            [_jsonString appendString:@"["];
        }
        else if ([elementName isEqual:@"ENTRY"])
        {
            if (depth == prevDepth) [_jsonString appendString:@","];
            depth++;
            
            if ([attributeDict objectForKeyGC:@"ID"])
            {
                [_jsonString appendFormat:@"\"%@\":", [attributeDict objectForKeyGC:@"ID"]];
                
                if ([[attributeDict objectForKeyGC:@"ID"] isEqual:@"UJ_NAME"])
                {
                    //NSLog(@"----->");
                }else if ([[attributeDict objectForKeyGC:@"ID"] isEqual:@"URL"]){
                    //NSLog(@"attributeDict :: [%@]",attributeDict);    
                    //.. URL 정보를 체크 하기위해 YES 로 변경합니다.
                    _URLstrCheck = YES;
                    //.. URL 정보 가 반복되는것을 체크 하는 카운트 입니다.
                    _strctn      =  0;
                }
                
            }
            else if ([attributeDict objectForKeyGC:@"ERRCODE"])
            {
                [_jsonString appendFormat:@"\"ERRCODE\":\"%@\"", [attributeDict objectForKeyGC:@"ERRCODE"]];
                
                if ([attributeDict objectForKeyGC:@"ERRMSG"])
                {
                    [_jsonString appendFormat:@",\"ERRMSG\":\"%@\"", [attributeDict objectForKeyGC:@"ERRMSG"]];
                }
            }
        }
        else if ([elementName isEqual:@"B64"] || [elementName isEqual:@"NUMBER"] || [elementName isEqual:@"STR"])
        {
            if (depth == prevDepth) [_jsonString appendString:@","];
            isExistValue = NO;
            
            if ([elementName isEqual:@"B64"])
            {
                [valueString setString:@""];
            }
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //NSLog(@"string :: [%@]",string);
    if (_CCTVParser) {    
        if ([currentEnementName isEqualToString:@"CCTVID"])
        {
            [_jsonString appendFormat:@"%@", string];
            isExistValue = YES;
        }
        else if ([currentEnementName isEqualToString:@"Available"])
        {
            [_jsonString appendFormat:@"%@", string];
            isExistValue = YES;
        }
        else if ([currentEnementName isEqualToString:@"Name"])
        {
            [_jsonString appendFormat:@"%@", string];
            isExistValue = YES;
        }
        else if ([currentEnementName isEqualToString:@"Lane"])
        {
            [_jsonString appendFormat:@"%@", string];
            isExistValue = YES;
        } 
        else if ([currentEnementName isEqualToString:@"GPSX"])
        {
            [_jsonString appendFormat:@"%@", string];
            isExistValue = YES;
        }
        else if ([currentEnementName isEqualToString:@"GPSY"])
        {
            [_jsonString appendFormat:@"%@", string];
            isExistValue = YES;
        }
        else if ([currentEnementName isEqualToString:@"Direction"])
        {
            if ([string hasPrefix:@"\""] || [string hasSuffix:@"\""]) {
                string = [string stringByReplacingOccurrencesOfString:@"\""
                                                           withString:@""];
            }
            
            [_jsonString appendFormat:@"%@", string];
            isExistValue = YES;
        }        
        else if ([currentEnementName isEqualToString:@"OfferName"])
        {
            [_jsonString appendFormat:@"%@", string];
            isExistValue = YES;
        }          
        else if ([currentEnementName isEqualToString:@"Version"])
        {
            [_jsonString appendFormat:@"%@", string];
            isExistValue = YES;
        } 
        else if ([currentEnementName isEqualToString:@"Ip"])
        {
            [_jsonString appendFormat:@"%@", string];
            isExistValue = YES;
        }
        else if ([currentEnementName isEqualToString:@"Port"])
        {
            [_jsonString appendFormat:@"%@", string];
            isExistValue = YES;
        } 
    }
    else
    {    
        if ([currentEnementName isEqualToString:@"B64"])
        {
            //[_jsonString appendFormat:@"\"%@\"", [AppCommon base64StringDecoder:string]];
            [valueString appendString:string]; 
            isExistValue = YES;
        }
        else if ([currentEnementName isEqualToString:@"NUMBER"])
        {
            [_jsonString appendString:string];
            isExistValue = YES;
        }
        else if ([currentEnementName isEqualToString:@"STR"])
        {
            //.. URL 정보일 경우 다른 파싱을 합니다.
            if(_URLstrCheck == YES){
                if(_strctn == 0){                    
                    [_jsonString appendFormat:@"\"%@\"", string];
                }else{
                    int strlength = [_jsonString length];
                    [_jsonString insertString:string atIndex:strlength - 1];
                }
                _strctn++;
                isExistValue = YES;
            }else{
                [_jsonString appendFormat:@"\"%@\"", string];
                isExistValue = YES;
            }
            
        }
        // chul
        else if ([currentEnementName isEqualToString:@"NONE"])
        {
            [_jsonString appendFormat:@"\"%@\"", string];
            isExistValue = YES;
        }  
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (_CCTVParser) {
        if ([elementName isEqual:@"Group"])
        {
            [_jsonString appendString:@"}"];
            depth--;
        }
        else if ([elementName isEqual:@"ChannelList"])
        {
            [_jsonString appendString:@"]"];
            depth--;
        }
        else if ([elementName isEqual:@"Channel"])
        {
            [_jsonString appendString:@"}"];
            depth--;
            //[_jsonString appendString:@", \n"];
        }
        else if ([elementName isEqualToString:@"CCTVID"])
        {
            [_jsonString appendFormat:@"\""];
        }
        else if ([elementName isEqualToString:@"Available"])
        {
            [_jsonString appendFormat:@"\""];
        }
        else if ([elementName isEqualToString:@"Name"])
        {
            [_jsonString appendFormat:@"\""];
        }
        else if ([elementName isEqualToString:@"Lane"])
        {
            [_jsonString appendFormat:@"\""];
        } 
        else if ([elementName isEqualToString:@"GPSX"])
        {
            [_jsonString appendFormat:@"\""];
        }
        else if ([elementName isEqualToString:@"GPSY"])
        {
            [_jsonString appendFormat:@"\""];
        }
        else if ([elementName isEqualToString:@"Direction"])
        {
            [_jsonString appendFormat:@"\""];
        }        
        else if ([elementName isEqualToString:@"OfferName"])
        {
            [_jsonString appendFormat:@"\""];
        }          
        else if ([elementName isEqualToString:@"Version"])
        {
            [_jsonString appendFormat:@"\""];
        } 
        else if ([elementName isEqualToString:@"Ip"])
        {
            [_jsonString appendFormat:@"\""];
        }
        else if ([elementName isEqualToString:@"Port"])
        {
            [_jsonString appendFormat:@"\""];
        }        
        //        else if ([elementName isEqual:@"B64"])
        //        {
        //            if (!isExistValue) [_jsonString appendFormat:@"\"\""];
        //            else
        //            {
        //                [_jsonString appendFormat:@"\"%@\"", [AppCommon base64StringDecoder:valueString]];
        //                //[_jsonString appendFormat:@"\"%@\"", valueString];
        //                [valueString setString:@""];
        //            }
        //            
        //        }
        //        else if ([elementName isEqual:@"NUMBER"])
        //        {
        //            if (!isExistValue) [_jsonString appendFormat:@"0"];
        //        }
        //        else if ([elementName isEqual:@"STR"])
        //        {
        //            if (!isExistValue) [_jsonString appendFormat:@"\"\""];
        //        }
        //        // chul    
        //        else if ([elementName isEqual:@"NONE"])
        //        {
        //            if (!isExistValue) [_jsonString appendFormat:@"\"\""];
        //        }    
        
        //        if (!isExistValue) [_jsonString appendFormat:@"\"\""];
        
        prevDepth = depth;
    }
    else
    {      
        if ([elementName isEqual:@"MAP"])
        {
            [_jsonString appendString:@"}"];
            depth--;
        }
        else if ([elementName isEqual:@"LIST"])
        {
            [_jsonString appendString:@"]"];
            depth--;
        }
        else if ([elementName isEqual:@"ENTRY"])
        {
            depth--;
            //[_jsonString appendString:@", \n"];
        }
        else if ([elementName isEqual:@"B64"])
        {
            if (!isExistValue) [_jsonString appendFormat:@"\"\""];
            else
            {
                /*
                //NSLog(@"data =========>");
                //NSLog(@"%@", [AppCommon base64StringDecoder:valueString]);
                NSString *dataStr = [AppCommon base64StringDecoder:valueString];
                NSString *dataStr2 = [dataStr stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
                //NSString *dataStr2 = [self NSStringToJSONString:dataStr];
                //NSLog(@"res ==========>");
                //NSLog(@"%@", dataStr2);

                [_jsonString appendFormat:@"\"%@\"", dataStr2];            
                //[_jsonString appendFormat:@"\"%@\"", [AppCommon base64StringDecoder:valueString]];
                //[_jsonString appendFormat:@"\"%@\"", valueString];
                [valueString setString:@""];

                */
                
                NSString* json_escaped = [self NSStringToJSONString:[Base64  base64StringDecoder:valueString]];
                
                
                //[_jsonString appendFormat:@"\"%@\"", [AppCommon base64StringDecoder:valueString]];
                [_jsonString appendFormat:@"\"%@\"", json_escaped];
                [valueString setString:@""];
                 
            }
            
        }
        else if ([elementName isEqual:@"NUMBER"])
        {
            if (!isExistValue) [_jsonString appendFormat:@"0"];
        }
        else if ([elementName isEqual:@"STR"])
        {
            //.. 정보가 URL 이였을경우 NO 변경합니다.
            if(_URLstrCheck == YES)_URLstrCheck = NO;
            //.. STR 구문이 들어가는 부분입니다.
            if (!isExistValue) [_jsonString appendFormat:@"\"\""]; 
            
            
        }
        // chul    
        else if ([elementName isEqual:@"NONE"])
        {
            if (!isExistValue) [_jsonString appendFormat:@"\"\""];
        }    
        
        prevDepth = depth;
    }
}

- (NSString *)NSStringToJSONString:(NSString *)aString 
{
    NSMutableString *str = [NSMutableString stringWithString:aString];
    [str replaceOccurrencesOfString:@"\"\"" withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
    
    //[str replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"\n" withString:@"\\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"\b" withString:@"\\b" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"\f" withString:@"\\f" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"\r" withString:@"\\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"\t" withString:@"\\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
    
    return [NSString stringWithString:str];
}


@end
