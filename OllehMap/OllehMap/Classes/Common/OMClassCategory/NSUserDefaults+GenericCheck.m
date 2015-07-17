//
//  NSUserDefaults+GenericCheck.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 11. 16..
//
//

#import "NSUserDefaults+GenericCheck.h"

@implementation NSUserDefaults (GenericCheck)
- (id) objectForKeyGC:(NSString *)defaultName
{
    id object = [self objectForKey:defaultName];
    if ( object && [object isKindOfClass:[NSNull class]] )
    {
        object = nil;
    }
    return object;
}
- (void) setObjectGC:(id)value forKey:(NSString *)defaultName
{
    if ( value )
        [self setObject:value forKey:defaultName];
    else
        [self setObject:[NSNull null] forKey:defaultName];
}
@end
