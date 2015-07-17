//
//  NSObject+Description.m
//  NSLogTest
//
//  Created by JiHyung on 13. 1. 15..
//  Copyright (c) 2013년 JiHyung. All rights reserved.
//


#import "NSObject+Description.h"

@implementation NSObject (Description)

-(NSString *) descriptionForObject:(NSObject *)obj
                            locale:(id)locale
                            indent:(NSUInteger)level
{
    NSString *objString = nil;
    
    // Key or NSString value
    if ([obj isKindOfClass:[NSString class]])
    {
        objString = [NSString stringWithFormat:@"\"%@\"", (NSString *)obj];
    }
    // NSDictionary, NSArray, NSOrderedSet, NSSet
    else if ([obj respondsToSelector:@selector(descriptionWithLocale:indent:)])
    {
        
        objString = [obj performSelector:@selector(descriptionWithLocale:indent:)
                              withObject:locale
                              withObject:(id)level];
    }
    // NSDate, NSValue (int, float, double ...)
    else if ([obj respondsToSelector:@selector(descriptionWithLocale:)])
    {
        objString = [obj performSelector:@selector(descriptionWithLocale:)
                              withObject:locale];
    }
    // Other Class
    else
    {
        objString = [obj description];
    }
    
    return objString;
}

@end