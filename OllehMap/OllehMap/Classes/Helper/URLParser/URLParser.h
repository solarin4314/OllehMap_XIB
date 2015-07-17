//
//  URLParser.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 10. 10..
//
//

#import <Foundation/Foundation.h>

@interface URLParser : NSObject {
    NSArray *variables;
}

@property (nonatomic, retain) NSArray *variables;

- (id)initWithURLString:(NSString *)url;
- (NSString *)valueForVariable:(NSString *)varNameOrigin;

@end