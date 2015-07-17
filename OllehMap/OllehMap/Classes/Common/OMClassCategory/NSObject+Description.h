//
//  NSObject+Description.h
//  NSLogTest
//
//  Created by JiHyung on 13. 1. 15..
//  Copyright (c) 2013년 JiHyung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Description)

-(NSString *) descriptionForObject:(NSObject *)obj
                            locale:(id)locale
                            indent:(NSUInteger)level;

@end
