//
//  URLParser.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 10. 10..
//
//

#import "URLParser.h"

@implementation URLParser
@synthesize variables;

- (id) initWithURLString:(NSString *)url
{
    self = [super init];
    if (self != nil) {
        NSString *string = url;
        NSScanner *scanner = [NSScanner scannerWithString:string];
        [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"&?"]];
        NSString *tempString;
        NSMutableArray *vars = [NSMutableArray new];
        [scanner scanUpToString:@"?" intoString:nil];       //ignore the beginning of the string and skip to the vars
        while ([scanner scanUpToString:@"&" intoString:&tempString])
        {
            NSObject *copyObj = tempString.copy;
            [vars addObject:copyObj];
            [copyObj release];
        }
        self.variables = vars;
        [vars release];
    }
    return self;
}

- (NSString *)valueForVariable:(NSString *)varNameOrigin
{
    NSString *varName = nil;
    if ( varNameOrigin && varNameOrigin.length > 0 )
        varName = varNameOrigin.uppercaseString;
    else
        return nil;
    
    for (NSString *var in self.variables)
    {
        if ( [var length] > [varName length]+1
            && [[var substringWithRange:NSMakeRange(0, [varName length]+1)].uppercaseString isEqualToString:[varName stringByAppendingString:@"="]] )
        {
            NSString *varValue = [var substringFromIndex:[varName length]+1];
            return varValue;
        }
    }
    return nil;
}

- (void) dealloc{
    self.variables = nil;
    [super dealloc];
}

@end