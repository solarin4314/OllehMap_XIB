//
//  CCTVViewController.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 9. 18..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCTVViewController : UIViewController <AVAudioSessionDelegate,AVAudioPlayerDelegate>
{
    NSMutableDictionary *_info;
    MPMoviePlayerViewController *_player;
}
@property (nonatomic, retain) MPMoviePlayerViewController *player;

- (void) showCCTV :(NSDictionary*)info;

@end
