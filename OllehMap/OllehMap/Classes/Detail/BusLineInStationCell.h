//
//  BusLineInStationCell.h
//  OllehMap
//
//  Created by 이 제민 on 12. 6. 26..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusLineInStationCell : UITableViewCell
{
    UILabel *_stationId;
    UILabel *_stationName;
    UIImageView *busLineImg;
}
@property (retain, nonatomic) IBOutlet UILabel *stationId;
@property (retain, nonatomic) IBOutlet UILabel *stationName;
@property (retain, nonatomic) IBOutlet UIImageView *busLineImg;
@property (retain, nonatomic) IBOutlet UIView *cellBg;

@end
