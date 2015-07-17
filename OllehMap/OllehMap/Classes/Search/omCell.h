//
//  omCell.h
//  OllehMap
//
//  Created by 이 제민 on 12. 5. 11..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface omCell : UITableViewCell
{
    TTTAttributedLabel *_label;
}

- (void)setString:(NSString *)str searchString:(NSString*)search;

@end
