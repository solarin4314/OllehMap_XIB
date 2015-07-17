//
//  AddressCell.h
//  OllehMap
//
//  Created by 이 제민 on 12. 8. 7..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KGeometry.h"
#import "SearchRouteDialogViewController.h"
#import "ServerConnector.h"
#import "AddressPOIViewController.h"

@interface AddressCell : UITableViewCell
{
    
}
@property (retain, nonatomic) IBOutlet UIView *addBgView;
@property (retain, nonatomic) IBOutlet UIImageView *addressImg;
@property (retain, nonatomic) IBOutlet UIImageView *addressStrImg;
@property (retain, nonatomic) IBOutlet UILabel *addressName;
@property (retain, nonatomic) IBOutlet UILabel *addressDistance;
@property (retain, nonatomic) IBOutlet UILabel *subAddress;
@property (retain, nonatomic) IBOutlet UIImageView *subAddressImg;
@property (retain, nonatomic) IBOutlet UIButton *addressSinglePOI;
@property (retain, nonatomic) IBOutlet UIImageView *segmentBar;
@property (retain, nonatomic) IBOutlet UIView *addressBtnView;

@property (retain, nonatomic) IBOutlet UIButton *addressStart;
@property (retain, nonatomic) IBOutlet UIButton *addressDest;
@property (retain, nonatomic) IBOutlet UIButton *addressVisit;
@property (retain, nonatomic) IBOutlet UIButton *addressShare;
@property (retain, nonatomic) IBOutlet UIButton *addressDetail;

- (IBAction)addressStartClick:(id)sender;
- (IBAction)addressDestClick:(id)sender;
- (IBAction)addressVisitClick:(id)sender;
- (IBAction)addressShareClick:(id)sender;
- (IBAction)addressDetailClick:(id)sender;



@end
