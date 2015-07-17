//
//  BusStationCell.h
//  OllehMap
//
//  Created by 이 제민 on 12. 8. 7..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KGeometry.h"
#import "SearchRouteDialogViewController.h"
#import "ServerConnector.h"
#import "BusStationDetailViewController.h"

@interface BusStationCell : UITableViewCell
{
    
}

@property (retain, nonatomic) IBOutlet UIView *busStationBgView;
@property (retain, nonatomic) IBOutlet UIImageView *busStationImg;
@property (retain, nonatomic) IBOutlet UIImageView *busStationStrImg;


@property (retain, nonatomic) IBOutlet UILabel *busStationName;
@property (retain, nonatomic) IBOutlet UILabel *busStationUniqueId;

@property (retain, nonatomic) IBOutlet UILabel *busStationDistance;

@property (retain, nonatomic) IBOutlet UIImageView *busStationRightBar;

@property (retain, nonatomic) IBOutlet UILabel *busStationDo;
@property (retain, nonatomic) IBOutlet UILabel *busStationGu;
@property (retain, nonatomic) IBOutlet UILabel *busStationDong;

@property (retain, nonatomic) IBOutlet UIButton *busStationSinglePOI;

@property (retain, nonatomic) IBOutlet UIView *busStationBtnView;

@property (retain, nonatomic) IBOutlet UIButton *busStationStart;
@property (retain, nonatomic) IBOutlet UIButton *busStationDest;
@property (retain, nonatomic) IBOutlet UIButton *busStationVisit;
@property (retain, nonatomic) IBOutlet UIButton *busStationShare;
@property (retain, nonatomic) IBOutlet UIButton *busStationDetail;

- (IBAction)busStationStartClick:(id)sender;
- (IBAction)busStationDestClick:(id)sender;
- (IBAction)busStationVisitClick:(id)sender;
- (IBAction)busStationShareClick:(id)sender;
- (IBAction)busStationDetailClick:(id)sender;


@end
