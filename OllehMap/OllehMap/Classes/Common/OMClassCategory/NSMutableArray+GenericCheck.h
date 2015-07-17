//
//  NSMutableArray+GenericCheck.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 11. 16..
//
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (GenericCheck)
- (id) objectAtIndexGC:(NSUInteger)index;
- (void) addObjectGC:(id)anObject;
- (void) setObjectGC:(id)obj atIndexedSubscript:(NSUInteger)idx;
@end
