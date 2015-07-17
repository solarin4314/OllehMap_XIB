//
//  NSDictionary+Description.m
//  NSLogTest
//
//  Created by JiHyung on 13. 1. 15..
//  Copyright (c) 2013년 JiHyung. All rights reserved.
//

#import "NSDictionary+Description.h"
#import "NSObject+Description.h"

@implementation NSDictionary (Description)

-(NSString *) descriptionWithLocale:(id)locale
                             indent:(NSUInteger)level
{
    NSMutableString *log = [NSMutableString string];
    
    if ([self.allKeys count] == 0)
    {
        [log appendString:@"0 key/value pairs"];
    }
    else
    {
        [log appendString:@"{\n"];
        
        // indent string
        NSMutableString *indentString = [NSMutableString string];
        for (int i = 0; i < level; i++)
        {
            [indentString appendString:@"\t"];
        }
        
        // key = value format
        id key = nil;
        for (int i = 0; i < [self count]; i++)
        {
            key = self.allKeys[i];
            
            [log appendFormat:@"\t%@%@ = %@", indentString,
             [self descriptionForObject:key locale:locale indent:level + 1],
             [self descriptionForObject:self[key] locale:locale indent:level + 1]];
            
            // check next key
            if (i + 1 < [self count])
            {
                [log appendString:@",\n"];
            }
            else
            {
                [log appendString:@"\n"];
            }
        }
        
        [log appendFormat:@"%@}", indentString];
    }
    
    return log;
}

@end
