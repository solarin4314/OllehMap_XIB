//
//  NSDictionary+GenericCheck.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 11. 16..
//
//

#import "NSDictionary+GenericCheck.h"

@implementation NSDictionary (GenericCheck)
- (id) objectForKeyGC:(id)aKey
{
    id object = [self objectForKey:aKey];
    if ( object && [object isKindOfClass:[NSNull class]] )
    {
        object = nil;
    }
    return object;
}
@end
