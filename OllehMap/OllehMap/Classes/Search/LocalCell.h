//
//  LocalCell.h
//  OllehMap
//
//  Created by 이 제민 on 12. 8. 6..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KGeometry.h"
#import "SearchRouteDialogViewController.h"
#import "ServerConnector.h"
#import "GeneralPOIDetailViewController.h"
#import "SubwayPOIDetailViewController.h"
#import "OilPOIDetailViewController.h"
#import "MoviePOIDetailViewController.h"

@interface LocalCell : UITableViewCell
{  
    
}

@property (retain, nonatomic) IBOutlet UIView *cellBgView;

@property (retain, nonatomic) IBOutlet UILabel *localName;
@property (retain, nonatomic) IBOutlet UILabel *localAddress;
@property (retain, nonatomic) IBOutlet UIImageView *localFreeCall;
@property (retain, nonatomic) IBOutlet UIImageView *localLeftBar;
@property (retain, nonatomic) IBOutlet UILabel *localDistance;
@property (retain, nonatomic) IBOutlet UIImageView *localRightBar;
@property (retain, nonatomic) IBOutlet UILabel *localUj;
@property (retain, nonatomic) IBOutlet UIButton *localSinglePOI;

@property (retain, nonatomic) IBOutlet UIImageView *localStrImg;
@property (retain, nonatomic) IBOutlet UIImageView *localImg;

@property (retain, nonatomic) IBOutlet UIView *localBtnView;

@property (retain, nonatomic) IBOutlet UIButton *localStart;
@property (retain, nonatomic) IBOutlet UIButton *localDest;
@property (retain, nonatomic) IBOutlet UIButton *localVisit;
@property (retain, nonatomic) IBOutlet UIButton *localShare;
@property (retain, nonatomic) IBOutlet UIButton *localDetail;

- (IBAction)localStartClick:(id)sender;
- (IBAction)localDestClick:(id)sender;
- (IBAction)localVisitClick:(id)sender;
- (IBAction)localShareClick:(id)sender;
- (IBAction)localDetailClick:(id)sender;



@end
