//
//  NSMutableDictionary+GenericCheck.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 11. 16..
//
//

#import "NSMutableDictionary+GenericCheck.h"

@implementation NSMutableDictionary (GenericCheck)
- (id) objectForKeyGC:(id)aKey
{
    id object = [self objectForKey:aKey];
    if ( object && [object isKindOfClass:[NSNull class]] )
    {
        object = nil;
    }
    return object;
}
- (void) setObjectGC:(id)anObject forKey:(id<NSCopying>)aKey
{
    if ( anObject )
        [self setObject:anObject forKey:aKey];
    else
        [self setObject:[NSNull null] forKey:aKey];
}
@end
