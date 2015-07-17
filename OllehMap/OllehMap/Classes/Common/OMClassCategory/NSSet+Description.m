//
//  NSSet+Description.m
//  NSLogTest
//
//  Created by JiHyung on 13. 1. 15..
//  Copyright (c) 2013년 JiHyung. All rights reserved.
//

#import "NSSet+Description.h"
#import "NSObject+Description.h"

@implementation NSSet (Description)

-(NSString *) descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    NSMutableString *log = [NSMutableString string];

    if ([self count] == 0)
    {
        [log appendString:@"There has no object."];
    }
    else
    {
        [log appendString:@"{(\n"];
        
        // indent string
        NSMutableString *indentString = [NSMutableString string];
        for (int i = 0; i < level; i++)
        {
            [indentString appendString:@"\t"];
        }
        
        // value format
        for (int i = 0; i < [self count]; i++)
        {
            [log appendFormat:@"\t%@%@", indentString,
             [self descriptionForObject:self.allObjects[i] locale:locale indent:level + 1]];
            
            // check next value
            if (i + 1 < [self count])
            {
                [log appendString:@",\n"];
            }
            else
            {
                [log appendString:@"\n"];
            }
        }
        
        [log appendFormat:@"%@)}", indentString];
        
    }
    
    return log;
}

@end
