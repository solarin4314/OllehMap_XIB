//
//  SubwayStationCell.h
//  OllehMap
//
//  Created by 이 제민 on 12. 8. 7..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KGeometry.h"
#import "SearchRouteDialogViewController.h"
#import "ServerConnector.h"
#import "SubwayPOIDetailViewController.h"


@interface SubwayStationCell : UITableViewCell
{
    
}

@property (retain, nonatomic) IBOutlet UILabel *subwayStationName;
@property (retain, nonatomic) IBOutlet UILabel *subwayStationLine;

@property (retain, nonatomic) IBOutlet UIImageView *subwayStationImg;
@property (retain, nonatomic) IBOutlet UIImageView *subwayStationStr;

@property (retain, nonatomic) IBOutlet UILabel *subwayStationDistance;
@property (retain, nonatomic) IBOutlet UIImageView *subwayStationRightBar;
@property (retain, nonatomic) IBOutlet UILabel *subwayStationDo;
@property (retain, nonatomic) IBOutlet UILabel *subwayStationGu;
@property (retain, nonatomic) IBOutlet UILabel *subwayStationDong;

@property (retain, nonatomic) IBOutlet UIButton *subwayStationSinglePOI;

@property (retain, nonatomic) IBOutlet UIView *subwayBgView;

@property (retain, nonatomic) IBOutlet UIView *subwayStationBtnView;
@property (retain, nonatomic) IBOutlet UIButton *subwayStart;
@property (retain, nonatomic) IBOutlet UIButton *subwayDest;
@property (retain, nonatomic) IBOutlet UIButton *subwayVisit;
@property (retain, nonatomic) IBOutlet UIButton *subwayShare;
@property (retain, nonatomic) IBOutlet UIButton *subwayDetail;

- (IBAction)subwayStartClick:(id)sender;
- (IBAction)subwayDestClick:(id)sender;
- (IBAction)subwayVisitClick:(id)sender;
- (IBAction)subwayShareClick:(id)sender;
- (IBAction)subwayDetailClick:(id)sender;



@end
