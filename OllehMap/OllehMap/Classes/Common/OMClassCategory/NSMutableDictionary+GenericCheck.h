//
//  NSMutableDictionary+GenericCheck.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 11. 16..
//
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (GenericCheck)
- (id) objectForKeyGC:(id)aKey;
- (void) setObjectGC:(id)anObject forKey:(id<NSCopying>)aKey;
@end
