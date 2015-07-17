//
//  NSString+AESCrypt.h
//  CCTVMap
//
//  Created by Seth Oh on 11. 3. 18..
//  Copyright 2011 Hubilon / Telematics Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+AESCrypt.h"

@interface NSString (AESCrypt)

- (NSString *)AES128EncryptWithKey:(NSString *)key;
- (NSString *)AES128DecryptWithKey:(NSString *)key;

@end
 