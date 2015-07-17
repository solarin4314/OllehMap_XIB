//
//  NSUserDefaults+GenericCheck.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 11. 16..
//
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (GenericCheck)
- (id) objectForKeyGC:(NSString *)defaultName;
- (void) setObjectGC:(id)value forKey:(NSString *)defaultName;
@end
