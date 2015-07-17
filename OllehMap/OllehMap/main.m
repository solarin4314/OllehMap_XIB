//
//  main.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 4. 17..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool 
    {
        @try  
        {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
        @catch (NSException *ex) 
        {
#ifdef USE_EXCEPTION_CALLBACK
            NSString *exceptionMessage = [NSString stringWithFormat:@"[Exception Message]\n%@\n[Exception CallStack]\n%@", ex, [ex callStackSymbols]];
            [[NSUserDefaults standardUserDefaults] setObject:exceptionMessage forKey:@"AppLastError"];         
            [[NSUserDefaults standardUserDefaults] synchronize];

            NSLog(@"\n[OllehMap Exception Log] \n%@", exceptionMessage);
#endif
            @throw ex;
        }
        
        return 0;
    }
}
